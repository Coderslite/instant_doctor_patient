import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/authentication/password-screnn.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../controllers/AuthenticationController.dart';
import '../../services/AuthenticationService.dart';

class OTPScreen extends StatefulWidget {
  final String otpFor;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? gender;
  final String? referredBy;

  const OTPScreen({
    super.key,
    required this.otpFor,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.gender,
    required this.referredBy,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  Duration time = const Duration(minutes: 1);
  String otp = '';
  Timer? timer;
  final authenticationController = Get.find<AuthenticationController>();
  final authenticationService = Get.find<AuthenticationService>();

  @override
  void initState() {
    super.initState();
    handleTime();
  }

  void handleTime() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (time.inSeconds > 0) {
        setState(() {
          time = Duration(seconds: time.inSeconds - 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> vibrate() async {
    await Haptics.vibrate(HapticsType.error);
  }

  Future<void> handleVerifyOTP() async {
    authenticationController.isLoading.value = true;
    var result = await authenticationService.handleVerifyOTP(otp: otp);
    authenticationController.isLoading.value = false;
    if (result) {
      var prefs = await SharedPreferences.getInstance();
      prefs.remove('otp');
      authenticationController.clearOTPStage();
      if (widget.otpFor == OtpFor.reset) {
        PasswordScreen(isResetPassword: true).launch(context);
      } else if (widget.otpFor == OtpFor.login) {
        authenticationController.handleSignIn(
          email: widget.email.validate(),
          password: widget.password.validate(),
          context: context,
        );
      } else if (widget.otpFor == OtpFor.register) {
        authenticationController.handleRegister(
          firstname: widget.firstname.validate(),
          lastname: widget.lastname.validate(),
          email: widget.email.validate(),
          password: widget.password.validate(),
          phoneNumber: widget.phoneNumber.validate(),
          gender: widget.gender.validate(),
          referredBy: widget.referredBy.validate(),
          context: context,
        );
      }
    } else {
      setState(() {
        otp = '';
      });
      vibrate();
      errorSnackBar(context: context, title: "Incorrect OTP");
    }
  }

  Future<void> handleResendOTP() async {
    try {
      authenticationController.isLoading.value = true;
      await authenticationService.handleSendOTP(email: widget.email.validate());
      setState(() {
        time = const Duration(minutes: 1);
        otp = '';
      });
      handleTime();
      if (!mounted) return;
      successSnackBar(context: context, title: "OTP sent successfully");
    } catch (err) {
      errorSnackBar(context: context, title: "Something went wrong");
    } finally {
      authenticationController.isLoading.value = false;
    }
  }

  void _addOTPDigit(String digit) {
    if (otp.length >= 5) return;
    setState(() {
      otp += digit;
    });
    if (otp.length == 5) {
      handleVerifyOTP();
    }
  }

  void _removeOTPDigit() {
    if (otp.isEmpty) return;
    setState(() {
      otp = otp.substring(0, otp.length - 1);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kText, size: 20),
            onPressed: () => finish(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                40.height,
                const Text(
                  'Verify Your Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kText, letterSpacing: -1.0),
                ),
                12.height,
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: kSub, height: 1.5),
                    children: [
                      const TextSpan(text: 'We have sent a 5-digit verification code to '),
                      TextSpan(
                        text: maskEmail(widget.email.validate()),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: kPrimary),
                      ),
                    ],
                  ),
                ),
                48.height,

                // OTP Input Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final char = otp.length > index ? otp[index] : "";
                    final isFocused = otp.length == index;
                    return Container(
                      width: 58,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isFocused ? kPrimary.withOpacity(0.05) : const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isFocused ? kPrimary : kBorder.withOpacity(0.5),
                          width: isFocused ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        char,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kText),
                      ),
                    );
                  }),
                ),

                32.height,

                // Resend Timer
                Center(
                  child: Obx(() {
                    if (authenticationController.isLoading.value) {
                      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
                    }
                    if (time.inSeconds > 0) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Didn't receive code? ", style: TextStyle(color: kSub, fontSize: 14)),
                          Text(
                            'Resend in ${(time.inSeconds % 60).toString().padLeft(2, '0')}s',
                            style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ],
                      );
                    }
                    return TextButton(
                      onPressed: handleResendOTP,
                      child: const Text("Resend New Code", style: TextStyle(color: kPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                    );
                  }),
                ),

                48.height,

                // Custom Dial Pad
                _buildDialPad(),
                
                40.height,
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
                onPressed: () => _addOTPDigit(digit),
              )).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Spacer
            _DialButton(text: '0', onPressed: () => _addOTPDigit('0')),
            _DialButton(
              icon: Icons.backspace_outlined,
              onPressed: _removeOTPDigit,
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

  const _DialButton({this.text, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
              ? Icon(icon, color: kText, size: 24)
              : Text(text!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kText)),
        ),
      ),
    );
  }
}
