import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/AnimatedCard.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/models/LabresultPricingModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../services/LabResultService.dart';
import '../../services/format_number.dart';
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
                    ? Loader().center()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Our lab result interpretation service offers comprehensive analysis and insights for your medical test results, all conveniently accessible through our mobile app.",
                            style: secondaryTextStyle(),
                          ),
                          AnimatedCard(
                            color1: kPrimary,
                            color2: kPrimaryDark,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                50.height,
                                Text(
                                  formatAmount(price!.amount.validate()),
                                  style: boldTextStyle(
                                    color: white,
                                    size: 30,
                                  ),
                                ),
                                50.height,
                                Text(
                                  "Allow our professional to interpret your lab result",
                                  style: secondaryTextStyle(
                                      size: 12, color: white),
                                ),
                                50.height,
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                      value: isChecked,
                                      activeColor: kPrimary,
                                      checkColor: white,
                                      onChanged: (val) {
                                        isChecked = !isChecked;
                                        setState(() {});
                                      }),
                                  Expanded(
                                    child: Text(
                                      "End user agreement to pricing policy",
                                      style: primaryTextStyle(),
                                    ),
                                  )
                                ],
                              ),
                              AppButton(
                                color: kPrimary,
                                width: double.infinity,
                                text: "Continue",
                                enabled: isChecked,
                                textColor: white,
                                disabledColor: dimGray,
                                disabledTextColor: white,
                                onTap: () {
                                  if (!isChecked) {
                                    toast("please accept policy to continue");
                                  } else {
                                    UploadLabResult(
                                      amount: price!.amount.validate(),
                                    ).launch(context);
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ))
          ],
        ),
      )),
    );
  }
}
