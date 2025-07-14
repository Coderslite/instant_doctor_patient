// ignore_for_file: constant_identifier_names

import 'dart:math';

const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

const defaultLanguage = 'en';
const MESSAGE_TOKEN = 'message_token';
const ONLINE = 'online';
const OFFLINE = 'offline';

class PaystackKey {
  // test credentials
  static String publicKey = "pk_test_d2811bea5f8ee3c81b0d10ec65f856a28aa47966";
  static String secretKey = "sk_test_5a009cc631c4d56e7c8b7dccdfdf471ebc4a8cba";
  static String doctorSubAccount = "ACCT_ex1om07101xar4a";
  static String pharmcySubAccount = "ACCT_lkl4dx60ww8d9fj";

  // live credentials
  // static String publicKey = "pk_live_fa9a859fed46fd231e65483c85f9611c98f0d173o";
  // static String secretKey = "sk_live_c07e9ad43ea5365e467383dab49c9dcefc1975cf";
  // static String doctorSubAccount = "";
  // static String pharmcySubAccount = "";
}

class MessageType {
  static String text = 'Text';
  static String image = 'Image';
  static String file = 'File';
  static String voice = 'Voice';
}

class MessageStatus {
  static String delivered = "Delivered";
  static String read = "Read";
  static String pending = "Pending";
  static String sent = "Sent";
}

class PaymentFor {
  static String order = 'Order';
  static String appointment = 'Appointment';
  static String labResult = 'LabResult';
}

class OtpFor {
  static String register = 'Register';
  static String login = 'Login';
  static String reset = 'Reset';
}
// const FIREBASE_URL = "https://instant-doctor.onrender.com";

const FIREBASE_URL =
    "https://us-central1-instant-doctor-a4e4c.cloudfunctions.net/api";

class NotificationType {
  static String chat = "Chat";
  static String transaction = "Transaction";
  static String appointment = "Appointment";
  static String medication = "Medication";
  static String call = "Call";
  static String labResult = "LabResult";
}

double calculateDistance2(
    double startLat, double startLng, double endLat, double endLng) {
  // Since the location package doesn't provide distance calculation,
  // we'll implement the Haversine formula manually
  const double earthRadius = 6371; // Earth's radius in kilometers

  // Convert degrees to radians
  double lat1 = startLat * (3.141592653589793 / 180);
  double lon1 = startLng * (3.141592653589793 / 180);
  double lat2 = endLat * (3.141592653589793 / 180);
  double lon2 = endLng * (3.141592653589793 / 180);

  // Haversine formula
  double dLat = lat2 - lat1;
  double dLon = lon2 - lon1;
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;

  return double.parse(distance.toStringAsFixed(2)); // Round to 2 decimal places
}

int getDiscountPrice({required int price, required int discount}) {
  var val = (price) / ((100 - discount) / 100);
  return val.toInt();
}

String maskEmail(String email) {
  // Split the email into two parts (before and after @)
  var emailParts = email.split('@');
  var username = emailParts[0];
  var domain = emailParts[1];

  // Mask part of the username
  var maskedUsername = "${username.substring(0, 2)}*****";

  // Return the masked email
  return "$maskedUsername@$domain";
}
