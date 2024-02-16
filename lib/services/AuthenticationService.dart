import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/UserController.dart';
import 'BaseService.dart';
import 'generateUserTag.dart';

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
    required String referredBy,
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
      if (referredBy.isNotEmpty) {
        await referralService.newReferral(
            userId: userController.userId.value, referredBy: referredBy);
      }
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
    var prefs = await SharedPreferences.getInstance();
    var tag = generateTag(firstname);
    prefs.setString('tag', tag);
    var data = {
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
      "gender": gender,
      "phoneNumber": phoneNumber,
      "id": uid,
      "tag": tag,
      "role": "User",
    };
    await userCol.doc(uid).set(data);
    return true;
  }

  handleListenAuth() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && user.emailVerified) {
        // Email is verified, proceed with your app logic
      }
    });
  }

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      toast('Verification email sent to ${user.email}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      toast("A reset password link as been sent to your mail");
      // Password reset email sent successfully
    } catch (error) {
      // Handle errors, such as invalid email or user not found
      toast('Error sending password reset email');
      print('Error sending password reset email: $error');
    }
  }
}
