import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/data/models/auth_session.dart';

void main() {
  group('AuthSession Model Tests', () {
    test('fromBackendResponse parses valid payload correctly', () {
      final backendResponse = {
        'token': 'eyJhbGciOiJIUzI1NiJ9.sample.token',
        'type': 'Bearer',
        'expiresIn': 86400,
        'username': 'admin',
        'roles': ['ROLE_ADMIN'],
      };

      final session = AuthSession.fromBackendResponse(backendResponse);

      expect(session.token, 'eyJhbGciOiJIUzI1NiJ9.sample.token');
      expect(session.type, 'Bearer');
      expect(session.username, 'admin');
      expect(session.roles, ['ROLE_ADMIN']);
      expect(session.isAdmin, isTrue);
      expect(session.displayRole, 'Administrator');
      expect(session.isExpired, isFalse);
      expect(session.isValid, isTrue);
    });

    test('isExpired and isValid identify expired session', () {
      final expiredSession = AuthSession(
        token: 'sample-token',
        type: 'Bearer',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        username: 'operator',
        roles: const ['ROLE_USER'],
      );

      expect(expiredSession.isExpired, isTrue);
      expect(expiredSession.isValid, isFalse);
      expect(expiredSession.isAdmin, isFalse);
      expect(expiredSession.displayRole, 'Operator');
    });

    test('toJson and fromJson serialize and deserialize correctly', () {
      final original = AuthSession(
        token: 'test-jwt-token',
        type: 'Bearer',
        expiresAt: DateTime.utc(2026, 12, 31, 23, 59, 59),
        username: 'fleet_manager',
        roles: const ['ROLE_ADMIN', 'ROLE_USER'],
      );

      final json = original.toJson();
      final restored = AuthSession.fromJson(json);

      expect(restored.token, original.token);
      expect(restored.type, original.type);
      expect(restored.username, original.username);
      expect(restored.roles, original.roles);
      expect(restored.expiresAt, original.expiresAt);
      expect(restored.isAdmin, isTrue);
    });

    test('toString masks JWT token to prevent secret leakage in logs', () {
      final session = AuthSession(
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.sensitivePayload',
        type: 'Bearer',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        username: 'admin',
        roles: const ['ROLE_ADMIN'],
      );

      final str = session.toString();
      expect(str, contains('token: eyJhbGciOi...'));
      expect(str, isNot(contains('sensitivePayload')));
      expect(str, contains('username: admin'));
      expect(str, contains('roles: [ROLE_ADMIN]'));
    });
  });
}
