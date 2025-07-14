import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/DailPad.dart';

class AuthScreen extends StatefulWidget {
  final bool fromApp;
  final VoidCallback? onAuthSuccess;
  const AuthScreen({super.key, required this.fromApp, this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _pin = '';
  bool _canUseBiometrics = false;
  bool _isAuthenticating = false;
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;
  String _countdown = '';
  bool _isLockedOut = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkBiometricAvailability();
    await _loadLockoutData();
    _updateCountdown();
    _startCountdownTimer();
  }

  Future<void> vibrate() async {
    print("vibrating");
    var type = FeedbackType.error;
    Vibrate.feedback(type);
    // Vibrate.vibrate();
  }

  Future<void> _checkBiometricAvailability() async {
    final bool canAuthenticate = await auth.canCheckBiometrics;
    setState(() {
      _canUseBiometrics = canAuthenticate;
    });
  }

  Future<void> _loadLockoutData() async {
    final prefs = await SharedPreferences.getInstance();
    final failedAttempts = prefs.getInt('failed_attempts') ?? 0;
    final lockoutTimestamp = prefs.getInt('lockout_timestamp');
    setState(() {
      _failedAttempts = failedAttempts;
      if (lockoutTimestamp != null) {
        _lockoutEndTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
        _isLockedOut = _lockoutEndTime!.isAfter(DateTime.now());
      }
    });
  }

  Future<void> _saveLockoutData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('failed_attempts', _failedAttempts);
    if (_lockoutEndTime != null) {
      await prefs.setInt(
          'lockout_timestamp', _lockoutEndTime!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('lockout_timestamp');
    }
  }

  void _updateCountdown() {
    if (_isLockedOut && _lockoutEndTime != null) {
      final now = DateTime.now();
      if (_lockoutEndTime!.isBefore(now)) {
        setState(() {
          _isLockedOut = false;
          _lockoutEndTime = null;
          _failedAttempts = 0;
          _countdown = '';
        });
        _saveLockoutData();
      } else {
        final remaining = _lockoutEndTime!.difference(now);
        setState(() {
          _countdown =
              '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel(); // Cancel any existing timer
    if (_isLockedOut && _lockoutEndTime != null) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        _updateCountdown();
        if (!_isLockedOut) {
          timer.cancel();
        }
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isLockedOut) return;
    try {
      setState(() {
        _isAuthenticating = true;
      });
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
      if (authenticated && mounted) {
        setState(() {
          _failedAttempts = 0;
        });
        await _saveLockoutData();
        widget.onAuthSuccess?.call();
        if (!widget.fromApp) {
          Root().launch(context, isNewTask: true);
        }
      } else if (!authenticated) {
        _handleFailedAttempt();
      }
    } catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
      });
      _handleFailedAttempt();
    }
  }

  void _handleFailedAttempt() {
    vibrate();
    setState(() {
      _failedAttempts++;
    });
    _saveLockoutData();
    if (_failedAttempts >= 3) {
      setState(() {
        _isLockedOut = true;
        _lockoutEndTime = DateTime.now().add(const Duration(minutes: 10));
        _pin = '';
      });
      _saveLockoutData();
      _updateCountdown();
      _startCountdownTimer();
      errorSnackBar(title: 'Too many failed attempts. Please wait 10 minutes.');
    } else {
      errorSnackBar(
          title: 'Authentication failed. $_failedAttempts/3 attempts.');
    }
  }

  void _addPinDigit(String digit) {
    if (_isLockedOut || _pin.length >= 5) return;
    setState(() {
      _pin += digit;
    });
    if (_pin.length == 5) {
      if (_pin == userController.pin.value) {
        setState(() {
          _failedAttempts = 0;
        });
        _saveLockoutData();
        widget.onAuthSuccess?.call();
        if (!widget.fromApp) {
          Root().launch(context, isNewTask: true);
        }
      } else {
        setState(() {
          _pin = '';
        });
        _handleFailedAttempt();
      }
    }
  }

  void _removePinDigit() {
    if (_isLockedOut || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: KeyboardDismisser(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryDark, kPrimary],
              ),
              image: const DecorationImage(
                image: AssetImage("assets/images/sol_bg.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
                opacity: 0.03,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    _isLockedOut ? 'Account Locked' : 'Welcome Back',
                    style: boldTextStyle(
                      size: 32,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLockedOut
                        ? 'Please wait $_countdown before trying again'
                        : 'Enter your PIN or use biometric authentication',
                    style: primaryTextStyle(
                      size: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // PIN display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _pin.length
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Dial pad
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
                          (digit) => DialButton(
                            text: digit,
                            onPressed:
                                _isLockedOut ? null : () => _addPinDigit(digit),
                          ),
                        ),
                        DialButton(
                          icon: Icons.fingerprint,
                          onPressed: _isLockedOut ||
                                  !_canUseBiometrics ||
                                  _isAuthenticating
                              ? null
                              : _authenticateWithBiometrics,
                        ),
                        DialButton(
                          text: '0',
                          onPressed:
                              _isLockedOut ? null : () => _addPinDigit('0'),
                        ),
                        DialButton(
                          icon: Icons.backspace,
                          onPressed: _isLockedOut ? null : _removePinDigit,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,
                      color: white,
                      opacity: AlwaysStoppedAnimation(0.6),
                    ),
                  ),
                  Text(
                    "Instant Doctor",
                    style: secondaryTextStyle(size: 16, color: whiteSmoke),
                  ),
                  // const Spacer(),
                  if (_isAuthenticating)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
