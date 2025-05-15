// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/AppointmentReportModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/ReportService.dart';
import 'AllReports.dart';

class CreateReportScreen extends StatefulWidget {
  final String userId;
  final String doctorId;
  final String appointmentId;
  const CreateReportScreen(
      {super.key,
      required this.userId,
      required this.doctorId,
      required this.appointmentId});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final reportService = Get.find<ReportService>();

  var category = '';
  var reportController = TextEditingController();
  bool isSending = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                backButton(context),
                Text(
                  "Create Report",
                  style: boldTextStyle(
                    color: kPrimary,
                    size: 14,
                  ),
                ),
                const Text("     "),
              ],
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                30.height,
                Text(
                  "Subject",
                  style: secondaryTextStyle(size: 12),
                ),
                5.height,
                Card(
                  color: context.cardColor,
                  child: DropdownButtonFormField(
                    items: [
                      "Network Issue",
                      "Doctor stopped Responding",
                      "Illness Still Persists",
                      "Medication recommended  isn't working",
                      "Others",
                    ]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    dropdownColor: context.cardColor,
                    style: primaryTextStyle(),
                    onChanged: (val) {
                      category = val.toString();
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      fillColor: context.cardColor,
                      filled: true,
                      hintText: "Select Category....",
                      hintStyle: secondaryTextStyle(),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                10.height,
                Text(
                  "Additional Information",
                  style: secondaryTextStyle(size: 12),
                ),
                5.height,
                Card(
                  color: context.cardColor,
                  child: AppTextField(
                    textFieldType: TextFieldType.OTHER,
                    controller: reportController,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 500,
                    textStyle: primaryTextStyle(),
                    decoration: InputDecoration(
                      hintText: "Type here....",
                      hintStyle: secondaryTextStyle(),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                20.height,
                const CircularProgressIndicator(
                  color: kPrimary,
                ).visible(isSending).center(),
                AppButton(
                  onTap: () async {
                    try {
                      isSending = true;
                      setState(() {});
                      var report = AppointmentReportModel(
                        subject: category,
                        report: reportController.text,
                        userId: widget.userId,
                        doctorId: widget.doctorId,
                        appointmentId: widget.appointmentId,
                        status: "Pending",
                        createdAt: Timestamp.now(),
                        updatedAt: Timestamp.now(),
                      );
                      await reportService.createReport(report);
                      toast("Report Created");
                      reportController.clear();
                      category = "";
                      setState(() {});
                      const AllReportScreen().launch(context);
                    } finally {
                      isSending = false;
                      setState(() {});
                    }
                  },
                  color: kPrimary,
                  width: double.infinity,
                  text: "Submit",
                  textColor: white,
                ).visible(!isSending)
              ],
            ))
          ],
        ),
      )),
    );
  }
}
