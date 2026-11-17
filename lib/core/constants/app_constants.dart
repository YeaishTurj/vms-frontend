/// Global Constants for the Vehicle Management System.
class AppConstants {
  AppConstants._();

  // App Branding
  static const String appName = 'Vehicle Management System';
  static const String appShortName = 'VMS Fleet';
  static const String appVersion = 'v1.0.0-foundation';

  // Layout Dimensions (Desktop-first)
  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const double headerHeight = 64.0;
  static const double defaultPadding = 24.0;
  static const double cardBorderRadius = 8.0;
  static const double inputBorderRadius = 6.0;

  // Responsive Breakpoints
  static const double desktopBreakpoint = 1024.0;
  static const double tabletBreakpoint = 768.0;

  // Route Identifiers
  static const String routeDashboard = '/dashboard';
  static const String routeVehicles = '/vehicles';
  static const String routeVehicleCreate = '/vehicles/new';
  static const String routeVehicleEdit = '/vehicles/edit';
  static const String routeLogin = '/login';
}
