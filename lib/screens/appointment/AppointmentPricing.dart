import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/services/IAPService.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

class AppointmentPricingScreen extends StatefulWidget {
  final bool fromDocScreen;
  const AppointmentPricingScreen({super.key, required this.fromDocScreen});

  @override
  State<AppointmentPricingScreen> createState() =>
      _AppointmentPricingScreenState();
}

class _AppointmentPricingScreenState extends State<AppointmentPricingScreen> {
  BookingController bookingController = Get.put(BookingController());
  final iapService = Get.find<IAPService>();
  final pricingService = Get.find<PricingService>();

  String selectedPackage = '';
  bool isChecked = false;
  int? selectedPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/thumbnail1.png"))),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Pricing",
                    style: boldTextStyle(size: 20, color: kPrimary),
                  ),
                  const Text("      "),
                ],
              ),
              20.height,
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    priceOptions(
                        name: "Basic",
                        id: 'appointment_basic',
                        image: "basic.png",
                        duration: 30 * 60,
                        desc: "Chat with Doctor for 30 minutes"),
                    20.height,
                    priceOptions(
                        name: "Standard",
                        id: 'appointment_standard',
                        image: "standard.png",
                        duration: 60 * 60,
                        desc: "Chat with Doctor for 1 hour"),
                    20.height,
                    priceOptions(
                        name: "Special",
                        id: 'appointment_special',
                        image: "special.png",
                        duration: 90 * 60,
                        desc: "Detailed discussion and symptom review"),
                  ],
                ),
              ),
              Row(
                children: [
                  Checkbox(
                      value: isChecked,
                      activeColor: kPrimary,
                      onChanged: (val) {
                        isChecked = val!;
                        setState(() {});
                      }),
                  Expanded(
                      child: Text(
                    "End user agreement to pricing policy",
                    style: primaryTextStyle(size: 14),
                  )),
                ],
              ),
              20.height,
              PremiumButton(
                onTap: () {
                  finish(context, selectedPrice);
                },
                text: "Proceed",
                enabled: isChecked && selectedPackage.isNotEmpty,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget priceOptions(
      {required String name,
      required String id,
      required String image,
      required int duration,
      required String desc}) {
    return Obx(() {
      // DEBUG: Print current state for this ID
      final String displayPrice = Platform.isAndroid
          ? iapService.getProductPrice(id)
          : pricingService.getFormattedPrice(id);

      final double rawPrice = Platform.isAndroid
          ? iapService.getProductRawPrice(id)
          : pricingService.getFinalPrice(id);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio(
              activeColor: kPrimary,
              value: name,
              groupValue: bookingController.package.value,
              onChanged: (val) {
                selectedPackage = val.toString();
                bookingController.price.value = rawPrice.toInt();
                bookingController.duration.value = duration;
                bookingController.package.value = id;
                selectedPrice = rawPrice.toInt();
                setState(() {});
              }),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/$image",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayPrice,
                    textAlign: TextAlign.center,
                    style: boldTextStyle(
                      color: white,
                      size: 30,
                    ),
                  ),
                  10.height,
                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: secondaryTextStyle(size: 12, color: white),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
