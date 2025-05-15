// ignore_for_file: constant_identifier_names

import 'package:geolocator/geolocator.dart';

const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

const defaultLanguage = 'en';
const MESSAGE_TOKEN = 'message_token';
const ONLINE = 'online';
const OFFLINE = 'offline';

class PaystackKey {
  static String publicKey = "pk_test_d2811bea5f8ee3c81b0d10ec65f856a28aa47966";
  static String secretKey = "sk_test_5a009cc631c4d56e7c8b7dccdfdf471ebc4a8cba";
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
  // Calculate distance in meters and convert to kilometers
  double distanceInMeters = Geolocator.distanceBetween(
    endLat,
    endLng,
    startLat,
    startLng,
  );
  double distanceInKilometers = distanceInMeters / 1000.0;

  return double.parse(
      distanceInKilometers.toStringAsFixed(2)); // Round to 2 decimal places
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