import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/medication/MedicationTracker.dart';
import 'package:nb_utils/nb_utils.dart';

class IntroMedicationTracker extends StatefulWidget {
  const IntroMedicationTracker({super.key});

  @override
  State<IntroMedicationTracker> createState() => _IntroMedicationTrackerState();
}

class _IntroMedicationTrackerState extends State<IntroMedicationTracker> {
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
                children: const [
                  BackButton(),
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
                      SizedBox(
                          width: 150,
                          height: 150,
                          child: Image.asset(
                            "assets/images/med.png",
                          )),
                      70.height,
                      Text(
                        "Medication Tracker",
                        style: boldTextStyle(size: 16),
                      ),
                      10.height,
                      Text(
                        "Join millions of people already taking control of their meds!             ",
                        textAlign: TextAlign.center,
                        style: secondaryTextStyle(size: 12),
                      ),
                    ],
                  ),
                  AppButton(
                    width: double.infinity,
                    onTap: () {
                      const MedicationTracker().launch(context);
                    },
                    text: "Continue",
                    textColor: white,
                    color: kPrimary,
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
