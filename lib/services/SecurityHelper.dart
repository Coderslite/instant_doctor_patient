import 'package:encrypt/encrypt.dart';

class SecurityHelper {
  // Define a 16-byte key and a 16-byte IV
  final _key = Key.fromUtf8('thisisatest12345'); // Replace with your secret key
  final _iv = IV.fromUtf8('thisisatest12345'); // Replace with your IV

  /// Encrypts the given text
  String encryptText(String plainText) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts the given encrypted text
  String decryptText(String encryptedText) {
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}
