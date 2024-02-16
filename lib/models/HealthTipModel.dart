import 'package:cloud_firestore/cloud_firestore.dart';

class HealthTipModel {
  String? id;
  String? title;
  String? description;
  String? category;
  String? type;
  String? image;
  int? views;
  Timestamp? createdAt;

  HealthTipModel({
    this.id,
    this.title,
    this.description,
    this.category,
    this.image,
    this.type,
    this.views,
    this.createdAt,
  });

  factory HealthTipModel.fromJson(Map<String, dynamic> json) {
    return HealthTipModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      image: json['image'],
      type: json['type'],
      views: json['views'],
      createdAt: json['createdAt'],
    );
  }
}
