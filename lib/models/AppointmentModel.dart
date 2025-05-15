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
  Timestamp? updatedAt;
  int? duration;
  int? price;
  String? package;
  String? videocallToken;
  bool? isPaid;

  AppointmentModel({
    this.id,
    this.userId,
    this.doctorId,
    this.complaint,
    this.status,
    this.startTime,
    this.endTime,
    this.duration,
    this.price,
    this.package,
    this.createdAt,
    this.updatedAt,
    this.videocallToken,
    this.isPaid,
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
      updatedAt: json['updatedAt'],
      package: json['package'],
      duration: json['duration'],
      price: json['price'],
      videocallToken: json['videocallToken'],
      isPaid: json['isPaid'],
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

  toJson() {
    Map<String, dynamic> data = {};
    data['id'] = id;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['message'] = message;
    data['fileUrl'] = fileUrl;
    data['type'] = type;
    data['status'] = status;
    return data;
  }
}
