// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/controllers/LabResultController.dart';
import 'package:instant_doctor/controllers/OrderController.dart';
import 'package:instant_doctor/services/AppointmentService.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:instant_doctor/services/StripeService.dart';
import 'package:instant_doctor/services/WalletService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/UserService.dart';

class PaymentController extends GetxController {
  var amount = '0'.obs;
  var isLoading = false.obs;
  final walletService = Get.find<WalletService>();
  final userService = Get.find<UserService>();
  final pricingService = Get.find<PricingService>();
  final stripeService = Get.find<StripeService>();

  bool get _isUsd => pricingService.userCurrency.value == 'USD';

  double getGatewayCharge(double amount) {
    double fee = amount * 0.014;
    double cap = _isUsd ? 2.0 : 2000.0;
    return 0; // Currently waived; re-enable by returning fee > cap ? cap : fee
  }

  int getTransferFee(double amount) {
    return 0; // Currently waived
  }

// ── Order surcharge (2% user surcharge + gateway fee) ────────────────────────
  double surChargeOrder(double amount, double deliveryFee) {
    const double surchargeRate = 0.02;
    double gatewayFee = getGatewayCharge(amount);
    double userSurcharge = (amount - deliveryFee) * surchargeRate;
    return userSurcharge + gatewayFee;
  }

// ── Appointment surcharge (gateway fee only) ─────────────────────────────────
  double surChargeAppointment(double amount) => getGatewayCharge(amount);

// ── Lab result surcharge (gateway fee only) ──────────────────────────────────
  double surChargeLabresult(double amount) => getGatewayCharge(amount);

// ── Platform earnings for pharmacy (kobo / cents) ────────────────────────────
  double calculatePlatformEarningForPharmacy(
      double transactionAmount, double deliveryFee) {
    const double platformFeeRate = 0.05;
    const double surchargeRate = 0.02;
    double gatewayFee = getGatewayCharge(transactionAmount);
    double platformFee = (transactionAmount - deliveryFee) * platformFeeRate;
    double userSurcharge = (transactionAmount - deliveryFee) * surchargeRate;
    return (platformFee + userSurcharge + gatewayFee) * 100;
  }

// ── Platform earnings for doctors (kobo / cents) ─────────────────────────────
  double calculatePlatformEarningForDoctors(double transactionAmount) {
    const double platformFeeRate = 0.40;
    double gatewayFee = getGatewayCharge(transactionAmount);
    double platformFee = transactionAmount * platformFeeRate;
    return (platformFee + gatewayFee) * 100;
  }

  // Flutterwave transaction fee (1.4% capped at ₦2000)
  double getFlutterwaveCharge(double amount) {
    double percentageFee = amount * 0.014;
    double totalFee = percentageFee;
    if (totalFee > 2000) {
      return 2000; // Cap at ₦2000
    }
    return totalFee;
  }

  Future<void> handlePaymentSuccess({
    required BuildContext context,
    required String paymentFor,
    required int amount,
    String? productId,
    String? currency,
    bool? isTrial,
    double surcharge = 0,
  }) async {
    final orderController = Get.find<OrderController>();
    final bookingController = Get.find<BookingController>();
    final labResultController = Get.find<LabResultController>();

    if (paymentFor == PaymentFor.appointment) {
      int platformEarning =
          calculatePlatformEarningForDoctors(amount.toDouble()).toInt();
      double doctorEarning = (amount + surcharge) - (platformEarning / 100.0);

      await bookingController.updateAppointmentAfterPayment(
        context,
        productId.validate(),
        isTrial.validate(),
        currency: currency,
      );

      await AppointmentService().updateDoctorEarning(
        appointmentId: productId.validate(),
        doctorEarning: doctorEarning.toInt(),
      );
    } else if (paymentFor == PaymentFor.order) {
      await orderController.orderNow(context);
    } else if (paymentFor == PaymentFor.labResult) {
      await labResultController.handleUploadFiles(context);
    }

    successSnackBar(context: context, title: "Payment Successful");
  }

