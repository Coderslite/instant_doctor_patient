import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/authentication/password-screnn.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

class SignUpScreen extends StatefulWidget {
  final String email;
  final String? referredBy;
  const SignUpScreen(
      {super.key, required this.email, required this.referredBy});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  var gender = '';
  var firstnameController = TextEditingController();
  var lastnameController = TextEditingController();
  var phoneController = TextEditingController();
  var referredBy = TextEditingController();
  @override
  Widget build(BuildContext context) {
    referredBy.text = widget.referredBy.validate();
    return KeyboardDismisser(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg3.png"),
              // colorFilter: ColorFilter.mode(kPrimary, BlendMode.color),
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
                  20.height,
                  Row(
                    children: [
                      backButton(context),
                    ],
                  ),
                  100.height,
                  Row(
                    children: [
                      Text(
                        "Please fill in the following details",
                        style: primaryTextStyle(color: context.iconColor),
                      ),
                    ],
                  ),
                  30.height,
                  Row(
                    children: [
                      Text(
                        "Sign Up",
                        style: boldTextStyle(
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
                    textStyle: primaryTextStyle(
                      size: 14,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 5, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: kPrimary)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                    ),
                  ),
                  20.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(
                      size: 14,
                    ),
                    controller: firstnameController,
                    decoration: InputDecoration(
                      label: Text(
                        "Firstname",
                        style: primaryTextStyle(
                          size: 14,
                        ),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 5, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: kPrimary)),
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
                  20.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(
                      size: 14,
                    ),
                    controller: lastnameController,
                    decoration: InputDecoration(
                      label: Text(
                        "Lastname",
                        style: primaryTextStyle(
                          size: 14,
                        ),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 5, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: kPrimary)),
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
                  20.height,
                  IntlPhoneField(
                    validator: (p0) {
                      if (!p0!.isValidNumber()) {
                        return "Not a valid number";
                      }
                      return null;
                    },
                    style: primaryTextStyle(
                      size: 14,
                    ),
                    dropdownTextStyle: primaryTextStyle(
                      size: 14,
                    ),
                    controller: phoneController,
                    decoration: InputDecoration(
                      label: Text(
                        "Phone Number",
                        style: primaryTextStyle(
                          size: 14,
                        ),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 5, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: kPrimary)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kPrimary),
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
                        style: boldTextStyle(size: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio(
                            activeColor: kPrimary,
                            value: "Male",
                            groupValue: gender,
                            onChanged: (val) {
                              gender = val.toString();
                              setState(() {});
                            },
                          ),
                          Text(
                            "Male",
                            style: primaryTextStyle(size: 14),
                          ),
                        ],
                      ),
                      10.width,
                      Row(
                        children: [
                          Radio(
                            activeColor: kPrimary,
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
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  20.height,
                  AppTextField(
                    textFieldType: TextFieldType.OTHER,
                    textStyle: primaryTextStyle(size: 14),
                    controller: referredBy,
                    decoration: InputDecoration(
                      label: Text(
                        "Referred Code (optional)",
                        style: primaryTextStyle(size: 14),
                      ),
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 5, horizontal: 10),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: kPrimary)),
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
                            referredBy: referredBy.text,
                          ).launch(context);
                        }
                      },
                      color: white,
                      textColor: kPrimary,
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
