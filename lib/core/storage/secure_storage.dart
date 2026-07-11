import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  static const String _accessTokenStorageKey = 'token_access';
  static const String _refreshTokenStorageKey = 'token_refresh';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenStorageKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenStorageKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenStorageKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenStorageKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenStorageKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenStorageKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
