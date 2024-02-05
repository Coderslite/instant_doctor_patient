import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/UserController.dart';
import 'BaseService.dart';

class AuthenticationService extends BaseService {
  var userCol = db.collection("Users");
  FirebaseAuth auth = FirebaseAuth.instance;
  UserController userController = Get.put(UserController());

  Future<bool> createUser({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    required String email,
    required String gender,
    required String password,
  }) async {
    var userRef = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    var result = await addUser(
        firstname: firstname,
        lastname: lastname,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        uid: userRef.user!.uid);

    if (result) {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString('userId', userRef.user!.uid);
      userController.userId.value = userRef.user!.uid;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addUser({
    required String firstname,
    required String lastname,
    required String email,
    required String phoneNumber,
    required String gender,
    required String uid,
  }) async {
    var data = {
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
      "gender": gender,
      "phoneNumber": phoneNumber,
      "id": uid,
      "role": "User",
    };
    await userCol.doc(uid).set(data);
    return true;
  }
}
