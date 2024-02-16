import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralModel {
  String? id;
  String? userId;
  String? referredBy;
  String? title;
  Timestamp? createdAt;

  ReferralModel({
    this.id,
    this.userId,
    this.referredBy,
    this.title,
    this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'],
      userId: json['userId'],
      referredBy: json['referredBy'],
      title: json['title'],
      createdAt: json['createdAt'],
    );
  }
}
