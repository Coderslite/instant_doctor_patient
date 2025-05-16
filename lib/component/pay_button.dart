import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/screens/wallet/SolanaWallet.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/GetUserId.dart';

payButton(context, {required int price, required String appointmentId}) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: gray.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                onTap: () async {
                  final paymentController = Get.find<PaymentController>();
                  var userInfo = await userService.getProfileById(
                      userId: userController.userId.value);
                  await paymentController.makePayment(
                      email: userInfo.email.validate(),
                      context: context,
                      amount: price.validate(),
                      paymentFor: 'Appointment',
                      productId: appointmentId);
                },
                width: double.infinity,
                child: SizedBox(
                  height: 40,
                  child: Image.asset(
                    "assets/images/paystack.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              10.height,
              AppButton(
                onTap: () {
                  SolanaScreen().launch(context);
                },
                width: double.infinity,
                child: SizedBox(
                  height: 40,
                  child: Image.asset(
                    "assets/images/solana.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
