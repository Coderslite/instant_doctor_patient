import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/models/MedicationModel.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';

class ActiveMedicationScreen extends StatefulWidget {
  final MedicationModel medication;
  const ActiveMedicationScreen({super.key, required this.medication});

  @override
  State<ActiveMedicationScreen> createState() => _ActiveMedicationScreenState();
}

class _ActiveMedicationScreenState extends State<ActiveMedicationScreen> {
  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime startDate = widget.medication.startTime!.toDate();
    DateTime endDate = widget.medication.endTime!.toDate();
    int currentDay = currentDate.isBefore(startDate)
        ? 0
        : currentDate.difference(startDate).inDays + 1;

    // Check if the medication is expired
    bool isExpired = currentDate.isAfter(endDate);

    // Calculate the total days of the medication
    int totalDays = endDate.difference(startDate).inDays + 1;
    double progressValue = currentDay / totalDays;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    backButton(context),
                    Text(
                      "Medication Tracker",
                      style: boldTextStyle(color: kPrimary),
                    ),
                    const Text(""),
                  ],
                ),
                20.height,
                Text(
                  "Time to take your medication",
                  style: secondaryTextStyle(size: 14),
                ),
                10.height,
                eachSummary(
                    label: "Medication  Name",
                    description: widget.medication.name!),
                eachSummary(
                    label: "Prescription",
                    description: widget.medication.prescription.validate()),
                eachSummary(
                    label: "Start and end date",
                    description:
                        "${DateFormat('yyyy-MM-dd').format(widget.medication.startTime!.toDate())} - ${DateFormat('yyyy-MM-dd').format(widget.medication.endTime!.toDate())}"),
                // eachSummary(
                //     label: "Dosage",
                //     description:
                //         "${widget.medication.morning} - ${widget.medication.midDay} - ${widget.medication.evening}"),
                // eachSummary(
                //     label: "Interval",
                //     description: "${widget.medication.interval} Hours daily"),
                50.height,
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    backgroundColor: grey,
                    color: kPrimary,
                    value: progressValue,
                  ),
                ),
                5.height,
                Row(
                  children: [
                    Text(
                      isExpired
                          ? "Medication Period has expired"
                          : "Good job Day $currentDay of $totalDays",
                      style: secondaryTextStyle(
                          size: 12, color: isExpired ? redColor : null),
                    ),
                  ],
                ),
                30.height,
                AppButton(
                  onTap: () {
                    toast("Medication Taken");
                  },
                  text: "Taken",
                  color: kPrimary,
                  textColor: white,
                  width: double.infinity,
                ),
              ],
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
