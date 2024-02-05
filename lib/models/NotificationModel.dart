import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  String? uniqueId;
  String? userId;
  String? title;
  String? type;
  String? status;
  Timestamp? createdAt;

  NotificationModel({
    this.id,
    this.uniqueId,
    this.userId,
    this.title,
    this.type,
    this.status,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      uniqueId: json['uniqueId'],
      userId: json['userId'],
      title: json['title'],
      type: json['type'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
