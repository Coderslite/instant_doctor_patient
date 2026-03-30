import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nb_utils/nb_utils.dart';

// ─── Palette — matches splash & home ──────────────────────────────────────────
const _bgTop = Color(0xFFEFF6FF);
const _bgMid = Color(0xFFF0FDF9);
const _white = Colors.white;
const _ink = Color(0xFF0F2744);
const _slate = Color(0xFF5E7A99);
const _green = Color(0xFF10B981);
const _greenSoft = Color(0xFFD1FAE5);
const _redLight = Color(0xFFFFEDED);
const _redText = Color(0xFFDC2626);

// ─────────────────────────────────────────────────────────────────────────────
class AuthScreen extends StatefulWidget {
  final bool fromApp;
  final VoidCallback? onAuthSuccess;
  const AuthScreen({super.key, required this.fromApp, this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ── PIN state ──────────────────────────────────────────────────────────────
  String _pin = '';
  bool _canBiometric = false;
  bool _isAuthing = false;
  int _failedAttempts = 0;
  DateTime? _lockoutEnd;
  String _countdown = '';
  bool _isLockedOut = false;
  Timer? _countdownTimer;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _entryCtrl; // card slides up
  late final AnimationController _shakeCtrl; // wrong-pin shake
  late final AnimationController _floatCtrl; // bg cross drift
  late final AnimationController _pulseCtrl; // biometric glow
  late final AnimationController _dotCtrl; // dot fill ripple

  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _headerFade;
  late final Animation<double> _shakeAnim;
  late final Animation<double> _floatY;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ── Card slide-up entry ────────────────────────────────────────────────
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOut)));

    // ── Wrong-PIN shake ────────────────────────────────────────────────────
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut));

    // ── Floating cross drift ───────────────────────────────────────────────
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3800))
      ..repeat(reverse: true);
    _floatY = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // ── Biometric pulse ────────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.22)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseOpacity = Tween<double>(begin: 0.22, end: 0.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // ── Dot ripple controller ──────────────────────────────────────────────
    _dotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _entryCtrl.forward();
    _initialize();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _entryCtrl.dispose();
    _shakeCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  // ─── Init ──────────────────────────────────────────────────────────────────
  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _checkBiometric();
    await _loadLockout();
    _updateCountdown();
    _startCountdown();
  }

  Future<void> _checkBiometric() async {
    final ok = await _localAuth.canCheckBiometrics;
    if (mounted) setState(() => _canBiometric = ok);
  }

  Future<void> _loadLockout() async {
    final prefs = await SharedPreferences.getInstance();
    final fails = prefs.getInt('failed_attempts') ?? 0;
    final ts = prefs.getInt('lockout_timestamp');
    if (mounted) {
      setState(() {
        _failedAttempts = fails;
        if (ts != null) {
          _lockoutEnd = DateTime.fromMillisecondsSinceEpoch(ts);
          _isLockedOut = _lockoutEnd!.isAfter(DateTime.now());
        }
      });
    }
  }

  Future<void> _saveLockout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('failed_attempts', _failedAttempts);
    if (_lockoutEnd != null) {
      await prefs.setInt(
          'lockout_timestamp', _lockoutEnd!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('lockout_timestamp');
    }
  }

  void _updateCountdown() {
    if (!_isLockedOut || _lockoutEnd == null) return;
    final now = DateTime.now();
    if (_lockoutEnd!.isBefore(now)) {
      setState(() {
        _isLockedOut = false;
        _lockoutEnd = null;
        _failedAttempts = 0;
        _countdown = '';
      });
      _saveLockout();
    } else {
      final rem = _lockoutEnd!.difference(now);
      setState(() {
        _countdown =
            '${rem.inMinutes}:${(rem.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_isLockedOut) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        _updateCountdown();
        if (!_isLockedOut) t.cancel();
      });
    }
  }

  // ─── Auth logic ────────────────────────────────────────────────────────────
  Future<void> _biometricAuth() async {
    if (_isLockedOut || _isAuthing) return;
    setState(() => _isAuthing = true);
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      setState(() => _isAuthing = false);
      if (ok && mounted) {
        setState(() => _failedAttempts = 0);
        await _saveLockout();
        _onSuccess();
      } else if (!ok) {
        _onFail();
      }
    } catch (_) {
      setState(() => _isAuthing = false);
      _onFail();
    }
  }

  void _addDigit(String d) {
    if (_isLockedOut || _pin.length >= 5) return;
    HapticFeedback.lightImpact();
    _dotCtrl.forward(from: 0);
    setState(() => _pin += d);
    if (_pin.length == 5) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (_pin == userController.pin.value) {
          setState(() => _failedAttempts = 0);
          _saveLockout();
          _onSuccess();
        } else {
          setState(() => _pin = '');
          _onFail();
        }
      });
    }
  }

  void _removeDigit() {
    if (_isLockedOut || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onSuccess() {
    widget.onAuthSuccess?.call();
    if (!widget.fromApp) Root().launch(context, isNewTask: true);
  }

  void _onFail() async {
    HapticFeedback.heavyImpact();
    await Haptics.vibrate(HapticsType.error);
    _shakeCtrl.forward(from: 0);
    setState(() => _failedAttempts++);
    _saveLockout();
    if (_failedAttempts >= 3) {
      setState(() {
        _isLockedOut = true;
        _lockoutEnd = DateTime.now().add(const Duration(minutes: 10));
        _pin = '';
      });
      _saveLockout();
      _updateCountdown();
      _startCountdown();
      errorSnackBar(
          context: context,
          title: 'Too many attempts. Please wait 10 minutes.');
    } else {
      errorSnackBar(
          context: context,
          title: 'Wrong PIN — $_failedAttempts/3 attempts used.');
    }
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: KeyboardDismisser(
        child: Scaffold(
          backgroundColor: _bgTop,
          body: Stack(children: [
            // ── Soft gradient background ────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bgTop, _bgMid, _white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // ── Floating medical cross particles ────────────────────────
            AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, __) {
                final v = _floatY.value;
                return Stack(children: [
                  _FloatCross(
                      x: sw * 0.06,
                      y: sh * 0.06 - v * 14,
                      size: 20,
                      opacity: 0.08 + v * 0.05,
                      color: kPrimary),
                  _FloatCross(
                      x: sw * 0.80,
                      y: sh * 0.10 + v * 10,
                      size: 15,
                      opacity: 0.06 + v * 0.04,
                      color: _green),
                  _FloatCross(
                      x: sw * 0.88,
                      y: sh * 0.30 - v * 16,
                      size: 12,
                      opacity: 0.05 + v * 0.03,
                      color: kPrimary),
                  _FloatCross(
                      x: sw * 0.04,
                      y: sh * 0.35 + v * 10,
                      size: 10,
                      opacity: 0.06,
                      color: _green),
                ]);
              },
            ),

            // ── Main column ─────────────────────────────────────────────
            SafeArea(
              child: Column(children: [
                // ── Top section — logo + greeting ──────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                    child: Column(children: [
                      // Logo circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _white,
                          boxShadow: [
                            BoxShadow(
                                color: kPrimary.withOpacity(0.14),
                                blurRadius: 24,
                                spreadRadius: 2),
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: Image.asset("assets/images/logo1.png",
                              width: 46, height: 46, fit: BoxFit.contain),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Greeting
                      Text(
                        _isLockedOut ? 'Account Locked' : 'Welcome Back',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLockedOut
                            ? 'Try again in $_countdown'
                            : 'Enter your PIN to continue',
                        style: const TextStyle(
                          fontSize: 14,
                          color: _slate,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ]),
                  ),
                ),

                const Spacer(),

                // ── White card — PIN + dialpad ─────────────────────────
                SlideTransition(
                  position: _cardSlide,
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      decoration: const BoxDecoration(
                        color: _white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(36)),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 40,
                              offset: Offset(0, -8)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── PIN dots ──────────────────────────────────
                          AnimatedBuilder(
                            animation: _shakeCtrl,
                            builder: (_, child) {
                              final shake =
                                  math.sin(_shakeAnim.value * math.pi * 6) * 10;
                              return Transform.translate(
                                offset: Offset(shake, 0),
                                child: child,
                              );
                            },
                            child: _PinDots(
                              filledCount: _pin.length,
                              isLockedOut: _isLockedOut,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Dial pad ──────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: _DialPad(
                              isLockedOut: _isLockedOut,
                              isAuthing: _isAuthing,
                              canBio: _canBiometric,
                              onDigit: _addDigit,
                              onDelete: _removeDigit,
                              onBio: _biometricAuth,
                              pulseScale: _pulseScale,
                              pulseOpacity: _pulseOpacity,
                            ),
                          ),

                          // Authenticating indicator
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isAuthing
                                ? Padding(
                                    key: const ValueKey('auth'),
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: kPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text('Verifying...',
                                            style: TextStyle(
                                                fontSize: 13, color: _slate)),
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    key: ValueKey('idle'), height: 16),
                          ),

                          // Lockout banner
                          if (_isLockedOut)
                            Container(
                              margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _redLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(children: [
                                const Icon(Icons.lock_outline_rounded,
                                    size: 18, color: _redText),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                  'Too many attempts. Retry in $_countdown',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: _redText,
                                      fontWeight: FontWeight.w500),
                                )),
                              ]),
                            ),

                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
// PIN DOTS
// =============================================================================
class _PinDots extends StatelessWidget {
  final int filledCount;
  final bool isLockedOut;
  const _PinDots({required this.filledCount, required this.isLockedOut});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: filled ? 20 : 14,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: isLockedOut
                ? _redText.withOpacity(filled ? 0.7 : 0.15)
                : filled
                    ? kPrimary
                    : const Color(0xFFE5E9F0),
            boxShadow: filled && !isLockedOut
                ? [
                    BoxShadow(
                        color: kPrimary.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1)
                  ]
                : [],
          ),
        );
      }),
    );
  }
}

