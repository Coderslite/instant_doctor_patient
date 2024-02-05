import 'package:cloud_firestore/cloud_firestore.dart';

class LapResultModel {
  String? id;
  String? userId;
  String? fileUrl;
  Timestamp? createdAt;

  LapResultModel({
    this.id,
    this.userId,
    this.fileUrl,
    this.createdAt,
  });
}
