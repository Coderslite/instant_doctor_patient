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
    print(userId);
    var result = await userCol
        .doc(userId)
        .update({"status": status, "lastSeen": Timestamp.now()});
    return result;
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
}
