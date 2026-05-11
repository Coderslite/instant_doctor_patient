import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/models/MedicationTakenModel.dart';
import 'package:instant_doctor/services/MedicationService.dart';
import 'package:nb_utils/nb_utils.dart';
import '../models/MedicationModel.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class MedicationController extends GetxController {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<bool> requestExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await Permission.scheduleExactAlarm.request();
      return result.isGranted;
    }
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  handleCreateMedication(
      BuildContext context, MedicationModel medication) async {
    final medicationService = Get.find<MedicationService>();
    isLoading.value = true;

    try {
      var medId = await medicationService.newMedication(medication: medication);
      var startDate = medication.startTime!.toDate();
      var endDate = medication.endTime!.toDate();

      // Schedule notifications for a rolling window (up to 30 days) to avoid OS limits
      final now = DateTime.now();
      final rollingEndDate = startDate.add(const Duration(days: 30)).isBefore(endDate) 
          ? startDate.add(const Duration(days: 30)) 
          : endDate;

      int dayOffset = 0;
      for (var currentDate = startDate;
          (currentDate.isBefore(rollingEndDate) || currentDate.isAtSameMomentAs(rollingEndDate));
          currentDate = currentDate.add(const Duration(days: 1))) {
        
        // Generate a base ID component for this medication
        // We use a bit-masking approach to ensure uniqueness across medId, day, and dose
        final int baseId = medId.hashCode.abs() % 10000;

        if (medication.morning != null) {
          await _scheduleNotification(
            context: context,
            id: baseId + (dayOffset * 3) + 0, 
            title: 'Medication Reminder',
            body: 'Time to take ${medication.name} (Morning dose)',
            scheduledTime: _combineDateAndTime(currentDate, medication.morning!),
          );
        }

        if (medication.midDay != null) {
          await _scheduleNotification(
            context: context,
            id: baseId + (dayOffset * 3) + 1,
            title: 'Medication Reminder',
            body: 'Time to take ${medication.name} (Afternoon dose)',
            scheduledTime: _combineDateAndTime(currentDate, medication.midDay!),
          );
        }

        if (medication.evening != null) {
          await _scheduleNotification(
            context: context,
            id: baseId + (dayOffset * 3) + 2,
            title: 'Medication Reminder',
            body: 'Time to take ${medication.name} (Evening dose)',
            scheduledTime: _combineDateAndTime(currentDate, medication.evening!),
          );
        }
        dayOffset++;
      }

      toast("Medication Added & Schedule Set");
    } catch (err) {
      toast(err.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _scheduleNotification({
    required BuildContext context,
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );
    DateTime now = DateTime.now();

    // Skip if reminder time is in the past
    if (scheduledTime.isBefore(now)) {
      return;
    }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminders',
      channelDescription: 'Channel for medication reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('tone1'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      autoCancel: false, // Prevents auto-dismissal
      timeoutAfter: 60000,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'tone1.mp3',
      interruptionLevel: InterruptionLevel.critical,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iosPlatformChannelSpecifics,
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('Error scheduling exact notification: $e');
      errorSnackBar(
          context: context, title: 'Error scheduling exact notification: $e');
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> cancelMedicationNotifications(
      String medId, DateTime startDate, DateTime endDate) async {
    try {
      final int baseId = medId.hashCode.abs() % 10000;
      
      // Cancel notifications for the possible 30-day rolling window
      for (int dayOffset = 0; dayOffset <= 30; dayOffset++) {
        await _notificationsPlugin.cancel(baseId + (dayOffset * 3) + 0); // Morning
        await _notificationsPlugin.cancel(baseId + (dayOffset * 3) + 1); // Midday
        await _notificationsPlugin.cancel(baseId + (dayOffset * 3) + 2); // Evening
      }
      toast("Notifications canceled for medication");
    } catch (e) {
      print("Error canceling notifications: $e");
    }
  }

  handleMedicationTaken(MedicationTakenModel medication) async {
    try {
      List<String>? allMedicationTaken = [];
      var prefs = await SharedPreferences.getInstance();
      var medicationTaken = prefs.getStringList('MedicationsTaken');
      if (medicationTaken != null && medicationTaken.isNotEmpty) {
        allMedicationTaken = medicationTaken;
      }
      allMedicationTaken.add(jsonEncode(medication.toJson()));
      toast("Medication Taken");
    } catch (err) {
      toast(err.toString());
      print(err);
    }
  }
}
