import 'dart:convert';

import 'package:get/get.dart';
import 'package:instant_doctor/models/MedicationTakenModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/MedicationModel.dart';
import 'AlarmController.dart';

class MedicationController extends GetxController {
  AlarmController alarmController = Get.put(AlarmController());
  var isLoading = false.obs;
  handleCreateMedication(MedicationModel medication) async {
    isLoading.value = true;
    try {
      await medicationService.newMedication(medication: medication);
      toast("Medication Added");
     await alarmController.handleAddToAlarms(medication);
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
