import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vms_frontend/core/theme/app_theme.dart';
import 'package:vms_frontend/data/services/api_client.dart';
import 'package:vms_frontend/data/services/auth_service.dart';
import 'package:vms_frontend/data/services/session_storage/session_storage_stub.dart';
import 'package:vms_frontend/routing/app_router.dart';
import 'package:vms_frontend/screens/login/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late AppRouter router;
    late InMemorySessionStorage storage;

    setUp(() {
      storage = InMemorySessionStorage();
      final mockClient = MockClient((request) async {
        if (request.url.path == '/auth/login' && request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          if (body['username'] == 'admin' && body['password'] == 'admin123') {
            return http.Response(
              jsonEncode({
                'token': 'jwt-mock-test-token',
                'type': 'Bearer',
                'expiresIn': 86400,
                'username': 'admin',
                'roles': ['ROLE_ADMIN'],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          } else {
            return http.Response(
              jsonEncode({
                'error': 'Unauthorized',
                'message': 'Invalid username or password',
              }),
              401,
              headers: {'content-type': 'application/json'},
            );
          }
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient);
      AuthService.instance.resetForTesting(
        client: apiClient,
        storage: storage,
      );

      router = AppRouter();
      router.setAuthenticated(false);
    });

    testWidgets('LoginScreen displays branding and credential fields', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
      );

      expect(find.text('VMS'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In to Dashboard'), findsOneWidget);
      expect(find.text('Sample Credentials (Mock Login)'), findsOneWidget);
    });

    testWidgets('Submitting empty fields triggers required-field validation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
      );

      // Clear the pre-filled demo text fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.at(0), '');
      await tester.enterText(textFields.at(1), '');
      await tester.pumpAndSettle();

      // Tap Sign In button
      final signInButton = find.text('Sign In to Dashboard');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Submitting invalid credentials displays friendly authentication error', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'wrong_user');
      await tester.enterText(textFields.at(1), 'wrong_pass');
      await tester.pumpAndSettle();

      final signInButton = find.text('Sign In to Dashboard');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Invalid username or password. Please verify your credentials and try again.'),
        findsOneWidget,
      );
      expect(router.isAuthenticated, isFalse);
    });

    testWidgets('Submitting valid credentials authenticates successfully', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'admin');
      await tester.enterText(textFields.at(1), 'admin123');
      await tester.pumpAndSettle();

      final signInButton = find.text('Sign In to Dashboard');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(router.isAuthenticated, isTrue);
      expect(router.currentScreen, AppScreen.dashboard);
    });

    testWidgets('Displays session expired warning banner when session expired', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Trigger session expiration
      AuthService.instance.handleSessionExpired();

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Your session has expired. Please sign in to continue.'),
        findsOneWidget,
      );
    });
  });
}
