import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../routing/app_router.dart';

/// Fixed left-side navigation drawer styled for corporate desktop view.
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
          width: collapsed ? AppConstants.sidebarCollapsedWidth : AppConstants.sidebarWidth,
          color: AppColors.sidebarBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand / Logo Section
              Container(
                height: AppConstants.headerHeight,
                padding: EdgeInsets.symmetric(horizontal: collapsed ? 16 : 20),
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        color: Colors.white,
                        size: 20,
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
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Fleet Intelligence',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.sidebarText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Navigation Links
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _SidebarNavItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isSelected: currentScreen == AppScreen.dashboard,
                      isCollapsed: collapsed,
                      onTap: () => router.navigateTo(AppScreen.dashboard),
                    ),
                    const SizedBox(height: 4),
                    _SidebarNavItem(
                      icon: Icons.directions_car_outlined,
                      activeIcon: Icons.directions_car_rounded,
                      label: 'Vehicles',
                      isSelected: currentScreen == AppScreen.vehicles ||
                          currentScreen == AppScreen.vehicleCreate ||
                          currentScreen == AppScreen.vehicleEdit,
                      isCollapsed: collapsed,
                      onTap: () => router.navigateTo(AppScreen.vehicles),
                    ),
                    const SizedBox(height: 4),
                    _SidebarNavItem(
                      icon: Icons.add_circle_outline_rounded,
                      activeIcon: Icons.add_circle_rounded,
                      label: 'Add Vehicle',
                      isSelected: currentScreen == AppScreen.vehicleCreate,
                      isCollapsed: collapsed,
                      onTap: () => router.navigateTo(AppScreen.vehicleCreate),
                    ),
                    const SizedBox(height: 16),
                    if (!collapsed)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text(
                          'OPERATIONS',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    _SidebarNavItem(
                      icon: Icons.build_circle_outlined,
                      activeIcon: Icons.build_circle,
                      label: 'Maintenance',
                      isSelected: false,
                      isCollapsed: collapsed,
                      badge: 'Soon',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Maintenance module will be activated in upcoming sprint.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    _SidebarNavItem(
                      icon: Icons.badge_outlined,
                      activeIcon: Icons.badge,
                      label: 'Drivers',
                      isSelected: false,
                      isCollapsed: collapsed,
                      badge: 'Soon',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Driver directory module will be activated in upcoming sprint.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    _SidebarNavItem(
                      icon: Icons.bar_chart_rounded,
                      activeIcon: Icons.bar_chart,
                      label: 'Reports',
                      isSelected: false,
                      isCollapsed: collapsed,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytics & reports will be activated in upcoming sprint.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Section: Sign Out / Version
              Container(
                padding: EdgeInsets.all(collapsed ? 12 : 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF1E293B), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    _SidebarNavItem(
                      icon: Icons.logout_rounded,
                      activeIcon: Icons.logout_rounded,
                      label: 'Sign Out',
                      isSelected: false,
                      isCollapsed: collapsed,
                      textColor: const Color(0xFFF87171),
                      onTap: () => router.navigateTo(AppScreen.login),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          AppConstants.appVersion,
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF475569),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;
  final String? badge;
  final Color? textColor;

  const _SidebarNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
    this.badge,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = textColor ?? AppColors.sidebarTextActive;
    final inactiveColor = textColor ?? AppColors.sidebarText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 12 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.sidebarSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? const Border(
                    left: BorderSide(color: AppColors.primaryLight, width: 3),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment:
                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected ? AppColors.primaryLight : inactiveColor,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.subtitle.copyWith(
                      color: isSelected ? activeColor : inactiveColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
