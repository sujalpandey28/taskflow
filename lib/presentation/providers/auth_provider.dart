// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:taskflow/core/tokens.dart';
// import 'package:taskflow/data/models/auth_model.dart';
// import 'package:taskflow/data/repositories/task_flowrepository.dart';

// enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// class AuthProvider extends ChangeNotifier {
//   final TaskFlowRepository repository;

//   AuthProvider({required this.repository});

//   final List<AuthCredentialModel> _registeredUsers = [];

//   AuthStatus _status = AuthStatus.initial;

//   AuthStatus get status => _status;

//   String? _errorMessage;

//   String? get errorMessage => _errorMessage;

//   String? _accessToken;

//   String? get accessToken => _accessToken;

//   String? _refreshToken;

//   String? get refreshToken => _refreshToken;

//   Timer? _expiryTimer;

//   DateTime? _accessTokenExpiry;

//   DateTime? get accessTokenExpiry => _accessTokenExpiry;

//   String? _email;

//   String? get email => _email;

//   String? _userId;

//   String? get userId => _userId;

//   String? _orgId;

//   String? get orgId => _orgId;

//   String? _role;

//   String? get role => _role;

//   bool get isAuthenticated => _status == AuthStatus.authenticated;

//   bool get isAdmin => _role == 'org_admin';

//   void _startExpiryTimer() {
//     _expiryTimer?.cancel();

//     if (_accessTokenExpiry == null) {
//       return;
//     }

//     final duration = _accessTokenExpiry!.difference(DateTime.now());

//     if (duration.isNegative) {
//       _handleAccessTokenExpiry();
//       return;
//     }

//     _expiryTimer = Timer(duration, _handleAccessTokenExpiry);
//   }

//   Future<bool> register({
//     required String email,
//     required String password,
//   }) async {
//     _errorMessage = null;

//     try {
//       final existingCredentials = await repository.getAuthCredentials();

//       final alreadyExists = existingCredentials.any(
//         (credential) => credential.email.toLowerCase() == email.toLowerCase(),
//       );

//       final alreadyRegistered = _registeredUsers.any(
//         (credential) => credential.email.toLowerCase() == email.toLowerCase(),
//       );

//       if (alreadyExists || alreadyRegistered) {
//         _errorMessage = 'An account with this email already exists.';
//         notifyListeners();
//         return false;
//       }

//       final credential = AuthCredentialModel(
//         email: email,
//         password: password,
//         orgId: 'org_a1b2c3',
//         role: 'member',
//       );

//       _registeredUsers.add(credential);

//       notifyListeners();

