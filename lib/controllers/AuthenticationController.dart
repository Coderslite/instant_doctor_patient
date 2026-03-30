import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/controllers/LocationController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/create_pin.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:instant_doctor/screens/authentication/otp_screen.dart';
import 'package:instant_doctor/screens/authentication/success_signup.dart';
import 'package:instant_doctor/services/AuthenticationService.dart';
import 'package:nb_utils/nb_utils.dart' hide log;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../constant/constants.dart';
import '../screens/authentication/referral_screen.dart';
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
      GoogleSignInAccount? userCred = await _googleSignIn.signIn();

      if (userCred != null) {
        if ((await handleCheckEmail(userCred.email)) == false) {
          if (!context.mounted) return;
          var result = await handleAuthGoogleSignin(context, userCred);
          if (!context.mounted) return;
          await handlePostAuth(
            userId: result.user!.uid,
            email: userCred.email,
            context: context,
            nextScreen: CreatePinScreen(),
          );
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
          if (!context.mounted) return;
          await handlePostAuth(
            userId: result.user!.uid,
            email: userCred.email,
            context: context,
            nextScreen: ReferralRegistrationScreen(),
            isNewUser: true,
          );
        }
      }
    } catch (error) {
      log(error.toString());
      toast("$error");
    } finally {
      googleSignin.value = false;
    }
  }

  handleSignIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.signOut();
      final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );
      log(value.toString());
      isLoading.value = false;
      if (!context.mounted) return;
      await handlePostAuth(
        userId: value.user!.uid,
        email: email,
        context: context,
        nextScreen: CreatePinScreen(),
      );
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
      log(e.code);
    } catch (err) {
      isLoading.value = false;
      toast("Something went wrong. Please try again.");
      log(err.toString());
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
      if (!context.mounted) return;
      await handlePostAuth(
        userId: userController.userId.value,
        email: email,
        context: context,
        nextScreen: const SuccessSignUp(),
      );
    } else {
      isLoading.value = false;
      if (!context.mounted) return;
      errorSnackBar(context: context, title: "Something went wrong");
    }
  }

  handleLogout(BuildContext context) async {
    FirebaseAuth.instance.signOut().then((value) async {
      if (!context.mounted) return;
      const LoginScreen().launch(context, isNewTask: true);
      final zegoCloudController = Get.find<ZegoCloudController>();
      await _googleSignIn.signOut();
      userService.updateStatus(
          userId: userController.userId.value, status: OFFLINE);
      var prefs = await SharedPreferences.getInstance();
      userController.userId.value = '';
      userController.pin.value = '';
      prefs.remove('userId');
      prefs.remove('pin');
      zegoCloudController.onUserLogout();
    });
  }

  Future<void> handleSendOTP({
    required BuildContext context,
    required String email,
    required String firstname,
    required String lastname,
    required String password,
    required String phoneNumber,
    required String gender,
    required String otpFor,
    required String referredBy,
  }) async {
    try {
      isLoading.value = true;
      if (otpFor == OtpFor.login) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.toLowerCase(),
            password: password,
          );
        } catch (ere) {
          if (!context.mounted) return;
          errorSnackBar(context: context, title: "Invalid Email or Password");
          return;
        }
      }

      // Store OTP stage and related data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isOTPStage', true);
      await prefs.setString('otpEmail', email);
      await prefs.setString('otpFirstname', firstname);
      await prefs.setString('otpLastname', lastname);
      await prefs.setString('otpPassword', password);
      await prefs.setString('otpPhoneNumber', phoneNumber);
      await prefs.setString('otpGender', gender);
      await prefs.setString('otpFor', otpFor);
      await prefs.setString('otpReferredBy', referredBy);

      await authenticationService.handleSendOTP(email: email);
      if (!context.mounted) return;
      successSnackBar(context: context, title: "OTP sent successfully");
      OTPScreen(
        otpFor: otpFor,
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        gender: gender,
        referredBy: referredBy,
      ).launch(Get.context!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearOTPStage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isOTPStage');
    await prefs.remove('otpEmail');
    await prefs.remove('otpFirstname');
    await prefs.remove('otpLastname');
    await prefs.remove('otpPassword');
    await prefs.remove('otpPhoneNumber');
    await prefs.remove('otpGender');
    await prefs.remove('otpFor');
    await prefs.remove('otpReferredBy');
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> handleAppleSignIn(BuildContext context,
      {required String referredBy}) async {
    try {
      isLoading.value = true;
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Perform Apple Sign-In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce, // Pass the hashed nonce
      );

      // Validate the idToken
      if (appleCredential.identityToken == null) {
        throw Exception("Apple Sign-In failed: No identity token returned.");
      }

      // Create OAuth credential for Apple
      final oAuthProvider = OAuthProvider("apple.com");
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken!,
        rawNonce: rawNonce, // Pass the raw nonce
        accessToken:
            appleCredential.authorizationCode, // Include authorization code
      );

      // Sign in to Firebase with the Apple credential
      final authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get user email (handle private email relay)
      String email = appleCredential.email ??
          authResult.user?.email ??
          "${authResult.user!.uid}@apple.user";

      // Check if user already exists in Firestore
      bool isNewUser = await handleCheckEmail(email);

      if (!context.mounted) return;
      await handlePostAuth(
        userId: authResult.user!.uid,
        email: email,
        context: context,
        nextScreen:
            isNewUser ? ReferralRegistrationScreen() : CreatePinScreen(),
      );
      toast("Login Successful with Apple");

      // If user is new, add their details to Firestore
      if (isNewUser) {
        await AuthenticationService().addUser(
          firstname: appleCredential.givenName ?? '',
          lastname: appleCredential.familyName ?? '',
          email: email,
          phoneNumber: '',
          photoUrl: '',
          gender: '',
          uid: authResult.user!.uid,
          password: '',
        );
        if (!context.mounted) return;
        ReferralRegistrationScreen().launch(context);
      } else {
        if (!context.mounted) return;
        CreatePinScreen().launch(context);
      }
    } catch (error) {
      log("Error during Apple Sign-In: $error");
      if (error is FirebaseAuthException &&
          error.code == 'invalid-credential') {
        toast("Apple Sign-In failed: Invalid credentials. Please try again.");
      } else if (error is SignInWithAppleAuthorizationException) {
        if (error.code == AuthorizationErrorCode.canceled) {
          toast("Apple Sign-In was canceled by the user.");
        } else {
          toast("Apple Sign-In failed: ${error.message}");
        }
      } else {
        toast("Apple Sign-In failed: $error");
      }
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  Future<void> handlePostAuth({
    required String userId,
    required String email,
    required BuildContext context,
    required Widget nextScreen,
    bool isNewUser = false,
  }) async {
    try {
      final zegoCloudController = Get.find<ZegoCloudController>();

      // Save user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId);
      userController.userId.value = userId;

      // Init services
      await zegoCloudController.handleInit();

      // Run location + currency in background (don't block UI)
      Future.microtask(() async {
        await Get.find<LocationController>()
            .handleGetMyLocation(isLogin: true, email: email);
      });

      // Navigate
      if (!context.mounted) return;
      nextScreen.launch(context, isNewTask: true);
    } catch (e) {
      log("Post auth error: $e");
    }
  }
}
