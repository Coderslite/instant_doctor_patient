import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nb_utils/nb_utils.dart';

class AuthScreen extends StatefulWidget {
  final bool fromApp;
  final VoidCallback? onAuthSuccess;
  const AuthScreen({super.key, required this.fromApp, this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _pin = '';
  bool _canBiometric = false;
  bool _isAuthing = false;
  int _failedAttempts = 0;
  DateTime? _lockoutEnd;
  String _countdown = '';
  bool _isLockedOut = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _initialize();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
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
      await prefs.setInt('lockout_timestamp', _lockoutEnd!.millisecondsSinceEpoch);
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
        _countdown = '${rem.inMinutes}:${(rem.inSeconds % 60).toString().padLeft(2, '0')}';
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
    setState(() => _pin += d);
    if (_pin.length == 5) {
      Future.delayed(const Duration(milliseconds: 200), () {
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
      errorSnackBar(context: context, title: 'Too many attempts. Please wait 10 minutes.');
    } else {
      errorSnackBar(context: context, title: 'Wrong PIN — $_failedAttempts/3 attempts used.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                40.height,
                Text(
                  _isLockedOut ? 'Account Locked' : 'Welcome Back',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kText, letterSpacing: -1.0),
                ),
                12.height,
                Text(
                  _isLockedOut 
                    ? 'Please wait $_countdown before trying again.' 
                    : 'Unlock your account using your 5-digit security PIN.',
                  style: const TextStyle(fontSize: 15, color: kSub, height: 1.5),
                ),
                64.height,

                // PIN Dots
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final isActive = index < _pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isLockedOut ? Colors.red.withOpacity(isActive ? 0.8 : 0.1) : (isActive ? kPrimary : const Color(0xFFF0F2F8)),
                          border: Border.all(
                            color: _isLockedOut ? Colors.red : (isActive ? kPrimary : kBorder.withOpacity(0.5)),
                            width: 1,
                          ),
                          boxShadow: (isActive && !_isLockedOut) ? [
                            BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                          ] : [],
                        ),
                      );
                    }),
                  ),
                ),

                80.height,

                // Dial Pad
                _buildDialPad(),
                
                40.height,

                if (!_isLockedOut)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot pin - maybe logout or reset via email
                      },
                      child: const Text('Forgot PIN?', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialPad() {
    return Column(
      children: [
        for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((digit) => _DialButton(
                text: digit,
                onPressed: () => _addDigit(digit),
              )).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _DialButton(
              icon: Icons.fingerprint_rounded,
              onPressed: _biometricAuth,
              color: kPrimary,
              isVisible: _canBiometric,
            ),
            _DialButton(text: '0', onPressed: () => _addDigit('0')),
            _DialButton(
              icon: Icons.backspace_outlined,
              onPressed: _removeDigit,
            ),
          ],
        ),
      ],
    );
  }
}

class _DialButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isVisible;

  const _DialButton({this.text, this.icon, required this.onPressed, this.color, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox(width: 80, height: 80);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBorder.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: color ?? kText, size: 28)
              : Text(text!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kText)),
        ),
      ),
    );
  }
}
