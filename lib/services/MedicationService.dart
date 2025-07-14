// ignore_for_file: empty_catches, file_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/MedicationController.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/MedicationModel.dart';

class MedicationService extends BaseService {
  var medicationCol =
      FirebaseFirestore.instance.collection("MedicationTracker");

  Stream<List<MedicationModel>> getUserMedications({required String userId}) {
    var medicationRef =
        medicationCol.where('userId', isEqualTo: userId).snapshots();
    return medicationRef.map((event) =>
        event.docs.map((e) => MedicationModel.fromJson(e.data())).toList());
  }

  newMedication({required MedicationModel medication}) async {
    var res = await medicationCol.add(medication.toJson());
    await medicationCol.doc(res.id).update({
      "id": res.id,
    });
    return res.id;
  }

  Future<void> deleteMedication({required MedicationModel medication}) async {
    var medicationController = Get.find<MedicationController>();
    await medicationController.cancelMedicationNotifications(
        medication.id.validate(),
        medication.startTime!.toDate(),
        medication.endTime!.toDate());
    await medicationCol.doc(medication.id.validate()).delete();
  }

  updateMedication({required MedicationModel medication}) async {
    await medicationCol.doc(medication.id).update(medication.toJson());
    return;
  }

  Future<void> saveMedicationLocal(MedicationModel medicationModel) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      List<String> allMedications = [];
      var medications = prefs.getStringList('medications');
      if (medications != null && medications.isNotEmpty) {
        allMedications = medications;
      }
      allMedications
          .add(jsonEncode(medicationModel.toJson())); // Fix this line as well
      prefs.setStringList(
        'medications',
        allMedications,
      );
    } catch (err) {}
    // return;
  }
}
