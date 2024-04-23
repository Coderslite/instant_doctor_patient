// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/MedicationController.dart';
import 'package:instant_doctor/screens/medication/MedicationTracker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../models/MedicationModel.dart';

class MedicationSummaryScreen extends StatefulWidget {
  final MedicationModel medication;
  const MedicationSummaryScreen({super.key, required this.medication});

  @override
  State<MedicationSummaryScreen> createState() =>
      _MedicationSummaryScreenState();
}

class _MedicationSummaryScreenState extends State<MedicationSummaryScreen> {
  MedicationController medicationController = Get.put(MedicationController());
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                  Text(
                    "Summary",
                    style: secondaryTextStyle(size: 14),
                  ),
                  10.height,
                  eachSummary(
                      label: "Medication type",
                      description: widget.medication.type!),
                  eachSummary(
                      label: "Medication  Name",
                      description: widget.medication.name!),
                  eachSummary(
                      label: "Start and end date",
                      description:
                          "${DateFormat('yyyy-MM-dd').format(widget.medication.startTime!.toDate())} - ${DateFormat('yyyy-MM-dd').format(widget.medication.endTime!.toDate())}"),
                  // eachSummary(
                  //     label: "Dosage",
                  //     description:
                  //         "${widget.medication.morning} - ${widget.medication.midDay} - ${widget.medication.evening}"),
                  eachSummary(
                      label: "Interval",
                      description: "${widget.medication.interval} Hours daily"),
                  20.height,
                  Row(
                    children: [
                      Checkbox(
                          activeColor: kPrimary,
                          value: isChecked,
                          onChanged: (val) {
                            isChecked = val!;
                            setState(() {});
                          }),
                      Expanded(
                          child: Text(
                        "I accept to recieve notification outside of this app to remind me of my on going trearment and failure to adhere to prescription may render medicaion useless",
                        style: secondaryTextStyle(size: 12),
                      )),
                    ],
                  ),
                  50.height,
                  const CircularProgressIndicator(
                    color: kPrimary,
                  ).center().visible(medicationController.isLoading.value),
                  AppButton(
                    onTap: () async {
                      await medicationController
                          .handleCreateMedication(widget.medication);
                      const MedicationTracker().launch(context);
                    },
                    text: "Add Medication",
                    color: !isChecked ? grey : kPrimary,
                    textColor: white,
                    width: double.infinity,
                    disabledColor: dimGray,
                    disabledTextColor: white,
                    enabled: isChecked,
                  ).visible(!medicationController.isLoading.value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  eachSummary({required String label, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: primaryTextStyle(size: 14),
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kPrimary)),
            child: Text(
              description,
              style: primaryTextStyle(size: 14),
            ).center(),
          ))
        ],
      ),
    );
  }
}
