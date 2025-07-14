import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/auth_screen.dart';
import 'package:instant_doctor/screens/authentication/create_pin.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:instant_doctor/screens/authentication/otp_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../controllers/AuthenticationController.dart';
import '../../controllers/ZegocloudController.dart';
import '../../services/GetUserId.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final zegoCloudController = Get.find<ZegoCloudController>();
  final authenticationController = Get.find<AuthenticationController>();

  Future<bool> _checkOTPStage() async {
    final prefs = await SharedPreferences.getInstance();
    bool isOTPStage = prefs.getBool('isOTPStage') ?? false;
    return isOTPStage;
  }

  handleNext() async {
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      // Check if the user is in the OTP stage
      bool isOTPStage = await _checkOTPStage();

      if (isOTPStage) {
        // Retrieve stored OTP-related data from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String email = prefs.getString('otpEmail') ?? '';
        String firstname = prefs.getString('otpFirstname') ?? '';
        String lastname = prefs.getString('otpLastname') ?? '';
        String password = prefs.getString('otpPassword') ?? '';
        String phoneNumber = prefs.getString('otpPhoneNumber') ?? '';
        String gender = prefs.getString('otpGender') ?? '';
        String otpFor = prefs.getString('otpFor') ?? '';
        String referredBy = prefs.getString('otpReferredBy') ?? '';

        // Navigate to OTPScreen with the required parameters
        OTPScreen(
          otpFor: otpFor,
          firstname: firstname,
          lastname: lastname,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          gender: gender,
          referredBy: referredBy,
        ).launch(context, isNewTask: true);
      } else if (user != null) {
        await getUserId();
        await zegoCloudController.handleInit();
        print("user pin is: ${userController.pin.value}");
        if (userController.pin.value.validate().isEmpty) {
          CreatePinScreen().launch(context, isNewTask: true);
        } else {
          AuthScreen(fromApp: false).launch(context, isNewTask: true);
        }
      } else {
        LoginScreen().launch(context, isNewTask: true);
      }
    });
  }

  @override
  void initState() {
    handleNext();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/thumbnail1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  "assets/images/logo1.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            20.height,
            // const SpinKitFadingCircle(
            //   color: kPrimary,
            //   size: 50.0,
            // ).center()
          ],
        ).center(),
      ),
    );
  }
}