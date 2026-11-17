import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vms_frontend/data/models/vehicle.dart';
import 'package:vms_frontend/data/repositories/vehicle_repository.dart';
import 'package:vms_frontend/data/services/api_client.dart';
import 'package:vms_frontend/data/services/api_exception.dart';
import 'package:vms_frontend/data/services/vehicle_api_service.dart';

void main() {
  group('VehicleRepository & API Integration Tests', () {
    late VehicleRepository repository;

    test('fetchVehicles successfully parses paginated backend response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/vehicles');
        expect(request.url.queryParameters['page'], '0');
        expect(request.url.queryParameters['size'], '8');

        final responseBody = jsonEncode({
          'content': [
            {
              'id': 1,
              'vehicleNumber': 'ABC-1234',
              'company': 'Apex Logistics',
              'type': 'Semi-Truck',
              'brand': 'Freightliner',
              'model': 'Cascadia',
              'status': 'Active',
            }
          ],
          'number': 0,
          'size': 8,
          'totalElements': 1,
          'totalPages': 1,
          'last': true,
          'first': true,
          'empty': false,
        });

        return http.Response(responseBody, 200, headers: {
          'content-type': 'application/json',
        });
      });

      final apiClient = ApiClient(client: mockClient);
      final apiService = VehicleApiService(client: apiClient);
      repository = VehicleRepository(apiService: apiService);

      await repository.fetchVehicles(page: 0, size: 8);

      expect(repository.isLoading, isFalse);
      expect(repository.errorMessage, isNull);
      expect(repository.vehicles.length, 1);
      expect(repository.vehicles.first.vehicleNumber, 'ABC-1234');
      expect(repository.totalElements, 1);
      expect(repository.totalPages, 1);
      expect(repository.isFirstPage, isTrue);
      expect(repository.isLastPage, isTrue);
    });

    test('registerVehicle sends POST /vehicles and updates repository state', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/vehicles');

        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        expect(payload['vehicleNumber'], 'NEW-9999');

        final created = {
          'id': 42,
          'vehicleNumber': 'NEW-9999',
          'company': 'Apex Logistics',
          'type': 'Van',
          'brand': 'Ford',
          'model': 'Transit',
          'status': 'Active',
        };

        return http.Response(jsonEncode(created), 201, headers: {
          'content-type': 'application/json',
          'location': '/vehicles/42',
        });
      });

      final apiClient = ApiClient(client: mockClient);
      final apiService = VehicleApiService(client: apiClient);
      repository = VehicleRepository(apiService: apiService);

      const toCreate = Vehicle(
        id: '',
        vehicleNumber: 'NEW-9999',
        company: 'Apex Logistics',
        type: 'Van',
        brand: 'Ford',
        model: 'Transit',
        status: VehicleStatus.active,
      );

      final result = await repository.registerVehicle(toCreate);

      expect(result.id, '42');
      expect(result.vehicleNumber, 'NEW-9999');
      expect(repository.vehicles.any((v) => v.vehicleNumber == 'NEW-9999'), isTrue);
    });

    test('registerVehicle throws ApiException with 409 on duplicate vehicle number', () async {
      final mockClient = MockClient((request) async {
        final errorResponse = jsonEncode({
          'status': 409,
          'error': 'Duplicate Vehicle Number',
          'message': "Vehicle number 'DUPLICATE-1' is already registered.",
          'timestamp': '2026-11-17T15:00:00Z',
        });

        return http.Response(errorResponse, 409, headers: {
          'content-type': 'application/json',
        });
      });

      final apiClient = ApiClient(client: mockClient);
      final apiService = VehicleApiService(client: apiClient);
      repository = VehicleRepository(apiService: apiService);

      const duplicate = Vehicle(
        id: '',
        vehicleNumber: 'DUPLICATE-1',
        company: 'Company',
        type: 'Van',
        brand: 'Brand',
        model: 'Model',
        status: VehicleStatus.active,
      );

      expect(
        () => repository.registerVehicle(duplicate),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having((e) => e.isDuplicate, 'isDuplicate', isTrue)
              .having((e) => e.message, 'message', contains('already registered')),
        ),
      );
    });

    test('updateVehicle sends PUT /vehicles/{id} and updates list', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/vehicles/10');

        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        expect(payload['model'], 'Transit Custom');

        final updated = {
          'id': 10,
          'vehicleNumber': 'ABC-1234',
          'company': 'Apex Logistics',
          'type': 'Van',
          'brand': 'Ford',
          'model': 'Transit Custom',
          'status': 'Active',
        };

        return http.Response(jsonEncode(updated), 200, headers: {
          'content-type': 'application/json',
        });
      });

      final apiClient = ApiClient(client: mockClient);
      final apiService = VehicleApiService(client: apiClient);
      repository = VehicleRepository(apiService: apiService);

      const toUpdate = Vehicle(
        id: '10',
        vehicleNumber: 'ABC-1234',
        company: 'Apex Logistics',
        type: 'Van',
        brand: 'Ford',
        model: 'Transit Custom',
        status: VehicleStatus.active,
      );

      final result = await repository.updateVehicle(toUpdate);

      expect(result.id, '10');
      expect(result.model, 'Transit Custom');
    });

    test('deleteVehicle sends DELETE /vehicles/{id} and removes record from list', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/vehicles/10');
        return http.Response('', 204);
      });

      final apiClient = ApiClient(client: mockClient);
      final apiService = VehicleApiService(client: apiClient);
      repository = VehicleRepository(apiService: apiService);

      await repository.deleteVehicle('10');
      expect(repository.vehicles.any((v) => v.id == '10'), isFalse);
    });

    test('deleteVehicle throws ApiException with 404 when vehicle not found', () async {
      final mockClient = MockClient((request) async {
        final errorResponse = jsonEncode({
          'status': 404,
          'error': 'Not Found',
          'message': 'Vehicle not found with ID: 999',
          'timestamp': '2026-11-17T15:00:00Z',
        });
        return http.Response(errorResponse, 404, headers: {
          'content-type': 'application/json',
        });
      });

      final apiClient = ApiClient(client: mockClient);
      final apiService = VehicleApiService(client: apiClient);
      repository = VehicleRepository(apiService: apiService);

      expect(
        () => repository.deleteVehicle('999'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.isNotFound, 'isNotFound', isTrue),
        ),
      );
    });
  });
}
