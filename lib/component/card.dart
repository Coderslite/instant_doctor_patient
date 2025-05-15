import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/AnimatedCard.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/profile/wallet_setup/WalletSetup.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../services/UserService.dart';
import '../services/format_number.dart';

AnimatedCard card(BuildContext context) {
  UserController userController = Get.put(UserController());
  final userService = Get.find<UserService>();

  return AnimatedCard(
    color1: kPrimary,
    color2: kPrimaryDark,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Available Balance",
              style: boldTextStyle(
                size: 12,
                color: white,
              ),
            ),
            10.height,
            StreamBuilder<UserModel>(
                stream: userController.userId.isNotEmpty
                    ? userService.getProfile(
                        userId: userController.userId.value)
                    : const Stream.empty(), // return empty stream if null
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    var data = snapshot.data;
                    return data!.currency.isEmptyOrNull
                        ? ElevatedButton(
                            onPressed: () {
                              const WalletSetupScreen().launch(context);
                            },
                            child: Text(
                              "Complete Setup",
                              style: boldTextStyle(color: kPrimary),
                            ))
                        : Text(
                            formatAmount(data.amount.validate().toInt()),
                            style: boldTextStyle(
                              size: 20,
                              color: white,
                            ),
                          );
                  }
                  return const CircularProgressIndicator(
                    color: white,
                  ).center();
                }),
          ],
        ),
        40.height,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.copy,
                  color: white,
                  size: 12,
                ),
                5.width,
                Text(
                  "copy ID",
                  style: boldTextStyle(size: 12, color: white),
                ),
              ],
            ).onTap(() {
              Clipboard.setData(
                ClipboardData(text: userController.tag.value),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied'),
                ),
              );
            }),
            Text(
              "@${userController.tag.value}",
              style: boldTextStyle(color: white, size: 16),
            ),
          ],
        )
      ],
    ),
  );
}
