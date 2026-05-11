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
  String? currency;
  String? package;
  String? videocallToken;
  bool? isPaid;
  bool? isTrial;

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
    this.currency,
    this.package,
    this.createdAt,
    this.updatedAt,
    this.videocallToken,
    this.isPaid,
    this.isTrial,
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
      currency: json['currency'],
      videocallToken: json['videocallToken'],
      isPaid: json['isPaid'],
      isTrial: json['isTrial'],
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
  String? repliedTo;
  String? repliedText;
  String? repliedSender;
  bool? isDeleted;
  Timestamp? deleted;
  bool? isEdited;
  Timestamp? edited;

  AppointmentConversationModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.message,
    this.fileUrl,
    this.type,
    this.status,
    this.createdAt,
    this.repliedSender,
    this.repliedText,
    this.repliedTo,
    this.isDeleted,
    this.deleted,
    this.isEdited,
    this.edited,
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
      repliedTo: json['repliedTo'],
      repliedText: json['repliedText'],
      repliedSender: json['repliedSender'],
      deleted: json['deleted'],
      edited: json['edited'],
      isDeleted: json['isDeleted'],
      isEdited: json['isEdited'],
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
    data['repliedTo'] = repliedTo;
    data['repliedText'] = repliedText;
    data['repliedSender'] = repliedSender;
    return data;
  }
}