// =============================================================================
// DIAL PAD
// =============================================================================
class _DialPad extends StatelessWidget {
  final bool isLockedOut;
  final bool isAuthing;
  final bool canBio;
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final VoidCallback onBio;
  final Animation<double> pulseScale;
  final Animation<double> pulseOpacity;

  const _DialPad({
    required this.isLockedOut,
    required this.isAuthing,
    required this.canBio,
    required this.onDigit,
    required this.onDelete,
    required this.onBio,
    required this.pulseScale,
    required this.pulseOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(children: [
      // Digit rows
      ...rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row
                  .map((d) => _DialKey(
                        label: d,
                        onTap: isLockedOut ? null : () => onDigit(d),
                      ))
                  .toList(),
            ),
          )),

      // Bottom row — biometric | 0 | backspace
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Biometric — with breathing glow
          canBio
              ? AnimatedBuilder(
                  animation: pulseScale,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow halo
                      Transform.scale(
                        scale: pulseScale.value,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimary.withOpacity(pulseOpacity.value),
                          ),
                        ),
                      ),
                      _DialKey(
                        icon: Icons.fingerprint_rounded,
                        iconColor: kPrimary,
                        onTap: (isLockedOut || isAuthing) ? null : onBio,
                        outlined: true,
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: 88, height: 72),

