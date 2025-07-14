import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicationModel {
  String? id;
  String? userId;
  String? name;
  String? prescription;
  Timestamp? startTime;
  Timestamp? endTime;
  TimeOfDay? morning;
  TimeOfDay? midDay;
  TimeOfDay? evening;
  int? interval;
  List<DateTime>? takenDates;
  List<DateTime>? missedDates;
  Map<String, List<TimeOfDay>>? dailyTakenTimes;
  Map<String, List<TimeOfDay>>? dailyMissedTimes;
  Timestamp? createdAt;

  MedicationModel({
    this.id,
    this.userId,
    this.name,
    this.prescription,
    this.startTime,
    this.endTime,
    this.morning,
    this.midDay,
    this.evening,
    this.interval,
    this.takenDates,
    this.missedDates,
    this.dailyTakenTimes,
    this.dailyMissedTimes,
    this.createdAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      prescription: json['prescription'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      morning: json['morning'] != null
          ? TimeOfDay(
              hour: json['morning']['hour'], minute: json['morning']['minute'])
          : null,
      midDay: json['midDay'] != null
          ? TimeOfDay(
              hour: json['midDay']['hour'], minute: json['midDay']['minute'])
          : null,
      evening: json['evening'] != null
          ? TimeOfDay(
              hour: json['evening']['hour'], minute: json['evening']['minute'])
          : null,
      interval: json['interval'],
      takenDates: json['takenDates'] != null
          ? (json['takenDates'] as List)
              .map((e) => (e as Timestamp).toDate())
              .toList()
          : null,
      missedDates: json['missedDates'] != null
          ? (json['missedDates'] as List)
              .map((e) => (e as Timestamp).toDate())
              .toList()
          : null,
      dailyTakenTimes: json['dailyTakenTimes'] != null
          ? Map<String, List<TimeOfDay>>.fromEntries(
              (json['dailyTakenTimes'] as Map).entries.map((entry) => MapEntry(
                    entry.key,
                    (entry.value as List)
                        .map((time) => TimeOfDay(
                              hour: time['hour'],
                              minute: time['minute'],
                            ))
                        .toList(),
                  )))
          : null,
      dailyMissedTimes: json['dailyMissedTimes'] != null
          ? Map<String, List<TimeOfDay>>.fromEntries(
              (json['dailyMissedTimes'] as Map).entries.map((entry) => MapEntry(
                    entry.key,
                    (entry.value as List)
                        .map((time) => TimeOfDay(
                              hour: time['hour'],
                              minute: time['minute'],
                            ))
                        .toList(),
                  )))
          : null,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? UniqueKey().toString(),
      'userId': userId,
      'name': name,
      'prescription': prescription,
      'startTime': startTime,
      'endTime': endTime,
      'morning': morning != null
          ? {'hour': morning!.hour, 'minute': morning!.minute}
          : null,
      'midDay': midDay != null
          ? {'hour': midDay!.hour, 'minute': midDay!.minute}
          : null,
      'evening': evening != null
          ? {'hour': evening!.hour, 'minute': evening!.minute}
          : null,
      'interval': interval,
      'takenDates': takenDates?.map((e) => Timestamp.fromDate(e)).toList(),
      'missedDates': missedDates?.map((e) => Timestamp.fromDate(e)).toList(),
      'dailyTakenTimes': dailyTakenTimes?.map((key, value) => MapEntry(key,
          value.map((e) => {'hour': e.hour, 'minute': e.minute}).toList())),
      'dailyMissedTimes': dailyMissedTimes?.map((key, value) => MapEntry(key,
          value.map((e) => {'hour': e.hour, 'minute': e.minute}).toList())),
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }
}

// Helper method to convert TimeOfDay to Map
Map<String, dynamic>? _timeOfDayToJson(TimeOfDay? timeOfDay) {
  if (timeOfDay == null) return null;
  return {
    'hour': timeOfDay.hour,
    'minute': timeOfDay.minute,
  };
}
