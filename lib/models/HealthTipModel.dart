import 'package:cloud_firestore/cloud_firestore.dart';

class HealthTipModel {
  String? id;
  String? title;
  String? description;
  String? categoryId;
  String? type;
  String? image;
  int? views;
  Timestamp? createdAt;

  HealthTipModel({
    this.id,
    this.title,
    this.description,
    this.categoryId,
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
      categoryId: json['categoryId'],
      image: json['image'],
      type: json['type'],
      views: json['views'],
      createdAt: json['createdAt'],
    );
  }
}

class HealthTipsCategoryModel {
  String? id;
  String? name;
  String? image;

  HealthTipsCategoryModel({
    this.id,
    this.name,
    this.image,
  });

  factory HealthTipsCategoryModel.fromJson(Map<String, dynamic> json) {
    return HealthTipsCategoryModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}
