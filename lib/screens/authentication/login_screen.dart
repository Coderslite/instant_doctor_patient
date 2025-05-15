import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/screens/authentication/email_screen.dart';
import 'package:instant_doctor/screens/authentication/forgot_password.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool obscuree = true;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
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
                      child: Image.asset(
                        "assets/images/logo.png",
                      ),
                    ),
                    30.height,
                    Row(
                      children: [
                        Text(
                          "Sign In",
                          style: boldTextStyle(
                            size: 32,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    20.height,
                    AppTextField(
                      textFieldType: TextFieldType.EMAIL,
                      textStyle: primaryTextStyle(),
                      controller: emailController,
                      autoFillHints: const [AutofillHints.email],
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
                          borderSide: const BorderSide(color: kPrimary),
                        ),
                      ),
                    ),
                    20.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: passwordController,
                      isPassword: true,
                      obscuringCharacter: "*",
                      textStyle: primaryTextStyle(),
                      autoFillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        label: Text(
                          "Password",
                          style: primaryTextStyle(),
                        ),
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                            vertical: 10, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: kPrimary)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: kPrimary),
                        ),
                      ),
                    ),
                    30.height,
                    Loader()
                        .center()
                        .visible(authenticationController.isLoading.value),
                    SizedBox(
                      child: AppButton(
                        width: double.infinity,
                        textColor: kPrimary,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await authenticationController.handleSignIn(
                                email: emailController.text,
                                password: passwordController.text,
                                context: context);
                            TextInput.finishAutofillContext();
                          }
                        },
                        text: "Continue",
                      ),
                    ).visible(!authenticationController.isLoading.value),
                    10.height,
                    Loader()
                        .center()
                        .visible(authenticationController.googleSignin.value),
                    AppButton(
                      width: double.infinity,
                      color: white,
                      onTap: () async {
                        authenticationController.handleGoogleSignin(context,
                            referredBy: '');
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot Password ?",
                          style: secondaryTextStyle(),
                        ).onTap(() {
                          const ForgotPassword().launch(context);
                        }),
                      ],
                    ),
                    10.height,
                    RichText(
                        text: TextSpan(
                            style: primaryTextStyle(),
                            text: "Don't have an account ? ",
                            children: [
                          TextSpan(
                              text: "Sign Up",
                              style: boldTextStyle(),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => const EmailScreen().launch(context)),
                        ]))
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
