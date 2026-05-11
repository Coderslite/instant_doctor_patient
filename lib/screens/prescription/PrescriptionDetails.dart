import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/PrescriptionModel.dart';

class Prescriptiondetails extends StatefulWidget {
  final Prescriptionmodel? prescription;
  const Prescriptiondetails({super.key, this.prescription});

  @override
  State<Prescriptiondetails> createState() => _PrescriptiondetailsState();
}

class _PrescriptiondetailsState extends State<Prescriptiondetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  backButton(context),
                  24.width,
                  const Text(
                    "Prescribed Drug",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kText,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: kBorder),
                        boxShadow: [
                          BoxShadow(
                            color: kText.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: kPrimary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.info_outline_rounded,
                                    color: kPrimary, size: 20),
                              ),
                              12.width,
                              const Text(
                                "Drug Information",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: kPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          24.height,
                          Text(
                            widget.prescription?.prescription.validate() ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: kText,
                              height: 1.6,
                            ),
                          ),
                          32.height,
                          const Divider(color: kBorder),
                          16.height,
                          const Text(
                            "Please follow the dosage as recommended by your doctor for effective results.",
                            style: TextStyle(
                              fontSize: 14,
                              color: kSub,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
