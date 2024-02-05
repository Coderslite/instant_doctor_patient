import 'package:flutter/material.dart';
import 'package:instant_doctor/screens/medication/MedicationTracker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';

class CompleteMedicationScreen extends StatefulWidget {
  const CompleteMedicationScreen({super.key});

  @override
  State<CompleteMedicationScreen> createState() =>
      _CompleteMedicationScreenState();
}

class _CompleteMedicationScreenState extends State<CompleteMedicationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Text(
                    "Medication Tracker",
                    style: boldTextStyle(color: kPrimary),
                  ),
                  const Text(""),
                ],
              ),
              20.height,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Column(
                      children: [
                        Text(
                          "Good Job",
                          style: boldTextStyle(color: kPrimary, size: 18),
                        ),
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: Image.asset(
                            "assets/images/thumb.png",
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Text(
                          "You have successfully finished your medication",
                          textAlign: TextAlign.center,
                          style: secondaryTextStyle(size: 16),
                        ),
                      ],
                    ),
                    AppButton(
                      onTap: () {
                        const MedicationTracker().launch(context);
                      },
                      text: "Done",
                      textColor: white,
                      color: kPrimary,
                      width: double.infinity,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
