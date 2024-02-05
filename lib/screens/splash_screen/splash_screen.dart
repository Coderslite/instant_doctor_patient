import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../services/GetUserId.dart';
import '../home/Root.dart';
import '../onboarding/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  handleNext() async {
    getUserId();
    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (user != null) {
        return Root().launch(context);
      } else {
        return const OnboardingScreen().launch(context);
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
            image: AssetImage("assets/images/bg5.png"),
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
