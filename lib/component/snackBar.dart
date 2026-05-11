import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../constant/color.dart';

void errorSnackBarWithClose({
  required BuildContext context,
  required String title,
}) {
  Get.snackbar(
    'Error',
    title,
    snackPosition: SnackPosition.TOP,
    backgroundColor: errorColor.withOpacity(0.9),
    colorText: white,
    margin: const EdgeInsets.all(16),
    borderRadius: 16,
    duration: const Duration(seconds: 5),
    isDismissible: true,
    mainButton: TextButton(
      onPressed: () => Get.back(),
      child: const Text('Close', style: TextStyle(color: white)),
    ),
    icon: const Icon(Icons.error_outline_rounded, color: white),
    shouldIconPulse: true,
    leftBarIndicatorColor: white,
  );
}

void errorSnackBar({
  required BuildContext context,
  required String title,
}) {
  Get.snackbar(
    'Error',
    title,
    snackPosition: SnackPosition.TOP,
    backgroundColor: redText.withOpacity(0.9),
    colorText: white,
    margin: const EdgeInsets.all(16),
    borderRadius: 16,
    duration: const Duration(seconds: 3),
    icon: const Icon(Icons.info_outline_rounded, color: white),
    leftBarIndicatorColor: white,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ],
  );
}

void successSnackBar({
  required BuildContext context,
  required String title,
}) {
  Get.snackbar(
    'Success',
    title,
    snackPosition: SnackPosition.TOP,
    backgroundColor: green.withOpacity(0.9),
    colorText: white,
    margin: const EdgeInsets.all(16),
    borderRadius: 16,
    duration: const Duration(seconds: 3),
    icon: const Icon(Icons.check_circle_outline_rounded, color: white),
    leftBarIndicatorColor: white,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ],
  );
}
