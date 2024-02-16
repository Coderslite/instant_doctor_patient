import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/ReferController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/ReferralModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:get/get.dart';

import '../../component/eachReferral.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  ReferralController referralController = Get.put(ReferralController());
  var controller = PanelController();

  @override
  void initState() {
    referralController.handleGetLink();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SlidingUpPanel(
          minHeight: MediaQuery.of(context).size.height / 2,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          controller: controller,
          // parallaxEnabled: true,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          body: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: kPrimary,
                image: DecorationImage(
                  image: AssetImage("assets/images/particle.png"),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackButton(),
                        Text(
                          "Instant Earn",
                          style: boldTextStyle(
                            color: white,
                            size: 16,
                          ),
                        ),
                        const Text("      "),
                      ]),
                  20.height,
                  Text(
                    "Earn ${formatAmount(500)} instant credits",
                    style: primaryTextStyle(size: 16, color: white),
                  ),
                  Text(
                    "by referring your friends",
                    style: primaryTextStyle(size: 16, color: white),
                  ),
                  20.height,
                  Text(
                    "Share Health, Earn Wealth!",
                    style: primaryTextStyle(
                      size: 12,
                      color: white,
                    ),
                  ),
                  50.height,
                  Row(children: [
                    Expanded(
                        child: AppTextField(
                      initialValue: referralController.shareLink.value,
                      readOnly: true,
                      textStyle: primaryTextStyle(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        fillColor: context.cardColor,
                        filled: true,
                        suffixIcon: MaterialButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: referralController.shareLink.value));

                            // Show a snackbar to indicate the text has been copied
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied'),
                              ),
                            );
                          },
                          child: Text(
                            "Copy",
                            style: primaryTextStyle(
                              color: kPrimary,
                              size: 10,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      textFieldType: TextFieldType.OTHER,
                    )),
                    10.width,
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.cardColor,
                        ),
                        onPressed: () {
                          referralController.handleRefer();
                        },
                        child: Text("Share",
                            style: primaryTextStyle(
                              color: kPrimary,
                              size: 12,
                            )))
                  ])
                ],
              )),
          color: context.cardColor,
          panel: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.height,
                Container(
                  width: 50,
                  height: 3,
                  color: dimGrey,
                ).center(),
                10.height,
                Text(
                  "Referrals",
                  style: primaryTextStyle(size: 16),
                ),
                Expanded(
                  child: FutureBuilder<List<ReferralModel>>(
                      future: referralService.getReferrals(
                          tag: userController.tag.value),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data!;
                          if (data.isEmpty) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No referrals yet",
                                  style: boldTextStyle(),
                                ),
                              ],
                            );
                          } else {
                            return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  var ref = data[index];
                                  return eachReferral(
                                      context: context, data: ref);
                                });
                          }
                        }
                        return CircularProgressIndicator().center();
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
