import 'package:flutter/material.dart';

Widget countryCheck() {
  return Container();
  // return Obx(
  //   () => AnimatedCrossFade(
  //     firstChild: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             color: fireBrick.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               SizedBox(
  //                 width: 40,
  //                 height: 40,
  //                 child: LottieBuilder.asset(
  //                     "assets/lottie/connection_error.json"),
  //               ),
  //               Expanded(
  //                 child: Text(
  //                   "This app is currently not available in your country ${locationController.myCountry.value}",
  //                   style: boldTextStyle(color: Color(0xFFfb2c56), size: 14),
  //                 ).center(),
  //               ),
  //             ],
  //           ),
  //         ),
  //         5.height, // Maintains the original spacer
  //       ],
  //     ),
  //     secondChild: SizedBox.shrink(),
  //     crossFadeState: (locationController.availableCountries
  //                     .contains(locationController.myCountry.value) ||
  //                 locationController.myCountry.value != 'null') ||
  //             locationController.myCountry.value.isEmpty
  //         ? CrossFadeState.showSecond
  //         : CrossFadeState.showFirst,
  //     duration: const Duration(milliseconds: 600),
  //   ),
  // );
}
