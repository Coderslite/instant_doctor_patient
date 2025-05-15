import 'package:cloud_firestore/cloud_firestore.dart';

class Prescriptionmodel {
  String? id;
  String? appointmentId;
  String? userId;
  String? doctorId;
  String? prescription;
  Timestamp? createdAt;
  bool? seen;

  Prescriptionmodel({
    this.id,
    this.appointmentId,
    this.userId,
    this.doctorId,
    this.prescription,
    this.createdAt,
    this.seen,
  });

  factory Prescriptionmodel.fromJson(Map<String, dynamic> json) {
    return Prescriptionmodel(
      id: json['id'],
      appointmentId: json['appointmentId'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      prescription: json['prescription'],
      createdAt: json['createdAt'],
      seen: json['seen'],
    );
  }
}
