import 'package:cloud_firestore/cloud_firestore.dart';

class WaitlistModel {
  String? id;
  String? userId;
  String? address;
  GeoPoint? location;
  Timestamp? createdAt;

  WaitlistModel({
    this.id,
    this.userId,
    this.address,
    this.location,
    this.createdAt,
  });

  factory WaitlistModel.fromJson(Map<String, dynamic> json) {
    return WaitlistModel(
      id: json['id'],
      userId: json['userId'],
      address: json['address'],
      location: json['location'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['address'] = address;
    data['location'] = location;
    data['createdAt'] = createdAt;
    return data;
  }
}
