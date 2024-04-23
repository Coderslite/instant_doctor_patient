import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/email_screen.dart';
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
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  String link = 'https://instantdoctor.page.link/refer';
  String? userId = '';

  handleNext() async {
    getUserId();
    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (user != null) {
        return const Root().launch(context);
      } else {
        return const OnboardingScreen().launch(context);
      }
    });
  }

  checkDynamicLink() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getDynamicLink(Uri.parse(link));
    final Uri? uri = initialLink?.link;
    final queryParams = uri?.queryParameters;
    userId = queryParams?['userId'].toString();
    setState(() {});
    if (userId != 'null' && userId != null) {
      Future.delayed(const Duration(seconds: 3)).then((value) {
        EmailScreen(
          userId: userId,
        ).launch(context);
      });
    } else {
      handleNext();
    }
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      print(dynamicLinkData);
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      final referral = queryParams['userId'].toString();
      if (referral.toString() != 'null') {
        Future.delayed(const Duration(seconds: 1)).then((value) {
          EmailScreen(userId: referral).launch(context);
        });
      }
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  @override
  void initState() {
    initDynamicLinks();
    checkDynamicLink();

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
