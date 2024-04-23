import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:instant_doctor/services/UploadFile.dart';

import '../main.dart';
import '../models/AppointmentReportModel.dart';

class ReportService extends BaseService {
  var reportCol = db.collection('Reports');
  Future createReport(AppointmentReportModel report) async {
    var ref = await reportCol.add(report.toJson());
    await updateReport(id: ref.id, data: {"id": ref.id});
    var reportR = AppointmentReportConversation(
      senderId: report.userId,
      receiverId: 'admin',
      message: report.report,
      type: MessageType.text,
      status: MessageStatus.delivered,
      createdAt: report.createdAt,
    );

    var ref2 = await reportCol
        .doc(ref.id)
        .collection("conversation")
        .add(reportR.toJson());
    await updateReportConv(
        reportId: ref.id, conversationId: ref2.id, data: {"id": ref2.id});
  }

  Future<AppointmentReportModel?> getReport(
      {required String appointmentId}) async {
    var reportRef =
        await reportCol.where('appointmentId', isEqualTo: appointmentId).get();
    var report = reportRef.docs;
    if (report.isNotEmpty) {
      return AppointmentReportModel.fromJson(report.first.data());
    } else {
      return null;
    }
  }

  Stream<List<AppointmentReportModel>> getAllReports({required String userId}) {
    var reportsnap = reportCol
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
    var reports = reportsnap.map((event) => event.docs
        .map((e) => AppointmentReportModel.fromJson(e.data()))
        .toList());
    return reports;
  }

  Stream<List<AppointmentReportConversation>> getReportConversation(
      {required String id}) {
    var reportSnap = reportCol
        .doc(id)
        .collection("conversation")
        .orderBy('createdAt', descending: true)
        .snapshots();
    var reports = reportSnap.map((event) => event.docs
        .map((e) => AppointmentReportConversation.fromJson(e.data()))
        .toList());
    return reports;
  }

  Future<void> updateReport(
      {required String id, required Map<String, dynamic> data}) async {
    await reportCol.doc(id).update(data);
  }

  Future<void> updateReportConv(
      {required String reportId,
      required String conversationId,
      required Map<String, dynamic> data}) async {
    await reportCol
        .doc(reportId)
        .collection("conversation")
        .doc(conversationId)
        .update(data);
  }

  handleSendMessage(
      {required String reportId,
      String? message,
      required List files,
      required String senderId,
      required String type}) async {
    String msgId = '';
    if (files!.isEmpty) {
      var data = {
        "message": message,
        "senderId": senderId,
        "receiverId": 'admin',
        "type": type,
        "status": MessageStatus.delivered,
        "createdAt": Timestamp.now(),
      };
      msgId = await sendMessage(reportId, data);
    } else {
      int count = 0;
      for (var file in files) {
        var fileUrl = await uploadReportFile(file, reportId);
        var data = {
          "message": count > 0 ? '' : message,
          "senderId": senderId,
          "type": type,
          "fileUrl": fileUrl,
          "createdAt": Timestamp.now(),
        };
        count++;
        msgId = await sendMessage(reportId, data);
        updateReportConv(reportId: reportId, conversationId: msgId, data: {
          "id": msgId,
        });
        updateReport(id: reportId, data: {
          "updatedAt": Timestamp.now(),
        });
      }
    }
  }

  Future<String> sendMessage(reportId, data) async {
    var messageRef =
        await reportCol.doc(reportId).collection("conversation").add(data);
    return messageRef.id;
  }

  Future<void> deleteReport({required String reportId}) async {
    var chats = await reportCol.doc(reportId).collection("conversation").get();
    for (var chat in chats.docs) {
      await reportCol
          .doc(reportId)
          .collection("conversation")
          .doc(chat.id)
          .delete();
    }
    await reportCol.doc(reportId).delete();
    return;
  }
}
