// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import '../models/NotificationModel.dart';
import 'BaseService.dart';

class NotificationService extends BaseService {
  var notificationCol = FirebaseFirestore.instance.collection("Notification");

  Future newNotification({
    required String userId,
    required String type,
    required String title,
    String? uniqueId,
  }) async {
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
  }

  Future<List<NotificationModel>> getUserNotifications(
      {required String userId}) async {
    var result = await notificationCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return result.docs
        .map((e) => NotificationModel.fromJson(e.data()))
        .toList();
  }

  Future<List<NotificationModel>> getUserAllUnSeenNotifications(
      {required String userId}) async {
    var result = await notificationCol
        .where('userId', isEqualTo: userId)
        .where('status', isNotEqualTo: MessageStatus.read)
        .get();
    return result.docs
        .map((e) => NotificationModel.fromJson(e.data()))
        .toList();
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

  Future updateNotificationStatus() async {
    var result = await notificationCol
        .where('userId', isEqualTo: userController.userId.value)
        .where('status', isNotEqualTo: MessageStatus.read)
        .get();
    for (var not in result.docs) {
      await notificationCol.doc(not.id).update({
        "status": MessageStatus.read,
      });
    }
  }
}
