import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'PremiumButton.dart';

import '../constant/color.dart';
import '../screens/home/Root.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child:
                    Image.asset("assets/images/thumb.png", fit: BoxFit.cover),
              ),
              10.height,
              Text(
                "Thank You!",
                style: boldTextStyle(size: 35, color: kPrimary),
              ),
              0.height,
              Text(
                "Payment Successful!",
                style: primaryTextStyle(
                  size: 18,
                  color: greenColor,
                ),
              ),
              4.height,
              Text(
                "Your appointment has been booked",
                style: secondaryTextStyle(
                  size: 14,
                ),
              ),
              40.height,
              PremiumButton(
                onTap: () {
                  const Root().launch(context);
                },
                text: "Done",
              ),
              20.height,
            ],
          ).center(),
        ),
      ),
    );
  }
}
