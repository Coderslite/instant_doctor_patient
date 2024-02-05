import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/BookingController.dart';
import '../services/formatDuration.dart';

class TimeRemaining extends StatefulWidget {
  final AppointmentModel appointment;
  const TimeRemaining({super.key, required this.appointment});

  @override
  State<TimeRemaining> createState() => _TimeRemainingState();
}

class _TimeRemainingState extends State<TimeRemaining> {
  BookingController bookingController = Get.put(BookingController());
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var startTime = widget.appointment.startTime;
    var now = Timestamp.now();
    var isExpired = now.compareTo(startTime!) > 0;
    var timeRemaining = startTime.toDate().difference(DateTime.now());

    return Row(
      children: [
        const Icon(
          Icons.visibility,
          size: 12,
          color: dimGray,
        ),
        5.width,
        Text(
          isExpired
              ? "Expired Session"
              : "Starts in ${formatDuration(timeRemaining)}",
          style: secondaryTextStyle(size: 10),
        ),
      ],
    );
  }
}
