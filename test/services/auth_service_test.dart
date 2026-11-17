import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vms_frontend/core/config/api_config.dart';
import 'package:vms_frontend/data/models/auth_session.dart';
import 'package:vms_frontend/data/services/api_client.dart';
import 'package:vms_frontend/data/services/api_exception.dart';
import 'package:vms_frontend/data/services/auth_service.dart';
import 'package:vms_frontend/data/services/session_storage/session_storage_stub.dart';

void main() {
  group('AuthService Tests', () {
    late InMemorySessionStorage storage;

    setUp(() {
      storage = InMemorySessionStorage();
    });

    test('login with valid credentials authenticates and persists session', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/auth/login');
        expect(request.method, 'POST');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['username'], 'admin');
        expect(body['password'], 'admin123');

        return http.Response(
          jsonEncode({
            'token': 'mock-jwt-token-xyz',
            'type': 'Bearer',
            'expiresIn': 3600,
            'username': 'admin',
            'roles': ['ROLE_ADMIN'],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final authService = AuthService.instance;
      authService.resetForTesting(client: apiClient, storage: storage);

      expect(authService.isAuthenticated, isFalse);

      final session = await authService.login('admin', 'admin123');

      expect(session.token, 'mock-jwt-token-xyz');
      expect(session.username, 'admin');
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentToken, 'mock-jwt-token-xyz');
      expect(authService.currentUsername, 'admin');

      // Verify session was persisted to storage
      final storedRaw = storage.read('vms_auth_session');
      expect(storedRaw, isNotNull);
      final storedJson = jsonDecode(storedRaw!) as Map<String, dynamic>;
      expect(storedJson['token'], 'mock-jwt-token-xyz');
    });

    test('login with invalid credentials throws friendly 401 ApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': 'Unauthorized',
            'message': 'Invalid username or password',
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final authService = AuthService.instance;
      authService.resetForTesting(client: apiClient, storage: storage);

      expect(
        () => authService.login('wrong-user', 'wrong-pass'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having(
                (e) => e.message,
                'message',
                'Invalid username or password. Please verify your credentials and try again.',
              ),
        ),
      );

      expect(authService.isAuthenticated, isFalse);
      expect(storage.read('vms_auth_session'), isNull);
    });

    test('login with empty credentials throws 400 without network call', () async {
      var callMade = false;
      final mockClient = MockClient((request) async {
        callMade = true;
        return http.Response('{}', 200);
      });

      final apiClient = ApiClient(client: mockClient);
      final authService = AuthService.instance;
      authService.resetForTesting(client: apiClient, storage: storage);

      expect(
        () => authService.login('', '  '),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('cannot be empty')),
        ),
      );

      expect(callMade, isFalse);
    });

    test('logout purges in-memory session and persisted storage', () async {
      final authService = AuthService.instance;
      authService.resetForTesting(storage: storage);

      authService.setSession(
        AuthSession(
          token: 'token-to-clear',
          type: 'Bearer',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          username: 'admin',
          roles: const ['ROLE_ADMIN'],
        ),
      );

      expect(authService.isAuthenticated, isTrue);
      expect(storage.read('vms_auth_session'), isNotNull);

      await authService.logout();

      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentSession, isNull);
      expect(authService.currentToken, isNull);
      expect(storage.read('vms_auth_session'), isNull);
    });

    test('restoreSession loads valid session and discards expired session', () {
      final authService = AuthService.instance;

      // Storing an active session
      final activeSession = AuthSession(
        token: 'active-token',
        type: 'Bearer',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        username: 'active_admin',
        roles: const ['ROLE_ADMIN'],
      );
      storage.write('vms_auth_session', jsonEncode(activeSession.toJson()));

      authService.resetForTesting(storage: storage);
      authService.restoreSession();

      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUsername, 'active_admin');

      // Storing an expired session
      final expiredSession = AuthSession(
        token: 'expired-token',
        type: 'Bearer',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        username: 'old_admin',
        roles: const ['ROLE_ADMIN'],
      );
      storage.write('vms_auth_session', jsonEncode(expiredSession.toJson()));

      authService.restoreSession();

      expect(authService.isAuthenticated, isFalse);
      expect(storage.read('vms_auth_session'), isNull);
    });

    test('handleSessionExpired sets session notification and purges credentials', () {
      final authService = AuthService.instance;
      authService.resetForTesting(storage: storage);

      authService.setSession(
        AuthSession(
          token: 'token-to-expire',
          type: 'Bearer',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          username: 'admin',
          roles: const ['ROLE_ADMIN'],
        ),
      );

      expect(authService.isAuthenticated, isTrue);

      authService.handleSessionExpired();

      expect(authService.isAuthenticated, isFalse);
      expect(authService.sessionMessage, contains('expired'));
      expect(storage.read('vms_auth_session'), isNull);
    });

    test('ApiClient automatically attaches Bearer token to outgoing requests', () async {
      String? authHeaderReceived;
      final mockClient = MockClient((request) async {
        authHeaderReceived = request.headers['Authorization'];
        return http.Response('[]', 200, headers: {'content-type': 'application/json'});
      });

      final apiClient = ApiClient(
        client: mockClient,
        tokenProvider: () => 'my-injected-bearer-token',
      );

      await apiClient.get(ApiConfig.vehiclesUri());

      expect(authHeaderReceived, 'Bearer my-injected-bearer-token');
    });

    test('ApiClient triggers onUnauthorized callback when non-login request gets 401', () async {
      var unauthorizedTriggered = false;
      final mockClient = MockClient((request) async {
        return http.Response('{"error":"Unauthorized"}', 401, headers: {'content-type': 'application/json'});
      });

      final apiClient = ApiClient(
        client: mockClient,
        onUnauthorized: () {
          unauthorizedTriggered = true;
        },
      );

      try {
        await apiClient.get(ApiConfig.vehiclesUri());
      } catch (_) {}

      expect(unauthorizedTriggered, isTrue);
    });
  });
}
