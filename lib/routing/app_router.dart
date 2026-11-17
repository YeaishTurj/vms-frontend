import 'package:flutter/material.dart';
import '../models/vehicle.dart';

/// Navigation states for the VMS single-page desktop-first shell.
enum AppScreen {
  login,
  dashboard,
  vehicles,
  vehicleCreate,
  vehicleEdit,
}

/// Simple, robust navigation coordinator without external dependencies.
class AppRouter extends ChangeNotifier {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;

  AppRouter._internal();

  AppScreen _currentScreen = AppScreen.dashboard;
  Vehicle? _selectedVehicleForEdit;
  bool _isSidebarCollapsed = false;

  AppScreen get currentScreen => _currentScreen;
  Vehicle? get selectedVehicleForEdit => _selectedVehicleForEdit;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  void navigateTo(AppScreen screen) {
    _currentScreen = screen;
    if (screen != AppScreen.vehicleEdit) {
      _selectedVehicleForEdit = null;
    }
    notifyListeners();
  }

  void navigateToEditVehicle(Vehicle vehicle) {
    _selectedVehicleForEdit = vehicle;
    _currentScreen = AppScreen.vehicleEdit;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  String get screenTitle {
    switch (_currentScreen) {
      case AppScreen.login:
        return 'Sign In';
      case AppScreen.dashboard:
        return 'Executive Fleet Dashboard';
      case AppScreen.vehicles:
        return 'Vehicle Inventory';
      case AppScreen.vehicleCreate:
        return 'Register New Vehicle';
      case AppScreen.vehicleEdit:
        return 'Edit Vehicle Specifications';
    }
  }

  String get breadcrumb {
    switch (_currentScreen) {
      case AppScreen.login:
        return 'Authentication / Sign In';
      case AppScreen.dashboard:
        return 'Fleet Management / Overview';
      case AppScreen.vehicles:
        return 'Fleet Management / Vehicles';
      case AppScreen.vehicleCreate:
        return 'Fleet Management / Vehicles / Add';
      case AppScreen.vehicleEdit:
        return 'Fleet Management / Vehicles / Edit (${_selectedVehicleForEdit?.licensePlate ?? ''})';
    }
  }
}
