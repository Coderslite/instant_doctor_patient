import 'package:cloud_firestore/cloud_firestore.dart';

class DrugModel {
  String? id;
  String? pharmacyId;
  String? category;
  String? name;
  String? description;
  int? amount;
  int quantity;
  int? remaining;
  int? purchasePrice;
  int? discount;
  List? images;
  Timestamp? createdAt;

  DrugModel({
    this.id,
    this.pharmacyId,
    this.category,
    this.name,
    this.description,
    this.amount,
    this.purchasePrice,
    this.discount,
    this.quantity = 1,
    this.remaining,
    this.images,
    this.createdAt,
  });

  factory DrugModel.fromJson(Map<String, dynamic> json) {
    return DrugModel(
      id: json['id'],
      pharmacyId: json['pharmacyId'],
      category: json['category'],
      name: json['name'],
      description: json['description'],
      amount: json['amount'],
      discount: json['discount'] ?? 0,
      purchasePrice: json['purchasePrice'],
      quantity: json['quantity'] ?? 1,
      remaining: json['remaining'],
      images: json['images'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'quantity': quantity,
        'remaining': remaining,
        'pharmacyId': pharmacyId,
        'discount': discount,
        'images': images,
      };

  DrugModel copyWith({
    String? id,
    String? pharmacyId,
    String? name,
    String? description,
    int? amount,
    int? purchasePrice,
    int? discount,
    int? quantity,
    int? remaining,
    List? images,
    Timestamp? createdAt,
  }) {
    return DrugModel(
      id: id ?? this.id,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      discount: discount ?? this.discount,
      quantity: quantity ?? this.quantity,
      remaining: remaining ?? this.remaining,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DrugCategoryModel {
  String? id;
  String? name;
  DrugCategoryModel({
    this.id,
    this.name,
  });

  factory DrugCategoryModel.fromJson(Map<String, dynamic> json) {
    return DrugCategoryModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
