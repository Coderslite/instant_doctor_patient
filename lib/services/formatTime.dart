import 'package:flutter/material.dart';

String formatTimeOfDay(TimeOfDay timeOfDay) {
  // Extract hour and minute from TimeOfDay
  int hour = timeOfDay.hour;
  int minute = timeOfDay.minute;

  // Determine if it's AM or PM
  String period = hour < 12 ? 'AM' : 'PM';

  // Convert hour to 12-hour format
  hour = hour % 12;
  hour = hour == 0 ? 12 : hour; // Handle 12 AM

  // Format minute with leading zero if needed
  String minuteStr = minute < 10 ? '0$minute' : minute.toString();

  // Construct the string representation
  return '$hour:$minuteStr $period';
}
