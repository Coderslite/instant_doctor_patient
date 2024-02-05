import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? id;
  String? title;
  String? userId;
  String? transactionType;
  int? amount;
  Timestamp? createdAt;

  TransactionModel({
    this.id,
    this.title,
    this.userId,
    this.transactionType,
    this.amount,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      userId: json['userId'],
      transactionType: json['transactionType'],
      amount: json['amount'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['userId'] = userId;
    data['transactionType'] = transactionType;
    data['amount'] = amount;
    data['createdAt'] = createdAt;

    return data;
  }
}
