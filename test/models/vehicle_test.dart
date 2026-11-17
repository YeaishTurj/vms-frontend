import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/models/vehicle.dart';

void main() {
  group('Vehicle Model & VehicleStatus Tests', () {
    test('VehicleStatus.fromString correctly parses all statuses', () {
      expect(VehicleStatus.fromString('active'), VehicleStatus.active);
      expect(VehicleStatus.fromString('Active'), VehicleStatus.active);
      expect(VehicleStatus.fromString('inactive'), VehicleStatus.inactive);
      expect(VehicleStatus.fromString('Inactive'), VehicleStatus.inactive);
      expect(
        VehicleStatus.fromString('under maintenance'),
        VehicleStatus.underMaintenance,
      );
      expect(
        VehicleStatus.fromString('maintenance'),
        VehicleStatus.underMaintenance,
      );
      expect(VehicleStatus.fromString('unknown_status'), VehicleStatus.active);
    });

    test('Vehicle displayName combines brand and model', () {
      const vehicle = Vehicle(
        id: 'vms-test-1',
        vehicleNumber: 'DM-TEST-01',
        company: 'Test Logistics',
        type: 'Sedan',
        brand: 'Toyota',
        model: 'Corolla',
        status: VehicleStatus.active,
      );

      expect(vehicle.displayName, 'Toyota Corolla');
    });

    test('Vehicle copyWith correctly updates specified attributes', () {
      const original = Vehicle(
        id: 'vms-test-1',
        vehicleNumber: 'DM-TEST-01',
        company: 'Test Logistics',
        type: 'Sedan',
        brand: 'Toyota',
        model: 'Corolla',
        status: VehicleStatus.active,
      );

      final updated = original.copyWith(
        company: 'Updated Fleet',
        status: VehicleStatus.underMaintenance,
      );

      expect(updated.id, original.id);
      expect(updated.vehicleNumber, original.vehicleNumber);
      expect(updated.company, 'Updated Fleet');
      expect(updated.status, VehicleStatus.underMaintenance);
      expect(updated.brand, 'Toyota');
      expect(updated.model, 'Corolla');
    });

    test('Vehicle commonTypes and commonCompanies are populated', () {
      expect(
        Vehicle.commonTypes,
        containsAll(['Sedan', 'SUV', 'Truck', 'Van']),
      );
      expect(Vehicle.commonCompanies, isNotEmpty);
    });
  });
}
