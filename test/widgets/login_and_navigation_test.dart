import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/core/theme/app_theme.dart';
import 'package:vms_frontend/routing/app_router.dart';
import 'package:vms_frontend/screens/login/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late AppRouter router;

    setUp(() {
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

      final signInButton = find.text('Sign In to Dashboard');
      await tester.tap(signInButton);
      await tester.pump();

      // Wait for simulated delay
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(router.isAuthenticated, isTrue);
      expect(router.currentScreen, AppScreen.dashboard);
    });
  });
}