          // Zero
          _DialKey(
            label: '0',
            onTap: isLockedOut ? null : () => onDigit('0'),
          ),

          // Backspace
          _DialKey(
            icon: Icons.backspace_outlined,
            onTap: isLockedOut ? null : onDelete,
            isSmall: true,
          ),
        ],
      ),
    ]);
  }
}

// =============================================================================
// INDIVIDUAL DIAL KEY
// =============================================================================
class _DialKey extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool outlined;
  final bool isSmall;

  const _DialKey({
    this.label,
    this.icon,
    this.iconColor,
    this.onTap,
    this.outlined = false,
    this.isSmall = false,
  });

  @override
  State<_DialKey> createState() => _DialKeyState();
}

class _DialKeyState extends State<_DialKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _pressAnim = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _pressCtrl.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _pressCtrl.reverse();
              widget.onTap!();
            },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (_, child) =>
            Transform.scale(scale: _pressAnim.value, child: child),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: disabled
                ? const Color(0xFFF5F7FA)
                : widget.outlined
                    ? _white
                    : const Color(0xFFF5F7FA),
            border: widget.outlined
                ? Border.all(color: kPrimary.withOpacity(0.25), width: 1.5)
                : null,
          ),
          child: Center(
            child: widget.label != null
                ? Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: disabled ? const Color(0xFFCBD5E1) : _ink,
                      letterSpacing: -0.3,
                    ),
                  )
                : Icon(
                    widget.icon,
                    size: widget.isSmall ? 22 : 28,
                    color: disabled
                        ? const Color(0xFFCBD5E1)
                        : widget.iconColor ?? _slate,
                  ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FLOATING CROSS PARTICLE
// =============================================================================
class _FloatCross extends StatelessWidget {
  final double x, y, size, opacity;
  final Color color;
  const _FloatCross(
      {required this.x,
      required this.y,
      required this.size,
      required this.opacity,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: _MedPlus(size: size, color: color),
      ),
    );
  }
}

class _MedPlus extends StatelessWidget {
  final double size;
  final Color color;
  const _MedPlus({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = size * 0.22;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        Container(
            width: size,
            height: t,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(t / 2))),
        Container(
            width: t,
            height: size,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(t / 2))),
      ]),
    );
  }
}
