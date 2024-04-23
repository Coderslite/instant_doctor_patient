// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:instant_doctor/screens/authentication/signup.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../controllers/AuthenticationController.dart';

class EmailScreen extends StatefulWidget {
  final String? userId;
  const EmailScreen({super.key, this.userId});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());
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
              image: AssetImage("assets/images/bg3.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Obx(
            () => SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    50.height,
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset("assets/images/logo.png"),
                    ),
                    30.height,
                    Row(
                      children: [
                        Text(
                          "Sign Up",
                          style: boldTextStyle(
                            color: kPrimary,
                            size: 32,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    20.height,
                    AppTextField(
                      controller: emailController,
                      textFieldType: TextFieldType.EMAIL,
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
                            borderSide: const BorderSide(color: kPrimary)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ),
                    30.height,
                    const CircularProgressIndicator()
                        .center()
                        .visible(authenticationController.isLoading.value),
                    AppButton(
                      width: double.infinity,
                      color: kPrimary,
                      textColor: whiteColor,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          if (await authenticationController
                              .handleCheckEmail(emailController.text)) {
                            SignUpScreen(
                              email: emailController.text,
                              referredBy: widget.userId,
                            ).launch(context);
                          } else {
                            toast("email already exist");
                          }
                        }
                      },
                      text: "Continue",
                    ).visible(!authenticationController.isLoading.value),
                    10.height,
                    Text(
                      "or",
                      style: secondaryTextStyle(size: 20),
                    ),
                    10.height,
                    const CircularProgressIndicator()
                        .center()
                        .visible(authenticationController.googleSignin.value),
                    AppButton(
                      width: double.infinity,
                      color: white,
                      onTap: () {
                        authenticationController.handleGoogleSignin(context,referredBy:widget.userId.validate());
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: Image.asset(
                                "assets/images/google.png",
                              ),
                            ),
                            10.width,
                            const Text("Continue with Google"),
                          ]).center(),
                    ).visible(!authenticationController.googleSignin.value),
                    10.height,
                    RichText(
                      text: TextSpan(
                        style: primaryTextStyle(color: kPrimary),
                        text: "Already have an account ? ",
                        children: [
                          TextSpan(
                              text: "Sign In",
                              style: boldTextStyle(color: kPrimary),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => const LoginScreen().launch(context)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
