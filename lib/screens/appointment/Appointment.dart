// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/EachAppointment.dart';
import '../../controllers/BookingController.dart';
import '../../controllers/PaymentController.dart';
import '../../controllers/SettingController.dart';
import '../../services/AppointmentService.dart';
import '../../services/GetUserId.dart';
import '../chat/ChatInterface.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final SettingsController settingsController = Get.find();
  AppointmentService appointmentService = AppointmentService();
  UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // ignore: unused_local_variable
        bool isDarkMode = settingsController.isDarkMode.value;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "My Appointments",
                      style: boldTextStyle(
                        color: kPrimary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                10.height,
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: () {
                    return Future.delayed(
                      const Duration(seconds: 2),
                    );
                  },
                  child: StreamBuilder<List<AppointmentModel>>(
                      stream: userController.userId.isEmpty
                          ? null
                          : appointmentService
                              .getAllAppointment(userController.userId.value),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString()).center();
                        }
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return _buildNoAppointmentFound();
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data!.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var appointment = snapshot.data![index];
                                  var startTime = appointment.startTime;
                                  var endTime = appointment.endTime;
                                  var now = Timestamp.now();
                                  var isExpired = now.compareTo(endTime!) > 0;
                                  var isOngoing =
                                      now.compareTo(startTime!) >= 0 &&
                                          now.compareTo(endTime) <= 0;

                                  return Slidable(
                                    enabled: isExpired,
                                    key: ValueKey(appointment.id.validate()),
                                    startActionPane: ActionPane(
                                      // A motion is a widget used to control how the pane animates.
                                      motion: const ScrollMotion(),

                                      // A pane can dismiss the Slidable.
                                      dismissible: DismissiblePane(
                                          onDismissed: () async {
                                        await appointmentService
                                            .deleteAppointment(
                                                appointmentId:
                                                    appointment.id.validate());
                                      }),

                                      // All actions are defined in the children parameter.
                                      children: [
                                        // A SlidableAction can have an icon and/or a label.
                                        SlidableAction(
                                          onPressed: (s) async {
                                            await appointmentService
                                                .deleteAppointment(
                                                    appointmentId: appointment
                                                        .id
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
                                    child: eachAppointment(
                                            context: context,
                                            docId:
                                                appointment.doctorId.validate(),
                                            appointment: appointment,
                                            isExpired: isExpired,
                                            isOngoing: isOngoing)
                                        .onTap(() async {
                                      if (isExpired &&
                                          appointment.isPaid == false) {
                                        errorSnackBar(
                                            title:
                                                "This appointment has expired");
                                        return;
                                      }
                                      if (!appointment.isPaid.validate() &&
                                          !appointment.isTrial.validate()) {
                                        await showConfirmDialog(context,
                                            "Do you want to make payment now ?",
                                            onAccept: () {
                                          handleMakePayment(appointment);
                                        });
                                        return;
                                      }
                                      if (appointment.doctorId
                                          .validate()
                                          .isEmpty) {
                                        errorSnackBar(
                                            title:
                                                "Appointment is not assigned to a doctor yet");
                                        return;
                                      }
                                      ChatInterface(
                                        appointmentId: appointment.id!,
                                        docId: appointment.doctorId!,
                                        appointment: appointment,
                                        videocallToken: appointment
                                            .videocallToken
                                            .validate(),
                                        isExpired: isExpired,
                                      ).launch(context);
                                    }),
                                  );
                                });
                          }
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: kPrimary,
                          ),
                        );
                      }),
                ))
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNoAppointmentFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.calendar_circle, size: 80, color: Colors.grey[400]),
        SizedBox(height: 20),
        Text(
          "No Appointment Found",
          style: boldTextStyle(size: 18),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            "You haven't made any appointment yet, click on the button below to start",
            textAlign: TextAlign.center,
            style: primaryTextStyle(size: 14, color: Colors.grey),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => NewAppointment().launch(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text(
            "Book Appointment",
            style: boldTextStyle(color: white),
          ),
        ),
      ],
    );
  }

  handleMakePayment(AppointmentModel appointment) async {
    final bookingController = Get.find<BookingController>();
    final paymentController = Get.find<PaymentController>();
    try {
      bookingController.isLoading.value = true;
      setState(() {});
      var userInfo =
          await userService.getProfileById(userId: userController.userId.value);
      await paymentController.makePayment(
          email: userInfo.email.validate(),
          context: context,
          amount: appointment.price.validate(),
          paymentFor: 'Appointment',
          productId: appointment.id);
    } finally {
      bookingController.isLoading.value = false;
    }
  }
}
