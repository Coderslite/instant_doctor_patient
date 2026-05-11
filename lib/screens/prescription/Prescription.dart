import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/screens/prescription/PrescriptionDetails.dart';
import 'package:instant_doctor/services/PresciptionService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/ProfileImage.dart';
import '../../constant/color.dart';
import '../../constant/constants.dart';
import '../../models/AppointmentModel.dart';
import '../../models/PrescriptionModel.dart';
import '../../models/UserModel.dart';
import '../../services/UserService.dart';
import '../../services/formatDate.dart';

class PrescriptionScreen extends StatefulWidget {
  final AppointmentModel appointment;
  const PrescriptionScreen({super.key, required this.appointment});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final presciptionService = Get.find<PresciptionService>();
  final userService = Get.find<UserService>();

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
                    "Prescriptions",
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

            // Doctor Profile Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StreamBuilder<UserModel>(
                stream: userService.getProfile(userId: widget.appointment.doctorId.validate()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var userData = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          profileImage(userData, 56, 56, context: context),
                          16.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dr. ${userData.firstName} ${userData.lastName}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: kText,
                                  ),
                                ),
                                4.height,
                                Text(
                                  userData.speciality.validate(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: kSub,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox(height: 80, child: Center(child: Loader()));
                }
              ),
            ),
            32.height,

            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  12.width,
                  const Text(
                    "Doctor's Prescriptions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kText,
                    ),
                  ),
                ],
              ),
            ),
            16.height,

            // Prescription List
            Expanded(
              child: StreamBuilder<List<Prescriptionmodel>>(
                stream: presciptionService.getUserPrescription(
                    appointmentId: widget.appointment.id.validate()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    if (data.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 64, color: kSub.withOpacity(0.3)),
                          16.height,
                          Text(
                            "No prescriptions yet",
                            style: TextStyle(color: kSub.withOpacity(0.5), fontSize: 16),
                          ),
                        ],
                      ).center();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        var prescription = data[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kBorder),
                          ),
                          child: InkWell(
                            onTap: () {
                              Prescriptiondetails(prescription: prescription).launch(context);
                              if (!prescription.seen.validate()) {
                                presciptionService.updatePrescription(
                                  data: {"seen": true},
                                  prescribeId: prescription.id.validate(),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: kPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.medication_rounded, color: kPrimary),
                                  ),
                                  16.width,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                prescription.prescription.validate(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: kText,
                                                ),
                                              ),
                                            ),
                                            if (!prescription.seen.validate())
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: kPrimary,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  "NEW",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        4.height,
                                        Text(
                                          formatDate(prescription.createdAt!.toDate()),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: kSub,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  8.width,
                                  const Icon(Icons.chevron_right_rounded, color: kSub),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  }
                  return const Center(child: Loader());
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
