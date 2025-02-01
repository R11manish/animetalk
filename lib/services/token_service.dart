import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final storage = const FlutterSecureStorage();
  static const String _tokenKey = 'api_token';

  Future<void> saveToken(String token) async {
    if (token.isEmpty) {
      throw ArgumentError('Token cannot be empty');
    }

    try {
      await storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw StorageException('Failed to save token: ${e.toString()}');
    }
  }

  Future<String?> getToken() async {
    try {
      return await storage.read(key: _tokenKey);
    } catch (e) {
      throw StorageException('Failed to retrieve token: ${e.toString()}');
    }
  }

  Future<void> deleteToken() async {
    try {
      await storage.delete(key: _tokenKey);
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
