// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/screens/doctors/AllDoctors.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';

class AppointmentPricingScreen extends StatefulWidget {
  final bool fromDocScreen;
  const AppointmentPricingScreen({super.key, required this.fromDocScreen});

  @override
  State<AppointmentPricingScreen> createState() =>
      _AppointmentPricingScreenState();
}

class _AppointmentPricingScreenState extends State<AppointmentPricingScreen> {
  BookingController bookingController = Get.put(BookingController());
  String selectedPackage = '';
  bool isChecked = false;
  int? selectedPrice;
  @override
  Widget build(BuildContext context) {
    List<Widget> prices = [
      priceOptions(
          name: "Basic",
          image: "basic.png",
          price: 5000,
          duration: 30 * 60,
          desc: "Chat with Doctor for 30 minutes"),
      priceOptions(
          name: "Standard",
          image: "standard.png",
          price: 9500,
          duration: (30 * 2) * 60,
          desc: "Chat with Doctor for 1 hour"),
      priceOptions(
          name: "Special",
          image: "special.png",
          price: 14000,
          duration: (30 * 3) * 60,
          desc: "Chat with Doctor for 1 hour with 30 minutes added."),
    ];
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
                  const BackButton(),
                  Text(
                    "Pricing",
                    style: boldTextStyle(size: 20, color: kPrimary),
                  ),
                  const Text("      "),
                ],
              ),
              20.height,
              Expanded(
                child: GridView.count(
                  mainAxisSpacing: 20,
                  physics: BouncingScrollPhysics(),
                  crossAxisCount: 1,
                  children: prices,
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
              AppButton(
                onTap: () {
                  widget.fromDocScreen
                      ? finish(context, selectedPrice)
                      : const AllDoctorsScreen().launch(context);
                },
                width: double.infinity,
                color: kPrimary,
                text: "Proceed",
                enabled: isChecked && selectedPackage.isNotEmpty,
                textColor: whiteColor,
                disabledColor: dimGray,
                disabledTextColor: white,
              )
            ],
          ),
        ),
      ),
    );
  }

  Obx priceOptions(
      {required String name,
      required String image,
      required int price,
      required int duration,
      required String desc}) {
    return Obx(() {
      var x = bookingController.package.value;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio(
              activeColor: kPrimary,
              value: name,
              groupValue: bookingController.package.value,
              onChanged: (val) {
                selectedPackage = val.toString();
                bookingController.price.value = price;
                bookingController.duration.value = duration;
                bookingController.package.value = name;

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
                    formatAmount(price),
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
