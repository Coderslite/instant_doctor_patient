// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:instant_doctor/controllers/IncomingCallController.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../constant/constants.dart';
import '../main.dart';
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

class FirebaseMessagings {
  void displayLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.instantdoctor',
      'Instant Doctor',
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.high,
      colorized: true,
      color: kPrimary,
      enableLights: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  void showIncomingCallNotification(RemoteMessage message) async {
    var data = message.data;
    var appointmentId = data['id'];
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'incoming_call_channel_id',
      'Incoming Call',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      enableVibration: false,
      colorized: true,
      color: kPrimary,
      onlyAlertOnce: false,
      ongoing: true,
      audioAttributesUsage: AudioAttributesUsage.voiceCommunicationSignalling,
      actions: [
        AndroidNotificationAction(
          'reject',
          'Reject',
        ),
        AndroidNotificationAction(
          'accept',
          'Accept Call',
          cancelNotification: true,
          showsUserInterface: true,
        ),
      ],
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: appointmentId,
    );
  }

  handleScheduleNotification(
      tz.TZDateTime scheduledTime, String title, String desc) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.instantdoctor.schedule',
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
      title, // Notification title
      desc, // Notification body
      scheduledTime, // Scheduled date and time
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // New parameter
    );
  }

  handleInit() async {
    if (isMobile && !kIsWeb) {
      await Firebase.initializeApp();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      // Request notification permissions

      var result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();

      if (result == true) {
      } else {}
      var prefs = await SharedPreferences.getInstance();
      var token = await firebaseMessaging.getToken();
      prefs.setString(MESSAGE_TOKEN, token.toString());

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        var payload = message.data;
        if (payload['type'] == 'Call') {
          IncomingCall().showCalling(payload['id']);
        }
      });


      // Handle incoming messages and display notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        var payload = message.data;
        if (payload['type'] == 'Call') {
          IncomingCall().showCalling(payload['id']);
        } else {
          displayLocalNotification(message);
        }
      });
    }
  }
}
