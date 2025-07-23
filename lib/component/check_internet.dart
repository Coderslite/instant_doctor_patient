import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/ConnectivityController.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

Widget internetCheck() {
  ConnectivityController connectivityController =
      Get.find<ConnectivityController>();
  return Obx(
    () => AnimatedCrossFade(
      firstChild: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child:
                    LottieBuilder.asset("assets/lottie/connection_error.json"),
              ),
              Text(
                "No Internet Connection",
                style: boldTextStyle(color: Color(0xFFfb2c56), size: 14),
              ).center(),
            ],
          ),
          5.height, // Maintains the original spacer
        ],
      ),
      secondChild: SizedBox.shrink(),
      crossFadeState: connectivityController.internetConnected.value
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 600),
    ),
  );
}
