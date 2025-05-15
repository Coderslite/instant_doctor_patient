import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../screens/home/Root.dart';

class SuccessReportScreen extends StatefulWidget {
  const SuccessReportScreen({super.key});

  @override
  State<SuccessReportScreen> createState() => _SuccessReportScreenState();
}

class _SuccessReportScreenState extends State<SuccessReportScreen> {
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
                "Report Submitted",
                style: primaryTextStyle(
                  size: 16,
                ),
              ),
              40.height,
              AppButton(
                onTap: () {
                  const Root().launch(context);
                },
                text: "Done",
                width: double.infinity,
                color: kPrimary,
                textColor: white,
              ),
              20.height,
            ],
          ).center(),
        ),
      ),
    );
  }
}
