import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/authentication/password-screnn.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/DailPad.dart';
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
  final _formKey = GlobalKey<FormState>();
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
    print("vibrating");
    var type = FeedbackType.error;
    Vibrate.feedback(type);
    // Vibrate.vibrate();
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
            context: context);
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
      } else {}
    } else {
      setState(() {
        otp = '';
      });
      vibrate(); // Vibration for incorrect OTP
      errorSnackBar(title: "Incorrect OTP");
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
      successSnackBar(title: "OTP sent successfully");
    } catch (err) {
      errorSnackBar(title: "Something went wrong");
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
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    "OTP Verification",
                    style: boldTextStyle(
                      size: 32,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Enter the 5-digit OTP sent to\n${maskEmail(widget.email.validate())}",
                    textAlign: TextAlign.center,
                    style: primaryTextStyle(
                      size: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // OTP display
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
                            color: index < otp.length
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
                            onPressed: () => _addOTPDigit(digit),
                          ),
                        ),
                        const SizedBox
                            .shrink(), // Empty space for fingerprint (not used)
                        DialButton(
                          text: '0',
                          onPressed: () => _addOTPDigit('0'),
                        ),
                        DialButton(
                          icon: Icons.backspace,
                          onPressed: _removeOTPDigit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Resend OTP and timer
                  Obx(
                    () => authenticationController.isLoading.value
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Column(
                            children: [
                              if (time.inSeconds > 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Resend in ",
                                      style: boldTextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        size: 16,
                                      ),
                                    ),
                                    Text(
                                      '${(time.inMinutes % 60).toString().padLeft(2, '0')}:${(time.inSeconds % 60).toString().padLeft(2, '0')}',
                                      style: boldTextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              if (time.inSeconds == 0)
                                TextButton(
                                  onPressed: handleResendOTP,
                                  child: Text(
                                    "Resend OTP",
                                    style: boldTextStyle(
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