  // ── Stripe Payment (replaces makeInAppPurchase on Android) ─────────────────
  Future<void> makeStripePayment({
    required BuildContext context,
    required double amount,
    required String paymentFor,
    String? productId,
    String? currency,
    bool? isTrial,
    String? customerEmail,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;

    final bookingController = Get.find<BookingController>();
    final orderController = Get.find<OrderController>();
    final labResultController = Get.find<LabResultController>();

    try {
      final String resolvedCurrency =
          currency ?? pricingService.userCurrency.value;

      // Convert to smallest unit (cents, pence, kobo, etc.)
      final int amountInMinorUnits =
          StripeService.toMinorUnits(amount, resolvedCurrency);

      final bool success = await stripeService.makeStripePayment(
        context: context,
        amountInMinorUnits: amountInMinorUnits,
        currency: resolvedCurrency,
        customerEmail: customerEmail,
        description: _descriptionFor(paymentFor),
      );

      if (success) {
        await handlePaymentSuccess(
          context: context,
          paymentFor: paymentFor,
          amount: amount.toInt(),
          productId: productId,
          currency: resolvedCurrency,
          isTrial: isTrial,
        );
      } else {
        errorSnackBar(context: context, title: "Payment Cancelled");
        _resetLoadingStates(paymentFor, bookingController, orderController,
            labResultController);
      }
    } catch (e) {
      log("❌ Stripe Payment Error: $e");
      errorSnackBar(context: context, title: "Payment Error");
      _resetLoadingStates(
          paymentFor, bookingController, orderController, labResultController);
    } finally {
      isLoading.value = false;
    }
  }

  String _descriptionFor(String paymentFor) {
    if (paymentFor == PaymentFor.appointment) {
      return 'Medical Consultation — Instant Doctor';
    } else if (paymentFor == PaymentFor.labResult) {
      return 'Lab Result Interpretation — Instant Doctor';
    } else if (paymentFor == PaymentFor.order) {
      return 'Medication Order — Instant Doctor';
    }
    return 'Payment — Instant Doctor';
  }

  // ── Flutterwave (kept for African currencies: NGN, GHS, KES, etc.) ─────────
  Future makeFlutterwavePayment({
    required String email,
    required BuildContext context,
    required int amount,
    required String paymentFor,
    String? productId,
    String? currency,
    bool? isTrial,
  }) async {
    final orderController = Get.find<OrderController>();
    final bookingController = Get.find<BookingController>();
    final labResultController = Get.find<LabResultController>();
    isLoading.value = true;

    try {
      var user =
          await userService.getProfileById(userId: userController.userId.value);
      var name = "${user.firstName.validate()} ${user.lastName.validate()}";
      var phone = user.phoneNumber.validate();

      var surcharge = paymentFor == PaymentFor.order
          ? surChargeOrder(
              amount.toDouble(), orderController.deliveryFee.value.toDouble())
          : paymentFor == PaymentFor.appointment
              ? surChargeAppointment(amount.toDouble())
              : surChargeLabresult(amount.toDouble());
      var transferFee = getTransferFee(amount.toDouble());

      double totalAmount = amount + surcharge + transferFee;

      final Customer customer =
          Customer(name: name, phoneNumber: phone, email: email);
      final Flutterwave flutterwave = Flutterwave(
        publicKey: dotenv.env['FLUTTERWAVE_PUBLIC_KEY'] ?? "",
        txRef: "$name${DateTime.now().millisecondsSinceEpoch}",
        amount: totalAmount.toString(),
        customer: customer,
        paymentOptions: "ussd, card, bank transfer",
        customization: Customization(title: "Instant Doctor"),
        redirectUrl: "https://instantdoctor.co",
        isTestMode: false,
        currency: currency ?? pricingService.userCurrency.value,
      );

      final ChargeResponse response = await flutterwave.charge(context);

      if (response.success == true) {
        await handlePaymentSuccess(
          context: context,
          paymentFor: paymentFor,
          amount: amount,
          productId: productId,
          currency: currency ?? pricingService.userCurrency.value,
          isTrial: isTrial,
          surcharge: surcharge,
        );
      } else {
        errorSnackBar(context: context, title: "Payment Cancelled");
        if (paymentFor == PaymentFor.appointment) {
          bookingController.isLoading.value = false;
        } else if (paymentFor == PaymentFor.order) {
          orderController.isLoading.value = false;
        } else if (paymentFor == PaymentFor.labResult) {
          labResultController.isUpload.value = false;
        }
      }
    } catch (err) {
      log(err.toString());
      errorSnackBar(context: context, title: "Payment Error");
      if (paymentFor == PaymentFor.appointment) {
        bookingController.isLoading.value = false;
      } else if (paymentFor == PaymentFor.order) {
        orderController.isLoading.value = false;
      } else if (paymentFor == PaymentFor.labResult) {
        labResultController.isUpload.value = false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future makePaystackPayment({
    required String email,
    required BuildContext context,
    required int amount,
    required String paymentFor,
    String? productId,
    String? currency,
    bool? isTrial,
  }) async {
    final bookingController = Get.find<BookingController>();
    final orderController = Get.find<OrderController>();
    final labResultController = Get.find<LabResultController>();
    try {
      isLoading.value = true;
      await initialize();

      var surcharge = paymentFor == PaymentFor.order
          ? surChargeOrder(amount.toDouble(), 0)
          : paymentFor == PaymentFor.appointment
              ? surChargeAppointment(amount.toDouble())
              : surChargeLabresult(amount.toDouble());

      await FlutterPaystackPlus.openPaystackPopup(
        context: context,
        customerEmail: email,
        amount: (amount * 100).toString(),
        reference: DateTime.now().millisecondsSinceEpoch.toString(),
        secretKey: 'sk_live_c07e9ad43ea5365e467383dab49c9dcefc1975cf',
        callBackUrl: 'https://instantdoctor.co',
        currency: currency ?? pricingService.userCurrency.value,
        onSuccess: () async {
          await handlePaymentSuccess(
            context: context,
            paymentFor: paymentFor,
            amount: amount,
            productId: productId,
            currency: currency ?? pricingService.userCurrency.value,
            isTrial: isTrial,
            surcharge: surcharge,
          );
        },
        onClosed: () {
          if (paymentFor == PaymentFor.appointment) {
            bookingController.isLoading.value = false;
          } else if (paymentFor == PaymentFor.order) {
            orderController.isLoading.value = false;
          } else if (paymentFor == PaymentFor.labResult) {
            labResultController.isUpload.value = false;
          }
          errorSnackBar(context: context, title: "Payment Cancelled");
        },
      );
    } catch (e) {
      log(e.toString());
      if (paymentFor == PaymentFor.appointment) {
        bookingController.isLoading.value = false;
      } else if (paymentFor == PaymentFor.order) {
        orderController.isLoading.value = false;
      } else if (paymentFor == PaymentFor.labResult) {
        labResultController.isUpload.value = false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> chargeNativePayment({
    required BuildContext context,
    required int amount,
    required String paymentFor,
    String? productId,
    String? currency,
    bool? isTrial,
    required dynamic paymentToken,
  }) async {
    final bookingController = Get.find<BookingController>();
    final orderController = Get.find<OrderController>();
    final labResultController = Get.find<LabResultController>();

    if (isLoading.value) return;
    try {
      isLoading.value = true;

      final user =
          await userService.getProfileById(userId: userController.userId.value);
      final txRef =
          "ID-${user.lastName.validate()}-${DateTime.now().millisecondsSinceEpoch}";

      log("🍎 Raw Apple Pay Result: $paymentToken");

      String? actualToken;
      if (paymentToken is Map) {
        actualToken = paymentToken['token']?.toString();
      } else {
        actualToken = paymentToken.toString();
      }

      if (actualToken == null || actualToken.isEmpty) {
        actualToken = jsonEncode(paymentToken);
      }

      final body = {
        "amount": amount,
        "currency": currency ?? pricingService.userCurrency.value,
        "email": user.email.validate(),
        "tx_ref": txRef,
        "applepay_token": actualToken,
      };

      final response = await post(
        Uri.parse("$FIREBASE_URL/payment/charge-applepay"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        await handlePaymentSuccess(
          context: context,
          paymentFor: paymentFor,
          amount: amount,
          productId: productId,
          currency: currency ?? pricingService.userCurrency.value,
          isTrial: isTrial,
        );
      } else {
        log("❌ Payment Failed: ${response.body}");
        errorSnackBar(
            context: context, title: result['message'] ?? "Payment Failed");
        _resetLoadingStates(paymentFor, bookingController, orderController,
            labResultController);
      }
    } catch (e) {
      log("❌ Payment Error: $e");
      errorSnackBar(context: context, title: "An error occurred");
      _resetLoadingStates(
          paymentFor, bookingController, orderController, labResultController);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetLoadingStates(String paymentFor, BookingController b,
      OrderController o, LabResultController l) {
    if (paymentFor == PaymentFor.appointment) b.isLoading.value = false;
    if (paymentFor == PaymentFor.order) o.isLoading.value = false;
    if (paymentFor == PaymentFor.labResult) l.isUpload.value = false;
  }

  // Restored for Google Pay/Apple Pay native (order flow)
  Future<void> makeNativePayPayment({
    required BuildContext context,
    required int amount,
    required String paymentFor,
    String? productId,
    String? currency,
    bool? isTrial,
  }) async {
    await handlePaymentSuccess(
      context: context,
      paymentFor: paymentFor,
      amount: amount,
      productId: productId,
      currency: currency,
      isTrial: isTrial,
    );
  }
}
