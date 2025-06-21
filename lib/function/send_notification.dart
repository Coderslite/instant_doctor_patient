import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../constant/constants.dart';

Future<void> sendNotification(
    List tokens, String title, String body, String id, String type) async {
  var response = await http.post(Uri.parse("$FIREBASE_URL/notification"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "title": title,
        "body": body,
        "tokens": tokens,
        "id": id,
        "type": type,
      }));
  var responseData = jsonDecode(response.body);

  if (responseData['status'] == true) {
    print("sent");
  } else {
    print("failed");
  }
}

scheduleAppointmentNotification({
  required List tokens,
  required String title,
  required String body,
  required String id,
  required String type,
  required Timestamp scheduledTime,
  required Timestamp endTime,
}) async {
  var response = await http.post(
    Uri.parse("$FIREBASE_URL/notification/schedule"),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(
      <String, dynamic>{
        "title": title,
        "body": body,
        "tokens": tokens,
        "id": id,
        "type": type,
        "scheduledTime": {
          "seconds": scheduledTime.seconds,
          "nanoseconds": scheduledTime.nanoseconds
        },
        "endTime": {
          "seconds": endTime.seconds,
          "nanoseconds": endTime.nanoseconds
        }
      },
    ),
  );
  var responseData = jsonDecode(response.body);
  print(responseData);
  if (responseData['status'] == true) {
    print("schedule sent");
  } else {
    print("schedule failed");
  }
}

scheduleMedicationNotification(
    {required List tokens,
    required String title,
    required String body,
    required String id,
    required String type,
    required Timestamp scheduledTime,
    required String time}) async {
  var response =
      await http.post(Uri.parse("$FIREBASE_URL/medication/notification"),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            "title": title,
            "body": body,
            "tokens": tokens,
            "id": id,
            "type": type,
            "time": time,
            "scheduledTime": {
              "seconds": scheduledTime.seconds,
              "nanoseconds": scheduledTime.nanoseconds
            }
          }));
  var responseData = jsonDecode(response.body);
  if (responseData['status'] == true) {
    print("sent");
  } else {
    print("failed");
  }
}
