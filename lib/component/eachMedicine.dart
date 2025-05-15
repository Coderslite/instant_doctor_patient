import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/controllers/OrderController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/drug/Cart.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../constant/constants.dart';
import '../models/DrugModel.dart';
import '../screens/drug/MedicineDetails.dart';

Padding eachMedicine(BuildContext context,
    {required DrugModel drug, required String pharmacyName}) {
  final orderController = Get.find<OrderController>();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    child: Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: drug.images!.first,
                    fit: BoxFit.cover,
                  ),
                ),
              ).onTap(() {
                MedicineDetails(
                  pharmacyName: pharmacyName,
                  drug: drug,
                ).launch(context);
              }),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  decoration: BoxDecoration(
                    color: fireBrick,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    "${drug.discount} % off",
                    style: boldTextStyle(size: 10, color: white),
                  ),
                ),
              ).visible(drug.discount.validate() > 0),
            ],
          ),
          5.height,
          Text(
            drug.name.validate(),
            maxLines: 1,
            style: boldTextStyle(
              size: 13,
              weight: FontWeight.w900,
            ),
          ),
          Text(
            formatAmount(getDiscountPrice(
                price: drug.amount.validate(),
                discount: drug.discount.validate())),
            style: secondaryTextStyle(
              size: 10,
              decoration: TextDecoration.lineThrough,
              decorationColor:
                  settingsController.isDarkMode.value ? white : black,
            ),
          ).visible(drug.discount.validate() > 0),
          Text(
            formatAmount(drug.amount.validate().toInt()),
            style: boldTextStyle(
              size: 16,
            ),
          ),
          5.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: drug.remaining.validate() < 1
                        ? grey
                        : orderController.cart
                                .where((dru) => dru.id == drug.id)
                                .isNotEmpty
                            ? orangeRed
                            : kPrimary,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  drug.remaining.validate() < 1
                      ? "Out of stock"
                      : orderController.cart
                              .where((dru) => dru.id == drug.id)
                              .isNotEmpty
                          ? "Checkout"
                          : "Add to Cart",
                  style: boldTextStyle(color: white, size: 10),
                ),
              ).onTap(() {
                if (drug.remaining.validate() < 1) {
                  errorSnackBar(title: "Product is out of stock");
                  return;
                }
                if (orderController.cart
                    .where((dru) => dru.id == drug.id)
                    .isNotEmpty) {
                  CartScreen().launch(context);
                  return;
                }
                orderController.handleAddToCart(drug: drug);
              }),
              Icon(
                Icons.favorite_border,
                color: kPrimary,
              )
            ],
          )
        ],
      ),
    ),
  );
}
