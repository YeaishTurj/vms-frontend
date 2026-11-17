import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Operational status for a vehicle in the VMS fleet.
enum VehicleStatus {
  active('Active', AppColors.green, AppColors.greenBg),
  inactive('Inactive', AppColors.red, AppColors.redBg),
  underMaintenance('Under Maintenance', AppColors.amber, AppColors.amberBg);

  final String label;
  final Color color;
  final Color backgroundColor;

  const VehicleStatus(this.label, this.color, this.backgroundColor);

  static VehicleStatus fromString(String val) {
    switch (val.toLowerCase().replaceAll(' ', '')) {
      case 'active':
        return VehicleStatus.active;
      case 'inactive':
        return VehicleStatus.inactive;
      case 'undermaintenance':
      case 'maintenance':
        return VehicleStatus.underMaintenance;
      default:
        return VehicleStatus.active;
    }
  }
}

/// Core Vehicle Entity Model.
class Vehicle {
  final String id;
  final String vehicleNumber;
  final String company;
  final String type;
  final String brand;
  final String model;
  final VehicleStatus status;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    required this.status,
  });

  String get displayName => '$brand $model';

  Vehicle copyWith({
    String? id,
    String? vehicleNumber,
    String? company,
    String? type,
    String? brand,
    String? model,
    VehicleStatus? status,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      company: company ?? this.company,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
    );
  }

  // Predefined vehicle types for clean dropdown selection
  static const List<String> commonTypes = [
    'Sedan',
    'SUV',
    'Truck',
    'Van',
    'Bus',
    'Pickup',
    'Motorcycle',
  ];

  // Common corporate companies for quick autocomplete / selection
  static const List<String> commonCompanies = [
    'Apex Logistics',
    'Metro Express',
    'Global Transit',
    'Prime Fleet',
    'City Dispatch',
    'Eco Courier',
  ];
}
