import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/MedicationModel.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:instant_doctor/screens/medication/ActiveMedication.dart';
import 'package:instant_doctor/screens/medication/AddMedication.dart';
import 'package:instant_doctor/services/MedicationService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/check_country.dart';
import '../../component/check_internet.dart';
import '../../services/GetUserId.dart';
import '../../services/LabResultService.dart';

class MedicationTracker extends StatefulWidget {
  const MedicationTracker({super.key});

  @override
  State<MedicationTracker> createState() => _MedicationTrackerState();
}

class _MedicationTrackerState extends State<MedicationTracker> {
  final medicationService = Get.find<MedicationService>();
  final labResultService = Get.find<LabResultService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: obsidian,
        child: Column(
          children: [
            // --- Premium Header ---
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.offAll(Root()),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: white.withOpacity(0.1), width: 1),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: white, size: 18),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Medication Tracker",
                          style: boldTextStyle(
                              color: white, size: 18, letterSpacing: -0.5),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40), // Balance
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: kPrimary.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: kPrimary, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            "Slide left to manage or delete",
                            style: secondaryTextStyle(
                                color: kPrimary.withOpacity(0.8), size: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Content ---
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: pageGray,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      internetCheck(),
                      countryCheck(),
                      Expanded(
                        child: StreamBuilder<List<MedicationModel>>(
                            stream: medicationService.getUserMedications(
                                userId: userController.userId.value),
                            builder: (context, snapshot) {
                              print(snapshot.error);
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
                                        motion: const ScrollMotion(),
                                        dismissible: DismissiblePane(
                                            onDismissed: () async {
                                          await medicationService
                                              .deleteMedication(
                                                  medication: medication);
                                        }),
                                        children: [
                                          SlidableAction(
                                            onPressed: (s) async {
                                              HapticFeedback.mediumImpact();
                                              await medicationService
                                                  .deleteMedication(
                                                      medication: medication);
                                            },
                                            backgroundColor:
                                                const Color(0xFFE11D48),
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete_rounded,
                                            label: 'Delete',
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ],
                                      ),
                                      child: eachMedication(
                                        name: medication.name!,
                                        startTime: medication.startTime!,
                                        endTime: medication.endTime!,
                                      ).onTap(() {
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          const AddMedicationScreen().launch(context);
        },
        backgroundColor: obsidian,
        label: const Text("Add Medication",
            style: TextStyle(color: white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded, color: white),
      ),
    );
  }

  Padding eachMedication({
    required String name,
    required Timestamp startTime,
    required Timestamp endTime,
  }) {
    DateTime now = DateTime.now();
    DateTime start = DateTime(startTime.toDate().year, startTime.toDate().month,
        startTime.toDate().day);
    DateTime end = DateTime(
        endTime.toDate().year, endTime.toDate().month, endTime.toDate().day);
    DateTime today = DateTime(now.year, now.month, now.day);

    int currentDay =
        today.isBefore(start) ? 0 : today.difference(start).inDays + 1;

    bool isExpired = today.isAfter(end);
    int totalDays = end.difference(start).inDays + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: obsidian.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: null, // Handled by parent onTap
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/images/medication.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: boldTextStyle(
                              color: obsidian, size: 15, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isExpired
                                  ? Icons.event_busy_rounded
                                  : Icons.event_available_rounded,
                              size: 14,
                              color: isExpired ? redColor : kPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isExpired
                                  ? "Medication Completed"
                                  : "Day $currentDay of $totalDays",
                              style: secondaryTextStyle(
                                  size: 12,
                                  color: isExpired ? redColor : slate),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: slate.withOpacity(0.3),
                    size: 24,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
