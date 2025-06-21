// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/services/AppointmentService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/SuccessAppointment.dart';
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
    required BuildContext context,
  }) async {
    docId.value = doctorId;
    try {
      isLoading.value = true;
      if (price.value <= 0) {
        errorSnackBar(title: "Please select a valid package");
        return false;
      }
      if (package.value.isEmpty) {
        errorSnackBar(title: "Please select a valid package");
        return false;
      }
      if (complain.value.isEmpty) {
        errorSnackBar(title: "Please enter complain");
        return false;
      }

      if (selectedDate.isBefore(DateTime.now())) {
        toast('Selected date and time must be in the future');
        return false;
      }
      // Convert DateTime to Firebase Timestamp
      var endDate = selectedDate.add(Duration(seconds: duration.value));
      startTime = Timestamp.fromDate(selectedDate);
      endTime = Timestamp.fromDate(endDate);
      // var endDate2 = selectedDate.add(const Duration(minutes: 2));
      // var endTime2 = Timestamp.fromDate(endDate2);
      // var isAlreadyBooked = await appointmentService.isDoctorAlreadyBooked(
      //     docId: docId, startTime: startTime, endTime: endTime);
      // if (!isAlreadyBooked) {
      //   errorSnackBar(title: "This doctor is already booked within this time");
      //   return false;
      // }
      var userInfo =
          await userService.getProfileById(userId: userController.userId.value);
      var email = userInfo.email.validate();
      var appointmentId = await newBooking();
      print(appointmentId);
      await paymentController.makePayment(
          email: email,
          context: Get.context!,
          amount: price.value,
          paymentFor: 'Appointment',
          productId: appointmentId);
    } catch (err) {
      isLoading.value = false;
      toast(err.toString());
    }
  }

  Future<String> newBooking() async {
    var res = await appointmentService.createAppointment(
      docId: docId.value,
      userId: userController.userId.value,
      complain: complain.value,
      price: price.value,
      package: package.value,
      startTime: startTime!,
      endTime: endTime!,
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