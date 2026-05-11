// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/LapResultModel.dart';
import 'package:instant_doctor/screens/lab_result/AvailableLabResult.dart';
import 'package:instant_doctor/screens/lab_result/LapResultPricing.dart';
import 'package:instant_doctor/services/LabResultService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class LabResultScreen extends StatefulWidget {
  const LabResultScreen({super.key});

  @override
  State<LabResultScreen> createState() => _LabResultScreenState();
}

class _LabResultScreenState extends State<LabResultScreen> {
  final labResultService = Get.find<LabResultService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    backButton(context),
                    Text(
                      "Lab Reports",
                      style: boldTextStyle(size: 22, color: ink, letterSpacing: -0.5),
                    ),
                    GestureDetector(
                      onTap: () => const LabResultPricing().launch(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: obsidian,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: obsidian.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, color: white, size: 18),
                            4.width,
                            Text("New", style: boldTextStyle(color: white, size: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.height,
              Expanded(
                  child: StreamBuilder<List<LabResultModel>>(
                      stream: labResultService.getUserLabResult(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data!;
                          return data.isEmpty
                              ? Text(
                                  "No lab result uploaded",
                                  style: boldTextStyle(),
                                ).center()
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: data.length,
                                  itemBuilder: ((context, index) {
                                    var labResult = data[index];
                                    return Slidable(
                                      key: ValueKey(labResult.id),
                                      startActionPane: ActionPane(
                                        // A motion is a widget used to control how the pane animates.
                                        motion: const ScrollMotion(),

                                        // A pane can dismiss the Slidable.
                                        dismissible: DismissiblePane(
                                            onDismissed: () async {
                                          await labResultService
                                              .deleteLabResult(
                                                  id: labResult.id.validate());
                                        }),

                                        // All actions are defined in the children parameter.
                                        children: [
                                          // A SlidableAction can have an icon and/or a label.
                                          SlidableAction(
                                            onPressed: (s) async {
                                              await labResultService
                                                  .deleteLabResult(
                                                      id: labResult.id
                                                          .validate());
                                            },
                                            backgroundColor:
                                                const Color(0xFFFE4A49),
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Delete',
                                          ),
                                          // SlidableAction(
                                          //   onPressed: doNothing,
                                          //   backgroundColor: Color(0xFF21B7CA),
                                          //   foregroundColor: Colors.white,
                                          //   icon: Icons.share,
                                          //   label: 'Share',
                                          // ),
                                        ],
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: border),
                                          boxShadow: [
                                            BoxShadow(
                                              color: obsidian.withOpacity(0.02),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(20),
                                            onTap: () {
                                              if (labResult.status != 'Completed') {
                                                errorSnackBar(
                                                  context: context,
                                                  title: "Interpreted Lab Result is not available yet");
                                                return;
                                              }
                                              if (!labResult.opened.validate()) {
                                                labResultService.updateOpened(
                                                    id: labResult.id.validate());
                                              }
                                              LabResultAvailable(
                                                labResult: labResult,
                                              ).launch(context);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: kPrimary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(14),
                                                    ),
                                                    child: const Icon(
                                                      Icons.article_rounded,
                                                      size: 24,
                                                      color: kPrimary,
                                                    ),
                                                  ),
                                                  16.width,
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Lab Report #${index + 1}",
                                                              style: boldTextStyle(size: 15, color: ink),
                                                            ),
                                                            if (!labResult.opened.validate() && labResult.status.validate() == 'Completed') ...[
                                                              8.width,
                                                              Container(
                                                                width: 8,
                                                                height: 8,
                                                                decoration: const BoxDecoration(
                                                                  color: fireBrick,
                                                                  shape: BoxShape.circle,
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                        4.height,
                                                        Text(
                                                          timeago.format(labResult.createdAt!.toDate()),
                                                          style: secondaryTextStyle(size: 12, color: slate),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: labResult.status.validate() == 'Completed'
                                                          ? mediumSeaGreen.withOpacity(0.1)
                                                          : amber.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      labResult.status.validate() == 'Completed' ? "Completed" : "Pending",
                                                      style: boldTextStyle(
                                                        color: labResult.status.validate() == 'Completed' ? mediumSeaGreen : amber,
                                                        size: 11,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }));
                        }
                        return const CircularProgressIndicator(
                          color: kPrimary,
                        ).center();
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
