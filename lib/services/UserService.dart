// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:instant_doctor/services/GetUserId.dart';

import '../models/SavedLocationModel.dart';

class UserService extends BaseService {
  var userCol = db.collection("Users");
  Stream<UserModel> getProfile({required String userId}) {
    var result = userCol.doc(userId).snapshots();
    return result.map((event) => UserModel.fromJson(event.data()!));
  }

  Future<UserModel> getProfileById({required String userId}) async {
    var result = await userCol.doc(userId).get();
    return UserModel.fromJson(result.data()!);
  }

  Future<void> updateStatus(
      {required String userId, required String status}) async {
    var result = await userCol
        .doc(userId)
        .update({"status": status, "lastSeen": Timestamp.now()});
    return result;
  }

  Future<void> updateProfile(
      {required Map<String, dynamic> data, required userId}) async {
    await userCol.doc(userId).update(data);
  }

  Future<void> updateToken(
      {required String userId, required String token}) async {
    var result = await userCol.doc(userId).update(
      {
        "token": token,
      },
    );
    return result;
  }

  Future<String> getUserToken({required String userId}) async {
    var result = await userCol.doc(userId).get();
    var user = UserModel.fromJson(result.data()!);
    return user.token!;
  }

  Future<String> getUsername({required String userId}) async {
    var result = await userCol.doc(userId).get();
    var user = UserModel.fromJson(result.data()!);
    return "${user.firstName} ${user.lastName}";
  }

  Future<UserModel?> getUserByEmail({required String email}) async {
    var userRef = await userCol.where('email', isEqualTo: email).get();
    if (userRef.docs.isNotEmpty) {
      var userData = userRef.docs.first.data();
      return UserModel.fromJson(userData);
    } else {
      return null;
    }
  }

  Future<UserModel?> getUserByTag({required String tag}) async {
    var userRef = await userCol.where('tag', isEqualTo: tag).get();
    if (userRef.docs.isNotEmpty) {
      var userData = userRef.docs.first.data();
      return UserModel.fromJson(userData);
    } else {
      return null;
    }
  }

  Future<void> updateUserBalance(
      {required String id, required int amount}) async {
    userCol.doc(id).update({
      "amount": amount,
    });
  }

  // Add to your LocationController class
  Future<List<SavedLocation>> getSavedLocations() async {
    final userDoc = await userCol.doc(userController.userId.value).get();

    if (userDoc.exists && userDoc.data()?['savedLocations'] != null) {
      return (userDoc.data()!['savedLocations'] as List)
          .map((loc) => SavedLocation.fromMap(loc))
          .toList();
    }
    return [];
  }

  Future<void> saveLocation(SavedLocation location) async {
    final locations = await getSavedLocations();
    locations.add(location);

    await userCol.doc(userController.userId.value).update({
      'savedLocations': locations.map((loc) => loc.toMap()).toList(),
    });
  }

  Future<void> deleteSavedLocation(String id) async {
    final locations = await getSavedLocations();
    locations.removeWhere((loc) => loc.id == id);

    await userCol.doc(userController.userId.value).update({
      'savedLocations': locations.map((loc) => loc.toMap()).toList(),
    });
  }

  Future<void> setLocation(double lat, double lng, String address) async {
    locationController.latitude.value = lat;
    locationController.longitude.value = lng;
    locationController.address.value = address;
  }
}
