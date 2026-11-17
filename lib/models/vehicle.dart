import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Operational status of a fleet vehicle.
enum VehicleStatus {
  active('Active', AppColors.statusActive, AppColors.statusActiveBg),
  inService('In Service', AppColors.statusInService, AppColors.statusInServiceBg),
  maintenance('Maintenance', AppColors.statusMaintenance, AppColors.statusMaintenanceBg),
  inactive('Inactive', AppColors.statusInactive, AppColors.statusInactiveBg);

  final String label;
  final Color color;
  final Color backgroundColor;

  const VehicleStatus(this.label, this.color, this.backgroundColor);
}

/// Category of vehicle in the fleet.
enum VehicleType {
  sedan('Sedan'),
  suv('SUV'),
  truck('Truck'),
  van('Van'),
  bus('Bus');

  final String label;
  const VehicleType(this.label);
}

/// Fuel / Power source type.
enum FuelType {
  petrol('Petrol'),
  diesel('Diesel'),
  electric('Electric'),
  hybrid('Hybrid');

  final String label;
  const FuelType(this.label);
}

/// Core Vehicle Entity Model.
class Vehicle {
  final String id;
  final String vin;
  final String licensePlate;
  final String make;
  final String model;
  final int year;
  final VehicleType type;
  final FuelType fuelType;
  final int mileage;
  final VehicleStatus status;
  final String assignedDriver;
  final DateTime lastServiceDate;
  final String notes;

  const Vehicle({
    required this.id,
    required this.vin,
    required this.licensePlate,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    required this.fuelType,
    required this.mileage,
    required this.status,
    required this.assignedDriver,
    required this.lastServiceDate,
    this.notes = '',
  });

  String get displayName => '$year $make $model';

  Vehicle copyWith({
    String? id,
    String? vin,
    String? licensePlate,
    String? make,
    String? model,
    int? year,
    VehicleType? type,
    FuelType? fuelType,
    int? mileage,
    VehicleStatus? status,
    String? assignedDriver,
    DateTime? lastServiceDate,
    String? notes,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      type: type ?? this.type,
      fuelType: fuelType ?? this.fuelType,
      mileage: mileage ?? this.mileage,
      status: status ?? this.status,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      notes: notes ?? this.notes,
    );
  }
}
