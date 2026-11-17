import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/services/auth_service.dart';
import '../routing/app_router.dart';

/// Top application header for the Vehicle Management System.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return ListenableBuilder(
      listenable: router,
      builder: (context, _) {
        final isMobile = Responsive.isMobile(context);

        return Container(
          height: AppConstants.headerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Sidebar Collapse / Expand Toggle
              IconButton(
                icon: Icon(
                  isMobile
                      ? Icons.menu
                      : (router.isSidebarCollapsed
                            ? Icons.menu
                            : Icons.menu_open),
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                tooltip: isMobile
                    ? 'Open Navigation Menu'
                    : (router.isSidebarCollapsed
                          ? 'Expand Navigation'
                          : 'Collapse Navigation'),
                onPressed: () {
                  if (isMobile) {
                    Scaffold.maybeOf(context)?.openDrawer();
                  } else {
                    router.toggleSidebar();
                  }
                },
              ),
              const SizedBox(width: 8),

              // Search Icon / Quick Find
              SizedBox(
                width: isMobile ? 160 : 240,
                height: 36,
                child: TextField(
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search VMS...',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.softGray,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: AppColors.corporateBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      router.navigateTo(AppScreen.vehicles);
                    }
                  },
                ),
              ),

              const Spacer(),

              // Notification Icon
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'System Notifications',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'All fleet systems operational. 0 pending alerts.',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Vertical Divider
              Container(height: 24, width: 1, color: AppColors.border),
              const SizedBox(width: 16),

              // User Profile & Avatar
              ListenableBuilder(
                listenable: AuthService.instance,
                builder: (context, _) {
                  final session = AuthService.instance.currentSession;
                  final username = session?.username ?? 'Admin';
                  final initials = username.isNotEmpty
                      ? (username.length >= 2
                            ? username.substring(0, 2).toUpperCase()
                            : username.toUpperCase())
                      : 'AD';
                  final roleDisplay = session?.displayRole ?? 'Fleet Manager';

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.deepBlue,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: AppTextStyles.tableCellBold.copyWith(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            roleDisplay,
                            style: AppTextStyles.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
