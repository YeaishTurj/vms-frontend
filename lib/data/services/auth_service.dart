import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_config.dart';
import '../models/auth_session.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'session_storage/session_storage.dart';

/// Central reusable Authentication Service for the VMS Application.
/// Manages user authentication, token issuance, session persistence,
/// session expiration detection, and secure logout.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();

  factory AuthService({
    ApiClient? apiClient,
    SessionStorage? storage,
  }) {
    if (apiClient != null) {
      _instance._apiClient = apiClient;
    }
    if (storage != null) {
      _instance._storage = storage;
    }
    return _instance;
  }

  static AuthService get instance => _instance;

  AuthService._internal()
      : _apiClient = ApiClient(),
        _storage = createSessionStorage() {
    ApiClient.defaultTokenProvider = () => currentToken;
    ApiClient.defaultOnUnauthorized = handleSessionExpired;
    restoreSession();
  }

  static const String _sessionStorageKey = 'vms_auth_session';

  ApiClient _apiClient;
  SessionStorage _storage;
  AuthSession? _currentSession;
  String? _sessionMessage;

  /// Returns whether a valid, non-expired authentication session is currently active.
  bool get isAuthenticated {
    if (_currentSession == null) return false;
    if (_currentSession!.isExpired) {
      handleSessionExpired();
      return false;
    }
    return _currentSession!.isValid;
  }

  AuthSession? get currentSession => _currentSession;
  String? get currentToken => isAuthenticated ? _currentSession?.token : null;
  String? get currentUsername => _currentSession?.username;
  String? get sessionMessage => _sessionMessage;

  /// Clears any pending session banner message (e.g. session expired warning).
  void clearSessionMessage() {
    _sessionMessage = null;
  }

  /// Restores active session from tab-isolated storage upon app startup/reload.
  void restoreSession() {
    try {
      final jsonString = _storage.read(_sessionStorageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonString);
        final restored = AuthSession.fromJson(data);
        if (restored.isValid) {
          _currentSession = restored;
        } else {
          _storage.delete(_sessionStorageKey);
          _currentSession = null;
        }
      }
    } catch (_) {
      _storage.delete(_sessionStorageKey);
      _currentSession = null;
    }
  }

  /// Authenticates user credentials against the Spring Boot REST API.
  /// Passwords are never logged or persisted in client-side state.
  Future<AuthSession> login(String username, String password) async {
    _sessionMessage = null;

    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      throw const ApiException(
        statusCode: 400,
        message: 'Username and password cannot be empty.',
      );
    }

    // In production, enforce HTTPS if not running against a local loopback server
    if (kReleaseMode && !ApiConfig.isSecureForEnvironment) {
      throw const ApiException(
        statusCode: 0,
        message: 'Insecure connection: Authentication requires HTTPS in production.',
      );
    }

    try {
      // POST credentials to Spring Boot backend (/auth/login)
      final response = await _apiClient.post(
        ApiConfig.loginUri(),
        body: {
          'username': trimmedUsername,
          'password': trimmedPassword,
        },
      );

      if (response is Map<String, dynamic>) {
        final session = AuthSession.fromBackendResponse(response);
        _currentSession = session;

        // Persist token and minimal session metadata to tab storage
        _storage.write(_sessionStorageKey, jsonEncode(session.toJson()));

        notifyListeners();
        return session;
      } else {
        throw const ApiException(
          statusCode: 500,
          message: 'Unexpected authentication response received from server.',
        );
      }
    } on ApiException catch (e) {
      // Provide user-friendly authentication error messaging
      if (e.statusCode == 401) {
        throw const ApiException(
          statusCode: 401,
          message: 'Invalid username or password. Please verify your credentials and try again.',
        );
      }
      rethrow;
    }
  }

  /// Terminates the current authenticated session.
  /// Purges tokens and state, notifying all router and UI listeners.
  Future<void> logout() async {
    _currentSession = null;
    _sessionMessage = null;
    _storage.delete(_sessionStorageKey);
    notifyListeners();
  }

  /// Handles 401 Unauthorized API responses or expired tokens.
  /// Automatically purges stale session and notifies listeners.
  void handleSessionExpired() {
    _currentSession = null;
    _storage.delete(_sessionStorageKey);
    _sessionMessage = 'Your session has expired. Please sign in to continue.';
    notifyListeners();
  }

  /// Sets or updates the active session (supports testing or programmatic login).
  void setSession(AuthSession? session) {
    _currentSession = session;
    if (session != null) {
      _storage.write(_sessionStorageKey, jsonEncode(session.toJson()));
    } else {
      _storage.delete(_sessionStorageKey);
    }
    notifyListeners();
  }

  /// Resets AuthService state for automated testing.
  @visibleForTesting
  void resetForTesting({
    ApiClient? client,
    SessionStorage? storage,
    AuthSession? session,
  }) {
    if (client != null) _apiClient = client;
    if (storage != null) _storage = storage;
    _currentSession = session;
    _sessionMessage = null;
    notifyListeners();
  }
}
