// ignore_for_file: constant_identifier_names

const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

const defaultLanguage = 'en';
const MESSAGE_TOKEN = 'message_token';
const ONLINE = 'online';
const OFFLINE = 'offline';

class PaystackKey {
  static String publicKey = "pk_test_d2811bea5f8ee3c81b0d10ec65f856a28aa47966";
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
}

// const FIREBASE_URL = "https://instant-doctor.onrender.com";
const FIREBASE_URL =
    "https://parceldeliverylogistics.com/instantdoctorservice";

class NotificatonType {
  static String chat = "Chat";
  static String transaction = "Transaction";
  static String appointment = "Appointment";
  static String medication = "Medication";
  static String call = "Call";
}

