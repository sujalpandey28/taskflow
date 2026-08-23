// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SecureStorageService {
//   static const FlutterSecureStorage _storage = FlutterSecureStorage();

//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';
//   static const String _accessTokenExpiryKey = 'access_token_expiry';
//   static const String _userEmailKey = 'user_email';

//   static Future<void> saveAccessToken(String accessToken) async {
//     await _storage.write(key: _accessTokenKey, value: accessToken);
//   }

//   static Future<String?> readAccessToken() async {
//     return _storage.read(key: _accessTokenKey);
//   }

//   static Future<void> deleteAccessToken() async {
//     await _storage.delete(key: _accessTokenKey);
//   }

//   static Future<void> saveRefreshToken(String refreshToken) async {
//     await _storage.write(key: _refreshTokenKey, value: refreshToken);
//   }

//   static Future<String?> readRefreshToken() async {
//     return _storage.read(key: _refreshTokenKey);
//   }

//   static Future<void> deleteRefreshToken() async {
//     await _storage.delete(key: _refreshTokenKey);
//   }

//   static Future<void> saveAccessTokenExpiry(DateTime expiry) async {
//     await _storage.write(
//       key: _accessTokenExpiryKey,
//       value: expiry.toIso8601String(),
//     );
//   }

//   static Future<DateTime?> readAccessTokenExpiry() async {
//     final value = await _storage.read(key: _accessTokenExpiryKey);

//     if (value == null) {
//       return null;
//     }

//     return DateTime.tryParse(value);
//   }

//   static Future<void> deleteAccessTokenExpiry() async {
//     await _storage.delete(key: _accessTokenExpiryKey);
//   }

//   static Future<void> saveUserEmail(String email) async {
//     await _storage.write(key: _userEmailKey, value: email);
//   }

//   static Future<String?> readUserEmail() async {
//     return _storage.read(key: _userEmailKey);
//   }

//   static Future<void> deleteUserEmail() async {
//     await _storage.delete(key: _userEmailKey);
//   }

//   static Future<void> clearTokens() async {
//     await _storage.delete(key: _accessTokenKey);
//     await _storage.delete(key: _refreshTokenKey);
//     await _storage.delete(key: _accessTokenExpiryKey);
//     await _storage.delete(key: _userEmailKey);
//   }
// }

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<void> saveAccessToken(String accessToken);
  Future<String?> readAccessToken();
  Future<void> saveRefreshToken(String refreshToken);
  Future<String?> readRefreshToken();
  Future<void> saveAccessTokenExpiry(DateTime expiry);
  Future<DateTime?> readAccessTokenExpiry();
  Future<void> saveUserEmail(String email);
  Future<String?> readUserEmail();
  Future<void> clearTokens();
}

class SecureTokenStorage implements TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accessTokenExpiryKey = 'access_token_expiry';
  static const String _userEmailKey = 'user_email';

  @override
  Future<void> saveAccessToken(String accessToken) {
    return _storage.write(key: _accessTokenKey, value: accessToken);
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) {
    return _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveAccessTokenExpiry(DateTime expiry) {
    return _storage.write(
      key: _accessTokenExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  @override
  Future<DateTime?> readAccessTokenExpiry() async {
    final value = await _storage.read(key: _accessTokenExpiryKey);

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  @override
  Future<void> saveUserEmail(String email) {
    return _storage.write(key: _userEmailKey, value: email);
  }

  @override
  Future<String?> readUserEmail() {
    return _storage.read(key: _userEmailKey);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiryKey);
    await _storage.delete(key: _userEmailKey);
  }
}
