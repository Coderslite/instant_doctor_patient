import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  String? id;
  String? userId;
  String? doctorId;
  String? complaint;
  String? status;
  Timestamp? startTime;
  Timestamp? endTime;
  Timestamp? createdAt;
  String? videocallToken;

  AppointmentModel({
    this.id,
    this.userId,
    this.doctorId,
    this.complaint,
    this.status,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.videocallToken,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      status: json['status'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      createdAt: json['createdAt'],
      videocallToken: json['videocallToken'],

    );
  }
}

class AppointmentConversationModel {
  String? id;
  String? senderId;
  String? receiverId;
  String? message;
  String? fileUrl;
  String? type;
  String? status;
  Timestamp? createdAt;

  AppointmentConversationModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.message,
    this.fileUrl,
    this.type,
    this.status,
    this.createdAt,
  });

  factory AppointmentConversationModel.fromJson(Map<String, dynamic> json) {
    return AppointmentConversationModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      fileUrl: json['fileUrl'],
      type: json['type'],
      status: json['status'],
    );
  }
}
