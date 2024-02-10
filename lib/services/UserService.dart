import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:nb_utils/nb_utils.dart';

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

  Future<void> updateUserBalance(
      {required String id, required int amount}) async {
    userCol.doc(id).update({
      "amount": amount,
    });
  }
}
