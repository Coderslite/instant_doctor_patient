import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:instant_doctor/screens/authentication/success_signup.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:instant_doctor/services/AuthenticationService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/constants.dart';
import '../services/GetUserId.dart';

class AuthenticationController extends GetxController {
  AuthenticationService authenticationService = AuthenticationService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      "email",
      "profile",
      "openid",
      "https://www.googleapis.com/auth/userinfo.email",
    ],
  );
  RxBool isLoading = false.obs;
  RxBool googleSignin = false.obs;
  Future<bool> handleCheckEmail(String email) async {
    isLoading.value = true;
    var ref =
        await db.collection("Users").where("email", isEqualTo: email).get();
    isLoading.value = false;
    return ref.docs.isEmpty;
  }

  Future<UserCredential> handleAuthGoogleSignin(
      BuildContext context, GoogleSignInAccount userCred) async {
    final GoogleSignInAuthentication googleAuth = await userCred.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    var userRef = await FirebaseAuth.instance.signInWithCredential(credential);
    return userRef;
  }

  handleGoogleSignin(BuildContext context) async {
    try {
      googleSignin.value = true;

      GoogleSignInAccount? userCred = await _googleSignIn.signIn();

      if (userCred != null) {
        if ((await handleCheckEmail(userCred.email)) == false) {
          var result = await handleAuthGoogleSignin(context, userCred);
          var prefs = await SharedPreferences.getInstance();
          prefs.setString("userId", result.user!.uid);
          userController.userId.value = result.user!.uid;
        } else {
          var result = await handleAuthGoogleSignin(context, userCred);
          var prefs = await SharedPreferences.getInstance();
          prefs.setString("userId", result.user!.uid);
          userController.userId.value = result.user!.uid;

          await AuthenticationService().addUser(
              firstname: userCred.displayName!,
              lastname: '',
              email: userCred.email,
              phoneNumber: '',
              gender: '',
              uid: result.user!.uid);
        }

        Root().launch(context);
      }
    } catch (error) {
      print(error);
      toast("$error");
    } finally {
      googleSignin.value = false;
    }
  }

  handleSignIn(
      {required String email,
      required String password,
      required BuildContext context}) async {
    isLoading.value = true;
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      isLoading.value = false;
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", value.user!.uid);
      userController.userId.value = value.user!.uid;
      Root().launch(context);
      toast("Login Successful");
    }).catchError((err) {
      isLoading.value = false;
      toast("$err");
    });
  }

  handleRegister({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required BuildContext context,
  }) async {
    isLoading.value = true;
    var result = await authenticationService.createUser(
        firstname: firstname,
        lastname: lastname,
        phoneNumber: phoneNumber,
        email: email,
        gender: gender,
        password: password);
    if (result) {
      isLoading.value = false;
      SuccessSignUp().launch(context);
    } else {
      isLoading.value = false;
      toast("Something went wrong");
    }
  }

  handleLogout(BuildContext context) async {
    FirebaseAuth.instance.signOut().then((value) async {
      await _googleSignIn.signOut();
      userService.updateStatus(
          userId: userController.userId.value, status: OFFLINE);
      var prefs = await SharedPreferences.getInstance();
      prefs.remove('userId');
      const LoginScreen().launch(context);
    });
  }
}
