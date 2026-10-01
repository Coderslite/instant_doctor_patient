import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
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
  final pricingService = Get.find<PricingService>();

  String selectedPackageId = '';
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
                child: Obx(() {
                  final packages = pricingService.appointmentPackages;

                  if (pricingService.isLoading.value && packages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (packages.isEmpty) {
                    return Center(
                      child: Text(
                        "No pricing packages available",
                        style: secondaryTextStyle(size: 16),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: packages.length,
                    separatorBuilder: (_, __) => 20.height,
                    itemBuilder: (context, index) {
                      final pkg = packages[index];
                      return _priceOption(pkg);
                    },
                  );
                }),
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
                enabled: isChecked && selectedPackageId.isNotEmpty,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceOption(dynamic pkg) {
    final String pkgId = pkg.id ?? '';
    final String pkgName = pkg.name ?? 'Package';
    final String pkgDesc = pkg.desc ?? '';
    final int pkgDuration = pkg.duration ?? 0;

    return Obx(() {
      final String displayPrice = pricingService.getFormattedPrice(pkgId);
      final double rawPrice = pricingService.getFinalPrice(pkgId);

      // Pick an image based on index position
      final int idx = pricingService.appointmentPackages.indexOf(pkg);
      final images = ["basic.png", "standard.png", "special.png"];
      final image = images[idx % images.length];

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio(
              activeColor: kPrimary,
              value: pkgId,
              groupValue: selectedPackageId,
              onChanged: (val) {
                selectedPackageId = val.toString();
                bookingController.price.value = rawPrice.toInt();
                bookingController.duration.value = pkgDuration;
                bookingController.package.value = pricingService.getPackageType(pkgId);
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
                    pkgName,
                    textAlign: TextAlign.center,
                    style: boldTextStyle(
                      color: white,
                      size: 18,
                    ),
                  ),
                  6.height,
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
                    pkgDesc,
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
