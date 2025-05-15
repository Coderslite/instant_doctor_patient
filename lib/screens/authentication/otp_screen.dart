import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/authentication/password-screnn.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../controllers/AuthenticationController.dart';
import '../../services/AuthenticationService.dart';

class OTPScreen extends StatefulWidget {
  final bool isResetPassword;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? gender;
  final String? referredBy;
  const OTPScreen({
    super.key,
    required this.isResetPassword,
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
  var isChecked = false;
  Duration time =
      const Duration(minutes: 1); // Initial duration is set to 1 minute
  String otp = '';
  Timer? timer;

  final authenticationController = Get.find<AuthenticationController>();
  final authenticationService = Get.find<AuthenticationService>();

  handleTime() async {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time.inSeconds > 0) {
        setState(() {
          time = Duration(seconds: time.inSeconds - 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    handleTime();
    super.initState();
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
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "OTP has been sent to ${maskEmail(widget.email.validate())}",
                    textAlign: TextAlign.center,
                    style: boldTextStyle(
                      color: whiteColor,
                      size: 15,
                      weight: FontWeight.bold,
                    ),
                  ),
                  20.height,
                  SizedBox(
                    height: 45,
                    child: OTPTextField(
                      pinLength: 5,
                      onChanged: (p0) {
                        otp = p0;
                        setState(() {});
                      },
                      onCompleted: (p0) {
                        otp = p0;
                        setState(() {});
                        handleVerifyOTP();
                      },
                      boxDecoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  30.height.visible(
                        time.inSeconds > 0,
                      ),
                  Visibility(
                    visible: time.inSeconds > 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Resend in ",
                          style: boldTextStyle(color: whiteColor),
                        ),
                        Text(
                          '${(time.inMinutes % 60).toString().padLeft(2, '0')}:${(time.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: boldTextStyle(color: whiteColor),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: time.inSeconds == 0,
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            time = const Duration(minutes: 1);
                          });
                          // Restart timer
                          handleResensOTP();
                        },
                        child: Text(
                          "Resend",
                          style: boldTextStyle(color: white),
                        )),
                  ),
                  20.height,
                  Loader()
                      .center()
                      .visible(authenticationController.isLoading.value),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle form submission logic here
                          widget.isResetPassword
                              ? const PasswordScreen(isResetPassword: true)
                                  .launch(context)
                              : handleVerifyOTP();
                        }
                      },
                      text: "Continue",
                    ),
                  ).visible(!authenticationController.isLoading.value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  handleVerifyOTP() async {
    var result = await authenticationService.handleVerifyOTP(otp: otp);
    if (result) {
      authenticationController.otp.value = '';
      authenticationController.handleRegister(
          firstname: widget.firstname.validate(),
          lastname: widget.lastname.validate(),
          email: widget.email.validate(),
          password: widget.password.validate(),
          phoneNumber: widget.phoneNumber.validate(),
          gender: widget.gender.validate(),
          referredBy: widget.referredBy.validate(),
          context: context);
    } else {
      errorSnackBar(title: "Incorrect OTP");
    }
  }

  handleResensOTP() async {
    try {
      authenticationController.isLoading.value = true;
      await authenticationService.handleSendOTP(email: widget.email.validate());
      successSnackBar(title: "OTP sent successfully");
      handleTime();
    } catch (err) {
      errorSnackBar(title: "Something went wrong");
    } finally {
      authenticationController.isLoading.value = false;
    }
  }
}
