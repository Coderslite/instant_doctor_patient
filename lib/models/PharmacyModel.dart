import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyModel {
  String? id;
  String? name;
  String? email;
  int? deliveryCharge;
  String? address;
  int? discount;
  String? image;
  GeoPoint? location;
  String? phoneNumber;

  PharmacyModel({
    this.id,
    this.name,
    this.email,
    this.address,
    this.discount,
    this.image,
    this.deliveryCharge,
    this.location,
    this.phoneNumber,
  });
  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      image: json['image'],
      discount: json['discount'],
      deliveryCharge: json['deliveryFee'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
