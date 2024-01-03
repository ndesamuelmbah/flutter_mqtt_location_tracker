import 'dart:convert';

// import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

String encryptTextViaSha256(String encryptionKey, String plainText) {
  var key = utf8.encode(encryptionKey);
  var bytes = utf8.encode(plainText);

  var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
  var digest = hmacSha256.convert(bytes);
  return digest.toString();
}

bool verifyEncryptedData(
    String encryptionKey, String plainText, String hexadecimalDigest) {
  final sha256EncryptedText = encryptTextViaSha256(encryptionKey, plainText);
  return sha256EncryptedText == hexadecimalDigest;
}

encrypt.Encrypter getEncryter(String encryptionKey) {
  final key = encrypt.Key.fromUtf8(encryptionKey.substring(0, 32));
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  return encrypter;
}

String encryptWithEncrypt(String encryptionKey, String plainText) {
  final encrypter = getEncryter(encryptionKey);
  final iv = encrypt.IV.fromUtf8(encryptionKey.substring(0, 16));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

String decryptWithEncrypt(String encryptionKey, String base64EncryptedString) {
  final encrypter = getEncryter(encryptionKey);
  final iv = encrypt.IV.fromUtf8(encryptionKey.substring(0, 16));
  final encrypted = encrypt.Encrypted.fromBase64(base64EncryptedString);

  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  return decrypted;
}
