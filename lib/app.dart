import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/vehicles/vehicle_form_screen.dart';
import 'screens/vehicles/vehicle_list_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/app_sidebar.dart';

/// Root Application Widget configuring theme and navigation shell.
class VmsApp extends StatelessWidget {
  const VmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}

/// Fixed Shell containing the Sidebar, Header, and Dynamic Workspace area.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return ListenableBuilder(
      listenable: router,
      builder: (context, _) {
        // Full screen login without application shell
        if (router.currentScreen == AppScreen.login) {
          return const LoginScreen();
        }

        return Scaffold(
          body: Row(
            children: [
              // Fixed Corporate Navigation Sidebar
              const AppSidebar(),

              // Right Main Canvas (Header + Content Area)
              Expanded(
                child: Column(
                  children: [
                    const AppHeader(),
                    Expanded(
                      child: _buildCurrentScreen(router),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen(AppRouter router) {
    switch (router.currentScreen) {
      case AppScreen.login:
        return const LoginScreen();
      case AppScreen.dashboard:
        return const DashboardScreen();
      case AppScreen.vehicles:
        return const VehicleListScreen();
      case AppScreen.vehicleCreate:
        return const VehicleFormScreen();
      case AppScreen.vehicleEdit:
        return VehicleFormScreen(initialVehicle: router.selectedVehicleForEdit);
    }
  }
}
