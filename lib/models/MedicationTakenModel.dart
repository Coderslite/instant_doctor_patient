import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicationTakenModel {
  String? id;
  Timestamp? day;
  TimeOfDay? time;
  Timestamp? createdAt;

  MedicationTakenModel({
    this.id,
    this.day,
    this.time,
    this.createdAt,
  });

  factory MedicationTakenModel.fromJson(Map<String, dynamic> json) {
    return MedicationTakenModel(
      id: json['id'],
      day: json['day'],
      time: _parseTimeOfDay(json['time']),
      createdAt: json['createdAt'],
    );
  }

  static TimeOfDay? _parseTimeOfDay(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      final parts = json.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } else if (json is Map<String, dynamic>) {
      return TimeOfDay(hour: json['hour'], minute: json['minute']);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day?.toDate().toIso8601String(),
      'time': _timeOfDayToJson(time),
      'createdAt':
          createdAt?.toDate().toIso8601String(),
    };
  }

  Map<String, dynamic>? _timeOfDayToJson(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return null;
    return {
      'hour': timeOfDay.hour,
      'minute': timeOfDay.minute,
    };
  }
}
