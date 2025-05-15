import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';


errorSnackBar({required String title}) {
  return Get.snackbar(
    'Something went wrong',
    title,
    snackPosition: SnackPosition.TOP,
    backgroundColor: errorColor,
    colorText: Colors.white,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    borderRadius: 8,
    isDismissible: true,
    duration: Duration(seconds: 3),
    snackStyle: SnackStyle.FLOATING,
  );
}

successSnackBar({required String title}) {
  return Get.snackbar(
    'Successful',
    title,
    snackPosition: SnackPosition.TOP,
    backgroundColor: mediumSeaGreen,
    colorText: Colors.white,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    borderRadius: 8,
    isDismissible: true,
    duration: Duration(seconds: 3),
    snackStyle: SnackStyle.FLOATING,
  );
}