//       return true;
//     } catch (e) {
//       _errorMessage = 'Failed to create account.';
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> _handleAccessTokenExpiry() async {
//     _expiryTimer?.cancel();
//     _expiryTimer = null;

//     await refreshSession();
//   }

//   Future<void> login(String email, String password) async {
//     _status = AuthStatus.loading;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final credentials = await repository.getAuthCredentials();

//       final allCredentials = [...credentials, ..._registeredUsers];

//       AuthCredentialModel? matchedCredential;

//       for (final credential in allCredentials) {
//         if (credential.email == email && credential.password == password) {
//           matchedCredential = credential;
//           break;
//         }
//       }

//       if (matchedCredential == null) {
//         _status = AuthStatus.error;
//         _errorMessage = 'Invalid email or password.';
//         notifyListeners();
//         return;
//       }

//       final loginResponse = await repository.getMockLoginResponse();

//       final expiry = DateTime.now().add(
//         Duration(seconds: loginResponse.accessTokenExpiresInSeconds),
//       );

//       await SecureStorageService.saveAccessToken(loginResponse.accessToken);

//       await SecureStorageService.saveRefreshToken(loginResponse.refreshToken);

//       await SecureStorageService.saveAccessTokenExpiry(expiry);

//       _accessToken = loginResponse.accessToken;
//       _refreshToken = loginResponse.refreshToken;
//       _accessTokenExpiry = expiry;

//       _email = matchedCredential.email;
//       _orgId = matchedCredential.orgId;
//       _role = matchedCredential.role;

//       await SecureStorageService.saveUserEmail(matchedCredential.email);

//       final users = await repository.getUsers();

//       final matchingUsers = users.where(
//         (user) => user.email == matchedCredential!.email,
//       );

//       if (matchingUsers.isNotEmpty) {
//         _userId = matchingUsers.first.id;
//       } else {
//         _userId = 'local_${DateTime.now().millisecondsSinceEpoch}';
//       }

//       _startExpiryTimer();

//       _status = AuthStatus.authenticated;

//       notifyListeners();
//     } catch (e, stackTrace) {
//       debugPrint('AUTH TEST ERROR: $e');
//       debugPrintStack(stackTrace: stackTrace);

//       _status = AuthStatus.error;
//       _errorMessage = 'Something went wrong. Please try again.';
//       notifyListeners();
//     }
//   }

//   Future<void> checkSession() async {
//     _status = AuthStatus.loading;
//     notifyListeners();

//     try {
//       final accessToken = await SecureStorageService.readAccessToken();

//       final refreshToken = await SecureStorageService.readRefreshToken();

//       final expiry = await SecureStorageService.readAccessTokenExpiry();

//       final savedEmail = await SecureStorageService.readUserEmail();

//       if (accessToken == null ||
//           refreshToken == null ||
//           expiry == null ||
//           savedEmail == null) {
//         _status = AuthStatus.unauthenticated;
//         notifyListeners();
//         return;
//       }

//       _accessToken = accessToken;
//       _refreshToken = refreshToken;
//       _accessTokenExpiry = expiry;

//       final credentials = await repository.getAuthCredentials();

//       final matchedCredential = credentials.firstWhere(
//         (credential) => credential.email == savedEmail,
//       );

//       _email = matchedCredential.email;
//       _orgId = matchedCredential.orgId;
//       _role = matchedCredential.role;

//       final users = await repository.getUsers();

//       final matchedUser = users.firstWhere((user) => user.email == savedEmail);

//       _userId = matchedUser.id;

//       if (DateTime.now().isAfter(expiry)) {
//         await refreshSession();
//         return;
//       }

//       _startExpiryTimer();

//       _status = AuthStatus.authenticated;
//       notifyListeners();
//     } catch (e) {
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//     }
//   }

//   Future<void> refreshSession() async {
//     if (_refreshToken == null) {
//       await logout();
//       return;
//     }

//     try {
//       final loginResponse = await repository.getMockLoginResponse();

//       final expiry = DateTime.now().add(
//         Duration(seconds: loginResponse.accessTokenExpiresInSeconds),
//       );

//       await SecureStorageService.saveAccessToken(loginResponse.accessToken);

//       await SecureStorageService.saveAccessTokenExpiry(expiry);

//       _accessToken = loginResponse.accessToken;
//       _accessTokenExpiry = expiry;

//       _status = AuthStatus.authenticated;

//       _startExpiryTimer();

//       notifyListeners();
//     } catch (e) {
//       _status = AuthStatus.error;
//       _errorMessage = 'Session refresh failed.';
//       notifyListeners();
//     }
//   }

//   Future<void> logout() async {
//     _expiryTimer?.cancel();
//     _expiryTimer = null;

//     await SecureStorageService.clearTokens();

//     _accessToken = null;
//     _refreshToken = null;
//     _accessTokenExpiry = null;
//     _userId = null;
//     _email = null;
//     _orgId = null;
//     _role = null;

//     _status = AuthStatus.unauthenticated;
//     _errorMessage = null;

//     notifyListeners();
//   }
// }

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:taskflow/core/tokens.dart';
import 'package:taskflow/data/models/auth_model.dart';
import 'package:taskflow/data/repositories/task_flowrepository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final TaskFlowRepository repository;
  final TokenStorage tokenStorage;

  AuthProvider({required this.repository, TokenStorage? tokenStorage})
    : tokenStorage = tokenStorage ?? SecureTokenStorage();

  final List<AuthCredentialModel> _registeredUsers = [];

  AuthStatus _status = AuthStatus.initial;

  AuthStatus get status => _status;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  String? _accessToken;

  String? get accessToken => _accessToken;

  String? _refreshToken;

  String? get refreshToken => _refreshToken;

  Timer? _expiryTimer;

  DateTime? _accessTokenExpiry;

  DateTime? get accessTokenExpiry => _accessTokenExpiry;

  String? _email;

  String? get email => _email;

  String? _userId;

  String? get userId => _userId;

  String? _orgId;

  String? get orgId => _orgId;

  String? _role;

  String? get role => _role;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  bool get isAdmin => _role == 'org_admin';

  void _startExpiryTimer() {
    _expiryTimer?.cancel();

    if (_accessTokenExpiry == null) {
      return;
    }

    final duration = _accessTokenExpiry!.difference(DateTime.now());

    if (duration.isNegative) {
      _handleAccessTokenExpiry();
      return;
    }

    _expiryTimer = Timer(duration, _handleAccessTokenExpiry);
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;

    try {
      final existingCredentials = await repository.getAuthCredentials();

      final alreadyExists = existingCredentials.any(
        (credential) => credential.email.toLowerCase() == email.toLowerCase(),
      );

      final alreadyRegistered = _registeredUsers.any(
        (credential) => credential.email.toLowerCase() == email.toLowerCase(),
      );

      if (alreadyExists || alreadyRegistered) {
        _errorMessage = 'An account with this email already exists.';

        notifyListeners();
        return false;
      }

      final credential = AuthCredentialModel(
        email: email,
        password: password,
        orgId: 'org_a1b2c3',
        role: 'member',
      );

      _registeredUsers.add(credential);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create account.';

      notifyListeners();

      return false;
    }
  }

  Future<void> _handleAccessTokenExpiry() async {
    _expiryTimer?.cancel();
    _expiryTimer = null;

    await refreshSession();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final credentials = await repository.getAuthCredentials();

      final allCredentials = [...credentials, ..._registeredUsers];

      AuthCredentialModel? matchedCredential;

      for (final credential in allCredentials) {
        if (credential.email == email && credential.password == password) {
          matchedCredential = credential;
          break;
        }
      }

      if (matchedCredential == null) {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid email or password.';

        notifyListeners();
        return;
      }

      final loginResponse = await repository.getMockLoginResponse();

      final expiry = DateTime.now().add(
        Duration(seconds: loginResponse.accessTokenExpiresInSeconds),
      );

      await tokenStorage.saveAccessToken(loginResponse.accessToken);

      await tokenStorage.saveRefreshToken(loginResponse.refreshToken);

      await tokenStorage.saveAccessTokenExpiry(expiry);

      _accessToken = loginResponse.accessToken;
      _refreshToken = loginResponse.refreshToken;
      _accessTokenExpiry = expiry;

      _email = matchedCredential.email;
      _orgId = matchedCredential.orgId;
      _role = matchedCredential.role;

      await tokenStorage.saveUserEmail(matchedCredential.email);

      final users = await repository.getUsers();

      final matchingUsers = users.where(
        (user) => user.email == matchedCredential!.email,
      );

      if (matchingUsers.isNotEmpty) {
        _userId = matchingUsers.first.id;
      } else {
        _userId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      }

      _startExpiryTimer();

      _status = AuthStatus.authenticated;

      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Something went wrong. Please try again.';

      notifyListeners();
    }
  }

  Future<void> checkSession() async {
    _status = AuthStatus.loading;

    notifyListeners();

    try {
      final accessToken = await tokenStorage.readAccessToken();

      final refreshToken = await tokenStorage.readRefreshToken();

      final expiry = await tokenStorage.readAccessTokenExpiry();

      final savedEmail = await tokenStorage.readUserEmail();

      if (accessToken == null ||
          refreshToken == null ||
          expiry == null ||
          savedEmail == null) {
        _status = AuthStatus.unauthenticated;

        notifyListeners();
        return;
      }

      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _accessTokenExpiry = expiry;

      final credentials = await repository.getAuthCredentials();

      final matchedCredential = credentials.firstWhere(
        (credential) => credential.email == savedEmail,
      );

      _email = matchedCredential.email;
      _orgId = matchedCredential.orgId;
      _role = matchedCredential.role;

      final users = await repository.getUsers();

      final matchedUser = users.firstWhere((user) => user.email == savedEmail);

      _userId = matchedUser.id;

      if (DateTime.now().isAfter(expiry)) {
        await refreshSession();
        return;
      }

      _startExpiryTimer();

      _status = AuthStatus.authenticated;

      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;

      notifyListeners();
    }
  }

  Future<void> refreshSession() async {
    if (_refreshToken == null) {
      await logout();
      return;
    }

    try {
      final loginResponse = await repository.getMockLoginResponse();

      final expiry = DateTime.now().add(
        Duration(seconds: loginResponse.accessTokenExpiresInSeconds),
      );

      await tokenStorage.saveAccessToken(loginResponse.accessToken);

      await tokenStorage.saveAccessTokenExpiry(expiry);

      _accessToken = loginResponse.accessToken;
      _accessTokenExpiry = expiry;

      _status = AuthStatus.authenticated;

      _startExpiryTimer();

      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Session refresh failed.';

      notifyListeners();
    }
  }

  Future<void> logout() async {
    _expiryTimer?.cancel();
    _expiryTimer = null;

    await tokenStorage.clearTokens();

    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiry = null;

    _userId = null;
    _email = null;
    _orgId = null;
    _role = null;

    _status = AuthStatus.unauthenticated;
    _errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}
