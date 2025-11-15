import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/ConnectivityController.dart';
import 'package:instant_doctor/controllers/ZegocloudController.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/screens/authentication/auth_screen.dart';
import 'package:instant_doctor/screens/authentication/create_pin.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:instant_doctor/screens/authentication/otp_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
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
    return prefs.getBool('isOTPStage') ?? false;
  }

  Future<void> handleNext() async {
    try {
      final results = await Future.wait<Object>([
        _checkOTPStage(),
        Get.putAsync(() async {
          final connectivityController = Get.put(ConnectivityController());
          await connectivityController.initConnectivity();
          return connectivityController;
        }),
      ]);
      var prefs = await SharedPreferences.getInstance();

      final bool isOTPStage = results[0] as bool;
      final userId = prefs.getString('userId').validate();

      if (isOTPStage) {
        // Navigate to OTP screen...
      } else if (user != null && userId.isNotEmpty) {
        await Future.wait<void>([
          getUserId(),
          zegoCloudController.handleInit(),
        ]);

        if (userController.pin.value.validate().isEmpty) {
          CreatePinScreen().launch(context, isNewTask: true);
        } else {
          AuthScreen(fromApp: false).launch(context, isNewTask: true);
        }
      } else {
        LoginScreen().launch(context, isNewTask: true);
      }
    } catch (e) {
      debugPrint("Error during splash init: $e");
      LoginScreen().launch(context, isNewTask: true);
    }
  }

  @override
  void initState() {
    super.initState();
    // Start async navigation immediately without fixed delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              "Instant Doctor",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Professional Healthcare",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
