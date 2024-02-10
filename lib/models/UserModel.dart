import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? photoUrl;
  String? maritalStatus;
  Timestamp? dob;
  String? height;
  String? weight;
  String? bloodGroup;
  String? genotype;
  String? surgicalHistory;
  String? speciality;
  String? status;
  int? amount;
  int? experience;
  bool? isAvailable;
  List? workingHours;
  String? bio;
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
      this.maritalStatus,
      this.dob,
      this.height,
      this.weight,
      this.bloodGroup,
      this.genotype,
      this.surgicalHistory,
      this.speciality,
      this.status,
      this.amount,
      this.lastSeen,
      this.token,
      this.experience,
      this.isAvailable,
      this.workingHours,
      this.bio,
      this.state});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstname'],
      lastName: json['lastname'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      maritalStatus: json['maritalStatus'],
      dob:json['dob'],
      height: json['height'],
      weight: json['weight'],
      bloodGroup: json['bloodGroup'],
      genotype: json['genotype'],
      surgicalHistory: json['surgicalHistory'],
      speciality: json['specialization'],
      status: json['status'],
      amount: json['amount'] != null
          ? int.tryParse(json['amount'].toString())
          : null,
      lastSeen: json['lastSeen'],
      token: json['token'],
      experience: json['experience'],
      isAvailable: json['isAvailable'],
      workingHours: json['workingHour'],
      bio: json['bio'],
      state: json['stateOfOrigin'],
    );
  }
}
