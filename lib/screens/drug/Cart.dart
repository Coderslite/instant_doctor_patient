import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/drug/ChangePickup.dart';
import 'package:instant_doctor/screens/profile/personal/PersonalProfile.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/backButton.dart';
import '../../component/eachCart.dart';
import '../../controllers/LocationController.dart';
import '../../controllers/OrderController.dart';
import '../../controllers/UserController.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final orderController = Get.find<OrderController>();
  final locationController = Get.find<LocationController>();
  final userController = Get.find<UserController>(); // Add this line

  @override
  void initState() {
    super.initState();
    _calculateDeliveryFee();
  }

  Future<void> _calculateDeliveryFee() async {
    var res = await orderController.getTotalDeliveryFee();
    orderController.deliveryFee.value = res.toInt();
    setState(() {});
  }

  Future<void> _validateAndProceed() async {
    if (userController.phone.value.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Phone Number Required", style: boldTextStyle(size: 18)),
          backgroundColor: context.cardColor,
          content: Text(
            "Please update your phone number in your profile before proceeding with the order.",
            style: primaryTextStyle(
              size: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: primaryTextStyle(color: kPrimary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to profile screen
                PersonalProfileScreen().launch(context);
              },
              child:
                  Text("Update Profile", style: boldTextStyle(color: kPrimary)),
            ),
          ],
        ),
      );
      return;
    }

    if (locationController.latitude.value == 0 ||
        locationController.longitude.value == 0) {
      toast("Please select a delivery address");
      return;
    }

    showConfirmDialogCustom(
      context,
      title: "Do you want to proceed with checkout?",
      onAccept: (v) async {
        await orderController.makeOrder();
      },
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Subtotal:", orderController.subtotal.toInt()),
          8.height,
          Obx(() => _buildSummaryRow(
              "Delivery Fee:", orderController.deliveryFee.value)),
          Divider(height: 20, thickness: 1),
          Obx(() => _buildSummaryRow(
              "Total:",
              (orderController.subtotal + orderController.deliveryFee.value)
                  .toInt(),
              isTotal: true)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal ? boldTextStyle(size: 16) : primaryTextStyle()),
        Text(formatAmount(amount),
            style: isTotal
                ? boldTextStyle(size: 16, color: kPrimary)
                : primaryTextStyle()),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    orderController.isLoading.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text("My Cart", style: boldTextStyle(size: 20)),
                  Obx(() => Badge(
                        label: Text("${orderController.cart.length}"),
                        child: Icon(Icons.shopping_cart_outlined, size: 28),
                      )),
                ],
              ),
            ),

            // Address Section
            Obx(() {
              var address = locationController.address.value;
              return Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: address.isEmpty ? Colors.red : kPrimary),
                    12.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.isEmpty ? "Delivery Address" : "Deliver to",
                            style: secondaryTextStyle(size: 12),
                          ),
                          4.height,
                          Text(
                            address.isEmpty
                                ? "Select delivery address"
                                : address,
                            style: boldTextStyle(
                              color: address.isEmpty ? Colors.red : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ).onTap(() => ChangePickup().launch(context)),
              );
            }),

            // Cart Items
            Expanded(
              child: Obx(() {
                if (orderController.cart.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 60, color: Colors.grey[300]),
                      16.height,
                      Text("Your cart is empty",
                          style: boldTextStyle(size: 18)),
                      8.height,
                      Text("Add items to get started",
                          style: secondaryTextStyle()),
                    ],
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orderController.cart.length,
                  separatorBuilder: (_, __) => Divider(height: 16),
                  itemBuilder: (context, index) {
                    return Eachcart(drug: orderController.cart[index]);
                  },
                );
              }),
            ),

            // Order Summary
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Obx(() {
                    if (orderController.isCalculating.value) {
                      return LinearProgressIndicator(
                        color: kPrimary,
                      );
                    }
                    return _buildOrderSummary();
                  }),
                  16.height,
                  Obx(() {
                    bool isDisabled = orderController.isLoading.value ||
                        orderController.isCalculating.value ||
                        locationController.latitude.value == 0 ||
                        locationController.longitude.value == 0;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isDisabled ? null : _validateAndProceed,
                        child: orderController.isLoading.value
                            ? Loader()
                            : Text(
                                "Checkout - ${formatAmount((orderController.subtotal + orderController.deliveryFee.value).toInt())}",
                                style: boldTextStyle(color: white, size: 16),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
