import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? photoUrl;
  String? speciality;
  String? status;
  double? amount;
  int? experience;
  String? bio;
  bool? isAvailable;
  List? workingHours;
  String? state;
  Timestamp? lastSeen;
  String? token;
  UserModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phoneNumber,
      this.photoUrl,
      this.speciality,
      this.status,
      this.amount,
      this.lastSeen,
      this.token,
      this.experience,
      this.bio,
      this.isAvailable,
      this.workingHours,
      this.state});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstname'],
      lastName: json['lastname'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      speciality: json['specialization'],
      status: json['status'],
      amount: json['amount'],
      lastSeen: json['lastSeen'],
      token: json['token'],
      experience: json['experience'],
      bio: json['bio'],
      isAvailable: json['isAvailable'],
      workingHours: json['workingHour'],
      state: json['stateOfOrigin'],
    );
  }
}
