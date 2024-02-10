import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:instant_doctor/services/WalletService.dart';
import 'package:nb_utils/nb_utils.dart';

class PaymentController extends GetxController {
  var currency = 'NGN'.obs;
  var amount = '0'.obs;
  var isLoading = false.obs;
  WalletService walletService = WalletService();
  UserController userController = Get.put(UserController());
  handleTopUp(BuildContext context) async {
    try {
      await walletService.topUp(
        userId: userController.userId.value,
        amount: int.parse(amount.string),
      );
      toast("Top up successful");
      amount.value = '0';

      Root().launch(context);
    } catch (err) {
      toast(err.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
