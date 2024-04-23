import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/services/TransactionService.dart';
import 'package:instant_doctor/services/formatDate.dart';
import 'package:instant_doctor/services/format_number.dart';

import '../constant/constants.dart';
import '../controllers/ChatController.dart';
import '../function/send_notification.dart';
import '../main.dart';
import '../models/AppointmentModel.dart';
import 'UploadFile.dart';

class AppointmentService {
  ChatController chatController = Get.put(ChatController());
  var appointmentCollection = db.collection("Appointments");

  Future<bool> isDoctorAlreadyBooked({
    required String docId,
    required Timestamp startTime,
    required Timestamp endTime,
  }) async {
    try {
      // Convert Timestamp to DateTime
      DateTime startDateTime = startTime.toDate();
      DateTime endDateTime = endTime.toDate();

      // Query appointments for the doctor starting before the specified end time
      var startQuerySnapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('doctorId', isEqualTo: docId)
          .where('startTime', isLessThan: endTime)
          .get();

      // Query appointments for the doctor ending after the specified start time
      var endQuerySnapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('doctorId', isEqualTo: docId)
          .where('endTime', isGreaterThan: startTime)
          .get();

      // Merge the results of the two queries
      var querySnapshotDocs = [
        ...startQuerySnapshot.docs,
        ...endQuerySnapshot.docs,
      ];

      // If there are any appointments found, check if they overlap with the specified time range
      for (var doc in querySnapshotDocs) {
        Timestamp existingStartTime = doc['startTime'];
        Timestamp existingEndTime = doc['endTime'];

        // Convert Timestamp to DateTime for existing appointments
        DateTime existingStartDateTime = existingStartTime.toDate();
        DateTime existingEndDateTime = existingEndTime.toDate();

        // Check for overlapping appointments
        if ((existingStartDateTime.isAfter(startDateTime) &&
                existingStartDateTime.isBefore(endDateTime)) ||
            (existingEndDateTime.isAfter(startDateTime) &&
                existingEndDateTime.isBefore(endDateTime)) ||
            (existingStartDateTime.isBefore(startDateTime) &&
                existingEndDateTime.isAfter(endDateTime))) {
          // Overlapping appointments found, so doctor is already booked
          return true;
        }
      }

      // No overlapping appointments found, doctor is available
      return false;
    } catch (e) {
      // Handle any errors, such as Firebase exceptions
      print('Error checking doctor availability: $e');
      return false; // Assume doctor is not booked to avoid blocking the appointment
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
  }) async {
    var data = {
      "doctorId": docId,
      "userId": userId,
      "status": "Pending",
      "complain": complain,
      "startTime": startTime,
      "endTime": endTime,
      "price": price,
      "package": package,
      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now(),
    };

    var debitResult =
        await walletService.debitUser(userId: userId, amount: price);
    if (debitResult) {
      var result = await appointmentCollection.add(data);
      await appointmentCollection.doc(result.id).update({
        "id": result.id,
      });
      await transactionService.newTransaction(
          title:
              "${formatAmount(price)} was charged for your booked appointment",
          userId: userId,
          type: TransactionType.debit,
          amount: price);
      var doctoken = await userService.getUserToken(userId: docId);
      var usertoken = await userService.getUserToken(userId: userId);
      await notificationService.newNotification(
          userId: docId,
          type: NotificatonType.appointment,
          title:
              "You received an appointment ${formatDate(startTime.toDate())} - ${formatDate(endTime.toDate())}",
          tokens: [doctoken],
          isPushNotification: true);

      await notificationService.newNotification(
          userId: userId,
          type: NotificatonType.appointment,
          title:
              "You have successful schedule an appointment ${formatDate(startTime.toDate())} - ${formatDate(endTime.toDate())}",
          tokens: [usertoken],
          isPushNotification: true);

      return result.id;
    } else {
      return null;
    }
  }

  Stream<List<AppointmentModel>> getAllAppointment(String userId) {
    return appointmentCollection
        .where("userId", isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => AppointmentModel.fromJson(
                e.data(),
              ),
            )
            .toList());
  }

  Stream<List<AppointmentConversationModel>> getConversation(
      String appointmentId) {
    var query = appointmentCollection
        .doc(appointmentId)
        .collection("conversation")
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => AppointmentConversationModel.fromJson(e.data()))
            .toList());
    return query;
  }

  Stream<List<AppointmentConversationModel>> getUnreadChat(
      String appointmentId, String userId) {
    var query = appointmentCollection
        .doc(appointmentId)
        .collection("conversation")
        .where(
          'senderId',
          isEqualTo: userId,
        )
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
    if (files!.isEmpty) {
      var data = {
        "message": message,
        "senderId": senderId,
        "receiverId": receiverId,
        "type": type,
        "status": MessageStatus.delivered,
        "createdAt": Timestamp.now(),
      };
      msgId = await sendMessage(appointmentId, data);
    } else {
      int count = 0;
      for (var file in files) {
        var fileUrl = await uploadFile(file, appointmentId);
        var data = {
          "message": count > 0 ? '' : message,
          "senderId": senderId,
          "receiverId": receiverId,
          "type": type,
          "fileUrl": fileUrl,
          "createdAt": Timestamp.now(),
        };
        count++;
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
    });
    return colRef.id;
  }

  Future<void> updateAppointmentTime({required String appointmentId}) async {
    appointmentCollection.doc(appointmentId).update({
      "updatedAt": Timestamp.now(),
    });
  }

  Future<void> deleteAppointment({required String appointmentId}) async {
    var chats = await appointmentCollection
        .doc(appointmentId)
        .collection("conversation")
        .get();
    for (var chat in chats.docs) {
      await appointmentCollection
          .doc(appointmentId)
          .collection("conversation")
          .doc(chat.id)
          .delete();
    }
    await appointmentCollection.doc(appointmentId).delete();
    return;
  }
}
