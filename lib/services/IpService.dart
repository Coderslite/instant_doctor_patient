import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class IpLocationService {
  Future<Map<String, dynamic>> getLocationData() async {
    try {
      final response = await http.get(
        Uri.parse("https://ipapi.co/json/"),
      );

      log(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("IP location error: $e");
    }

    return {};
  }
}
