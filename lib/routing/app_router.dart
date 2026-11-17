import 'package:flutter/material.dart';

import '../models/vehicle.dart';

/// Available screen identifiers in the VMS single-page desktop navigation.
enum AppScreen { login, dashboard, vehicles, registerVehicle, editVehicle }

/// Central stateful navigation controller for VMS.
class AppRouter extends ChangeNotifier {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;

  AppRouter._internal();

  AppScreen _currentScreen = AppScreen.dashboard;
  Vehicle? _selectedVehicleForEdit;
  bool _isSidebarCollapsed = false;
  bool _isAuthenticated = true;

  AppScreen get currentScreen => _currentScreen;
  Vehicle? get selectedVehicleForEdit => _selectedVehicleForEdit;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  bool get isAuthenticated => _isAuthenticated;

  void navigateTo(AppScreen screen) {
    _currentScreen = screen;
    if (screen != AppScreen.editVehicle) {
      _selectedVehicleForEdit = null;
    }
    notifyListeners();
  }

  void navigateToEditVehicle(Vehicle vehicle) {
    _selectedVehicleForEdit = vehicle;
    _currentScreen = AppScreen.editVehicle;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void setSidebarCollapsed(bool value) {
    if (_isSidebarCollapsed != value) {
      _isSidebarCollapsed = value;
      notifyListeners();
    }
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    if (!value) {
      _currentScreen = AppScreen.login;
    } else {
      _currentScreen = AppScreen.dashboard;
    }
    notifyListeners();
  }

  String get screenTitle {
    switch (_currentScreen) {
      case AppScreen.login:
        return 'Sign In';
      case AppScreen.dashboard:
        return 'Dashboard';
      case AppScreen.vehicles:
        return 'Vehicles';
      case AppScreen.registerVehicle:
        return 'Register Vehicle';
      case AppScreen.editVehicle:
        return 'Edit Vehicle';
    }
  }
}
