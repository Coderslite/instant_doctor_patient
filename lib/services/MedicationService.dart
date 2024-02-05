import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/MedicationModel.dart';

class MedicationService extends BaseService {
  var medicationCol =
      FirebaseFirestore.instance.collection("MedicationTracker");

  Future<List<MedicationModel>> getUserMedications(
      {required String userId}) async {
    List<MedicationModel> medications = [];

    try {
      // Get SharedPreferences instance
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get the list of all medications saved in SharedPreferences
      List<String>? allMedications = prefs.getStringList('medications');

      if (allMedications != null) {
        // Iterate through each saved medication
        allMedications.forEach((medicationString) {
          // Parse the medication string to a MedicationModel object
          MedicationModel medication =
              MedicationModel.fromJson(jsonDecode(medicationString));

          // Check if the medication belongs to the specified userId
          if (medication.userId == userId) {
            medications.add(medication);
          }
        });
      }

      return medications;
    } catch (e) {
      // Handle any errors
      print("Error fetching medications: $e");
      return [];
    }
  }

  newMedication({required MedicationModel medication}) async {
    // var res = await medicationCol.add(medication.toMap());
    // await medicationCol.doc(res.id).update({
    //   "id": res.id,
    // });
    await saveMedicationLocal(medication);
    return;
  }

  // Future<List<MedicationModel>> getMedications({required String userId}) async {
  //   // var result = await medicationCol.where('userId', isEqualTo: userId).get();
  //   // return result.docs.map((e) => MedicationModel.fromJson(e.data())).toList();
  //   var prefs = await SharedPreferences.getInstance();
  //   var result = prefs.getStringList('medications');
  //   return result!.map((e) => MedicationModel.fromJson(jsonDecode(e))).toList();
  // }

  Future<void> deleteMedication({required String id}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? allMedications = prefs.getStringList('medications');

      if (allMedications != null) {
        // Filter out the medication with the specified ID
        List<String> updatedMedications =
            allMedications.where((medicationString) {
          Map<String, dynamic> medicationData = jsonDecode(medicationString);
          return medicationData['id'] != id;
        }).toList();

        // Save the updated medication list back to SharedPreferences
        await prefs.setStringList('medications', updatedMedications);
      }
    } catch (e) {
      print('Error deleting medication: $e');
      // Handle any errors
    }
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
      var res = prefs.setStringList(
        'medications',
        allMedications,
      );
    } catch (err) {
      print(err);
    }
    // return;
  }
}
