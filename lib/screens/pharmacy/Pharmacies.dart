import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/PharmacyModel.dart';
import 'package:instant_doctor/screens/drug/Cart.dart';
import 'package:instant_doctor/screens/drug/MedicineHome.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/eachPharmacy.dart';
import '../../controllers/LocationController.dart';
import '../../controllers/OrderController.dart';
import '../../services/PharmacyService.dart';
import '../drug/ChangePickup.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final pharmacyService = Get.find<PharmacyService>();
  final locationController = Get.find<LocationController>();
  final orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Pharmacies",
                    style: boldTextStyle(
                      size: 14,
                    ),
                  ),
                  Obx(
                    () => Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimary,
                          ),
                          child: Icon(
                            Icons.shopping_cart_checkout,
                            color: white,
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Badge(
                            label: Text(
                              "${orderController.cart.length}",
                              style: secondaryTextStyle(size: 12, color: white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).onTap(() {
                    CartScreen().launch(context);
                  }),
                ],
              ),
              10.height,
              Expanded(
                child: Obx(
                  () => locationController.address.value.isEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: fireBrick,
                              size: 70,
                            ),
                            10.height,
                            Text(
                              "Location update request",
                              style: boldTextStyle(
                                size: 18,
                              ),
                            ),
                            10.height,
                            Text(
                              "please kindly update your locatiom to proceed",
                              textAlign: TextAlign.center,
                              style: primaryTextStyle(size: 14),
                            ),
                            20.height,
                            AppButton(
                              onTap: () {
                                Navigator.pop(Get.context!);
                                ChangePickup().launch(Get.context!);
                              },
                              text: "Update Location",
                              textColor: white,
                              color: kPrimary,
                            )
                          ],
                        ).center()
                      : StreamBuilder<List<PharmacyModel>>(
                          stream: pharmacyService.getPharmacies(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data!;
                              return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return eachPharmacy(
                                    context,
                                    data[index],
                                  ).onTap(() {
                                    MedicineHome(
                                      pharmacyId: data[index].id.validate(),
                                      pharmacyName: data[index].name.validate(),
                                    ).launch(context);
                                  });
                                },
                              );
                            }
                            return Loader();
                          }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
