import 'package:cloud_firestore/cloud_firestore.dart';

class LabResultModel {
  String? id;
  String? userId;
  String? fileUrl;
  String? resultUrl;
  String? status;
  bool? opened;
  Timestamp? createdAt;

  LabResultModel({
    this.id,
    this.userId,
    this.fileUrl,
    this.resultUrl,
    this.opened,
    this.status,
    this.createdAt,
  });

  factory LabResultModel.fromJson(Map<String, dynamic> json) {
    return LabResultModel(
      id: json['id'],
      userId: json['userId'],
      fileUrl: json['fileUrl'],
      resultUrl: json['resultUrl'],
      opened: json['opened'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
