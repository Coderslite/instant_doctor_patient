import 'package:flutter/material.dart';
import 'package:instant_doctor/screens/authentication/password-screnn.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

class SignUpScreen extends StatefulWidget {
  final String email;
  const SignUpScreen({super.key, required this.email});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  var gender = '';
  var firstnameController = TextEditingController();
  var lastnameController = TextEditingController();
  var phoneController = TextEditingController();
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  120.height,
                  Row(
                    children: [
                      Text(
                        "Please fill in the following details",
                        style: primaryTextStyle(color: whiteColor),
                      ),
                    ],
                  ),
                  30.height,
                  Row(
                    children: [
                      Text(
                        "Sign Up",
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
                    enabled: false,
                    textFieldType: TextFieldType.EMAIL,
                    initialValue: widget.email,
                    textStyle: primaryTextStyle(size: 14, color: black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whiteColor,
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 10, horizontal: 10),
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
                      ),
                    ),
                  ),
                  20.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(size: 14, color: black),
                    controller: firstnameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whiteColor,
                      label: Text(
                        "Firstname",
                        style: primaryTextStyle(size: 14, color: black),
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
                      ),
                    ),
                  ),
                  20.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(size: 14, color: black),
                    controller: lastnameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whiteColor,
                      label: Text(
                        "Lastname",
                        style: primaryTextStyle(size: 14, color: black),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 10, horizontal: 10),
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
                      ),
                    ),
                  ),
                  20.height,
                  IntlPhoneField(
                    validator: (p0) {
                      if (!p0!.isValidNumber()) {
                        return "Not a valid number";
                      }
                      return null;
                    },
                    style: primaryTextStyle(size: 14, color: black),
                    controller: phoneController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whiteColor,
                      label: Text(
                        "Phone Number",
                        style: primaryTextStyle(size: 14, color: black),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 10, horizontal: 10),
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
                      ),
                    ),
                    initialCountryCode: 'NG',
                    onChanged: (phone) {},
                  ),
                  // 20.height,
                  Row(
                    children: [
                      Text(
                        "Gender",
                        style: boldTextStyle(color: whiteColor, size: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio(
                            activeColor: whiteColor,
                            value: "Male",
                            groupValue: gender,
                            onChanged: (val) {
                              gender = val.toString();
                              setState(() {});
                            },
                          ),
                          Text(
                            "Male",
                            style:
                                primaryTextStyle(color: whiteColor, size: 14),
                          ),
                        ],
                      ),
                      10.width,
                      Row(
                        children: [
                          Radio(
                            activeColor: whiteColor,
                            value: "Female",
                            groupValue: gender,
                            onChanged: (val) {
                              gender = val.toString();
                              setState(() {});
                            },
                          ),
                          Text(
                            "Female",
                            style: primaryTextStyle(
                              color: whiteColor,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  30.height,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          PasswordScreen(
                            email: widget.email,
                            firstname: firstnameController.text,
                            lastname: lastnameController.text,
                            phone: phoneController.text,
                            gender: gender,
                            isResetPassword: false,
                          ).launch(context);
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
