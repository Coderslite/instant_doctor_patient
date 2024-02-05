import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constant/constants.dart';

void sendNotification(
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
