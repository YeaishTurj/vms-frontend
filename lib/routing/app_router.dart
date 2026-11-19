import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../data/models/auth_session.dart';
import '../data/services/auth_service.dart';
import '../models/vehicle.dart';

/// Available screen identifiers in the VMS single-page desktop navigation.
enum AppScreen { login, dashboard, vehicles, registerVehicle, editVehicle }

/// Central stateful navigation controller for VMS.
class AppRouter extends ChangeNotifier {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;

  AppRouter._internal() {
    _authService = AuthService.instance;
    _authService.addListener(_onAuthChanged);
    _currentScreen = _authService.isAuthenticated
        ? AppScreen.dashboard
        : AppScreen.login;
  }

  late final AuthService _authService;
  AppScreen _currentScreen = AppScreen.login;
  Vehicle? _selectedVehicleForEdit;
  bool _isSidebarCollapsed = false;
  String? _globalSearchQuery;

  void _onAuthChanged() {
    if (!_authService.isAuthenticated) {
      if (_currentScreen != AppScreen.login) {
        _currentScreen = AppScreen.login;
        _selectedVehicleForEdit = null;
        _globalSearchQuery = null;
        notifyListeners();
      }
    }
  }

  AppScreen get currentScreen => _currentScreen;
  Vehicle? get selectedVehicleForEdit => _selectedVehicleForEdit;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get globalSearchQuery => _globalSearchQuery;

  /// Sets a global search query to pass to the vehicle list screen.
  void setGlobalSearchQuery(String? query) {
    _globalSearchQuery = query;
    notifyListeners();
  }

  /// Clears the global search query after consumption.
  void clearGlobalSearchQuery() {
    _globalSearchQuery = null;
  }

  /// Navigates to a target screen with authentication guard.
  void navigateTo(AppScreen screen) {
    if (!isAuthenticated && screen != AppScreen.login) {
      _currentScreen = AppScreen.login;
      _selectedVehicleForEdit = null;
      notifyListeners();
      return;
    }
    _currentScreen = screen;
    if (screen != AppScreen.editVehicle) {
      _selectedVehicleForEdit = null;
    }
    notifyListeners();
  }

  /// Navigates to the vehicle edit screen with authentication guard.
  void navigateToEditVehicle(Vehicle vehicle) {
    if (!isAuthenticated) {
      _currentScreen = AppScreen.login;
      _selectedVehicleForEdit = null;
      notifyListeners();
      return;
    }
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

  /// Updates authentication state.
  /// When setting to true in tests or mock setups, establishes a valid session.
  /// When setting to false, purges session via AuthService.logout().
  void setAuthenticated(bool value) {
    if (!value) {
      _authService.logout();
      _currentScreen = AppScreen.login;
    } else {
      if (!_authService.isAuthenticated) {
        _authService.setSession(
          AuthSession(
            token: 'authenticated-session-token',
            type: 'Bearer',
            expiresAt: DateTime.now().add(const Duration(hours: 24)),
            username: AppConstants.demoUsername,
            roles: const ['ROLE_ADMIN'],
          ),
        );
      }
      _currentScreen = AppScreen.dashboard;
    }
    notifyListeners();
  }

  /// Logs out the user and navigates to the login screen.
  Future<void> logout() async {
    await _authService.logout();
    _currentScreen = AppScreen.login;
    _selectedVehicleForEdit = null;
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
