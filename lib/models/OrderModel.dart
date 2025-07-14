import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? id;
  String? userId;
  String? pharmacyId;
  List? items;
  int? totalAmount;
  int? deliveryFee;
  int? pharmacyEarning;
  String? address;
  String? trackingId;
  String? status;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  OrderModel({
    this.id,
    this.userId,
    this.pharmacyId,
    this.items,
    this.totalAmount,
    this.deliveryFee,
    this.pharmacyEarning,
    this.address,
    this.trackingId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      pharmacyId: json['pharmacyId'],
      items: json['items'],
      address: json['address'],
      deliveryFee: json['deliveryFee'],
      trackingId: json['trackingId'],
      status: json['status'],
      totalAmount: json['totalAmount'],
      pharmacyEarning: json['pharmacyEarning'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  toJson() {
    var data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['pharmacyId'] = pharmacyId;
    data['items'] = items;
    data['status'] = status;
    data['totalAmount'] = totalAmount;
    data['pharmacyEarning'] = pharmacyEarning;
    data['trackingId'] = trackingId;
    data['address'] = address;
    data['deliveryFee'] = deliveryFee;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
