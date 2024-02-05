import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../main.dart';
import '../services/format_number.dart';

Container card(BuildContext context) {
  UserController userController = Get.put(UserController());
  return Container(
    height: 200,
    width: MediaQuery.of(context).size.width / 1.1,
    alignment: Alignment.topLeft,
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: kPrimary,
      image: const DecorationImage(
        image: AssetImage("assets/images/particle.png"),
        fit: BoxFit.cover,
        opacity: 0.4,
      ),
      boxShadow: [
        BoxShadow(
          color: dimGray.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 3,
          offset: const Offset(0, 5),
        ),
      ],
    ),
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
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    var data = snapshot.data;
                    return Text(
                      "\NGN ${formatAmount(data!.amount.validate().toInt())}",
                      style: boldTextStyle(
                        size: 20,
                        color: white,
                      ),
                    );
                  }
                  return CircularProgressIndicator(
                    color: white,
                  ).center();
                }),
          ],
        ),
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
            ),
            Text(
              userController.userId.value,
              style: boldTextStyle(color: white, size: 16),
            ),
          ],
        )
      ],
    ),
  );
}
