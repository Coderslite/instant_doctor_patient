import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentReportModel {
  String? id;
  String? subject;
  String? report;
  String? userId;
  String? doctorId;
  String? appointmentId;
  String? status;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  AppointmentReportModel({
    this.id,
    this.subject,
    this.report,
    this.userId,
    this.doctorId,
    this.appointmentId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentReportModel.fromJson(Map<String, dynamic> json) {
    return AppointmentReportModel(
      id: json['id'],
      doctorId: json['doctorId'],
      userId: json['userId'],
      appointmentId: json['appointmentId'],
      subject: json['subject'],
      report: json['report'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['doctorId'] = doctorId;
    data['userId'] = userId;
    data['appointmentId'] = appointmentId;
    data['subject'] = subject;
    data['report'] = report;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class AppointmentReportConversation {
  String? id;
  String? senderId;
  String? receiverId;
  String? message;
  String? fileUrl;
  String? type;
  String? status;
  Timestamp? createdAt;

  AppointmentReportConversation({
    this.id,
    this.senderId,
    this.receiverId,
    this.message,
    this.fileUrl,
    this.type,
    this.status,
    this.createdAt,
  });

  factory AppointmentReportConversation.fromJson(Map<String, dynamic> json) {
    return AppointmentReportConversation(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      fileUrl: json['fileUrl'],
      type: json['type'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['message'] = message;
    data['fileUrl'] = fileUrl;
    data['type'] = type;
    data['status'] = status;
    data['createdAt'] = createdAt;
    return data;
  }
}
