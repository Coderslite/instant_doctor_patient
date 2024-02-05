import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instant_doctor/screens/authentication/password-screnn.dart';
import 'package:instant_doctor/screens/authentication/success_signup.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

class OTPScreen extends StatefulWidget {
  final bool isResetPassword;
  const OTPScreen({
    super.key,
    required this.isResetPassword,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  var isChecked = false;
  Duration time =
      const Duration(minutes: 1); // Initial duration is set to 1 minute

  Timer? timer;

  handleTime() {
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
                  Row(
                    children: [
                      Text(
                        "OTP has been sent to u********@gmail.com ",
                        style: boldTextStyle(
                          color: whiteColor,
                          size: 15,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  20.height,
                  SizedBox(
                    height: 45,
                    child: OTPTextField(
                      pinLength: 5,
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
                          handleTime();
                        },
                        child: Text(
                          "Resend",
                          style: primaryTextStyle(),
                        )),
                  ),
                  20.height,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle form submission logic here
                          widget.isResetPassword
                              ? const PasswordScreen(isResetPassword: true)
                                  .launch(context)
                              : const SuccessSignUp().launch(context);
                        }
                      },
                      text: "Continue",
                    ),
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
