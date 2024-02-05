import 'package:flutter/material.dart';
import 'package:instant_doctor/screens/authentication/otp_screen.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
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
              image: AssetImage("assets/images/bg2.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Forgot Password",
                  style: boldTextStyle(size: 30, color: whiteColor),
                ),
                Text(
                  "Enter valid email username to receive password reset code.",
                  style: primaryTextStyle(
                    size: 14,
                    color: whiteColor,
                  ),
                ),
                20.height,
                AppTextField(
                  textFieldType: TextFieldType.EMAIL,
                  textStyle: primaryTextStyle(color: context.cardColor),
                  decoration: InputDecoration(
                      fillColor: white,
                      filled: true,
                      label: Text(
                        "Email Address",
                        style: primaryTextStyle(),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 5, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: whiteColor)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: whiteColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: whiteColor,
                        ),
                      )),
                ),
                10.height,
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    color: context.iconColor,
                    onTap: () {
                      const OTPScreen(
                        isResetPassword: true,
                      ).launch(context);
                    },
                    text: "Reset Password",
                    textColor: kPrimary,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
