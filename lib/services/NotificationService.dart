import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/function/send_notification.dart';
import '../models/NotificationModel.dart';
import 'BaseService.dart';

class NotificationService extends BaseService {
  var notificationCol = FirebaseFirestore.instance.collection("Notification");

  Future newNotification(
      {required String userId,
      required String type,
      required String title,
      String? uniqueId,
      List? tokens,
      required bool isPushNotification}) async {
    var data = {
      "userId": userId,
      "type": type,
      "title": title,
      "uniqueId": uniqueId,
      "status": MessageStatus.delivered,
      "createdAt": Timestamp.now(),
    };

    var notRef = await notificationCol.add(data);
    await notificationCol.doc(notRef.id).update({
      "id": notRef.id,
    });
    if (isPushNotification == true && tokens!.isNotEmpty) {
      sendNotification(
          tokens,
          "Instant Doctor",
          type == NotificatonType.appointment
              ? "You just received a new appointment schedule"
              : title,
          notRef.id,
          type);
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(
      {required String userId}) {
    var result = notificationCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
    return result.map((event) =>
        event.docs.map((e) => NotificationModel.fromJson(e.data())).toList());
  }

  Stream<List<NotificationModel>> getUserUnSeenNotifications(
      {required String userId}) {
    var result = notificationCol
        .where('userId', isEqualTo: userId)
        .where('status', isNotEqualTo: MessageStatus.read)
        .snapshots();
    return result.map((event) =>
        event.docs.map((e) => NotificationModel.fromJson(e.data())).toList());
  }

  Future updateNotificationStatus({required notificationId}) async {
    await notificationCol.doc(notificationId).update({
      "status": MessageStatus.read,
    });
  }
}
