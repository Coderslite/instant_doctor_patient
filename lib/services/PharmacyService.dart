import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/DrugModel.dart';
import 'package:instant_doctor/models/PharmacyModel.dart';

import 'DrugService.dart';

class PharmacyService {
  final drugService = Get.find<DrugService>();
  var pharmacyCol = db.collection("Pharmacies");

  Stream<List<PharmacyModel>> getPharmacies() {
    var ref = pharmacyCol.where('status', isNotEqualTo: 'deleted').snapshots();
    return ref.map((event) =>
        event.docs.map((e) => PharmacyModel.fromJson(e.data())).toList());
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

  Stream<List<PharmacyModel>> getPharmaciesNearby(LatLng userPosition) async* {
    // First get all active pharmacies
    var allPharmacies = await pharmacyCol
        .where('status', isNotEqualTo: 'deleted')
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => PharmacyModel.fromJson(doc.data()))
            .toList());

    // Filter pharmacies within 2km
    final nearbyPharmacies = allPharmacies.where((pharmacy) {
      if (pharmacy.location == null) return false;

      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        pharmacy.location!.latitude,
        pharmacy.location!.longitude,
      );

      return distance <= 2000; // 2000 meters = 2km
    }).toList();

    yield nearbyPharmacies;

    // Also listen for real-time updates
    yield* pharmacyCol
        .where('status', isNotEqualTo: 'deleted')
        .snapshots()
        .asyncMap((snapshot) async {
      final pharmacies = snapshot.docs
          .map((doc) => PharmacyModel.fromJson(doc.data()))
          .toList();

      return pharmacies.where((pharmacy) {
        if (pharmacy.location == null) return false;

        final distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          pharmacy.location!.latitude,
          pharmacy.location!.longitude,
        );

        return distance <= 2000;
      }).toList();
    });
  }
}
