import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionHelper {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyStorageKey = 'db_encryption_key';

  Future<String> _generateRandomKey() async {
    final key = Key.fromSecureRandom(32); // Clave AES de 256 bits
    return base64UrlEncode(key.bytes);
  }

  Future<String> getEncryptionKey() async {
    String? key = await _secureStorage.read(key: _keyStorageKey);
    if (key == null) {
      key = await _generateRandomKey();
      await _secureStorage.write(key: _keyStorageKey, value: key);
    }
    return key;
  }
}
