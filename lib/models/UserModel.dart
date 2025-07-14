import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? country;
  String? currency;
  String? phoneNumber;
  String? photoUrl;
  String? maritalStatus;
  String? tag;
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
  bool? isTrialAvailable;
  GeoPoint? location;
  String? address;
  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.country,
    this.address,
    this.location,
    this.currency,
    this.phoneNumber,
    this.photoUrl,
    this.maritalStatus,
    this.tag,
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
    this.state,
    this.isTrialAvailable,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstname'],
      lastName: json['lastname'],
      email: json['email'],
      country: json['country'],
      address: json['address'],
      location: json['location'] ?? GeoPoint(0, 0),
      currency: json['currency'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      maritalStatus: json['maritalStatus'],
      dob: json['dob'],
      tag: json['tag'],
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
      isTrialAvailable: json['isTrialAvailable']??true,
    );
  }
}
