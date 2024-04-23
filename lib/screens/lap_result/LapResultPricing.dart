import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../services/format_number.dart';
import 'UploadLabResult.dart';

class LabResultPricing extends StatefulWidget {
  const LabResultPricing({super.key});

  @override
  State<LabResultPricing> createState() => _LabResultPricingState();
}

class _LabResultPricingState extends State<LabResultPricing> {
  bool isChecked = false;
  String type = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
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
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Our lab result interpretation service offers comprehensive analysis and insights for your medical test results, all conveniently accessible through our mobile app.",
                  style: secondaryTextStyle(),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage(
                        "assets/images/basic.png",
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatAmount(1000),
                        style: boldTextStyle(
                          color: white,
                          size: 30,
                        ),
                      ),
                      10.height,
                      Text(
                        "Allow our professional to interpret your lab result",
                        style: secondaryTextStyle(size: 12, color: white),
                      )
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
                          const UploadLabResult().launch(context);
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
