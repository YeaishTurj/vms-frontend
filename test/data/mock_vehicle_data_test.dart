import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/data/mock_vehicle_data.dart';
import 'package:vms_frontend/models/vehicle.dart';

void main() {
  group('MockVehicleData Repository & CRUD Tests', () {
    late MockVehicleData mockData;

    setUp(() {
      mockData = MockVehicleData();
      mockData.resetToInitialSeed();
    });

    test('Initial seed contains at least 8 realistic vehicles', () {
      expect(mockData.vehicles.length, greaterThanOrEqualTo(8));
      expect(mockData.totalCount, mockData.vehicles.length);
      expect(mockData.activeCount, greaterThan(0));
      expect(mockData.inactiveCount, greaterThanOrEqualTo(0));
      expect(mockData.maintenanceCount, greaterThanOrEqualTo(0));
    });

    test('Sum of status metrics matches totalCount', () {
      final sum =
          mockData.activeCount +
          mockData.inactiveCount +
          mockData.maintenanceCount;
      expect(sum, mockData.totalCount);
    });

    test('Adding a new vehicle increments totalCount and reflects in list', () {
      final initialCount = mockData.totalCount;
      const newVehicle = Vehicle(
        id: 'vms-new-99',
        vehicleNumber: 'DM-NEW-99-9999',
        company: 'Prime Fleet',
        type: 'Electric',
        brand: 'Tesla',
        model: 'Model Y',
        status: VehicleStatus.active,
      );

      mockData.addVehicle(newVehicle);

      expect(mockData.totalCount, initialCount + 1);
      expect(mockData.getVehicleById('vms-new-99'), isNotNull);
      expect(
        mockData.getVehicleById('vms-new-99')?.vehicleNumber,
        'DM-NEW-99-9999',
      );
    });

    test('Duplicate Vehicle Number is detected and rejected', () {
      final existingNumber = mockData.vehicles.first.vehicleNumber;

      // Duplicate check for a new vehicle should return true
      final isDuplicate = mockData.isVehicleNumberDuplicate(existingNumber);
      expect(isDuplicate, isTrue);

      // Duplicate check for an existing vehicle excluding its own id should return false
      final ownId = mockData.vehicles.first.id;
      final isSelfUpdate = mockData.isVehicleNumberDuplicate(
        existingNumber,
        excludeId: ownId,
      );
      expect(isSelfUpdate, isFalse);

      // Non-existent vehicle number should return false
      final isNewUnique = mockData.isVehicleNumberDuplicate(
        'BRAND-NEW-UNIQUE-999',
      );
      expect(isNewUnique, isFalse);
    });

    test('Updating an existing vehicle modifies fields properly', () {
      final target = mockData.vehicles.first;
      final updated = target.copyWith(
        company: 'Apex Logistics Refined',
        status: VehicleStatus.inactive,
      );

      mockData.updateVehicle(updated);

      final retrieved = mockData.getVehicleById(target.id);
      expect(retrieved?.company, 'Apex Logistics Refined');
      expect(retrieved?.status, VehicleStatus.inactive);
    });

    test(
      'Deleting a vehicle decrements count and removes it from repository',
      () {
        final initialCount = mockData.totalCount;
        final targetId = mockData.vehicles.first.id;

        mockData.deleteVehicle(targetId);

        expect(mockData.totalCount, initialCount - 1);
        expect(mockData.getVehicleById(targetId), isNull);
      },
    );
  });
}
