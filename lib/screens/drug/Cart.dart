import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/drug/ChangePickup.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/backButton.dart';
import '../../component/eachCart.dart';
import '../../controllers/LocationController.dart';
import '../../controllers/OrderController.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final orderController = Get.find<OrderController>();
  final locationController = Get.find<LocationController>();
  @override
  void initState() {
    super.initState();
    _calculateDeliveryFee();
  }

  Future<void> _calculateDeliveryFee() async {
    var res = await orderController.getTotalDeliveryFee();
    orderController.deliveryFee.value = res.toInt();
    setState(() {}); // Update UI after calculating delivery fee
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
                  Text("My Cart", style: boldTextStyle(size: 18)),
                  Obx(
                    () => Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.shopping_cart_checkout),
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
                  ),
                ],
              ),
              10.height,
              Obx(() {
                var address = locationController.address.value;
                return Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: address.isEmpty ? errorColor : kPrimary,
                    ),
                    10.width,
                    Expanded(
                        child: Text(
                      address.isEmpty ? "Select Home address" : address,
                      style: boldTextStyle(
                          size: 14,
                          color: address.isEmpty ? errorColor : kPrimary),
                    )),
                  ],
                ).onTap(() {
                  ChangePickup().launch(context);
                });
              }),
              10.height,
              Expanded(
                child: Obx(
                  () => orderController.cart.isEmpty
                      ? Text("No cart available",
                              style: boldTextStyle(size: 15))
                          .center()
                      : ListView.builder(
                          itemCount: orderController.cart.length,
                          itemBuilder: (context, index) {
                            return Eachcart(
                              drug: orderController.cart[index],
                            );
                          },
                        ),
                ),
              ),
              10.height,
              Obx(() {
                var isCalculating = orderController.isCalculating.value;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subtotal:", style: boldTextStyle()),
                          Obx(() => Text(
                                formatAmount(orderController.subtotal.toInt()),
                                textAlign: TextAlign.end,
                                style: boldTextStyle(),
                              )),
                        ],
                      ),
                      10.height,
                      isCalculating
                          ? Loader()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Delivery Fee:", style: boldTextStyle()),
                                Text(
                                  formatAmount(
                                      orderController.deliveryFee.value),
                                  textAlign: TextAlign.end,
                                  style: boldTextStyle(),
                                ),
                              ],
                            ),
                    ],
                  ),
                );
              }),
              10.height,
              Obx(
                () {
                  double totalAmount = orderController.subtotal +
                      orderController.deliveryFee.value;
                  return orderController.isLoading.value
                      ? Loader()
                      : AppButton(
                          enabled: !orderController.isCalculating.value &&
                              locationController.latitude.value != 0 &&
                              locationController.longitude.value != 0,
                          disabledColor: grey,
                          disabledTextColor: white,
                          onTap: () {
                            showConfirmDialogCustom(context,
                                title:
                                    "Do you want to proceed with the checkout",
                                onAccept: (v) async {
                              await orderController.makeOrder();
                            });
                          },
                          color: kPrimary,
                          width: double.infinity,
                          text:
                              "Checkout for NGN ${formatAmount(totalAmount.toInt())}",
                          textColor: white,
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
