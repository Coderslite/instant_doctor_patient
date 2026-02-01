// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/ReferController.dart';
import 'package:instant_doctor/screens/authentication/success_signup.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';

class ReferralRegistrationScreen extends StatefulWidget {
  final String? userId;
  const ReferralRegistrationScreen({super.key, this.userId});

  @override
  State<ReferralRegistrationScreen> createState() =>
      _ReferralRegistrationScreenState();
}

class _ReferralRegistrationScreenState
    extends State<ReferralRegistrationScreen> {
  var referalController = TextEditingController();
  var referralController = Get.find<ReferralController>();
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
              // colorFilter: ColorFilter.mode(kPrimary, BlendMode.color),
              fit: BoxFit.cover,
            ),
          ),
          child: Obx(
            () => SingleChildScrollView(
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
                        "Referred By",
                        style: boldTextStyle(
                          size: 32,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  20.height,
                  AppTextField(
                    controller: referalController,
                    textFieldType: TextFieldType.OTHER,
                    textStyle: primaryTextStyle(),
                    decoration: InputDecoration(
                      label: Text(
                        "Referral Code (optional)",
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
                  Loader().center().visible(referralController.isLoading.value),
                  AppButton(
                    width: double.infinity,
                    textColor: kPrimary,
                    onTap: () async {
                      if (referalController.text.isEmpty) {
                        SuccessSignUp().launch(context);
                      } else {
                        referralController.handleNewReferral(
                            referralCode: referalController.text);
                        SuccessSignUp().launch(context);
                      }
                    },
                    text: "Continue",
                  ).visible(!referralController.isLoading.value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
