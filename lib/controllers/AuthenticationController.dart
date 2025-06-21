import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:instant_doctor/screens/authentication/otp_screen.dart';
import 'package:instant_doctor/screens/authentication/success_signup.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:instant_doctor/services/AuthenticationService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../constant/constants.dart';
import '../services/GetUserId.dart';
import '../services/ReferralService.dart';
import '../services/UserService.dart';
import 'ZegocloudController.dart';

class AuthenticationController extends GetxController {
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
  RxString otp = ''.obs;

  final authenticationService = Get.find<AuthenticationService>();
  final userService = Get.find<UserService>();
  var referralService = Get.find<ReferralService>();

  Future<bool> handleCheckEmail(String email) async {
    isLoading.value = true;
    var ref = await db
        .collection("Users")
        .where("email", isEqualTo: email.toLowerCase())
        .get();
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

  handleGoogleSignin(BuildContext context, {required String referredBy}) async {
    try {
      googleSignin.value = true;
      final zegoCloudController = Get.find<ZegoCloudController>();

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
            photoUrl: userCred.photoUrl.validate(),
            gender: '',
            uid: result.user!.uid,
            password: '',
          );
          if (referredBy.isNotEmpty) {
            await referralService.newReferral(
                userId: userController.userId.value, referredBy: referredBy);
          }
        }
        await zegoCloudController.handleInit();
        const Root().launch(context);
      }
    } catch (error) {
      print(error);
      toast("$error");
    } finally {
      googleSignin.value = false;
    }
  }

  Future<void> handleAppleSignIn(BuildContext context) async {
    try {
      final zegoCloudController = Get.find<ZegoCloudController>();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential using the Apple ID token and access token
      final oAuthProvider = OAuthProvider("apple.com");
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Once signed in, handle saving the user details (similar to Google Sign-In flow)
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", authResult.user!.uid);
      userController.userId.value = authResult.user!.uid;

      // Optionally add user data to Firestore or your database if it's a new user
      if (authResult.additionalUserInfo?.isNewUser == true) {
        await AuthenticationService().addUser(
            firstname: appleCredential.givenName ?? '',
            lastname: appleCredential.familyName ?? '',
            email: appleCredential.email ?? '',
            phoneNumber: '',
            gender: '',
            uid: authResult.user!.uid,
            password: '',
            photoUrl: '');
      }
      await zegoCloudController.handleInit();
      // Navigate to the home screen or root after successful login
      const Root().launch(context);
      toast("Login Successful with Apple");
    } catch (error) {
      print("Error during Apple Sign-In: $error");
      toast("Apple Sign-In failed: $error");
    }
  }

  handleSignIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    isLoading.value = true;
    try {
      final zegoCloudController = Get.find<ZegoCloudController>();
      final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );
      print(value);
      isLoading.value = false;

      var prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", value.user!.uid);
      userController.userId.value = value.user!.uid;

      await zegoCloudController.handleInit();
      const Root().launch(context);
      toast("Login Successful");
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String errorMessage = "An error occurred. Please try again later.";

      // Handle specific FirebaseAuthException error codes
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Invalid Credentials. Please try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many failed attempts. Please try again later.";
      }
      toast(errorMessage);
      print(e.code);
    } catch (err) {
      isLoading.value = false;
      toast("Something went wrong. Please try again.");
      print(err);
    }
  }

  handleRegister({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String phoneNumber,
    required String gender,
    required String referredBy,
    required BuildContext context,
  }) async {
    final zegoCloudController = Get.find<ZegoCloudController>();
    isLoading.value = true;
    var result = await authenticationService.createUser(
      firstname: firstname,
      lastname: lastname,
      phoneNumber: phoneNumber,
      email: email.toLowerCase(),
      gender: gender,
      password: password,
      referredBy: referredBy,
    );
    if (result) {
      isLoading.value = false;
      await zegoCloudController.handleInit();
      const SuccessSignUp().launch(context);
    } else {
      isLoading.value = false;
      errorSnackBar(title: "Something went wrong");
    }
  }

  handleLogout(BuildContext context) async {
    FirebaseAuth.instance.signOut().then((value) async {
      final zegoCloudController = Get.find<ZegoCloudController>();
      await _googleSignIn.signOut();
      userService.updateStatus(
          userId: userController.userId.value, status: OFFLINE);
      var prefs = await SharedPreferences.getInstance();
      prefs.remove('userId');
      const LoginScreen().launch(context);
      zegoCloudController.onUserLogout();
    });
  }

  handleSendOTP(
      {required String email,
      required String firstname,
      required String lastname,
      required String password,
      required String phoneNumber,
      required String gender,
      required bool isResetPassword,
      required String referredBy}) async {
    try {
      isLoading.value = true;
      await authenticationService.handleSendOTP(email: email);
      successSnackBar(title: "OTP sent successfully");
      OTPScreen(
              isResetPassword: isResetPassword,
              firstname: firstname,
              lastname: lastname,
              email: email,
              password: password,
              phoneNumber: phoneNumber,
              gender: gender,
              referredBy: referredBy)
          .launch(Get.context!);
    } finally {
      isLoading.value = false;
    }
  }
}
