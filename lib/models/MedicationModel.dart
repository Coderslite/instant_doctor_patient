import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicationModel {
  String? id;
  String? userId;
  String? name;
  String? type;
  String? color;
  String? prescription;
  Timestamp? startTime;
  Timestamp? endTime;
  TimeOfDay? morning;
  TimeOfDay? midDay;
  TimeOfDay? evening;
  int? interval;
  Timestamp? createdAt;

  MedicationModel({
    this.id,
    this.userId,
    this.name,
    this.type,
    this.color,
    this.prescription,
    this.startTime,
    this.endTime,
    this.morning,
    this.midDay,
    this.evening,
    this.interval,
    this.createdAt,
  });
  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      type: json['type'],
      color: json['color'],
      prescription: json['prescription'],
      startTime: json['startTime'] != null
          ? Timestamp.fromDate(DateTime.parse(json['startTime']))
          : null,
      endTime: json['endTime'] != null
          ? Timestamp.fromDate(DateTime.parse(json['endTime']))
          : null,
      morning: _parseTimeOfDay(json['morning']),
      midDay: _parseTimeOfDay(json['midDay']),
      evening: _parseTimeOfDay(json['evening']),
      interval: json['interval'],
      createdAt: json['createdAt'] != null
          ? Timestamp.fromDate(DateTime.parse(json['createdAt']))
          : null,
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


// Helper method to convert Map to TimeOfDay

  Map<String, dynamic> toJson() {
    return {
      'id': UniqueKey().toString(),
      'userId': userId,
      'name': name,
      'type': type,
      'color': color,
      'prescription': prescription,
      'startTime':
          startTime?.toDate().toIso8601String(),
      'endTime': endTime?.toDate().toIso8601String(),
      'morning': _timeOfDayToJson(morning), // Convert TimeOfDay to Map
      'midDay': _timeOfDayToJson(midDay), // Convert TimeOfDay to Map
      'evening': _timeOfDayToJson(evening), // Convert TimeOfDay to Map
      'interval': interval,
      'createdAt':
          createdAt?.toDate().toIso8601String(),
    };
  }

  // Helper method to convert TimeOfDay to Map
  Map<String, dynamic>? _timeOfDayToJson(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return null;
    return {
      'hour': timeOfDay.hour,
      'minute': timeOfDay.minute,
    };
  }
}
