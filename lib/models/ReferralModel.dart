import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralModel {
  String? id;
  String? userId;
  String? referredBy;
  String? name;
  int? amountEarned;
  double? totalCommissionEarned;
  String? status;
  Timestamp? createdAt;

  ReferralModel({
    this.id,
    this.userId,
    this.referredBy,
    this.amountEarned,
    this.totalCommissionEarned,
    this.status,
    this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'],
      userId: json['userId'],
      referredBy: json['referredBy'],
      amountEarned: json['amountEarned'],
      totalCommissionEarned: json['totalCommissionEarned'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
