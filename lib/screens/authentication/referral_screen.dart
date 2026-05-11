import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/ReferController.dart';
import 'package:instant_doctor/screens/authentication/success_signup.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

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
  final referalController = TextEditingController();
  final referralController = Get.find<ReferralController>();

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kText, size: 20),
            onPressed: () => finish(context),
          ),
        ),
        body: SafeArea(
          child: Obx(
            () => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  40.height,
                  // Gift Icon Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        color: kPrimary,
                        size: 48,
                      ),
                    ),
                  ),
                  40.height,
                  const Text(
                    "Have a Referral\nCode?",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: kText,
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),
                  12.height,
                  const Text(
                    "Enter your friend's referral code to unlock special benefits and rewards.",
                    style: TextStyle(
                      fontSize: 15,
                      color: kSub,
                      height: 1.5,
                    ),
                  ),
                  48.height,

                  // Referral Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Referral Code",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      10.height,
                      TextFormField(
                        controller: referalController,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kText,
                        ),
                        decoration: InputDecoration(
                          hintText: "e.g. HEALTH2024",
                          hintStyle: TextStyle(
                            color: kSub.withOpacity(0.4),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.local_offer_outlined,
                            color: kPrimary.withOpacity(0.5),
                            size: 20,
                          ),
                          fillColor: const Color(0xFFF8FAFF),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: kPrimary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  64.height,

                  // Action Button
                  PremiumButton(
                    onTap: () async {
                      if (referalController.text.isEmpty) {
                        const SuccessSignUp().launch(context);
                      } else {
                        referralController.handleNewReferral(
                          referralCode: referalController.text,
                        );
                        const SuccessSignUp().launch(context);
                      }
                    },
                    isLoading: referralController.isLoading.value,
                    text: referalController.text.isEmpty
                        ? "Skip for now"
                        : "Apply & Continue",
                  ),
                  24.height,
                  if (referalController.text.isNotEmpty)
                    Center(
                      child: TextButton(
                        onPressed: () => const SuccessSignUp().launch(context),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            color: kSub,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  40.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
