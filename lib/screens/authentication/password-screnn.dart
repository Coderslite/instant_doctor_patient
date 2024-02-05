// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/screens/authentication/otp_screen.dart';
import 'package:instant_doctor/screens/authentication/success_reset.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';

class PasswordScreen extends StatefulWidget {
  final String? firstname;
  final String? lastname;
  final String? phone;
  final String? email;
  final String? gender;
  final bool isResetPassword;
  const PasswordScreen({
    super.key,
    required this.isResetPassword,
    this.firstname,
    this.lastname,
    this.phone,
    this.email,
    this.gender,
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  var isChecked = false;
  var pass1 = TextEditingController();
  var pass2 = TextEditingController();

  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        body: Obx(
          () => Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg1.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    120.height,
                    Row(
                      children: [
                        Text(
                          "Almost Done",
                          style: primaryTextStyle(color: whiteColor),
                        ),
                      ],
                    ).visible(!widget.isResetPassword),
                    30.height,
                    Row(
                      children: [
                        Text(
                          widget.isResetPassword
                              ? "Reset Password"
                              : "Password",
                          style: boldTextStyle(
                            color: whiteColor,
                            size: 32,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    20.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      obscuringCharacter: "*",
                      controller: pass1,
                      isPassword: true,
                      textStyle: primaryTextStyle(size: 14, color: black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: whiteColor,
                        label: Text(
                          "Password",
                          style: primaryTextStyle(color: black),
                        ),
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                            vertical: 10, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: whiteColor,
                          ),
                        ),
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
                        ),
                      ),
                    ),
                    20.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      obscuringCharacter: "*",
                      isPassword: true,
                      controller: pass2,
                      textStyle: primaryTextStyle(size: 14, color: black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: whiteColor,
                        label: Text(
                          "Retype Password",
                          style: primaryTextStyle(color: black),
                        ),
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                            vertical: 10, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: whiteColor,
                          ),
                        ),
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
                        ),
                      ),
                    ),
                    20.height.visible(!widget.isResetPassword),
                    Row(
                      children: [
                        Checkbox(
                            activeColor: white,
                            checkColor: kPrimary,
                            value: isChecked,
                            onChanged: (val) {
                              isChecked = val!;
                              setState(() {});
                            }),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: Text(
                            "I agree that all information provided in this section are valid .",
                            style: primaryTextStyle(
                              color: whiteColor,
                            ),
                          ),
                        )
                      ],
                    ).visible(!widget.isResetPassword),
                    30.height,
                    CircularProgressIndicator(
                      color: white,
                    )
                        .center()
                        .visible(authenticationController.isLoading.value),
                    AppButton(
                      width: double.infinity,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          if (pass1.text == pass2.text) {
                            widget.isResetPassword
                                ? const SuccessPassReset().launch(context)
                                : authenticationController.handleRegister(
                                    firstname: widget.firstname!,
                                    lastname: widget.lastname!,
                                    email: widget.email!,
                                    password: pass1.text,
                                    phoneNumber: widget.phone!,
                                    gender: widget.gender!,
                                    context: context);
                          } else {
                            toast("Password does not match");
                          }
                        }
                      },
                      text: "Continue",
                    ).visible(!authenticationController.isLoading.value),
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
