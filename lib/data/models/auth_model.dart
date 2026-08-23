import 'dart:convert';

class AuthCredentialModel {
  final String email;
  final String password;
  final String orgId;
  final String role;

  AuthCredentialModel({
    required this.email,
    required this.password,
    required this.orgId,
    required this.role,
  });

  factory AuthCredentialModel.fromMap(Map<String, dynamic> map) {
    return AuthCredentialModel(
      email: map['email'] as String,
      password: map['password'] as String,
      orgId: map['org_id'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'org_id': orgId,
      'role': role,
    };
  }

  String toJson() => json.encode(toMap());

  factory AuthCredentialModel.fromJson(String source) =>
      AuthCredentialModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class MockLoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final int accessTokenExpiresInSeconds;
  final int refreshTokenExpiresInSeconds;

  MockLoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.refreshTokenExpiresInSeconds,
  });

  factory MockLoginResponseModel.fromMap(Map<String, dynamic> map) {
    return MockLoginResponseModel(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      accessTokenExpiresInSeconds:
          map['access_token_expires_in_seconds'] as int,
      refreshTokenExpiresInSeconds:
          map['refresh_token_expires_in_seconds'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expires_in_seconds': accessTokenExpiresInSeconds,
      'refresh_token_expires_in_seconds': refreshTokenExpiresInSeconds,
    };
  }

  String toJson() => json.encode(toMap());

  factory MockLoginResponseModel.fromJson(String source) =>
      MockLoginResponseModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}
