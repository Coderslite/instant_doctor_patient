import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:instant_doctor/services/WalletService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';

import '../services/UserService.dart';
import 'OrderController.dart';

class PaymentController extends GetxController {
  var amount = '0'.obs;
  var isLoading = false.obs;
  final walletService = Get.find<WalletService>();
  final userService = Get.find<UserService>();

  Future<void> handleTopUp(BuildContext context,
      {required String token}) async {
    try {
      final userController = Get.find<UserController>();
      await walletService.topUp(
        userId: userController.userId.value,
        amount: int.parse(amount.string),
      );
      successSnackBar(title: "Top up successful");
      amount.value = '0';

      const Root().launch(context);
    } catch (err) {
      toast(err.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> makePayment(
      {required String email,
      required BuildContext context,
      required int amount,
      required String paymentFor,
      String? productId}) async {
    bool response = false;
    final orderController = Get.find<OrderController>();
    final bookingController = Get.find<BookingController>();

    await PaystackFlutter().pay(
      context: context,
      secretKey:
          'sk_test_5a009cc631c4d56e7c8b7dccdfdf471ebc4a8cba', // Your Paystack secret key gotten from your Paystack dashboard.
      amount: amount.toDouble() *
          100, // The amount to be charged in the smallest currency unit. If amount is 600, multiply by 100(600*100)
      email: email, // The customer's email address.
      callbackUrl:
          'https://callback.com', // The URL to which Paystack will redirect the user after the transaction.
      showProgressBar:
          true, // If true, it shows progress bar to inform user an action is in progress when getting checkout link from Paystack.
      paymentOptions: [
        PaymentOption.card,
        PaymentOption.bankTransfer,
        PaymentOption.mobileMoney
      ],
      currency: Currency.NGN,
      metaData: {
        "payment_for": paymentFor,
        "product_id": productId,
        "product_price": amount.toDouble() * 100,
      },
      onSuccess: (paystackCallback) async {
        if (paymentFor == 'Appointment') {
          bookingController.updateAppointmentAfterPayment(productId.validate());
        }
        if (paymentFor == 'Order') {
          orderController.orderNow();
        }
      }, // A callback function to be called when the payment is successful.
      onCancelled: (paystackCallback) {
        if (paymentFor == 'Appointment') {
          bookingController.isLoading.value = false;
          errorSnackBar(title: "Payment not successful");
        }
        if (paymentFor == 'Order') {
          orderController.isLoading.value = false;
          errorSnackBar(title: "Payment not successful");
        }
      }, // A callback function to be called when the payment is canceled.
    );
    return response;
  }
}
