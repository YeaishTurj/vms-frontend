import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';

/// In-memory repository providing static and mutable mock fleet data.
class MockVehicleData extends ChangeNotifier {
  // Singleton pattern for simple shared in-memory state
  static final MockVehicleData _instance = MockVehicleData._internal();
  factory MockVehicleData() => _instance;

  MockVehicleData._internal() {
    _vehicles = List.from(_seedVehicles);
  }

  late List<Vehicle> _vehicles;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  static final List<Vehicle> _seedVehicles = [
    Vehicle(
      id: 'VMS-101',
      vin: '1HGCR2F83HA129482',
      licensePlate: 'DHK-METRO-GA-1122',
      make: 'Toyota',
      model: 'Camry',
      year: 2023,
      type: VehicleType.sedan,
      fuelType: FuelType.hybrid,
      mileage: 18450,
      status: VehicleStatus.active,
      assignedDriver: 'Rafiqul Islam',
      lastServiceDate: DateTime(2026, 9, 14),
      notes: 'Executive corporate transport vehicle. Pristine condition.',
    ),
    Vehicle(
      id: 'VMS-102',
      vin: '1FTFW1E84PKB21094',
      licensePlate: 'DHK-METRO-TA-4455',
      make: 'Ford',
      model: 'F-150',
      year: 2022,
      type: VehicleType.truck,
      fuelType: FuelType.diesel,
      mileage: 48920,
      status: VehicleStatus.inService,
      assignedDriver: 'Kamal Hossain',
      lastServiceDate: DateTime(2026, 8, 20),
      notes: 'Assigned to logistics and heavy depot dispatch route.',
    ),
    Vehicle(
      id: 'VMS-103',
      vin: '5YJ3E1EB8NF192847',
      licensePlate: 'DHK-METRO-BHA-8899',
      make: 'Tesla',
      model: 'Model 3',
      year: 2024,
      type: VehicleType.sedan,
      fuelType: FuelType.electric,
      mileage: 12100,
      status: VehicleStatus.active,
      assignedDriver: 'Tanvir Ahmed',
      lastServiceDate: DateTime(2026, 10, 05),
      notes: 'Zero emissions fleet pool car. Home base fast-charger equipped.',
    ),
    Vehicle(
      id: 'VMS-104',
      vin: 'WD3PE8CD8NP394851',
      licensePlate: 'DHK-METRO-CHA-3321',
      make: 'Mercedes-Benz',
      model: 'Sprinter 2500',
      year: 2021,
      type: VehicleType.van,
      fuelType: FuelType.diesel,
      mileage: 87400,
      status: VehicleStatus.maintenance,
      assignedDriver: 'Unassigned',
      lastServiceDate: DateTime(2026, 11, 01),
      notes: 'Brake pad replacement and transmission inspection in progress.',
    ),
    Vehicle(
      id: 'VMS-105',
      vin: '1GNSKBKC9MR109283',
      licensePlate: 'DHK-METRO-GHA-7766',
      make: 'Chevrolet',
      model: 'Tahoe Premier',
      year: 2023,
      type: VehicleType.suv,
      fuelType: FuelType.petrol,
      mileage: 31200,
      status: VehicleStatus.active,
      assignedDriver: 'Mahmudur Rahman',
      lastServiceDate: DateTime(2026, 7, 19),
      notes: 'VIP protocol fleet. All periodic maintenance checks current.',
    ),
    Vehicle(
      id: 'VMS-106',
      vin: '2C4RC1CG5NR678912',
      licensePlate: 'DHK-METRO-NA-9988',
      make: 'Chrysler',
      model: 'Pacifica Hybrid',
      year: 2022,
      type: VehicleType.van,
      fuelType: FuelType.hybrid,
      mileage: 41500,
      status: VehicleStatus.inService,
      assignedDriver: 'Shamsul Alam',
      lastServiceDate: DateTime(2026, 9, 28),
      notes: 'Employee shuttle daily route from central office to technology park.',
    ),
    Vehicle(
      id: 'VMS-107',
      vin: '4UZAA2AC5NCBL1283',
      licensePlate: 'DHK-METRO-JA-0011',
      make: 'Volvo',
      model: '9700 Coach',
      year: 2020,
      type: VehicleType.bus,
      fuelType: FuelType.diesel,
      mileage: 134200,
      status: VehicleStatus.active,
      assignedDriver: 'Abdul Gafur',
      lastServiceDate: DateTime(2026, 10, 12),
      notes: 'Long-haul inter-city corporate conference transport.',
    ),
    Vehicle(
      id: 'VMS-108',
      vin: 'JM3KFBCM9P1827364',
      licensePlate: 'DHK-METRO-KHA-6655',
      make: 'Mazda',
      model: 'CX-5',
      year: 2021,
      type: VehicleType.suv,
      fuelType: FuelType.petrol,
      mileage: 62000,
      status: VehicleStatus.inactive,
      assignedDriver: 'Unassigned',
      lastServiceDate: DateTime(2026, 5, 11),
      notes: 'Decommissioned pending auction disposal.',
    ),
  ];

  // Repository Methods
  Vehicle? findById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  void addVehicle(Vehicle vehicle) {
    _vehicles.insert(0, vehicle);
    notifyListeners();
  }

  void updateVehicle(Vehicle updated) {
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
      notifyListeners();
    }
  }

  void deleteVehicle(String id) {
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Dashboard Aggregates
  int get totalVehicles => _vehicles.length;

  int get countActive =>
      _vehicles.where((v) => v.status == VehicleStatus.active).length;

  int get countInService =>
      _vehicles.where((v) => v.status == VehicleStatus.inService).length;

  int get countMaintenance =>
      _vehicles.where((v) => v.status == VehicleStatus.maintenance).length;

  int get countInactive =>
      _vehicles.where((v) => v.status == VehicleStatus.inactive).length;

  int get totalFleetMileage =>
      _vehicles.fold<int>(0, (sum, v) => sum + v.mileage);
}
