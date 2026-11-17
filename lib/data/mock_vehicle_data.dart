import 'package:flutter/foundation.dart';

import '../models/vehicle.dart';

/// In-memory reactive repository managing the VMS fleet data.
class MockVehicleData extends ChangeNotifier {
  // Singleton pattern for shared local state across screens
  static final MockVehicleData _instance = MockVehicleData._internal();
  factory MockVehicleData() => _instance;

  MockVehicleData._internal() {
    _vehicles = List.from(_seedVehicles);
  }

  late List<Vehicle> _vehicles;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  // Initial seed data with at least 8 realistic corporate vehicles
  static final List<Vehicle> _seedVehicles = [
    const Vehicle(
      id: 'vms-001',
      vehicleNumber: 'DM-GA-11-2041',
      company: 'Apex Logistics',
      type: 'Sedan',
      brand: 'Toyota',
      model: 'Camry',
      status: VehicleStatus.active,
    ),
    const Vehicle(
      id: 'vms-002',
      vehicleNumber: 'DM-TA-14-8821',
      company: 'Metro Express',
      type: 'Truck',
      brand: 'Ford',
      model: 'F-150',
      status: VehicleStatus.underMaintenance,
    ),
    const Vehicle(
      id: 'vms-003',
      vehicleNumber: 'DM-BHA-22-9011',
      company: 'Global Transit',
      type: 'Van',
      brand: 'Mercedes-Benz',
      model: 'Sprinter',
      status: VehicleStatus.active,
    ),
    const Vehicle(
      id: 'vms-004',
      vehicleNumber: 'DM-CHA-55-1234',
      company: 'Apex Logistics',
      type: 'SUV',
      brand: 'Toyota',
      model: 'Prado',
      status: VehicleStatus.active,
    ),
    const Vehicle(
      id: 'vms-005',
      vehicleNumber: 'DM-GHA-77-6543',
      company: 'Prime Fleet',
      type: 'Bus',
      brand: 'Volvo',
      model: '9700',
      status: VehicleStatus.underMaintenance,
    ),
    const Vehicle(
      id: 'vms-006',
      vehicleNumber: 'DM-NA-33-8765',
      company: 'Metro Express',
      type: 'Sedan',
      brand: 'Honda',
      model: 'Civic',
      status: VehicleStatus.inactive,
    ),
    const Vehicle(
      id: 'vms-007',
      vehicleNumber: 'DM-JA-44-3322',
      company: 'Eco Courier',
      type: 'Van',
      brand: 'Ford',
      model: 'Transit',
      status: VehicleStatus.active,
    ),
    const Vehicle(
      id: 'vms-008',
      vehicleNumber: 'DM-KHA-19-4455',
      company: 'Global Transit',
      type: 'SUV',
      brand: 'Hyundai',
      model: 'Santa Fe',
      status: VehicleStatus.active,
    ),
    const Vehicle(
      id: 'vms-009',
      vehicleNumber: 'DM-DA-88-7711',
      company: 'City Dispatch',
      type: 'Truck',
      brand: 'Isuzu',
      model: 'NPR',
      status: VehicleStatus.inactive,
    ),
    const Vehicle(
      id: 'vms-010',
      vehicleNumber: 'DM-RA-99-0012',
      company: 'Prime Fleet',
      type: 'Sedan',
      brand: 'Tesla',
      model: 'Model 3',
      status: VehicleStatus.active,
    ),
  ];

  // ---------------------------------------------------------------------------
  // CRUD Operations
  // ---------------------------------------------------------------------------

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

  /// Validates duplicate Vehicle Number across all records.
  /// If [excludeId] is provided (during edit), that vehicle's own ID is ignored.
  bool isVehicleNumberDuplicate(String vehicleNumber, {String? excludeId}) {
    final normalized = vehicleNumber.trim().toLowerCase();
    return _vehicles.any((v) {
      if (excludeId != null && v.id == excludeId) {
        return false;
      }
      return v.vehicleNumber.trim().toLowerCase() == normalized;
    });
  }

  // ---------------------------------------------------------------------------
  // Dashboard Aggregates
  // ---------------------------------------------------------------------------

  int get totalCount => _vehicles.length;

  int get activeCount =>
      _vehicles.where((v) => v.status == VehicleStatus.active).length;

  int get inactiveCount =>
      _vehicles.where((v) => v.status == VehicleStatus.inactive).length;

  int get maintenanceCount =>
      _vehicles.where((v) => v.status == VehicleStatus.underMaintenance).length;
}
