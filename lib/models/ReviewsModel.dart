import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/main.dart';

class ReviewsModel {
  String? id;
  int? rating;
  String? userId;
  String? doctorId;
  String? review;
  String? appointmentId;
  Timestamp? createdAt;

  ReviewsModel({
    this.id,
    this.rating,
    this.userId,
    this.doctorId,
    this.review,
    this.appointmentId,
    this.createdAt,
  });

  factory ReviewsModel.fromJson(Map<String, dynamic> json) {
    return ReviewsModel(
      id: json['id'],
      rating: json['rating'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      review: json['review'],
      appointmentId: json['appointmentId'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data["id"] = id;
    data['rating'] = rating;
    data['userId'] = userId;
    data['doctorId'] = doctorId;
    data['review'] = review;
    data['appointmentId'] = appointmentId;
    data['createdAt'] = createdAt;
    return data;
  }

  
}
