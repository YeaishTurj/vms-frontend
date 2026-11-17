import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vms_frontend/core/theme/app_theme.dart';
import 'package:vms_frontend/data/models/vehicle.dart';
import 'package:vms_frontend/data/repositories/vehicle_repository.dart';
import 'package:vms_frontend/data/services/api_client.dart';
import 'package:vms_frontend/data/services/vehicle_api_service.dart';
import 'package:vms_frontend/routing/app_router.dart';
import 'package:vms_frontend/screens/vehicles/vehicle_form_screen.dart';
import 'package:vms_frontend/screens/vehicles/vehicle_list_screen.dart';
import 'package:vms_frontend/widgets/app_button.dart';
import 'package:vms_frontend/widgets/confirmation_dialog.dart';

void main() {
  group('Vehicle Full CRUD Workflow Widget Tests', () {
    late VehicleRepository repository;
    late List<Map<String, dynamic>> inMemoryBackendDatabase;

    setUp(() {
      inMemoryBackendDatabase = [
        {
          'id': 1,
          'vehicleNumber': 'DM-GA-11-2041',
          'company': 'Apex Logistics',
          'type': 'Sedan',
          'brand': 'Toyota',
          'model': 'Camry',
          'status': 'Active',
        },
        {
          'id': 2,
          'vehicleNumber': 'DM-TA-12-8842',
          'company': 'Metro Express',
          'type': 'Van',
          'brand': 'Ford',
          'model': 'Transit',
          'status': 'Under Maintenance',
        },
      ];

      final mockClient = MockClient((request) async {
        final path = request.url.path;
        final method = request.method;

        // GET /vehicles (paginated)
        if (path == '/vehicles' && method == 'GET') {
          final page = int.tryParse(request.url.queryParameters['page'] ?? '0') ?? 0;
          final size = int.tryParse(request.url.queryParameters['size'] ?? '10') ?? 10;
          final total = inMemoryBackendDatabase.length;
          final totalPages = (total / size).ceil();

          return http.Response(
            jsonEncode({
              'content': inMemoryBackendDatabase,
              'number': page,
              'size': size,
              'totalElements': total,
              'totalPages': totalPages > 0 ? totalPages : 1,
              'last': true,
              'first': page == 0,
              'empty': inMemoryBackendDatabase.isEmpty,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        // GET /vehicles/{id}
        if (path.startsWith('/vehicles/') && method == 'GET') {
          final idStr = path.replaceFirst('/vehicles/', '');
          final match = inMemoryBackendDatabase.cast<Map<String, dynamic>?>().firstWhere(
                (v) => v!['id'].toString() == idStr,
                orElse: () => null,
              );
          if (match != null) {
            return http.Response(jsonEncode(match), 200, headers: {'content-type': 'application/json'});
          }
          return http.Response(
            jsonEncode({'status': 404, 'error': 'Not Found', 'message': 'Vehicle not found'}),
            404,
            headers: {'content-type': 'application/json'},
          );
        }

        // POST /vehicles (register)
        if (path == '/vehicles' && method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final num = body['vehicleNumber'] as String? ?? '';

          if (inMemoryBackendDatabase.any((v) => v['vehicleNumber'] == num)) {
            return http.Response(
              jsonEncode({
                'status': 409,
                'error': 'Duplicate Vehicle Number',
                'message': "Vehicle number '$num' is already registered.",
              }),
              409,
              headers: {'content-type': 'application/json'},
            );
          }

          final newId = inMemoryBackendDatabase.length + 1;
          final created = {
            'id': newId,
            'vehicleNumber': num,
            'company': body['company'] ?? '',
            'type': body['type'] ?? 'Sedan',
            'brand': body['brand'] ?? '',
            'model': body['model'] ?? '',
            'status': body['status'] ?? 'Active',
          };
          inMemoryBackendDatabase.insert(0, created);

          return http.Response(
            jsonEncode(created),
            201,
            headers: {'content-type': 'application/json', 'location': '/vehicles/$newId'},
          );
        }

        // PUT /vehicles/{id} (edit)
        if (path.startsWith('/vehicles/') && method == 'PUT') {
          final idStr = path.replaceFirst('/vehicles/', '');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final num = body['vehicleNumber'] as String? ?? '';

          // Check duplicate
          final duplicate = inMemoryBackendDatabase.any(
            (v) => v['id'].toString() != idStr && v['vehicleNumber'] == num,
          );
          if (duplicate) {
            return http.Response(
              jsonEncode({
                'status': 409,
                'error': 'Duplicate Vehicle Number',
                'message': "Vehicle number '$num' already exists on another vehicle.",
              }),
              409,
              headers: {'content-type': 'application/json'},
            );
          }

          final index = inMemoryBackendDatabase.indexWhere((v) => v['id'].toString() == idStr);
          if (index != -1) {
            final updated = {
              'id': int.tryParse(idStr) ?? idStr,
              'vehicleNumber': num,
              'company': body['company'] ?? '',
              'type': body['type'] ?? 'Sedan',
              'brand': body['brand'] ?? '',
              'model': body['model'] ?? '',
              'status': body['status'] ?? 'Active',
            };
            inMemoryBackendDatabase[index] = updated;
            return http.Response(jsonEncode(updated), 200, headers: {'content-type': 'application/json'});
          }

          return http.Response(
            jsonEncode({'status': 404, 'error': 'Not Found', 'message': 'Vehicle not found'}),
            404,
            headers: {'content-type': 'application/json'},
          );
        }

        // DELETE /vehicles/{id} (delete)
        if (path.startsWith('/vehicles/') && method == 'DELETE') {
          final idStr = path.replaceFirst('/vehicles/', '');
          inMemoryBackendDatabase.removeWhere((v) => v['id'].toString() == idStr);
          return http.Response('', 204);
        }

        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final apiService = VehicleApiService(client: apiClient);
      repository = VehicleRepository(apiService: apiService);

      AppRouter().setAuthenticated(true);
    });

    testWidgets('Vehicle List loads and renders vehicles with pagination and badges', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: VehicleListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DM-GA-11-2041'), findsOneWidget);
      expect(find.text('DM-TA-12-8842'), findsOneWidget);
      expect(find.text('Apex Logistics'), findsOneWidget);
      expect(find.text('Metro Express'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Under Maintenance'), findsOneWidget);
      expect(find.text('Showing 1 to 2 of 2 vehicles'), findsOneWidget);
    });

    testWidgets('Register new vehicle submits POST /vehicles and displays in list', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: VehicleFormScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in Form Fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4)); // vehicleNumber, company, brand, model

      await tester.enterText(textFields.at(0), 'NEW-FLEET-99');
      await tester.enterText(textFields.at(1), 'Prime Fleet');
      await tester.enterText(textFields.at(2), 'Volvo');
      await tester.enterText(textFields.at(3), 'XC90');
      await tester.pumpAndSettle();

      // Submit Form
      final submitButton = find.widgetWithText(AppButton, 'Save Vehicle');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(repository.vehicles.any((v) => v.vehicleNumber == 'NEW-FLEET-99'), isTrue);
      expect(inMemoryBackendDatabase.first['vehicleNumber'], 'NEW-FLEET-99');
    });

    testWidgets('Register duplicate vehicle number displays 409 error banner', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: VehicleFormScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Enter existing vehicle number
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'DM-GA-11-2041');
      await tester.enterText(textFields.at(1), 'Apex Logistics');
      await tester.enterText(textFields.at(2), 'Toyota');
      await tester.enterText(textFields.at(3), 'Camry');
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(AppButton, 'Save Vehicle');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Duplicate Vehicle Number Detected'), findsOneWidget);
      expect(
        find.text("Vehicle number 'DM-GA-11-2041' is already registered."),
        findsOneWidget,
      );
    });

    testWidgets('Edit vehicle submits PUT /vehicles/{id} preserving ID', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const targetVehicle = Vehicle(
        id: '1',
        vehicleNumber: 'DM-GA-11-2041',
        company: 'Apex Logistics',
        type: 'Sedan',
        brand: 'Toyota',
        model: 'Camry Hybrid',
        status: VehicleStatus.active,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: VehicleFormScreen(initialVehicle: targetVehicle)),
        ),
      );
      await tester.pumpAndSettle();

      // Update model field
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(3), 'Camry Hybrid 2026');
      await tester.pumpAndSettle();

      final saveButton = find.text('Save Changes');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final updatedInDb = inMemoryBackendDatabase.firstWhere((v) => v['id'] == 1);
      expect(updatedInDb['model'], 'Camry Hybrid 2026');
    });

    testWidgets('Delete vehicle displays ConfirmationDialog and removes record', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: VehicleListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DM-GA-11-2041'), findsOneWidget);

      // Find and tap the delete button for the first vehicle
      final deleteIcons = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteIcons, findsNWidgets(2));

      await tester.tap(deleteIcons.first);
      await tester.pumpAndSettle();

      // Confirmation dialog should be displayed
      expect(find.byType(ConfirmationDialog), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to permanently delete this vehicle from the management system? This action cannot be undone.',
        ),
        findsOneWidget,
      );

      // Tap confirm Delete inside Dialog
      final confirmDeleteButton = find.descendant(
        of: find.byType(ConfirmationDialog),
        matching: find.widgetWithText(AppButton, 'Delete Vehicle'),
      );
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      expect(find.text('DM-GA-11-2041'), findsNothing);
      expect(inMemoryBackendDatabase.any((v) => v['id'] == 1), isFalse);
    });
  });
}
