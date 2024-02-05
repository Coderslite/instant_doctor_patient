// ignore_for_file: constant_identifier_names

const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

const defaultLanguage = 'en';
const MESSAGE_TOKEN = 'message_token';
const ONLINE = 'online';
const OFFLINE = 'offline';

class VideoCallKey {
  static String appId = "5778132b16d543109303817a5da4b475";
  static String token =
      "007eJxTYAg5etnlUdB1/5g9EsVvpsS3rXx7uVr9iKz+hdJHPRV/vzxXYDA1N7cwNDZKMjRLMTUxNjSwNDYwtjA0TzRNSTRJMjE3vfClMbUhkJGBfzcvEyMDBIL4vAyeecUliXklLvnJJflFDAwASt8lEA==";
}

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

const FIREBASE_URL = "https://instant-doctor.onrender.com";

class NotificatonType {
  static String chat = "Chat";
  static String transaction = "Transaction";
  static String appointment = "Appointment";
  static String medication = "Medication";
}

const APPOINTMENT_CHARGE = 100;
