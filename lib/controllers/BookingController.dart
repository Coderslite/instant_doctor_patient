import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/FirebaseMessaging.dart';
import 'package:instant_doctor/main.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/get_weekday.dart';
import 'package:timezone/timezone.dart' as tz;

class BookingController extends GetxController {
  List<DateTime> nextTwoWeeks = [];
  String? selectedMonth;
  DateTime? selectedDate;
  RxString complain = ''.obs;
  RxBool isLoading = false.obs;
  TimeOfDay? time;
  RxInt price = 0.obs;
  RxString package = ''.obs;
  RxString duration = ''.obs;

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
      Timestamp startTime = Timestamp.fromDate(dateTime);
      var res = await appointmentService.createAppointment(
          docId: docId,
          userId: userId,
          complain: complain.value,
          price: price.value,
          package: package.value,
          startTime: startTime);
      if (res) {
        selectedDate = null;
        complain.value = '';
        time = null;
        price.value = 0;
        package.value = '';
        duration.value = '';
        tz.TZDateTime scheduledTime = tz.TZDateTime.from(dateTime, tz.local);
        FirebaseMessagings().handleScheduleNotification(scheduledTime,
            "Appointment Update", "Its time for your scheduled appointment");
      }

      return res;
    } catch (err) {
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
