import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/DrugModel.dart';
import 'package:instant_doctor/models/PharmacyModel.dart';

import '../constant/constants.dart';
import 'DrugService.dart';

class PharmacyService {
  final drugService = Get.find<DrugService>();
  var pharmacyCol = db.collection("Pharmacies");

  Stream<List<PharmacyModel>> getPharmacies() {
    var ref = pharmacyCol.where('status', isNotEqualTo: 'deleted').snapshots();
    return ref.map((event) =>
        event.docs.map((e) => PharmacyModel.fromJson(e.data())).toList());
  }

  Stream<PharmacyModel> getPharmacyById({required String id}) {
    var ref = pharmacyCol.doc(id).snapshots();
    return ref.map((event) => PharmacyModel.fromJson(event.data()!));
  }

  Stream<List<DrugModel>> getPharmacyDrug({required String pharmacyId}) {
    print(pharmacyId);
    var ref = drugService.drugCol
        .where('pharmacyId', isEqualTo: pharmacyId)
        .where('status', isNotEqualTo: 'deleted')
        .snapshots();

    return ref.map((event) =>
        event.docs.map((e) => DrugModel.fromJson(e.data())).toList());
  }

  Stream<List<PharmacyModel>> getPharmaciesNearby(LatLng userPosition) {
    return pharmacyCol
        .where('status', isNotEqualTo: 'deleted')
        .snapshots()
        .map((snapshot) {
      final pharmacies = snapshot.docs
          .map((doc) => PharmacyModel.fromJson(doc.data()))
          .where((pharmacy) {
        if (pharmacy.location == null) return false;

        final distance = calculateDistance2(
          userPosition.latitude,
          userPosition.longitude,
          pharmacy.location!.latitude,
          pharmacy.location!.longitude,
        );
        print(distance);

        return distance <= 5; // 2km
      }).toList();

      return pharmacies;
    });
  }
}
