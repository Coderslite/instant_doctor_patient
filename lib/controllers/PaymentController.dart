import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/controllers/LapResultController.dart';
import 'package:instant_doctor/services/AppointmentService.dart';
import 'package:instant_doctor/services/WalletService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paystack_flutter_sdk/paystack_flutter_sdk.dart';

import '../services/UserService.dart';
import 'OrderController.dart';
import 'package:http/http.dart' as http;

class PaymentController extends GetxController {
  var amount = '0'.obs;
  var isLoading = false.obs;
  final walletService = Get.find<WalletService>();
  final userService = Get.find<UserService>();
  final _paystack = Paystack();

  double surChargeOrder(double amount, double deliveryFee) {
    const double surchargeRate = 0.02; // 2% user surcharge
    double paystackCharge = getPaystackCharge(amount);

    final double userSurcharge = (amount - deliveryFee) * surchargeRate;
    return userSurcharge + paystackCharge;
  }

  double surChargeAppointment(double amount) {
    double paystackCharge = getPaystackCharge(amount);

    return paystackCharge;
  }

  double surChargeLabresult(double amount) {
    double paystackCharge = getPaystackCharge(amount);
    return paystackCharge;
  }

  int getTransferFee(double amount) {
    if (amount <= 5000) {
      return 10;
    } else if (amount <= 50000) {
      return 25;
    } else {
      return 50;
    }
  }

  double calculatePlatformEarningForPharmacy(
      double transactionAmount, double deliveryFee) {
    const double platformFeeRate = 0.05; // 5% platform fee
    const double surchargeRate = 0.02; // 2% user surcharge
    double paystackCharge = getPaystackCharge(transactionAmount);
    final double platformFee =
        (transactionAmount - deliveryFee) * platformFeeRate;
    final double userSurcharge =
        (transactionAmount - deliveryFee) * surchargeRate;
    final double platformEarnings = platformFee + userSurcharge;

    return (platformEarnings + paystackCharge) * 100;
  }

  double calculatePlatformEarningForDoctors(double transactionAmount) {
    const double platformFeeRate = 0.30; // 5% platform fee
    double paystackCharge = getPaystackCharge(transactionAmount);

    final double platformFee = transactionAmount * platformFeeRate;
    final double platformEarnings = platformFee;

    return (platformEarnings + paystackCharge) * 100;
  }

  double getPaystackCharge(double amount) {
    double percentageFee = amount * 0.015;
    double additionalFee = amount >= 2500 ? 100 : 0;
    double totalFee = percentageFee + additionalFee;

    // Cap the fee at ₦2000
    if (totalFee > 2000) {
      return 2000;
    }

    return totalFee;
  }

  initialize() async {
    try {
      final response = await _paystack.initialize(
          PaystackKey.publicKey, true); // allow logging
      if (response) {
        log("Sucessfully initialised the SDK");
      } else {
        log("Unable to initialise the SDK");
      }
    } on PlatformException catch (e) {
      log(e.message!);
    }
  }

  Future makePayment({
    required String email,
    required BuildContext context,
    required int amount,
    required String paymentFor,
    String? productId,
  }) async {
    String reference = "";
    try {
      final orderController = Get.find<OrderController>();
      final bookingController = Get.find<BookingController>();
      var labResultController = Get.find<LabResultController>();
      isLoading.value = true;
      await initialize();

      // Calculate platform earnings (in kobo)
      int platformEarning = paymentFor == PaymentFor.order
          ? calculatePlatformEarningForPharmacy(amount.toDouble(),
                  orderController.deliveryFee.value.toDouble())
              .toInt()
          : paymentFor == PaymentFor.appointment
              ? calculatePlatformEarningForDoctors(amount.toDouble()).toInt()
              : amount; // For lab results, no platform earning deduction

      // Calculate surcharge (in Naira)
      var surcharge = paymentFor == PaymentFor.order
          ? surChargeOrder(
              amount.toDouble(), orderController.deliveryFee.value.toDouble())
          : paymentFor == PaymentFor.appointment
              ? surChargeAppointment(amount.toDouble())
              : surChargeLabresult(amount.toDouble());
      var transferFee = getTransferFee(
        amount.toDouble(),
      );
      var recipientEarning =
          ((amount + surcharge + transferFee) * 100) - platformEarning;

      // Paystack processes amounts in kobo
      var accessCode = await getAccessCode(
          email,
          ((amount + surcharge) * 100).toString(),
          paymentFor,
          recipientEarning.toInt());
      final response = await _paystack.launch(accessCode);

      if (response.status == "success") {
        reference = response.reference;
        log(reference);
        if (paymentFor == PaymentFor.appointment) {
          // Convert platformEarning from kobo to Naira for calculation
          double doctorEarning =
              (amount + surcharge) - (platformEarning / 100.0);
          bookingController.updateAppointmentAfterPayment(productId.validate());
          AppointmentService().updateDoctorEarning(
            appointmentId: productId.validate(),
            doctorEarning: doctorEarning.toInt(),
          );
        }
        if (paymentFor == PaymentFor.order) {
          // Convert platformEarning from kobo to Naira for calculation
          double pharmacyEarning =
              (amount + surcharge) - (platformEarning / 100.0);
          orderController.orderNow(
            pharmacyEarning: pharmacyEarning.toInt(),
          );
        }
        if (paymentFor == PaymentFor.labResult) {
          labResultController.handleUploadFiles(context);
        }
      } else if (response.status == "cancelled") {
        if (paymentFor == 'Appointment') {
          bookingController.isLoading.value = false;
          errorSnackBar(title: "Payment not successful");
        }
        if (paymentFor == 'Order') {
          orderController.isLoading.value = false;
          errorSnackBar(title: "Payment not successful");
        }
      } else {
        log(response.message);
      }
    } on PlatformException catch (e) {
      log(e.message!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getAccessCode(String email, String amount, String paymentFor,
      int recipientEarning) async {
    var res = await http.post(
        Uri.parse("https://api.paystack.co/transaction/initialize"),
        headers: {
          "Authorization": "Bearer ${PaystackKey.secretKey}",
          // "Content-Type": "application/json",
        },
        body: {
          "email": email,
          "amount": amount,
          "subaccount": paymentFor == PaymentFor.order
              ? PaystackKey.pharmcySubAccount
              : paymentFor == PaymentFor.appointment
                  ? PaystackKey.doctorSubAccount
                  : '',
          "bearer": "subaccount",
          "transaction_charge": (recipientEarning).toString(),
        });
    var responseData = jsonDecode(res.body);
    print(responseData);
    if (responseData['status'] == true) {
      return responseData['data']['access_code'];
    }
    return '';
  }
}
