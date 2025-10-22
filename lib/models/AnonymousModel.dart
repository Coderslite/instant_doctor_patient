import 'package:cloud_firestore/cloud_firestore.dart';

class AnonymousModel {
  String? id;
  String? question;
  String? answer;
  String? userId;
  String? status;
  Timestamp? createdAt;

  AnonymousModel({
    this.id,
    this.question,
    this.answer,
    this.userId,
    this.status,
    this.createdAt,
  });

  factory AnonymousModel.fromJson(Map<String, dynamic> json) {
    return AnonymousModel(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      userId: json['userId'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
