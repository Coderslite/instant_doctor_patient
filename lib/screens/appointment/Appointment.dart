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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../component/EachAppointment.dart';
import '../../component/check_country.dart';
import '../../component/check_internet.dart';
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
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isDarkMode = settingsController.isDarkMode.value;
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimary,
          onPressed: () => NewAppointment().launch(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              internetCheck(),
              countryCheck(),
              // Header Section
              Text(
                "My Appointments",
                textAlign: TextAlign.center,
                style: boldTextStyle(
                  size: 18,
                  color: kPrimary,
                ),
              ),

              10.height,
              Divider(),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: StreamBuilder<List<AppointmentModel>>(
                    stream: userController.userId.isEmpty
                        ? null
                        : appointmentService
                            .getAllAppointment(userController.userId.value),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return _buildEmptyState();
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
                              var isOngoing = now.compareTo(startTime!) >= 0 &&
                                  now.compareTo(endTime) <= 0;

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _buildAppointmentCard(
                                      context,
                                      appointment,
                                      isExpired,
                                      isOngoing,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }
                      return _buildEmptyState();
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentModel appointment,
    bool isExpired,
    bool isOngoing,
  ) {
    return Slidable(
      enabled: isExpired || !appointment.isPaid.validate(),
      key: ValueKey(appointment.id.validate()),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () async {
            await _showDeleteConfirmation(appointment);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (s) async {
              await _showDeleteConfirmation(appointment);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: eachAppointment(
        context: context,
        docId: appointment.doctorId.validate(),
        appointment: appointment,
        isExpired: isExpired,
        isOngoing: isOngoing,
      ).onTap(() {
        _handleAppointmentTap(appointment, isExpired);
      }),
    );
  }

  Future<void> _showDeleteConfirmation(AppointmentModel appointment) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Appointment"),
        content: Text("Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              setState(() {});
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await appointmentService.deleteAppointment(
          appointmentId: appointment.id.validate());
      successSnackBar(title: "Appointment deleted");
    }
  }

  Future<void> _handleAppointmentTap(
      AppointmentModel appointment, bool isExpired) async {
    if (isExpired && appointment.isPaid == false) {
      print("clicked");
      errorSnackBar(title: "This appointment has expired");
      return;
    }

    if (!appointment.isPaid.validate() && !appointment.isTrial.validate()) {
      await _showPaymentDialog(appointment);
      return;
    }

    if (appointment.doctorId.validate().isEmpty) {
      errorSnackBar(title: "Appointment is not assigned to a doctor yet");
      return;
    }

    ChatInterface(
      appointmentId: appointment.id!,
      docId: appointment.doctorId!,
      appointment: appointment,
      videocallToken: appointment.videocallToken.validate(),
      isExpired: isExpired,
      update: handleUpdate,
    ).launch(context);
  }

  handleUpdate() async {
    print("update");
    setState(() {});
  }

  Future<void> _showPaymentDialog(AppointmentModel appointment) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Required"),
        content:
            Text("You need to complete payment to access this appointment"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Later"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              handleMakePayment(appointment);
            },
            child: Text("Pay Now", style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Icon(CupertinoIcons.calendar_circle,
              size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            "No Appointments Yet",
            style: boldTextStyle(size: 22),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "You don't have any appointments scheduled yet. Tap the + button to book your first consultation.",
              textAlign: TextAlign.center,
              style: secondaryTextStyle(size: 14),
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
            ),
            child: Text(
              "Book Appointment",
              style: boldTextStyle(color: white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: kPrimary),
          SizedBox(height: 16),
          Text("Loading your appointments...", style: secondaryTextStyle()),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text("Something went wrong", style: boldTextStyle()),
          SizedBox(height: 8),
          Text(error, style: secondaryTextStyle(), textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: Text("Try Again"),
          ),
        ],
      ),
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
