import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/MedicationModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constant/color.dart';

class AlarmController extends GetxController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> removeAlarm(String id) async {
    // Cancel the notification associated with the medication's ID
    await flutterLocalNotificationsPlugin.cancel(id.hashCode);

    // Optionally, remove the medication from persistent storage (SharedPreferences)
    var prefs = await SharedPreferences.getInstance();
    var alarms = prefs.getStringList('Alarms');
    if (alarms != null && alarms.isNotEmpty) {
      alarms.removeWhere((alarm) {
        Map<String, dynamic> alarmData = jsonDecode(alarm);
        return alarmData['id'] == id;
      });
      prefs.setStringList('Alarms', alarms);
    }
  }

  Future<void> handleAddToAlarms(MedicationModel medication) async {
    try {
      List<String>? scheduledAlarm = [];
      var prefs = await SharedPreferences.getInstance();
      var alarms = prefs.getStringList('Alarms');
      if (alarms != null && alarms.isNotEmpty) {
        scheduledAlarm = alarms;
      }
      scheduledAlarm.add(jsonEncode(medication.toJson()));
      prefs.setStringList('medications', scheduledAlarm);
      await handleScheduleAlarm(medication);
    } catch (err) {
      print(err);
    }
  }

  Future<void> handleScheduleAlarm(MedicationModel medication) async {
    DateTime startTime = medication.startTime!.toDate();
    DateTime endTime = medication.endTime!.toDate();
    TimeOfDay? morning = medication.morning;
    TimeOfDay? midDay = medication.midDay;
    TimeOfDay? evening = medication.evening;

    int diff = endTime.difference(startTime).inDays;

    for (int count = 0; count <= diff; count++) {
      DateTime currentDate = startTime.add(Duration(days: count));

      if (morning != null) {
        await _scheduleAlarmForTime(currentDate, morning, medication);
      }
      if (midDay != null) {
        await _scheduleAlarmForTime(currentDate, midDay, medication);
      }
      if (evening != null) {
        await _scheduleAlarmForTime(currentDate, evening, medication);
      }
    }
  }

  Future<void> _scheduleAlarmForTime(
      DateTime date, TimeOfDay time, MedicationModel medicationModel) async {
    tz.TZDateTime scheduledTime = tz.TZDateTime.from(
        date.add(Duration(
          hours: time.hour,
          minutes: time.minute,
        )),
        tz.local);

    var newDate = date.add(Duration(
      hours: time.hour,
      minutes: time.minute,
    ));
    DateTime currentDateTime = DateTime.now();

    // Calculate the duration between the target and current date and time
    Duration difference = newDate.difference(currentDateTime);

    print("seconds $difference");

    // Convert the duration to seconds
    // int seconds = difference.inSeconds;
    // Workmanager().registerOneOffTask(
    //     "${UniqueKey().hashCode}", "MedicationTracker",
    //     initialDelay: Duration(seconds: seconds));

    // FlutterBackgroundService().invoke(
    //   "medication",
    //   {"time": seconds},
    // );
    // Workmanager().registerOneOffTask(
    //   "${UniqueKey().hashCode}",
    //   "MedicationTracker",
    //   constraints: Constraints(
    //     networkType: NetworkType.not_required,
    //   ),
    //   initialDelay: Duration(seconds: seconds),
    // );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.instantdoctor',
      'Instant Doctor',
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      ongoing: true,
      colorized: true,
      color: kPrimary,
      enableLights: true,
      // audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: RawResourceAndroidNotificationSound('tone1'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      UniqueKey().hashCode, // Notification ID
      'Medication Reminder', // Notification title
      'It\'s time to take your  medication!', // Notification body
      scheduledTime, // Scheduled date and time
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // New parameter
      payload: jsonEncode(medicationModel.toJson()),
    );
  }



  Future<void> displayNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.instantdoctor.medication',
      'Instant Doctor',
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      ongoing: true,
      colorized: true,
      color: kPrimary,
      enableLights: true,
      // audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      sound: RawResourceAndroidNotificationSound('tone1'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        UniqueKey().hashCode,
        'Medication Tracker',
        "Its time to take your medication",
        platformChannelSpecifics);
  }
}
