import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/data/models/paginated_vehicles.dart';
import 'package:vms_frontend/models/vehicle.dart';

void main() {
  group('Vehicle JSON Serialization Tests', () {
    test('Vehicle.fromJson correctly parses backend payload', () {
      final json = {
        'id': 101,
        'vehicleNumber': 'ABC-1234',
        'company': 'Apex Logistics',
        'type': 'Semi-Truck',
        'brand': 'Freightliner',
        'model': 'Cascadia',
        'status': 'Active',
      };

      final vehicle = Vehicle.fromJson(json);

      expect(vehicle.id, '101');
      expect(vehicle.vehicleNumber, 'ABC-1234');
      expect(vehicle.company, 'Apex Logistics');
      expect(vehicle.type, 'Semi-Truck');
      expect(vehicle.brand, 'Freightliner');
      expect(vehicle.model, 'Cascadia');
      expect(vehicle.status, VehicleStatus.active);
    });

    test('Vehicle.toJson formats payload matching backend request contract', () {
      const vehicle = Vehicle(
        id: '101',
        vehicleNumber: 'ABC-1234',
        company: 'Apex Logistics',
        type: 'Semi-Truck',
        brand: 'Freightliner',
        model: 'Cascadia',
        status: VehicleStatus.active,
      );

      final json = vehicle.toJson();

      expect(json['vehicleNumber'], 'ABC-1234');
      expect(json['company'], 'Apex Logistics');
      expect(json['type'], 'Semi-Truck');
      expect(json['brand'], 'Freightliner');
      expect(json['model'], 'Cascadia');
      expect(json['status'], 'Active');
      expect(json.containsKey('id'), isFalse);
    });

    test('PaginatedVehicles.fromJson correctly parses Spring Page response', () {
      final pageJson = {
        'content': [
          {
            'id': 1,
            'vehicleNumber': 'ABC-1234',
            'company': 'Apex Logistics',
            'type': 'Truck',
            'brand': 'Volvo',
            'model': 'FH16',
            'status': 'Active',
          }
        ],
        'number': 0,
        'size': 10,
        'totalElements': 1,
        'totalPages': 1,
        'last': true,
        'first': true,
        'empty': false,
      };

      final page = PaginatedVehicles.fromJson(pageJson);

      expect(page.content.length, 1);
      expect(page.content[0].vehicleNumber, 'ABC-1234');
      expect(page.number, 0);
      expect(page.size, 10);
      expect(page.totalElements, 1);
      expect(page.totalPages, 1);
      expect(page.last, isTrue);
      expect(page.first, isTrue);
      expect(page.empty, isFalse);
    });
  });
}
