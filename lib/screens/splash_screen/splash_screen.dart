import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/ConnectivityController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/auth_screen.dart';
import 'package:instant_doctor/screens/authentication/create_pin.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:instant_doctor/screens/authentication/otp_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:upgrader/upgrader.dart';
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
    Future.delayed(const Duration(seconds: 2)).then((value) async {
      // Check if the user is in the OTP stage
      ConnectivityController connectivityController =
          Get.put(ConnectivityController());
      await connectivityController.initConnectivity();
      bool isOTPStage = await _checkOTPStage();
      var prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userId').validate();
      print(user);
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
      } else if (user != null && userId.isNotEmpty) {
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
        // color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with clean styling
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/logo1.png",
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App name
              Text(
                "Instant Doctor",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              Text(
                "Professional Healthcare",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 48),

              // Simple loading indicator
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
