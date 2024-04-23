import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/ProfileImage.dart';
import '../../../constant/color.dart';
import '../../../main.dart';
import '../../../models/UserModel.dart';
import '../../../services/GetUserId.dart';
import '../personal/PersonalProfile.dart';

class WalletSetupScreen extends StatefulWidget {
  const WalletSetupScreen({super.key});

  @override
  State<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends State<WalletSetupScreen> {
  var controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // ignore: unused_local_variable
        bool isDarkMode = settingsController.isDarkMode.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<UserModel>(
                stream:
                    userService.getProfile(userId: userController.userId.value),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const BackButton(
                                color: kPrimary,
                              ),
                              Text(
                                "Wallet Setup",
                                style: boldTextStyle(
                                  size: 16,
                                  color: kPrimary,
                                ),
                              ),
                              Container(),
                            ],
                          ),
                          1.height,
                          profileImage(data, 100, 100,context: context).center(),
                          30.height,
                          Text(
                            "Complete Wallet Setup",
                            style: secondaryTextStyle(
                              size: 14,
                            ),
                          ),
                          10.height,
                          profileOption("Country", data.country.validate(),
                              key: "country"),
                          profileOption("Currency", data.currency.validate(),
                              key: "currency"),
                        ],
                      ),
                    );
                  }
                  return const CircularProgressIndicator(
                    color: kPrimary,
                  ).center();
                }),
          ),
        );
      }),
    );
  }

  profileOption(String title, String description, {required String key}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Card(
        color: context.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: boldTextStyle(size: 14),
                  ),
                  5.height,
                  Text(
                    description,
                    style: secondaryTextStyle(size: 12),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              )
            ],
          ),
        ),
      ),
    ).onTap(() async {
      controller.clear();
      controller.text = description;
      setState(() {});
      if (key == 'dob') {
        var date = await showDatePicker(
            context: context,
            firstDate: DateTime.now().subtract(const Duration(days: 36500)),
            lastDate: DateTime.now());
        if (date != null) {
          var timeStamp = Timestamp.fromDate(date);
          userService.updateProfile(data: {
            "dob": timeStamp,
          }, userId: userController.userId.value);
        } else {
          toast("Date was not selected");
        }
      } else {
        if (key == 'currency') {
          toast("Change you country in order to change you currency");
        } else {
          showDialog(
            context: context,
            builder: (context) => ProfileUpdateDialog(
              controller: controller,
              keey: key,
              title: title,
            ),
          );
        }
      }
    });
  }
}
