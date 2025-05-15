import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/screens/prescription/PrescriptionDetails.dart';
import 'package:instant_doctor/services/PresciptionService.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../component/ProfileImage.dart';
import '../../constant/color.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Prescriptions",
                    style: boldTextStyle(
                      size: 16,
                    ),
                  ),
                  Text("     ")
                ],
              ),
              Card(
                color: context.cardColor,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<UserModel>(
                        stream: userService.getProfile(
                            userId: widget.appointment.doctorId.validate()),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var userData = snapshot.data!;
                            return Row(
                              children: [
                                profileImage(userData, 50, 50,
                                    context: context),
                                10.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${userData.firstName} ${userData.lastName}",
                                        style: boldTextStyle(
                                          size: 16,
                                        ),
                                      ),
                                      Text(
                                        userData.speciality.validate(),
                                        style: secondaryTextStyle(
                                          size: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return Loader();
                        })),
              ),
              10.height,
              Text(
                "Doctors Prescriptions",
                style: secondaryTextStyle(color: kPrimary),
              ),
              SizedBox(
                width: 100,
                child: Divider(),
              ),
              10.height,
              Expanded(
                  child: StreamBuilder<List<Prescriptionmodel>>(
                      stream: presciptionService.getUserPrescription(
                          appointmentId: widget.appointment.id.validate()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data!;
                          return data.isEmpty
                              ? Text(
                                  "No prescription yet",
                                  style: boldTextStyle(),
                                ).center()
                              : ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    var prescription = data[index];
                                    return Card(
                                      color: context.cardColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          prescription
                                                              .prescription
                                                              .validate(),
                                                          maxLines: 1,
                                                          style: boldTextStyle(
                                                            size: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      Badge(
                                                        backgroundColor:
                                                            kPrimary,
                                                        label: Text(
                                                          "new",
                                                          style: boldTextStyle(
                                                              color: white,
                                                              size: 10),
                                                        ),
                                                      ).visible(!prescription
                                                          .seen
                                                          .validate()),
                                                    ],
                                                  ),
                                                  Text(
                                                    formatDate(prescription
                                                        .createdAt!
                                                        .toDate()),
                                                    maxLines: 1,
                                                    style: secondaryTextStyle(
                                                      size: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: kPrimary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).onTap(
                                      () {
                                        Prescriptiondetails(
                                          prescription: prescription,
                                        ).launch(context);
                                        if (!prescription.seen.validate()) {
                                          presciptionService.updatePrescription(
                                            data: {"seen": true},
                                            prescribeId:
                                                prescription.id.validate(),
                                          );
                                        }
                                      },
                                    );
                                  });
                        }
                        return Loader();
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
