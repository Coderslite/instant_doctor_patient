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

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

class FirebaseMessagings {
  void displayLocalNotification(RemoteMessage message) async {
    AndroidNotification? android = message.notification?.android;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.instantdoctor',
      'Instant Doctor',
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.high,
      colorized: true,
      color: kPrimary,
      enableLights: true,
      icon: android?.smallIcon,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  void displayScheduleLocalNotification(RemoteMessage message) async {
    AndroidNotification? android = message.notification?.android;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.instantdoctor.schedule',
      'Instant Doctor',
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.high,
      colorized: true,
      color: kPrimary,
      enableLights: true,
      icon: android?.smallIcon,
      sound: RawResourceAndroidNotificationSound('tone1'),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      message.data['id'].hashCode,
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
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      appointmentId.hashCode,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: appointmentId,
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
        } else if (payload['type'] == NotificatonType.appointment ||
            payload['type'] == NotificatonType.medication) {
          displayScheduleLocalNotification(message);
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
