import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../routing/app_router.dart';

/// Fixed left-side navigation sidebar for the Vehicle Management System.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return ListenableBuilder(
      listenable: router,
      builder: (context, _) {
        final collapsed = router.isSidebarCollapsed;
        final currentScreen = router.currentScreen;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: collapsed
              ? AppConstants.sidebarCollapsedWidth
              : AppConstants.sidebarWidth,
          color: AppColors.sidebarBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo & App Name Header
              Container(
                height: AppConstants.headerHeight,
                padding: EdgeInsets.symmetric(horizontal: collapsed ? 16 : 20),
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF285E8E), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.corporateBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppConstants.appShortName,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Navigation Items List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isSelected: currentScreen == AppScreen.dashboard,
                      isCollapsed: collapsed,
                      onTap: () => router.navigateTo(AppScreen.dashboard),
                    ),
                    const SizedBox(height: 4),
                    _SidebarItem(
                      icon: Icons.directions_car_outlined,
                      activeIcon: Icons.directions_car_rounded,
                      label: 'Vehicles',
                      isSelected:
                          currentScreen == AppScreen.vehicles ||
                          currentScreen == AppScreen.editVehicle,
                      isCollapsed: collapsed,
                      onTap: () => router.navigateTo(AppScreen.vehicles),
                    ),
                    const SizedBox(height: 4),
                    _SidebarItem(
                      icon: Icons.add_box_outlined,
                      activeIcon: Icons.add_box_rounded,
                      label: 'Register Vehicle',
                      isSelected: currentScreen == AppScreen.registerVehicle,
                      isCollapsed: collapsed,
                      onTap: () => router.navigateTo(AppScreen.registerVehicle),
                    ),
                    const SizedBox(height: 4),
                    _SidebarItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      label: 'Settings',
                      isSelected: false,
                      isCollapsed: collapsed,
                      isPlaceholder: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Settings navigation item (Visual reference only).',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Section: Sign Out
              Container(
                padding: EdgeInsets.all(collapsed ? 12 : 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF285E8E), width: 1),
                  ),
                ),
                child: _SidebarItem(
                  icon: Icons.logout_rounded,
                  activeIcon: Icons.logout_rounded,
                  label: 'Sign Out',
                  isSelected: false,
                  isCollapsed: collapsed,
                  textColor: const Color(0xFFEF9A9A),
                  onTap: () => router.setAuthenticated(false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;
  final bool isPlaceholder;
  final Color? textColor;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
    this.isPlaceholder = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeTextColor = textColor ?? AppColors.sidebarTextActive;
    final inactiveTextColor = textColor ?? AppColors.sidebarText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppColors.sidebarHover,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 12 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.sidebarActiveItem
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected ? AppColors.white : inactiveTextColor,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.subtitle.copyWith(
                      color: isSelected ? activeTextColor : inactiveTextColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPlaceholder)
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: Color(0xFF9CA3AF),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
