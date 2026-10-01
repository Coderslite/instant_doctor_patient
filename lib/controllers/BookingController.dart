// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/controllers/showPayment.dart';
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
  RxList selectedSymptoms = [].obs;
  RxString docId = ''.obs;
  RxString docToken = ''.obs;
  RxString userToken = ''.obs;
  Timestamp? startTime;
  Timestamp? endTime;
  RxString currentAppointmentId = ''.obs;

  late StreamController<void> updateStreamController;
  final userService = Get.find<UserService>();
  final paymentController = Get.find<PaymentController>();
  final appointmentService = Get.find<AppointmentService>();

  Future handleBookAppointment({
    required doctorId,
    required bool isTrial,
    required bool isPaystack,
    required BuildContext context,
  }) async {
    // If the doctor changes, we should create a NEW appointment record
    if (docId.value != doctorId) {
      currentAppointmentId.value = '';
    }
    docId.value = doctorId;
    try {
      isLoading.value = true;

      // Validate package selection
      if (package.value.isEmpty) {
        isLoading.value = false;
        errorSnackBar(context: context, title: "Please select a valid package");
        return false;
      }

      // Validate symptoms/complaint
      // if (complain.value.isEmpty) {
      //   errorSnackBar(context: context, title: "Please describe your symptoms");
      //   return false;
      // }

      // Validate date/time (must be at least 5 minutes ahead of current time)
      final minAllowedTime = DateTime.now().add(Duration(minutes: 5));
      if (selectedDate.isBefore(minAllowedTime)) {
        isLoading.value = false;
        errorSnackBar(
            context: context,
            title:
                "Selected date and time must be at least 5 minutes from now");
        return false;
      }

      // Calculate end time
      var endDate = isTrial
          ? selectedDate.add(Duration(minutes: 30))
          : selectedDate.add(Duration(seconds: duration.value));
      startTime = Timestamp.fromDate(selectedDate);
      endTime = Timestamp.fromDate(endDate);

      // Check if doctor is available (commented out as in original)
      // var isAlreadyBooked = await appointmentService.isDoctorAlreadyBooked(...)

      var userInfo =
          await userService.getProfileById(userId: userController.userId.value);
      var email = userInfo.email.validate();
      // REUSE EXISTING ID IF AVAILABLE (To avoid duplicates on cancel/retry)
      var appointmentId = await newBooking(isTrial);
      currentAppointmentId.value = appointmentId;

      // Skip payment for trial appointments
      if (isTrial) {
        // You might want to add specific trial handling here
        // For example, mark appointment as trial in database
        successSnackBar(
            context: context, title: "Trial appointment booked successfully!");
        isLoading.value = false;
        settingsController.trialAvailable.value = false;
        await userService.updateProfile(
            data: {"isTrialAvailable": false, "isPaid": true},
            userId: userController.userId.value);
        await updateAppointmentAfterPayment(context, appointmentId, isTrial);
      } else {
        var appt = await appointmentService.getAppointment(
            appointmentId: appointmentId);
        // isLoading.value = true;
        handleShowPaymentOption(context, appointment: appt);
      }
    } catch (err) {
      isLoading.value = false;
      errorSnackBar(context: context, title: "Booking failed");
    }
  }

  Future<String> newBooking(bool isTrial) async {
    var res = await appointmentService.createAppointment(
      docId: isTrial
          ? settingsController.trialDoctor.value.isEmpty
              ? TRIAL_DOCTOR_ID
              : settingsController.trialDoctor.value
          : docId.value,
      userId: userController.userId.value,
      complain: complain.value,
      symptoms: selectedSymptoms,
      price: price.value,
      package: package.value,
      startTime: startTime!,
      endTime: endTime!,
      isTrial: isTrial,
      appointmentId: currentAppointmentId.value, // Pass existing ID if any
    );

    if (res != null) {
      return res;
    } else {
      return "";
    }
  }

  Future<void> updateAppointmentAfterPayment(
      BuildContext context, String appointmentId, bool isTrial,
      {String? currency}) async {
    try {
      var res = await appointmentService.updateAppointmentAfterPayment(
          appointmentId: appointmentId, isTrial: isTrial, currency: currency);

      if (res) {
        // Reset booking state on success
        currentAppointmentId.value = '';
        selectedDate = DateTime.now();
        complain.value = '';
        price.value = 0;
        package.value = '';
        duration.value = 0;
        selectedSymptoms.value = [];
        SuccessScreen().launch(Get.context!);
      } else {
        errorSnackBar(context: context, title: "Something went wrong");
      }
    } catch (e) {
      errorSnackBar(context: context, title: "Failed to update appointment");
    } finally {
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
