import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/AppointmentPricingModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/formatDate.dart';

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
  final notificationService = Get.find<NotificationService>();

  var appointmentCollection = db.collection("Appointments");
  var appointmentPricingCollection = db.collection("AppointmentPricing");

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
      "status": "pending",
      "complain": complain,
      "startTime": startTime,
      "endTime": endTime,
      "price": price,
      "package": package,
      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now(),
      "isPaid": false,
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
    if (appointmentId.trim().isEmpty) {
      print("Invalid appointmentId passed to updateAppointmentAfterPayment.");
      return false;
    }

    try {
      // Step 1: Update isPaid flag
      await appointmentCollection.doc(appointmentId).update({
        "isPaid": true,
      });

      // Step 2: Fetch appointment
      var appointment = await getAppointment(appointmentId: appointmentId);

      var usertoken = await userService.getUserToken(
        userId: userController.userId.value,
      );

      // Step 4: Send in-app notifications
      notificationService.newNotification(
        userId: appointment.doctorId.validate(),
        type: NotificationType.appointment,
        title:
            "You received an appointment ${formatDate(appointment.startTime!.toDate())} - ${formatDate(appointment.endTime!.toDate())}",
      );

      notificationService.newNotification(
        userId: userController.userId.value,
        type: NotificationType.appointment,
        title:
            "You have successfully scheduled an appointment ${formatDate(appointment.startTime!.toDate())} - ${formatDate(appointment.endTime!.toDate())}",
      );

      sendNotification(
        [usertoken],
        "New Appointment",
        "You have successfully scheduled an appointment ${formatDate(appointment.startTime!.toDate())} - ${formatDate(appointment.endTime!.toDate())}",
        appointmentId,
        NotificationType.transaction,
      );

      // Step 6: Schedule reminders
      scheduleAppointmentNotification(
        tokens: [usertoken],
        title: "",
        body: "",
        id: appointmentId,
        type: NotificationType.appointment,
        scheduledTime: appointment.startTime!,
        endTime: appointment.endTime!,
      );

      return true;
    } catch (err, stack) {
      print("Error in updateAppointmentAfterPayment: $err");
      return false;
    }
  }

  Stream<List<AppointmentModel>> getAllAppointment(String userId) {
    return appointmentCollection
        .where("userId", isEqualTo: userId)
        .where('status', isNotEqualTo: 'deleted')
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

  Future<void> deleteAppointment({required String appointmentId}) async {
    var chats = await appointmentCollection
        .doc(appointmentId)
        .update({"status": 'deleted'});
    // for (var chat in chats.docs) {
    //   await appointmentCollection
    //       .doc(appointmentId)
    //       .collection("conversation")
    //       .doc(chat.id)
    //       .delete();
    // }
    // await appointmentCollection.doc(appointmentId).delete();
    return;
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
