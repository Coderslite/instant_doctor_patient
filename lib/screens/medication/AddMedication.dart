import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/MedicationModel.dart';
import '../../services/formatTime.dart';
import 'MedicationSummary.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  int? selectedIndex;
  int? colorIdx;

  var pilType = '';
  var name = '';
  var colorName = '';
  var prescription = '';
  Timestamp? startTime;
  Timestamp? endTime;
  TimeOfDay? morning;
  TimeOfDay? midDay;
  TimeOfDay? evening;
  var interval = 0;
  var isLoading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    backButton(context),
                    Text(
                      "Add Medication",
                      style: boldTextStyle(color: kPrimary),
                    ),
                    const Text(""),
                  ],
                ),
                20.height,
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Card(
                    color: context.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Medication For",
                            style: boldTextStyle(size: 12),
                          ),
                          10.height,
                          AppTextField(
                            textFieldType: TextFieldType.OTHER,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "field is requireed";
                              }
                              return null;
                            },
                            textStyle: primaryTextStyle(),
                            onChanged: (p0) {
                              name = p0.toString();
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: "Input medication name",
                              hintStyle: secondaryTextStyle(),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: kPrimary,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: kPrimary,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          20.height,
                          Text(
                            "Medication Prescription",
                            style: boldTextStyle(size: 12),
                          ),
                          10.height,
                          AppTextField(
                            textFieldType: TextFieldType.OTHER,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "field is requireed";
                              }
                              return null;
                            },
                            onChanged: (p0) {
                              prescription = p0.toString();
                              setState(() {});
                            },
                            textStyle: primaryTextStyle(),
                            minLines: 5,
                            maxLines: 7,
                            decoration: InputDecoration(
                              hintText:
                                  "Input directions for usage e.g 2 hous before dinner",
                              hintStyle: secondaryTextStyle(),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: kPrimary,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: kPrimary,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                10.height,
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Card(
                    color: context.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Schedule",
                            style: secondaryTextStyle(size: 12),
                          ),
                          10.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Start Date",
                                    style: boldTextStyle(size: 12),
                                  ),
                                  5.height,
                                  Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: kPrimaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      startTime == null
                                          ? "Select Date"
                                          : DateFormat('yyyy-MM-dd')
                                              .format(startTime!.toDate()),
                                      style: primaryTextStyle(
                                          size: 12, color: black),
                                    ).center(),
                                  ).onTap(() async {
                                    var selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 120)),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light(),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (selectedDate != null) {
                                      Timestamp selectedTimestamp =
                                          Timestamp.fromDate(
                                        DateTime(
                                            selectedDate.year,
                                            selectedDate.month,
                                            selectedDate.day),
                                      );
                                      startTime = selectedTimestamp;
                                      setState(() {});
                                    }
                                  }),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "End Date",
                                    style: boldTextStyle(size: 12),
                                  ),
                                  5.height,
                                  Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: kPrimaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      endTime == null
                                          ? "Select Date"
                                          : DateFormat('yyyy-MM-dd')
                                              .format(endTime!.toDate()),
                                      style: primaryTextStyle(
                                          size: 12, color: black),
                                    ).center(),
                                  ).onTap(() async {
                                    var selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 120)),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light(),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (selectedDate != null) {
                                      // Set the selected date to the end of the day (11:59 PM)
                                      DateTime selectedEndDate = DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                        23, // Hour
                                        59, // Minute
                                        59, // Second
                                        999, // Millisecond
                                      );

                                      Timestamp selectedTimestamp =
                                          Timestamp.fromDate(selectedEndDate);

                                      // Now you can use 'selectedTimestamp' in your Firebase Firestore operations.
                                      endTime = selectedTimestamp;
                                      setState(() {});
                                    }
                                  }),
                                ],
                              ),
                            ],
                          ),
                          10.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Morning",
                                    style: boldTextStyle(size: 12),
                                  ),
                                  5.height,
                                  Container(
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: kPrimaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      morning == null
                                          ? "Select Time"
                                          : formatTimeOfDay(morning!),
                                      style: primaryTextStyle(
                                          size: 12, color: black),
                                    ).center(),
                                  ).onTap(() async {
                                    var selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: morning ?? TimeOfDay.now(),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light(),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (selectedTime != null) {
                                      morning = selectedTime;
                                      setState(() {});
                                    }
                                  })
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mid Day",
                                    style: boldTextStyle(size: 12),
                                  ),
                                  5.height,
                                  Container(
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: kPrimaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      midDay == null
                                          ? "Select Time"
                                          : formatTimeOfDay(midDay!),
                                      style: primaryTextStyle(
                                          size: 12, color: black),
                                    ).center(),
                                  ).onTap(() async {
                                    var selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: midDay ?? TimeOfDay.now(),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light(),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (selectedTime != null) {
                                      midDay = selectedTime;
                                      setState(() {});
                                    }
                                  })
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Evening",
                                    style: boldTextStyle(size: 12),
                                  ),
                                  5.height,
                                  Container(
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: kPrimaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      evening == null
                                          ? "Select Time"
                                          : formatTimeOfDay(evening!),
                                      style: primaryTextStyle(
                                          size: 12, color: black),
                                    ).center(),
                                  ).onTap(() async {
                                    var selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: evening ?? TimeOfDay.now(),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light(),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (selectedTime != null) {
                                      evening = selectedTime;
                                      setState(() {});
                                    }
                                  })
                                ],
                              ),
                            ],
                          ),
                          20.height,
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text(
                          //       "Time Interval",
                          //       style: boldTextStyle(size: 12),
                          //     ),
                          //     5.height,
                          //     Row(
                          //       children: [
                          //         SizedBox(
                          //           height: 50,
                          //           width: 60,
                          //           child: AppTextField(
                          //             textFieldType: TextFieldType.NUMBER,
                          //             validator: (value) {
                          //               if (value!.isEmpty) {
                          //                 return "field is requireed";
                          //               }
                          //               return null;
                          //             },
                          //             maxLength: 2,
                          //             inputFormatters: [
                          //               FilteringTextInputFormatter.allow(RegExp(
                          //                   r'[0-9]')), // Only allow digits 0-9
                          //             ],
                          //             textStyle: primaryTextStyle(color: black),
                          //             onChanged: (p0) {
                          //               if (p0.isNotEmpty &&
                          //                   p0.toString() != 'null') {
                          //                 interval = int.parse(p0.toString());
                          //                 setState(() {});
                          //               } else {
                          //                 interval = 0;
                          //               }
                          //             },
                          //             decoration: InputDecoration(
                          //               filled: true,
                          //               fillColor: kPrimaryLight,
                          //               border: OutlineInputBorder(
                          //                 borderSide: BorderSide.none,
                          //                 borderRadius:
                          //                     BorderRadius.circular(10),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //         5.width,
                          //         Text(
                          //           "Hours",
                          //           style: primaryTextStyle(size: 12),
                          //         ),
                          //       ],
                          //     ),
                          //   ],
                          // ),

                          20.height,
                        ],
                      ),
                    ),
                  ),
                ),
                20.height,
                AppButton(
                  width: double.infinity,
                  onTap: () {
                    if (startTime == null) {
                      toast("Please enter medication start time");
                      return;
                    }
                    if (endTime == null) {
                      toast("Please enter medication end time");
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      MedicationModel medication = MedicationModel(
                        id: Timestamp.now().toString(),
                        userId: userController.userId.value,
                        name: name,
                        prescription: prescription,
                        startTime: startTime,
                        endTime: endTime,
                        morning: morning,
                        midDay: midDay,
                        evening: evening,
                        interval: interval,
                        createdAt: Timestamp.now(),
                      );
                      MedicationSummaryScreen(
                        medication: medication,
                      ).launch(context);
                    }
                  },
                  text: "Continue",
                  textColor: white,
                  color: kPrimary,
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  pillColor(Color color, int idx) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        CircleAvatar(
          backgroundColor: color,
        ),
        Positioned(
            top: 0,
            right: 0,
            child: const Icon(
              Icons.check,
            ).visible(idx == colorIdx))
      ],
    ).onTap(() {
      colorIdx = idx;
      colorName = color.toString();
      setState(() {});
    });
  }

  pillType({
    required String type,
    required int selectedIdx,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: selectedIdx == selectedIndex ? kPrimary : grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        type,
        style: primaryTextStyle(size: 12, color: white),
      ),
    ).onTap(() {
      selectedIndex = selectedIdx;
      pilType = type;
      setState(() {});
    });
  }
}
