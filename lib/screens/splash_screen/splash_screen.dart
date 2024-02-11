import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/chat/VideoCall.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../controllers/FirebaseMessaging.dart';
import '../../controllers/IncomingCallController.dart';
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

  checkForInitialMessage() async {
    RemoteMessage? message = await firebaseMessaging.getInitialMessage();
    if (message != null) {
      var payload = message.data;
      toast("there is message");
      if (payload['type'] == 'Call') {
        Future.delayed(const Duration(seconds: 3)).then((value) {
          toast("${payload['id']}");
          IncomingCall().showCalling(payload['id']);
          // VideoCall(appointmentId: payload['id']).launch(context);
        });
      } else {
        toast("not a call messge");
      }
    } else {
      handleNext();
      toast("no message gotten");
    }
  }

  @override
  void initState() {
    checkForInitialMessage();
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
