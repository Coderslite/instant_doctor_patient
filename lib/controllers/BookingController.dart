// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/SuccessAppointment.dart';
import '../constant/constants.dart';
import '../function/send_notification.dart';
import '../services/get_weekday.dart';

class BookingController extends GetxController {
  RxString backgroundAppointmentId = ''.obs;
  List<DateTime> nextTwoWeeks = [];
  String? selectedMonth;
  DateTime? selectedDate;
  RxString complain = ''.obs;
  RxBool isLoading = false.obs;
  TimeOfDay? time;
  RxInt price = 0.obs;
  RxString package = ''.obs;
  RxInt duration = 0.obs;

  List<String> availableMonths = [];

  late StreamController<void> updateStreamController;

  Future<bool> handleBookAppointment({
    required docId,
    required String userId,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      DateTime dateTime = DateTime(selectedDate!.year, selectedDate!.month,
          selectedDate!.day, time!.hour, time!.minute);
      if (dateTime.isBefore(DateTime.now())) {
        toast('Selected date and time must be in the future');
        return false;
      }
      // Convert DateTime to Firebase Timestamp
      var endDate = dateTime.add(Duration(seconds: duration.value));
      Timestamp startTime = Timestamp.fromDate(dateTime);
      Timestamp endTime = Timestamp.fromDate(endDate);
      var endDate2 = dateTime.add(Duration(minutes: 2));
      var endTime2 = Timestamp.fromDate(endDate2);
      var isAlreadyBooked = await appointmentService.isDoctorAlreadyBooked(
          docId: docId, startTime: startTime, endTime: endTime);
      if (!isAlreadyBooked) {
        var userToken = await userService.getUserToken(userId: userId);
        var docToken = await userService.getUserToken(userId: docId);

        var res = await appointmentService.createAppointment(
          docId: docId,
          userId: userId,
          complain: complain.value,
          price: price.value,
          package: package.value,
          startTime: startTime,
          endTime: endTime,
        );

        if (res != null) {
          await scheduleAppointmentNotification(
            tokens: [userToken, docToken],
            title: "",
            body: "",
            id: res,
            type: NotificatonType.appointment,
            scheduledTime: startTime,
            endTime: endTime,
          );
          selectedDate = null;
          complain.value = '';
          time = null;
          price.value = 0;
          package.value = '';
          duration.value = 0;
          Get.off(const SuccessScreen());
        }

        // toast("is avaiable");

        return true;
      } else {
        toast("This doctor is already booked within this time");
        return false;
      }
    } catch (err) {
      print(err);
      toast(err.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    availableMonths = generateAvailableMonths();
    // Set the selected month to the current month initially
    selectedMonth = DateFormat('MMMM').format(DateTime.now());
    nextTwoWeeks = generateAvailableDates(selectedMonth);
    updateStreamController = StreamController<void>();
    super.onInit();
  }
}
