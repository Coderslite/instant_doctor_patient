import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/AppointmentPricingModel.dart';
import 'package:instant_doctor/services/DoctorService.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/formatDate.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import '../constant/constants.dart';
import '../controllers/ChatController.dart';
import '../function/send_notification.dart';
import '../main.dart';
import '../models/AppointmentModel.dart';
import 'NotificationService.dart';
import 'SecurityHelper.dart';
import 'UploadFile.dart';
import 'package:nb_utils/nb_utils.dart';

class AppointmentService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final notificationService = Get.find<NotificationService>();
  var appointmentCollection = db.collection("Appointments");
  var appointmentPricingCollection = db.collection("AppointmentPricing");

  AppointmentService() {
    _initializeNotifications();
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

  Future<bool> requestExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await Permission.scheduleExactAlarm.request();
      return result.isGranted;
    }
  }

  Future<void> scheduleAppointmentNotification({
    required String title,
    required String body,
    required String id,
    required String type,
    required Timestamp scheduledTime,
    required Timestamp endTime,
  }) async {
    try {
      // Convert Timestamp to DateTime
      DateTime scheduledDateTime = scheduledTime.toDate();
      DateTime now = DateTime.now();

      // Define notification intervals (30, 5, and 0 minutes before)
      List<int> reminderMinutes = [30, 5, 0];

      for (int i = 0; i < reminderMinutes.length; i++) {
        int minutesBefore = reminderMinutes[i];
        DateTime reminderTime =
            scheduledDateTime.subtract(Duration(minutes: minutesBefore));

        // Skip if reminder time is in the past
        if (reminderTime.isBefore(now)) {
          print(
              'Skipping reminder for $minutesBefore minutes before appointment as it is in the past');
          continue;
        }

        final tz.TZDateTime tzReminderTime = tz.TZDateTime.from(
          reminderTime,
          tz.local,
        );

        // Generate unique notification ID for each reminder
        int notificationId = (id.hashCode + i + 1); // +1, +2, +3 for uniqueness

        // Customize body for start time notification
        String notificationBody = body.isEmpty
            ? minutesBefore == 0
                ? 'Your appointment is starting now at ${formatDate(scheduledDateTime)}'
                : 'Your appointment is in $minutesBefore minutes at ${formatDate(scheduledDateTime)}'
            : body.replaceAll('{minutes}',
                minutesBefore == 0 ? '0' : minutesBefore.toString());

        // Define notification details
        AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'appointment_channel',
          'Appointment Reminders',
          channelDescription: 'Channel for appointment reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('tone1'),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          autoCancel: false,
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

        // Schedule the notification
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title.isEmpty ? 'Appointment Reminder' : title,
          notificationBody,
          tzReminderTime,
          NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iosPlatformChannelSpecifics,
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }

      toast("Appointment reminders scheduled");
    } catch (e) {
      print('Error scheduling appointment notification: $e');
      toast("Error scheduling notification: $e");
    }
  }

  Future<void> cancelAppointmentNotification({
    required String appointmentId,
  }) async {
    try {
      // Cancel all three notifications (30, 5, and 0 minutes)
      for (int i = 1; i <= 3; i++) {
        int notificationId = (appointmentId.hashCode + i);
        await _notificationsPlugin.cancel(notificationId);
      }
      toast("Appointment notifications canceled");
    } catch (e) {
      print("Error canceling appointment notifications: $e");
      toast("Error canceling notifications: $e");
    }
  }

  Future<bool> isDoctorAlreadyBooked({
    required String docId,
    required Timestamp startTime,
    required Timestamp endTime,
  }) async {
    try {
      DateTime startDateTime = startTime.toDate();
      DateTime endDateTime = endTime.toDate();

      var startQuerySnapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('doctorId', isEqualTo: docId)
          .where('startTime', isLessThan: endTime)
          .get();

      var endQuerySnapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('doctorId', isEqualTo: docId)
          .where('endTime', isGreaterThan: startTime)
          .get();

      var querySnapshotDocs = [
        ...startQuerySnapshot.docs,
        ...endQuerySnapshot.docs,
      ];

      for (var doc in querySnapshotDocs) {
        Timestamp existingStartTime = doc['startTime'];
        Timestamp existingEndTime = doc['endTime'];

        DateTime existingStartDateTime = existingStartTime.toDate();
        DateTime existingEndDateTime = existingEndTime.toDate();

        if ((existingStartDateTime.isAfter(startDateTime) &&
                existingStartDateTime.isBefore(endDateTime)) ||
            (existingEndDateTime.isAfter(startDateTime) &&
                existingEndDateTime.isBefore(endDateTime)) ||
            (existingStartDateTime.isBefore(startDateTime) &&
                existingEndDateTime.isAfter(endDateTime))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error checking doctor availability: $e');
      return false;
    }
  }

  Future<AppointmentModel> getAppointment(
      {required String appointmentId}) async {
    var appointmentRef = await appointmentCollection.doc(appointmentId).get();
    var appointment = appointmentRef.data();
    return AppointmentModel.fromJson(appointment!);
  }

  Future<String?> createAppointment({
    required String docId,
    required String userId,
    required String complain,
    required int price,
    required String package,
    required Timestamp endTime,
    required Timestamp startTime,
    required bool isTrial,
  }) async {
    var data = {
      "doctorId": docId,
      "userId": userId,
      "status": "pending",
      "complain": complain,
      "startTime": startTime,
      "endTime": endTime,
      "price": price,
      "package": package,
      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now(),
      "isPaid": false,
      "isTrial": isTrial,
    };
    var result = await appointmentCollection.add(data);
    await appointmentCollection.doc(result.id).update({
      "id": result.id,
    });
    return result.id;
  }

  Future<bool> updateAppointmentAfterPayment({
    required String appointmentId,
  }) async {
    final doctorService = Get.find<DoctorService>();

    if (appointmentId.trim().isEmpty) {
      print("Invalid appointmentId passed to updateAppointmentAfterPayment.");
      toast("Invalid appointment ID");
      return false;
    }

    try {
      await appointmentCollection.doc(appointmentId).update({
        "isPaid": true,
        "updatedAt": Timestamp.now(),
      });

      var appointment = await getAppointment(appointmentId: appointmentId);

      await notificationService.newNotification(
        userId: appointment.doctorId.validate(),
        type: NotificationType.appointment,
        title:
            "You received an appointment ${formatDate(appointment.startTime!.toDate())} - ${formatDate(appointment.endTime!.toDate())}",
      );

      await notificationService.newNotification(
        userId: userController.userId.value,
        type: NotificationType.appointment,
        title:
            "You have successfully scheduled an appointment ${formatDate(appointment.startTime!.toDate())} - ${formatDate(appointment.endTime!.toDate())}",
      );

      var docTokens = await doctorService.getDoctorsToken();
      sendNotification(
        docTokens,
        "New Appointment",
        "A new appointment have been scheduled, kindly accept it..",
        appointmentId,
        NotificationType.appointment,
      );

      await scheduleAppointmentNotification(
        title: "Appointment Reminder",
        body:
            "Your appointment is in {minutes} minutes at ${formatDate(appointment.startTime!.toDate())}",
        id: appointmentId,
        type: NotificationType.appointment,
        scheduledTime: appointment.startTime!,
        endTime: appointment.endTime!,
      );

      return true;
    } catch (err) {
      print("Error in updateAppointmentAfterPayment: $err");
      toast("Error processing payment: $err");
      return false;
    }
  }

  Future<void> deleteAppointment({required String appointmentId}) async {
    try {
      await cancelAppointmentNotification(appointmentId: appointmentId);

      await appointmentCollection.doc(appointmentId).update({
        "status": 'deleted',
        "updatedAt": Timestamp.now(),
      });

      toast("Appointment deleted successfully");
    } catch (e) {
      print("Error deleting appointment: $e");
      toast("Error deleting appointment: $e");
    }
  }

  Stream<List<AppointmentModel>> getAllAppointment(String userId) {
    return appointmentCollection
        .where("userId", isEqualTo: userId)
        .where('status', isNotEqualTo: 'deleted')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => AppointmentModel.fromJson(e.data()))
            .toList());
  }

  Stream<List<AppointmentConversationModel>> getConversation(
      String appointmentId) {
    ChatController chatController = Get.put(ChatController());

    var query = appointmentCollection
        .doc(appointmentId)
        .collection("conversation")
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) {
      chatController.message.value = event.docs
          .map((r) => AppointmentConversationModel.fromJson(r.data()))
          .toList();
      return event.docs
          .map((e) => AppointmentConversationModel.fromJson(e.data()))
          .toList();
    });
    return query;
  }

  Stream<List<AppointmentConversationModel>> getUnreadChat(
      String appointmentId, String userId) {
    var query = appointmentCollection
        .doc(appointmentId)
        .collection("conversation")
        .where('senderId', isEqualTo: userId)
        .where('status', isNotEqualTo: MessageStatus.read)
        .snapshots()
        .map((event) => event.docs
            .map((e) => AppointmentConversationModel.fromJson(e.data()))
            .toList());
    return query;
  }

  Future updateChatStatus(
      {required String appointmentId, required String userId}) async {
    var result = await appointmentCollection
        .doc(appointmentId)
        .collection("conversation")
        .where('senderId', isEqualTo: userId)
        .where('status', isNotEqualTo: MessageStatus.read)
        .get();
    for (var i = 0; i < result.docs.length; i++) {
      var data = result.docs[i];
      updateReadChat(appointmentId: appointmentId, chatId: data.id);
    }
  }

  Future updateReadChat(
      {required String appointmentId, required String chatId}) async {
    await appointmentCollection
        .doc(appointmentId)
        .collection("conversation")
        .doc(chatId)
        .update({"status": MessageStatus.read});
    return;
  }

  Future<String> handleSendMessage(
      {required String appointmentId,
      String? message,
      List? files,
      required String senderId,
      required String receiverId,
      required String type}) async {
    String msgId = '';
    ChatController chatController = Get.put(ChatController());

    if (files!.isEmpty) {
      var data = {
        "message": SecurityHelper().encryptText(message.validate()),
        "senderId": senderId,
        "receiverId": receiverId,
        "type": type,
        "status": MessageStatus.pending,
        "createdAt": Timestamp.now(),
      };
      chatController.message.value = [
        AppointmentConversationModel.fromJson(data),
        ...chatController.message
      ];
      msgId = await sendMessage(appointmentId, data);
    } else {
      int count = 0;
      for (var file in files) {
        var fileUrl = await uploadFile(file, appointmentId);
        var data = {
          "message":
              count > 0 ? '' : SecurityHelper().encryptText(message.validate()),
          "senderId": senderId,
          "receiverId": receiverId,
          "type": type,
          "fileUrl": fileUrl,
          "createdAt": Timestamp.now(),
          "status": MessageStatus.pending,
        };
        count++;
        chatController.message.value = [
          AppointmentConversationModel.fromJson(data),
          ...chatController.message
        ];
        msgId = await sendMessage(appointmentId, data);
      }
    }
    chatController.files.clear();
    chatController.images.clear();
    return msgId;
  }

  Future<String> sendMessage(appointmentId, data) async {
    updateAppointmentTime(appointmentId: appointmentId);
    var colRef = await appointmentCollection
        .doc(appointmentId)
        .collection("conversation")
        .add(data);

    colRef.update({
      "id": colRef.id,
      "status": MessageStatus.delivered,
    });
    return colRef.id;
  }

  Future<void> updateAppointmentTime({required String appointmentId}) async {
    appointmentCollection.doc(appointmentId).update({
      "updatedAt": Timestamp.now(),
    });
  }

  Future<void> updateDoctorEarning(
      {required String appointmentId, required int doctorEarning}) async {
    appointmentCollection.doc(appointmentId).update({
      "doctorEarning": doctorEarning,
    });
  }

  Future<List<Appointmentpricingmodel>> getAppointmentPrice() async {
    var ref = await appointmentPricingCollection
        .orderBy('amount', descending: false)
        .get();
    return ref.docs
        .map((e) => Appointmentpricingmodel.fromJson(e.data()))
        .toList();
  }
}
