import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';

import 'PremiumButton.dart';

Widget backButton(BuildContext context) {
  return PremiumButton(
    onTap: () {
      Get.back();
    },
    text: "",
    icon: Icons.arrow_back_ios_new,
    color: obsidian,
    textColor: Colors.white,
    borderRadius: 12,
    width: 44,
    height: 44,
  );
}
