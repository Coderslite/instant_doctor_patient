// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutterwave_standard/flutterwave.dart';
// import 'package:flutterwave_standard/models/subaccount.dart';
// import 'package:get/get.dart';
// import 'package:instant_doctor/component/snackBar.dart';
// import 'package:instant_doctor/constant/constants.dart';
// import 'package:instant_doctor/controllers/BookingController.dart';
// import 'package:instant_doctor/controllers/LabResultController.dart';
// import 'package:instant_doctor/services/AppointmentService.dart';
// import 'package:instant_doctor/services/GetUserId.dart';
// import 'package:instant_doctor/services/WalletService.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:uuid/uuid.dart';

// import '../services/UserService.dart';
// import 'OrderController.dart';

// class PaymentController extends GetxController {
//   var amount = '0'.obs;
//   var isLoading = false.obs;
//   final walletService = Get.find<WalletService>();
//   final userService = Get.find<UserService>();

//   // Surcharge for orders (2% user surcharge + Flutterwave fee)
//   double surChargeOrder(double amount, double deliveryFee) {
//     const double surchargeRate = 0.02; // 2% user surcharge
//     double flutterwaveCharge = getFlutterwaveCharge(amount);
//     final double userSurcharge = (amount - deliveryFee) * surchargeRate;
//     return userSurcharge + flutterwaveCharge;
//   }

//   // Surcharge for appointments (Flutterwave fee only)
//   double surChargeAppointment(double amount) {
//     return getFlutterwaveCharge(amount);
//   }

//   // Surcharge for lab results (Flutterwave fee only)
//   double surChargeLabresult(double amount) {
//     return getFlutterwaveCharge(amount);
//   }

//   // Transfer fee (same as Paystack for consistency)
//   int getTransferFee(double amount) {
//     if (amount <= 5000) {
//       return 10;
//     } else if (amount <= 50000) {
//       return 25;
//     } else {
//       return 50;
//     }
//   }

//   // Platform earnings for pharmacy (in kobo)
//   double calculatePlatformEarningForPharmacy(
//       double transactionAmount, double deliveryFee) {
//     const double platformFeeRate = 0.05; // 5% platform fee
//     const double surchargeRate = 0.02; // 2% user surcharge
//     double flutterwaveCharge = getFlutterwaveCharge(transactionAmount);
//     final double platformFee =
//         (transactionAmount - deliveryFee) * platformFeeRate;
//     final double userSurcharge =
//         (transactionAmount - deliveryFee) * surchargeRate;
//     final double platformEarnings = platformFee + userSurcharge;
//     return (platformEarnings + flutterwaveCharge) * 100; // Convert to kobo
//   }

//   // Platform earnings for doctors (in kobo)
//   double calculatePlatformEarningForDoctors(double transactionAmount) {
//     const double platformFeeRate = 0.30; // 30% platform fee
//     double flutterwaveCharge = getFlutterwaveCharge(transactionAmount);
//     final double platformFee = transactionAmount * platformFeeRate;
//     final double platformEarnings = platformFee;
//     return (platformEarnings + flutterwaveCharge) * 100; // Convert to kobo
//   }

//   // Flutterwave transaction fee (1.4% capped at ₦2000)
//   double getFlutterwaveCharge(double amount) {
//     double percentageFee = amount * 0.014; // 1.4% fee
//     double totalFee = percentageFee;
//     if (totalFee > 2000) {
//       return 2000; // Cap at ₦2000
//     }
//     return totalFee;
//   }

//   Future makePayment({
//     required String email,
//     required BuildContext context,
//     required int amount,
//     required String paymentFor,
//     String? productId,
//     bool? isTrial,
//   }) async {
//     final orderController = Get.find<OrderController>();
//     final bookingController = Get.find<BookingController>();
//     var labResultController = Get.find<LabResultController>();
//     isLoading.value = true;

//     try {
//       var user =
//           await userService.getProfileById(userId: userController.userId.value);
//       var name = "${user.firstName.validate()} ${user.lastName.validate()}";
//       var phone = user.phoneNumber.validate();

