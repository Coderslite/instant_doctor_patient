import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:nb_utils/nb_utils.dart';

class SuccessPassReset extends StatefulWidget {
  const SuccessPassReset({super.key});

  @override
  State<SuccessPassReset> createState() => _SuccessPassResetState();
}

class _SuccessPassResetState extends State<SuccessPassReset> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Password Reset Succesful Check Your Mail",
              textAlign: TextAlign.center,
              style: boldTextStyle(color: whiteColor),
            ),
            20.height,
            AppButton(
              onTap: () {
                LoginScreen().launch(context);
              },
              text: "Back to Sign in",
              textColor: kPrimary,
            )
          ],
        ),
      ),
    );
  }
}
