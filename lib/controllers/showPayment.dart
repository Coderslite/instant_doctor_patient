import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/controllers/LabResultController.dart';
import 'package:instant_doctor/controllers/OrderController.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/GetUserId.dart';

handleShowPaymentOption(BuildContext context,
    {required AppointmentModel appointment}) async {
  final bookingController = Get.find<BookingController>();
  final paymentController = Get.find<PaymentController>();
  showModalBottomSheet(
      context: context,
      backgroundColor: context.scaffoldBackgroundColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                onTap: () async {
                  try {
                    bookingController.isLoading.value = true;
                    var userInfo = await userService.getProfileById(
                        userId: userController.userId.value);
                    await paymentController.makePaystackPayment(
                      email: userInfo.email.validate(),
                      context: context,
                      amount: appointment.price.validate(),
                      paymentFor: 'Appointment',
                      productId: appointment.id,
                    );
                  } finally {
                    bookingController.isLoading.value = false;
                  }
                },
                width: double.infinity,
                child: Image.asset(
                  "assets/images/paystack.png",
                  height: 40,
                ),
              ),
              10.height,
              AppButton(
                onTap: () async {
                  try {
                    bookingController.isLoading.value = true;
                    var userInfo = await userService.getProfileById(
                        userId: userController.userId.value);
                    await paymentController.makeFlutterwavePayment(
                      email: userInfo.email.validate(),
                      context: context,
                      amount: appointment.price.validate(),
                      paymentFor: 'Appointment',
                      productId: appointment.id,
                    );
                  } finally {
                    bookingController.isLoading.value = false;
                  }
                },
                width: double.infinity,
                child: Image.asset(
                  "assets/images/flutterwave.png",
                  height: 40,
                ),
              ),
            ],
          ),
        );
      });
}

handleShowPaymentOptionBook(BuildContext context) async {
  final bookingController = Get.find<BookingController>();
  final paymentController = Get.find<PaymentController>();
  showModalBottomSheet(
      context: context,
      backgroundColor: context.scaffoldBackgroundColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                onTap: () async {
                  try {
                    bookingController.isLoading.value = true;
                    await bookingController.handleBookAppointment(
                        isTrial: false,
                        doctorId: '',
                        isPaystack: true,
                        context: context);
                  } finally {
                    bookingController.isLoading.value = false;
                  }
                },
                width: double.infinity,
                child: Image.asset(
                  "assets/images/paystack.png",
                  height: 40,
                ),
              ),
              10.height,
              AppButton(
                onTap: () async {
                  try {
                    bookingController.isLoading.value = true;
                    await bookingController.handleBookAppointment(
                        isTrial: false,
                        doctorId: '',
                        isPaystack: true,
                        context: context);
                  } finally {
                    bookingController.isLoading.value = false;
                  }
                },
                width: double.infinity,
                child: Image.asset(
                  "assets/images/flutterwave.png",
                  height: 40,
                ),
              ),
            ],
          ),
        );
      });
}

handleShowPaymentOptionLab(BuildContext context,
    {required int amount, required String email}) async {
  final paymentController = Get.find<PaymentController>();
  final LabResultController labResultController = Get.find();

  showModalBottomSheet(
      context: context,
      backgroundColor: context.scaffoldBackgroundColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                onTap: () async {
                  try {
                    paymentController.makePaystackPayment(
                        email: email,
                        context: context,
                        amount: amount,
                        paymentFor: PaymentFor.labResult);
                  } finally {
                    labResultController.isUpload.value = false;
                  }
                },
                width: double.infinity,
                child: Image.asset(
                  "assets/images/paystack.png",
                  height: 40,
                ),
              ),
              10.height,
              AppButton(
                onTap: () async {
                  try {
                    paymentController.makeFlutterwavePayment(
                        email: email,
                        context: context,
                        amount: amount,
                        paymentFor: PaymentFor.labResult);
                  } finally {
                    labResultController.isUpload.value = false;
                  }
                },
                width: double.infinity,
                child: Image.asset(
                  "assets/images/flutterwave.png",
                  height: 40,
                ),
              ),
            ],
          ),
        );
      });
}

handleShowPaymentOptionOrder(BuildContext context,
    {required bool isPaystack}) async {
  final paymentController = Get.find<PaymentController>();
  final orderController = Get.find<OrderController>();

  showModalBottomSheet(
      context: context,
      backgroundColor: context.scaffoldBackgroundColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                onTap: () async {
                  try {
                    await orderController.makeOrder(isPaystack);
                  } finally {
                    orderController.isLoading.value = false;
                  }
                },
                width: double.infinity,
                child: Image.asset(
                  "assets/images/paystack.png",
                  height: 40,
                ),
              ),
              10.height,
              AppButton(
                onTap: () async {
                  try {
                    await orderController.makeOrder(isPaystack);
                  } finally {
                    orderController.isLoading.value = false;
                  }
                },
                width: double.infinity,
                child: Image.asset(
                  "assets/images/flutterwave.png",
                  height: 40,
                ),
              ),
            ],
          ),
        );
      });
}