//       // Calculate platform earnings (in kobo)
//       int platformEarning = paymentFor == PaymentFor.order
//           ? calculatePlatformEarningForPharmacy(amount.toDouble(),
//                   orderController.deliveryFee.value.toDouble())
//               .toInt()
//           : paymentFor == PaymentFor.appointment
//               ? calculatePlatformEarningForDoctors(amount.toDouble()).toInt()
//               : 0; // No platform earning for lab results

//       // Calculate surcharge (in Naira)
//       var surcharge = paymentFor == PaymentFor.order
//           ? surChargeOrder(
//               amount.toDouble(), orderController.deliveryFee.value.toDouble())
//           : paymentFor == PaymentFor.appointment
//               ? surChargeAppointment(amount.toDouble())
//               : surChargeLabresult(amount.toDouble());
//       var transferFee = getTransferFee(amount.toDouble());

//       // Total amount to charge (in Naira)
//       double totalAmount = amount + surcharge;

//       // Recipient's earning (in kobo)
//       var recipientEarning =
//           ((amount + surcharge + transferFee) * 100) - platformEarning;

//       // Calculate subaccount split ratio (as percentage)
//       int splitRatio = paymentFor == PaymentFor.labResult
//           ? 100 // Lab results: subaccount gets 100% (minus Flutterwave fee)
//           : ((recipientEarning / (totalAmount * 100)) * 100).round();

//       // Define subaccount
//       List<SubAccount> subAccounts = [];
//       if (paymentFor != PaymentFor.labResult) {
//         subAccounts.add(SubAccount(
//           id: paymentFor == PaymentFor.order
//               ? 'RS_7C07E6AB1D0088E7F838A63E3020BAC6' // Replace with actual ID
//               : 'RS_A22ECC233CDCDEAA5C771EB554DF5AB1', // Replace with actual ID
//           transactionSplitRatio: splitRatio,
//           transactionChargeType: 'percentage',
//           transactionPercentage: (splitRatio / 100.0),
//         ));
//       }

//       final Customer customer =
//           Customer(name: name, phoneNumber: phone, email: email);
//       final Flutterwave flutterwave = Flutterwave(
//         publicKey: "FLWPUBK-90c2abbe1e7a5b975e45d9cb006bbeea-X",
//         txRef: "$name${DateTime.now().millisecondsSinceEpoch}",
//         amount: totalAmount.toString(),
//         customer: customer,
//         paymentOptions: "ussd,card,banktransfer",
//         customization: Customization(title: "Instant Doctor"),
//         redirectUrl: "https://instantdoctor.co",
//         isTestMode: false,
//         currency: userController.currency.value,
//         subAccounts: subAccounts,
//       );

//       final ChargeResponse response = await flutterwave.charge(context);

//       if (response.success == true) {
//         if (paymentFor == PaymentFor.appointment) {
//           // Convert platformEarning from kobo to Naira for calculation
//           double doctorEarning =
//               (amount + surcharge) - (platformEarning / 100.0);
//           bookingController.updateAppointmentAfterPayment(
//               productId.validate(), isTrial.validate());
//           AppointmentService().updateDoctorEarning(
//             appointmentId: productId.validate(),
//             doctorEarning: doctorEarning.toInt(),
//           );
//         }
//         if (paymentFor == PaymentFor.order) {
//           orderController.orderNow();
//         }
//         if (paymentFor == PaymentFor.labResult) {
//           labResultController.handleUploadFiles(context);
//         }
//         successSnackBar(title: "Payment Successful");
//       } else {
//         if (paymentFor == PaymentFor.appointment) {
//           errorSnackBar(title: "Payment not successful");
//         }
//         if (paymentFor == PaymentFor.order) {
//           errorSnackBar(title: "Payment not successful");
//         }
//         errorSnackBar(title: "Payment Cancelled");
//         bookingController.isLoading.value = false;
//       }
//     } catch (err) {
//       orderController.isLoading.value = false;
//       bookingController.isLoading.value = false;
//       log(err.toString());
//       errorSnackBar(title: "Payment Error");
//     } finally {
//       isLoading.value = false;
//       // bookingController.isLoading.value = false;
//       orderController.isLoading.value = false;
//     }
//   }
// }
