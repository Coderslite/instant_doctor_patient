// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../controllers/ZegocloudController.dart';
import '../../services/GetUserId.dart';
import '../home/Root.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? userId = '';
  final zegoCloudController = Get.find<ZegoCloudController>();

  handleNext() async {
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      if (user != null) {
        await getUserId();
        await zegoCloudController.handleInit();
        return Root().launch(context, isNewTask: true);
      } else {
        return LoginScreen().launch(context, isNewTask: true);
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
