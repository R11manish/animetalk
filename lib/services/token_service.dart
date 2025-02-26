import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final storage = const FlutterSecureStorage();

  Future<void> saveToken(String key, String token) async {
    if (token.isEmpty) {
      throw ArgumentError('Token cannot be empty');
    }

    try {
      await storage.write(key: key, value: token);
    } catch (e) {
      throw StorageException('Failed to save token: ${e.toString()}');
    }
  }

  Future<String?> getToken(String key) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      throw StorageException('Failed to retrieve token: ${e.toString()}');
    }
  }

  Future<void> deleteToken(String key) async {
    try {
      await storage.delete(key: key);
    } catch (e) {
      throw StorageException('Failed to delete token: ${e.toString()}');
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}
