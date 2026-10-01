import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/BookingController.dart';

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
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    final pricingService = Get.find<PricingService>();
    final isOngoing = pricingService.isAppointmentOngoing(widget.appointment);
    final statusText = pricingService.getAppointmentStatusText(widget.appointment);

    return Row(
      children: [
        Icon(
          Icons.timer,
          size: 12,
          color: isOngoing ? mediumSeaGreen : dimGray,
        ),
        5.width,
        Text(
          statusText,
          style: secondaryTextStyle(
              size: 10, color: isOngoing ? mediumSeaGreen : null),
        ),
      ],
    );
  }
}
