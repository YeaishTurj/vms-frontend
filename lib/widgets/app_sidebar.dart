import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../routing/app_router.dart';

/// Fixed dark corporate-blue left-side navigation sidebar for the Vehicle Management System.
class AppSidebar extends StatelessWidget {
  /// When true, renders inside a mobile Drawer instead of a fixed desktop sidebar.
  final bool isDrawer;

  const AppSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return ListenableBuilder(
      listenable: router,
      builder: (context, _) {
        final collapsed = !isDrawer && router.isSidebarCollapsed;
        final currentScreen = router.currentScreen;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isDrawer
              ? AppConstants.sidebarWidth
              : (collapsed
                    ? AppConstants.sidebarCollapsedWidth
                    : AppConstants.sidebarWidth),
          color: AppColors.sidebarBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo & App Name Header
              _buildHeader(context, collapsed),

              // Navigation Items List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  children: [
                    if (!collapsed) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 4, 12, 8),
                        child: Text(
                          'MAIN NAVIGATION',
                          style: TextStyle(
                            color: Color(0xFF90CAF9),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],

                    // 1. Dashboard
                    _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isSelected: currentScreen == AppScreen.dashboard,
                      isCollapsed: collapsed,
                      onTap: () {
                        if (isDrawer) Navigator.of(context).pop();
                        router.navigateTo(AppScreen.dashboard);
                      },
                    ),
                    const SizedBox(height: 4),

                    // 2. Vehicles
                    _SidebarItem(
                      icon: Icons.directions_car_outlined,
                      activeIcon: Icons.directions_car_rounded,
                      label: 'Vehicles',
                      isSelected:
                          currentScreen == AppScreen.vehicles ||
                          currentScreen == AppScreen.editVehicle,
                      isCollapsed: collapsed,
                      onTap: () {
                        if (isDrawer) Navigator.of(context).pop();
                        router.navigateTo(AppScreen.vehicles);
                      },
                    ),
                    const SizedBox(height: 4),

                    // 3. Register Vehicle
                    _SidebarItem(
                      icon: Icons.add_circle_outline_rounded,
                      activeIcon: Icons.add_circle_rounded,
                      label: 'Register Vehicle',
                      isSelected: currentScreen == AppScreen.registerVehicle,
                      isCollapsed: collapsed,
                      onTap: () {
                        if (isDrawer) Navigator.of(context).pop();
                        router.navigateTo(AppScreen.registerVehicle);
                      },
                    ),

                    const SizedBox(height: 16),

                    if (!collapsed) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Text(
                          'SYSTEM',
                          style: TextStyle(
                            color: Color(0xFF90CAF9),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(color: Color(0xFF285E8E), height: 16),
                      ),
                    ],

                    // Settings (Visual only)
                    _SidebarItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                      label: 'Settings',
                      isSelected: false,
                      isCollapsed: collapsed,
                      isPlaceholder: true,
                      onTap: () {
                        if (isDrawer) Navigator.of(context).pop();
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

              // Bottom Section: Collapse Toggle & Sign Out
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF285E8E), width: 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Collapse / Expand toggle button (on desktop/tablet)
                    if (!isDrawer) ...[
                      _SidebarItem(
                        icon: collapsed
                            ? Icons.chevron_right_rounded
                            : Icons.chevron_left_rounded,
                        activeIcon: collapsed
                            ? Icons.chevron_right_rounded
                            : Icons.chevron_left_rounded,
                        label: collapsed
                            ? 'Expand Sidebar'
                            : 'Collapse Sidebar',
                        isSelected: false,
                        isCollapsed: collapsed,
                        textColor: const Color(0xFF90CAF9),
                        onTap: () => router.toggleSidebar(),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Sign Out
                    _SidebarItem(
                      icon: Icons.logout_rounded,
                      activeIcon: Icons.logout_rounded,
                      label: 'Sign Out',
                      isSelected: false,
                      isCollapsed: collapsed,
                      textColor: const Color(0xFFEF9A9A),
                      onTap: () {
                        if (isDrawer) Navigator.of(context).pop();
                        router.logout();
                      },
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

  Widget _buildHeader(BuildContext context, bool collapsed) {
    return Container(
      height: AppConstants.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 14 : 18),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF285E8E), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          // Logo Icon Emblem
          Tooltip(
            message: collapsed ? AppConstants.appName : '',
            waitDuration: const Duration(milliseconds: 300),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.corporateBlue,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),

          if (!collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appShortName,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'FLEET MANAGEMENT',
                    style: TextStyle(
                      color: Color(0xFF90CAF9),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isDrawer)
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                tooltip: 'Close Menu',
                onPressed: () => Navigator.of(context).pop(),
              ),
          ],
        ],
      ),
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
    final iconColor = isSelected
        ? AppColors.white
        : (textColor ?? const Color(0xFFCBD5E1));

    final itemWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.sidebarHover,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.corporateBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(isSelected ? activeIcon : icon, size: 20, color: iconColor),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.subtitle.copyWith(
                      color: isSelected ? activeTextColor : inactiveTextColor,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPlaceholder)
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: Color(0xFF90CAF9),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(
        message: label,
        preferBelow: false,
        verticalOffset: 0,
        margin: const EdgeInsets.only(left: 68),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        waitDuration: const Duration(milliseconds: 100),
        child: itemWidget,
      );
    }

    return itemWidget;
  }
}
