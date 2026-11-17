import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/models/vehicle.dart';
import 'package:vms_frontend/routing/app_router.dart';

void main() {
  group('AppRouter Navigation & State Tests', () {
    late AppRouter router;

    setUp(() {
      router = AppRouter();
      router.setAuthenticated(true);
      router.navigateTo(AppScreen.dashboard);
    });

    test('Initial screen defaults to Dashboard when authenticated', () {
      expect(router.currentScreen, AppScreen.dashboard);
      expect(router.screenTitle, 'Dashboard');
    });

    test(
      'Navigating between screens updates currentScreen and screenTitle',
      () {
        router.navigateTo(AppScreen.vehicles);
        expect(router.currentScreen, AppScreen.vehicles);
        expect(router.screenTitle, 'Vehicles');

        router.navigateTo(AppScreen.registerVehicle);
        expect(router.currentScreen, AppScreen.registerVehicle);
        expect(router.screenTitle, 'Register Vehicle');

        const sampleVehicle = Vehicle(
          id: 'vms-edit-test',
          vehicleNumber: 'DM-EDIT-01',
          company: 'Transit Co',
          type: 'Sedan',
          brand: 'Honda',
          model: 'Civic',
          status: VehicleStatus.active,
        );

        router.navigateToEditVehicle(sampleVehicle);
        expect(router.currentScreen, AppScreen.editVehicle);
        expect(router.selectedVehicleForEdit, sampleVehicle);
        expect(router.screenTitle, 'Edit Vehicle');

        // Navigating away clears selectedVehicleForEdit
        router.navigateTo(AppScreen.dashboard);
        expect(router.selectedVehicleForEdit, isNull);
      },
    );

    test('Sidebar collapse toggle and setter behave correctly', () {
      final initialCollapsed = router.isSidebarCollapsed;

      router.toggleSidebar();
      expect(router.isSidebarCollapsed, !initialCollapsed);

      router.setSidebarCollapsed(true);
      expect(router.isSidebarCollapsed, isTrue);

      router.setSidebarCollapsed(false);
      expect(router.isSidebarCollapsed, isFalse);
    });

    test('Authentication state transition toggles login and dashboard', () {
      router.setAuthenticated(false);
      expect(router.isAuthenticated, isFalse);
      expect(router.currentScreen, AppScreen.login);
      expect(router.screenTitle, 'Sign In');

      router.setAuthenticated(true);
      expect(router.isAuthenticated, isTrue);
      expect(router.currentScreen, AppScreen.dashboard);
    });

    test('Unauthenticated navigation attempts are guarded and redirected to login', () {
      router.setAuthenticated(false);
      expect(router.isAuthenticated, isFalse);

      router.navigateTo(AppScreen.vehicles);
      expect(router.currentScreen, AppScreen.login);

      const sampleVehicle = Vehicle(
        id: 'vms-edit-test',
        vehicleNumber: 'DM-EDIT-01',
        company: 'Transit Co',
        type: 'Sedan',
        brand: 'Honda',
        model: 'Civic',
        status: VehicleStatus.active,
      );
      router.navigateToEditVehicle(sampleVehicle);
      expect(router.currentScreen, AppScreen.login);
    });

    test('logout clears authentication and resets to login screen', () async {
      expect(router.isAuthenticated, isTrue);

      await router.logout();

      expect(router.isAuthenticated, isFalse);
      expect(router.currentScreen, AppScreen.login);
    });
  });
}
