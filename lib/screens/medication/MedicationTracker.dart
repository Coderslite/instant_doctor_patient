import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/MedicationModel.dart';
import 'package:instant_doctor/screens/medication/ActiveMedication.dart';
import 'package:instant_doctor/screens/medication/AddMedication.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../services/GetUserId.dart';

class MedicationTracker extends StatefulWidget {
  const MedicationTracker({super.key});

  @override
  State<MedicationTracker> createState() => _MedicationTrackerState();
}

class _MedicationTrackerState extends State<MedicationTracker> {
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
                    style: boldTextStyle(
                      color: kPrimary,
                    ),
                  ),
                  const Text(""),
                ],
              ),
              Marquee(
                child: Text(
                  "Slide to delete medication",
                  style: secondaryTextStyle(
                    size: 10,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<MedicationModel>>(
                    stream: medicationService.getUserMedications(
                        userId: userController.userId.value),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data;
                        if (data!.isEmpty) {
                          return Text(
                            "No Medication Added Yet",
                            style: boldTextStyle(size: 16),
                          ).center();
                        }
                        return ListView.builder(
                          itemCount: data.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            var medication = data[index];
                            return Slidable(
                              key: ValueKey(medication.id.validate()),
                              startActionPane: ActionPane(
                                // A motion is a widget used to control how the pane animates.
                                motion: const ScrollMotion(),

                                // A pane can dismiss the Slidable.
                                dismissible:
                                    DismissiblePane(onDismissed: () async {
                                  await medicationService.deleteMedication(
                                      id: medication.id.validate());
                                }),

                                // All actions are defined in the children parameter.
                                children: [
                                  // A SlidableAction can have an icon and/or a label.
                                  SlidableAction(
                                    onPressed: (s) async {
                                      await labResultService.deleteLabResult(
                                          id: medication.id.validate());
                                    },
                                    backgroundColor: Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                  // SlidableAction(
                                  //   onPressed: (s) {},
                                  //   backgroundColor: kPrimary,
                                  //   foregroundColor: Colors.white,
                                  //   icon: Icons.share,
                                  //   label: 'Edit',
                                  // ),
                                ],
                              ),
                              child: eachMedication(
                                name: medication.name!,
                                startTime: medication.startTime!,
                                endTime: medication.endTime!,
                              ).onTap(() {
                                // CompleteMedicationScreen().launch(context);
                                ActiveMedicationScreen(
                                  medication: medication,
                                ).launch(context);
                              }),
                            );
                          },
                        );
                      }
                      return const CircularProgressIndicator(
                        color: kPrimary,
                      ).center();
                    }),
              ),
              30.height,
              AppButton(
                onTap: () {
                  const AddMedicationScreen().launch(context);
                },
                width: double.infinity,
                text: "Add Medication",
                textColor: Colors.white,
                color: kPrimary,
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding eachMedication({
    required String name,
    required Timestamp startTime,
    required Timestamp endTime,
  }) {
    DateTime currentDate = DateTime.now();
    DateTime startDate = startTime.toDate();
    DateTime endDate = endTime.toDate();

    // Calculate the difference between the current date and the start date in days
    int currentDay = currentDate.isBefore(startDate)
        ? 0
        : currentDate.difference(startDate).inDays + 1;

    // Check if the medication is expired
    bool isExpired = currentDate.isAfter(endDate);

    // Calculate the total days of the medication
    int totalDays = endDate.difference(startDate).inDays + 1;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: context.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Image.asset(
                  "assets/images/medication.png",
                  fit: BoxFit.cover,
                ),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: boldTextStyle(color: kPrimary, size: 14),
                    ),
                    5.height,
                    Text(
                      isExpired ? "Expired" : "Day $currentDay of $totalDays",
                      style: secondaryTextStyle(
                          size: 12, color: isExpired ? redColor : null),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: kPrimary,
                size: 14,
              )
            ],
          ),
        ),
      ),
    );
  }
}
