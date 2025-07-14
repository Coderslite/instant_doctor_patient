// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/services/AppointmentService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/SuccessAppointment.dart';
import '../constant/constants.dart';
import '../services/GetUserId.dart';
import '../services/UserService.dart';

class BookingController extends GetxController {
  DateTime selectedDate = DateTime.now();
  RxString complain = ''.obs;
  RxBool isLoading = false.obs;
  RxInt price = 0.obs;
  RxString package = ''.obs;
  RxInt duration = 0.obs;

  RxString docId = ''.obs;
  RxString docToken = ''.obs;
  RxString userToken = ''.obs;
  Timestamp? startTime;
  Timestamp? endTime;

  late StreamController<void> updateStreamController;
  final userService = Get.find<UserService>();
  final paymentController = Get.find<PaymentController>();
  final appointmentService = Get.find<AppointmentService>();

  Future handleBookAppointment({
    required doctorId,
    required bool isTrial,
    required BuildContext context,
  }) async {
    docId.value = doctorId;
    try {
      isLoading.value = true;

      // Validate package selection
      if (package.value.isEmpty) {
        errorSnackBar(title: "Please select a valid package");
        return false;
      }

      // Validate symptoms/complaint
      if (complain.value.isEmpty) {
        errorSnackBar(title: "Please describe your symptoms");
        return false;
      }

      // Validate date/time (must be at least 5 minutes ahead of current time)
      final minAllowedTime = DateTime.now().add(Duration(minutes: 5));
      if (selectedDate.isBefore(minAllowedTime)) {
        errorSnackBar(
            title:
                "Selected date and time must be at least 5 minutes from now");
        return false;
      }

      // Calculate end time
      var endDate = isTrial
          ? selectedDate.add(Duration(days: 1))
          : selectedDate.add(Duration(seconds: duration.value));
      startTime = Timestamp.fromDate(selectedDate);
      endTime = Timestamp.fromDate(endDate);

      // Check if doctor is available (commented out as in original)
      // var isAlreadyBooked = await appointmentService.isDoctorAlreadyBooked(...)

      var userInfo =
          await userService.getProfileById(userId: userController.userId.value);
      var email = userInfo.email.validate();
      var appointmentId = await newBooking(isTrial);

      // Skip payment for trial appointments
      if (isTrial) {
        // You might want to add specific trial handling here
        // For example, mark appointment as trial in database
        successSnackBar(title: "Trial appointment booked successfully!");
        isLoading.value = false;
        settingsController.trialAvailable.value = false;
        await userService.updateProfile(
            data: {"isTrialAvailable": false, "isPaid": true},
            userId: userController.userId.value);
        await updateAppointmentAfterPayment(appointmentId);
      } else {
        // Proceed with payment for regular appointments
        await paymentController.makePayment(
          email: email,
          context: Get.context!,
          amount: price.value,
          paymentFor: PaymentFor.appointment,
          productId: appointmentId,
        );
      }
    } catch (err) {
      isLoading.value = false;
      errorSnackBar(title: "Booking failed");
    }
  }

  Future<String> newBooking(bool isTrial) async {
    var res = await appointmentService.createAppointment(
      docId: docId.value,
      userId: userController.userId.value,
      complain: complain.value,
      price: price.value,
      package: package.value,
      startTime: startTime!,
      endTime: endTime!,
      isTrial: isTrial,
    );

    if (res != null) {
      return res;
    } else {
      return "";
    }
  }

  Future<void> updateAppointmentAfterPayment(String appointmentId) async {
    var res = await appointmentService.updateAppointmentAfterPayment(
        appointmentId: appointmentId);

    if (res) {
      isLoading.value = false;
      selectedDate = DateTime.now();
      complain.value = '';
      price.value = 0;
      package.value = '';
      duration.value = 0;
      SuccessScreen().launch(Get.context!);
    } else {
      errorSnackBar(title: "Something went wrong");
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    // availableMonths = generateAvailableMonths();
    // Set the selected month to the current month initially
    // selectedMonth = DateFormat('MMMM').format(DateTime.now());
    // nextTwoWeeks = generateAvailableDates(selectedMonth);
    updateStreamController = StreamController<void>();
    super.onInit();
  }
}

// sudo gem uninstall ffi && sudo gem install ffi -- --enable-libffi-alloc
