import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';

Card backButton(BuildContext context) {
  return Card(
    color: context.cardColor,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        Icons.arrow_back_ios_new,
        color: kPrimary,
      ),
    ).onTap(() {
      Get.back();
    }),
  );
}
