import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/DrugModel.dart';
import 'package:instant_doctor/models/PharmacyModel.dart';

import 'DrugService.dart';

class PharmacyService {
  final drugService = Get.find<DrugService>();
  var pharmacyCol = db.collection("Pharmacies");

  Stream<List<PharmacyModel>> getPharmacies() {
    var ref = pharmacyCol.snapshots();
    return ref.map((event) =>
        event.docs.map((e) => PharmacyModel.fromJson(e.data())).toList());
  }

  Stream<List<DrugModel>> getPharmacyDrug({required String pharmacyId}) {
    print(pharmacyId);
    var ref = drugService.drugCol
        .where('pharmacyId', isEqualTo: pharmacyId)
        .snapshots();

    return ref.map((event) =>
        event.docs.map((e) => DrugModel.fromJson(e.data())).toList());
  }
}
