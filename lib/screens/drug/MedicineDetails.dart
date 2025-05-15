import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/DrugModel.dart';
import 'package:instant_doctor/screens/drug/Cart.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../component/backButton.dart';
import '../../constant/constants.dart';
import '../../controllers/OrderController.dart';
import '../../main.dart';

class MedicineDetails extends StatefulWidget {
  final DrugModel drug;
  final String pharmacyName;
  const MedicineDetails(
      {super.key, required this.drug, required this.pharmacyName});

  @override
  State<MedicineDetails> createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends State<MedicineDetails> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();
  final orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    _draggableController.addListener(() {
      if (_draggableController.size >= 0.7) {
        _isExpanded.value = true;
      } else {
        _isExpanded.value = false;
      }
    });
  }

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  var controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 30),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        itemCount: widget.drug.images!.length,
                        controller: controller,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: SizedBox(
                              // height: MediaQuery.of(context).size.height / 1.4,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: widget.drug.images![index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height / 3.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmoothPageIndicator(
                          controller: controller,
                          count: widget.drug.images!.length,
                          effect: SwapEffect(
                            activeDotColor: kPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        backButton(context),
                        Text(
                          widget.drug.name.validate(),
                          style: boldTextStyle(
                            size: 18,
                            color: black,
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
                                    style: secondaryTextStyle(
                                        size: 12, color: white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).onTap(() {
                          CartScreen().launch(context);
                        }),
                      ],
                    ).paddingSymmetric(
                      horizontal: 15,
                      vertical: 50,
                    ),
                  ),
                  DraggableScrollableSheet(
                    controller: _draggableController,
                    maxChildSize: 0.8,
                    initialChildSize: 0.3,
                    minChildSize: 0.3,
                    builder: (context, controller) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView(
                                controller: controller,
                                children: [
                                  Row(
                                    children: [
                                      ValueListenableBuilder<bool>(
                                        valueListenable: _isExpanded,
                                        builder: (context, isExpanded, child) {
                                          return Row(
                                            children: [
                                              Text(
                                                isExpanded
                                                    ? "Drag Down"
                                                    : "Drag Up",
                                                style: secondaryTextStyle(
                                                    size: 12),
                                              ),
                                              5.width,
                                              Icon(
                                                isExpanded
                                                    ? Icons.arrow_downward
                                                    : Icons.arrow_upward,
                                                color: grey.withOpacity(0.4),
                                                size: 14,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  10.height,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.drug.name.validate(),
                                        style: boldTextStyle(size: 18),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: fireBrick,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                            ),
                                            child: Text(
                                              "${widget.drug.discount} % off",
                                              style: boldTextStyle(
                                                  size: 10, color: white),
                                            ),
                                          ).visible(
                                              widget.drug.discount.validate() >
                                                  0),
                                          Text(
                                            formatAmount(widget.drug.amount
                                                .validate()
                                                .toInt()),
                                            style: boldTextStyle(size: 28),
                                          ),
                                          Text(
                                            formatAmount(getDiscountPrice(
                                                price: widget.drug.amount
                                                    .validate(),
                                                discount: widget.drug.discount
                                                    .validate())),
                                            style: secondaryTextStyle(
                                              size: 14,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor:
                                                  settingsController
                                                          .isDarkMode.value
                                                      ? white
                                                      : black,
                                            ),
                                          ).visible(
                                              widget.drug.discount.validate() >
                                                  0),
                                        ],
                                      ),
                                    ],
                                  ),
                                  30.height,
                                  Text(
                                    widget.drug.description.validate(),
                                    style: boldTextStyle(
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Obx(() {
              var isContained = orderController.cart
                  .where((dru) => dru.id == widget.drug.id)
                  .isNotEmpty;
              return AppButton(
                width: double.infinity,
                color: widget.drug.remaining.validate() < 1
                    ? grey
                    : isContained
                        ? orangeRed
                        : kPrimary,
                onTap: () {
                  if (widget.drug.remaining.validate() < 1) {
                    errorSnackBar(title: "Product is out of stock");
                    return;
                  }
                  if (!isContained) {
                    orderController.handleAddToCart(drug: widget.drug);
                    return;
                  }
                  CartScreen().launch(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.drug.remaining.validate() < 1
                          ? "Out of stock"
                          : isContained
                              ? "Proceed to checkout"
                              : "Add to Cart",
                      style: boldTextStyle(color: white),
                    ),
                    5.width,
                    Icon(
                      Icons.add_shopping_cart,
                      color: white,
                    )
                  ],
                ),
              ).paddingAll(10);
            })
          ],
        ),
      ),
    );
  }
}
