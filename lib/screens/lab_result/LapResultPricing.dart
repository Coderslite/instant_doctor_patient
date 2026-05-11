import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/AnimatedCard.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/models/LabresultPricingModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

import '../../constant/color.dart';
import '../../services/LabResultService.dart';
import '../../services/format_number.dart';
import 'package:instant_doctor/services/IAPService.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'UploadLabResult.dart';

class LabResultPricing extends StatefulWidget {
  const LabResultPricing({super.key});

  @override
  State<LabResultPricing> createState() => _LabResultPricingState();
}

class _LabResultPricingState extends State<LabResultPricing> {
  bool isChecked = false;
  LabresultPricingModel? price;
  String type = '';
  bool isLoading = true;
  final labResultService = Get.find<LabResultService>();
  final iapService = Get.find<IAPService>();

  @override
  void initState() {
    handleGetPrice();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleGetPrice() async {
    price = await labResultService.getLabresultPrice();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                backButton(context),
                Text(
                  "Lab Result Pricing",
                  style: boldTextStyle(
                    size: 16,
                    color: kPrimary,
                  ),
                ),
                const Text("    "),
              ],
            ),
            30.height,
            Expanded(
              child: isLoading
                  ? const Loader().center()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Our lab result interpretation service offers comprehensive analysis and insights for your medical test results, all conveniently accessible through our mobile app.",
                          style: secondaryTextStyle(color: slate, height: 1.5),
                        ),

                        // Premium Pricing Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: obsidian,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: obsidian.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.biotech_rounded,
                                    color: white, size: 32),
                              ),
                                Obx(() {
                                  final pricingService =
                                      Get.find<PricingService>();
                                  const String productId = 'lab_result_standard';

                                  final String displayPrice = Platform.isAndroid
                                      ? iapService.getProductPrice(productId)
                                      : pricingService.getFormattedPrice(productId);

                                  return Text(
                                    displayPrice,
                                    style: boldTextStyle(
                                        color: white,
                                        size: 36,
                                        letterSpacing: -1),
                                  );
                                }),
                              12.height,
                              Text(
                                "Professional interpretation by our medical team",
                                textAlign: TextAlign.center,
                                style: secondaryTextStyle(
                                    color: white.withOpacity(0.6), size: 14),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    value: isChecked,
                                    activeColor: obsidian,
                                    checkColor: white,
                                    side: const BorderSide(
                                        color: obsidian, width: 2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                    onChanged: (val) {
                                      setState(() => isChecked = val ?? false);
                                    }),
                                Expanded(
                                  child: Text(
                                    "I agree to the pricing and service policy",
                                    style: primaryTextStyle(
                                        color: slate, size: 14),
                                  ),
                                )
                              ],
                            ),
                            16.height,
                            PremiumButton(
                              text: "Continue to Upload",
                              enabled: isChecked,
                              onTap: () {
                                  final pricingService = Get.find<PricingService>();
                                  const String productId = 'lab_result_standard';
                                  final double amount = Platform.isAndroid 
                                      ? iapService.getProductRawPrice(productId)
                                      : pricingService.getFinalPrice(productId);

                                  UploadLabResult(
                                    amount: amount.toInt(),
                                  ).launch(context);
                              },
                            ),
                            24.height,
                          ],
                        )
                      ],
                    ),
            ),
          ],
        ),
      )),
    );
  }
}
