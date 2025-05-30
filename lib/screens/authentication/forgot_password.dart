import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/services/AuthenticationService.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../services/UserService.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final userService = Get.find<UserService>();

  var emailController = TextEditingController();
  bool isSending = false;
  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg3.png"),
              fit: BoxFit.cover,
              // colorFilter: ColorFilter.mode(kPrimary, BlendMode.color),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              backButton(context),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Forgot Password",
                    style: boldTextStyle(
                      size: 30,
                    ),
                  ),
                  Text(
                    "Enter valid email username to receive password reset code.",
                    style: primaryTextStyle(
                      size: 14,
                    ),
                  ),
                  20.height,
                  AppTextField(
                    textFieldType: TextFieldType.EMAIL,
                    controller: emailController,
                    textStyle: primaryTextStyle(),
                    decoration: InputDecoration(
                      label: Text(
                        "Email Address",
                        style: primaryTextStyle(),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 10, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                    ),
                  ),
                  10.height,
                 Loader().visible(isSending).center(),
                  AppButton(
                    width: double.infinity,
                    onTap: () async {
                      try {
                        isSending = true;
                        var user = await userService.getUserByEmail(
                            email: emailController.text);
                        if (user != null) {
                          setState(() {});
                          await AuthenticationService()
                              .resetPassword(emailController.text);
                        } else {
                          toast("User not found");
                        }
                      } finally {
                        isSending = false;
                        setState(() {});
                      }
                      // const OTPScreen(
                      //   isResetPassword: true,
                      // ).launch(context);
                    },
                    text: "Reset Password",
                    textColor: kPrimary,
                  ).visible(!isSending),
                ],
              ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}
