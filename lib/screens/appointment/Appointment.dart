import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/EachAppointment.dart';
import '../../controllers/SettingController.dart';
import '../../services/AppointmentService.dart';
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
        bool isDarkMode = settingsController.isDarkMode.value;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "My Appointments",
                      style: boldTextStyle(
                        color: kPrimary,
                        size: 20,
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
                            return Center(
                              child: Text(
                                "No Appointment Yet",
                                style: boldTextStyle(),
                              ),
                            );
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data!.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var appointment = snapshot.data![index];
                                  return eachAppointment(
                                          docId: appointment.doctorId,
                                          appointment: appointment)
                                      .onTap(() {
                                    ChatInterface(
                                      appointmentId: appointment.id!,
                                      docId: appointment.doctorId!,
                                      videocallToken:
                                          appointment.videocallToken.validate(),
                                    ).launch(context);
                                  });
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
}
