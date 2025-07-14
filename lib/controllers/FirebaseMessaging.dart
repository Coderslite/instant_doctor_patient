// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constant/color.dart';
import '../constant/constants.dart';
import '../main.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

class FirebaseMessagings {
  void displayLocalNotification(RemoteMessage message) async {
    AndroidNotification? android = message.notification?.android;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'instantdoctor',
      'Instant Doctor',
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.high,
      colorized: true,
      color: kPrimary,
      enableLights: true,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch,
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
      'com.instantdoctor_call',
      'Incoming Call',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      colorized: true,
      color: kPrimary,
      onlyAlertOnce: false,
      timeoutAfter: 30000,
      ongoing: true,
      sound: RawResourceAndroidNotificationSound('tone1'),
      actions: [
        AndroidNotificationAction(
          'reject',
          'Reject',
          titleColor: fireBrick,
        ),
        AndroidNotificationAction(
          'accept',
          'Accept Call',
          cancelNotification: true,
          showsUserInterface: true,
        ),
      ],
    );

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails);
    bool canceled = false;

    // Continuously show the notification until it's canceled
    while (!canceled) {
      await flutterLocalNotificationsPlugin.show(
        appointmentId.hashCode,
        message.notification!.title,
        message.notification!.body,
        platformChannelSpecifics,
        payload: appointmentId,
      );

      // Check if the notification is still being displayed
      canceled = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests()
          .then((value) => value.isEmpty);

      await Future.delayed(const Duration(seconds: 3));
    }
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
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      DarwinInitializationSettings darwinInitializationSettings =
          const DarwinInitializationSettings();
      InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: darwinInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        // onDidReceiveNotificationResponse: notificationTapBackground,
        // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      // Request notification permissions

      var result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      if (result == true) {
      } else {}
      var prefs = await SharedPreferences.getInstance();
      var token = await firebaseMessaging.getToken();
      print(token);
      prefs.setString(MESSAGE_TOKEN, token.toString());

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        var payload = message.data;
        if (payload['type'] == 'Call') {
          // IncomingCall().showCalling(payload['id']);
        }
      });

      // Handle incoming messages and display notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        var payload = message.data;
        if (payload['type'] == 'Call') {
          // IncomingCall().showCalling(payload['id']);
        } else if (payload['type'] == NotificationType.appointment ||
            payload['type'] == NotificationType.medication) {
          // displayScheduleLocalNotification(message);
        } else {
          displayLocalNotification(message);
        }
      });
    }
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin
        .cancelAll(); // or specify specific notification ID to cancel
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('AppointmentId');
  }
}
