import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/function/send_notification.dart';
import 'package:instant_doctor/models/MedicationTakenModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/MedicationModel.dart';
import 'AlarmController.dart';

class MedicationController extends GetxController {
  AlarmController alarmController = Get.put(AlarmController());
  var isLoading = false.obs;
  handleCreateMedication(MedicationModel medication) async {
    isLoading.value = true;
    var token =
        await userService.getUserToken(userId: userController.userId.value);
    try {
      var medId = await medicationService.newMedication(medication: medication);
      var startDate =
          medication.startTime!.toDate().subtract(const Duration(days: 1));
      var endDate = medication.endTime!.toDate();
      var dateDiff = endDate.difference(startDate);
      for (int x = 0; x < dateDiff.inDays; x++) {
        if (medication.morning != null) {
          var scheduleTime = startDate.add(Duration(
              hours: medication.morning!.hour,
              minutes: medication.morning!.minute));

          scheduleTime = scheduleTime.add(const Duration(days: 1));
          scheduleMedicationNotification(
              tokens: [token],
              title: "",
              body: "",
              id: medId,
              type: NotificatonType.medication,
              scheduledTime: Timestamp.fromDate(scheduleTime),
              time: "Morning");
        }
        if (medication.midDay != null) {
          var scheduleTime = startDate.add(Duration(
              hours: medication.midDay!.hour,
              minutes: medication.midDay!.minute));

          scheduleTime = scheduleTime.add(const Duration(days: 1));
          scheduleMedicationNotification(
              tokens: [token],
              title: "",
              body: "",
              id: medId,
              type: NotificatonType.medication,
              scheduledTime: Timestamp.fromDate(scheduleTime),
              time: "Afternoon");
        }
        if (medication.evening != null) {
          var scheduleTime = startDate.add(Duration(
              hours: medication.evening!.hour,
              minutes: medication.evening!.minute));

          scheduleTime = scheduleTime.add(const Duration(days: 1));
          scheduleMedicationNotification(
              tokens: [token],
              title: "",
              body: "",
              id: medId,
              type: NotificatonType.medication,
              scheduledTime: Timestamp.fromDate(scheduleTime),
              time: "Evening");
        }
      }
      toast("Medication Added");
    } catch (err) {
      toast(err.toString());
    } finally {
      isLoading.value = false;
    }
  }

  handleMedicationTaken(
    MedicationTakenModel medication,
  ) async {
    try {
      List<String>? allMedicationTaken = [];
      var prefs = await SharedPreferences.getInstance();
      var medicationTaken = prefs.getStringList('MedicationsTaken');
      if (medicationTaken != null && medicationTaken.isNotEmpty) {
        allMedicationTaken = medicationTaken;
      }
      allMedicationTaken.add(jsonEncode(medication.toJson()));
      alarmController.removeAlarm(medication.id!);
      toast("Medication Taken");
    } catch (err) {
      toast(err.toString());
      print(err);
    }
  }
}
