// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/LapResultModel.dart';
import 'package:instant_doctor/screens/lap_result/AvailableLabResult.dart';
import 'package:instant_doctor/screens/lap_result/LapResultPricing.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class LabResultScreen extends StatefulWidget {
  const LabResultScreen({super.key});

  @override
  State<LabResultScreen> createState() => _LabResultScreenState();
}

class _LabResultScreenState extends State<LabResultScreen> {
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
                    "Lab Result",
                    style: boldTextStyle(
                      size: 16,
                      color: kPrimary,
                    ),
                  ),
                  TextButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                    onPressed: () {
                      const LabResultPricing().launch(context);
                    },
                    child: Text(
                      "New",
                      style: primaryTextStyle(
                        color: white,
                      ),
                    ),
                  ),
                ],
              ),
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
                                      child: Card(
                                        color: context.cardColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.file_copy,
                                                    size: 26,
                                                    color: kPrimary,
                                                  ),
                                                  10.width,
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Lab Result ${index + 1}",
                                                            style:
                                                                boldTextStyle(
                                                              size: 14,
                                                              color: kPrimary,
                                                            ),
                                                          ),
                                                          10.width,
                                                          Icon(
                                                            Icons
                                                                .notifications_active,
                                                            color: fireBrick,
                                                            size: 18,
                                                          ).visible(!labResult
                                                              .opened
                                                              .validate() &&  labResult.status
                                                                .validate() ==
                                                            'Completed'),
                                                        ],
                                                      ),
                                                      Text(
                                                        timeago.format(labResult
                                                            .createdAt!
                                                            .toDate()),
                                                        style:
                                                            secondaryTextStyle(
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Status",
                                                    style: secondaryTextStyle(
                                                      size: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    labResult.status
                                                                .validate() ==
                                                            'Completed'
                                                        ? "Completed"
                                                        : "Pending",
                                                    style: primaryTextStyle(
                                                      color: labResult.status
                                                                  .validate() ==
                                                              'Completed'
                                                          ? mediumSeaGreen
                                                          : null,
                                                      size: 12,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ).onTap(() {
                                            if (!labResult.opened.validate()) {
                                              labResultService.updateOpened(
                                                  id: labResult.id.validate());
                                            }
                                            LabResultAvailable(
                                              labResult: labResult,
                                            ).launch(context);
                                          }),
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
