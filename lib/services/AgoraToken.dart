import 'dart:convert';

import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:http/http.dart' as http;

Future<String> getAgoraToken({required String appointmentId}) async {
  final response = await http.get(Uri.parse(
      "https://agora-token-server-k71g.onrender.com/rtc/Medication/subscriber/userAccount/1/"));
  var responseData = jsonDecode(response.body);
  var token = responseData['rtcToken'];
  print(token);
  return token;
}
