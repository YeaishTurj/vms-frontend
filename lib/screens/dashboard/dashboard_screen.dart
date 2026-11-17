import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/vehicle.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../routing/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

/// Clean corporate Dashboard Screen displaying live fleet summary cards and recent activity.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repository = VehicleRepository();
      repository.loadDashboardMetrics();
      repository.fetchVehicles(page: 0, size: 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = VehicleRepository();
    final router = AppRouter();
    final isMobile = Responsive.isMobile(context);

    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final totalCount = repository.totalCount;
        final activeCount = repository.activeCount;
        final inactiveCount = repository.inactiveCount;
        final maintenanceCount = repository.maintenanceCount;
        final recentVehicles = repository.vehicles.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header: Title (Top Left) & Main Action (Top Right)
              _buildHeader(router, isMobile),
              const SizedBox(height: 24),

              // Summary Cards Grid (Total, Active, Inactive, Under Maintenance)
              _buildSummaryGrid(
                totalCount: totalCount,
                activeCount: activeCount,
                inactiveCount: inactiveCount,
                maintenanceCount: maintenanceCount,
              ),
              const SizedBox(height: 24),

              // Recent Fleet Activity Section
              _buildRecentVehiclesCard(context, recentVehicles, router),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppRouter router, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          const Text(
            'Overview of enterprise fleet status and operational readiness.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Register Vehicle',
            icon: Icons.add_rounded,
            variant: AppButtonVariant.primary,
            fullWidth: true,
            onPressed: () => router.navigateTo(AppScreen.registerVehicle),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: AppTextStyles.h1),
            SizedBox(height: 4),
            Text(
              'Overview of enterprise fleet status and operational readiness.',
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
        AppButton(
          label: 'Register Vehicle',
          icon: Icons.add_rounded,
          variant: AppButtonVariant.primary,
          onPressed: () => router.navigateTo(AppScreen.registerVehicle),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid({
    required int totalCount,
    required int activeCount,
    required int inactiveCount,
    required int maintenanceCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet =
            constraints.maxWidth >= 540 && constraints.maxWidth < 900;

        double cardWidth;
        if (isDesktop) {
          cardWidth = (constraints.maxWidth - (3 * 16)) / 4;
        } else if (isTablet) {
          cardWidth = (constraints.maxWidth - 16) / 2;
        } else {
          cardWidth = constraints.maxWidth;
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _SummaryCard(
              width: cardWidth,
              title: 'Total Vehicles',
              count: totalCount,
              icon: Icons.directions_car_filled_rounded,
              color: AppColors.deepBlue,
              bgColor: AppColors.plateBg,
            ),
            _SummaryCard(
              width: cardWidth,
              title: 'Active Vehicles',
              count: activeCount,
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.green,
              bgColor: AppColors.greenBg,
            ),
            _SummaryCard(
              width: cardWidth,
              title: 'Inactive Vehicles',
              count: inactiveCount,
              icon: Icons.cancel_outlined,
              color: AppColors.red,
              bgColor: AppColors.redBg,
            ),
            _SummaryCard(
              width: cardWidth,
              title: 'Under Maintenance',
              count: maintenanceCount,
              icon: Icons.build_circle_outlined,
              color: AppColors.amber,
              bgColor: AppColors.amberBg,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentVehiclesCard(
    BuildContext context,
    List<Vehicle> recentVehicles,
    AppRouter router,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header with Title and View All Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.plateBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 16,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Recent Fleet Vehicles',
                      style: AppTextStyles.h3,
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.corporateBlue,
                  ),
                  label: const Text(
                    'View All Vehicles',
                    style: TextStyle(
                      color: AppColors.corporateBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () => router.navigateTo(AppScreen.vehicles),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),

          // Standardized Data Table
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth < 840
                        ? 840
                        : constraints.maxWidth,
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.tableHeaderBg,
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return AppColors.tableHeaderBg;
                      }
                      return AppColors.white;
                    }),
                    headingRowHeight: 48,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 60,
                    horizontalMargin: 20,
                    columnSpacing: 24,
                    dividerThickness: 1,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'VEHICLE NUMBER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'COMPANY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'TYPE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'BRAND & MODEL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'STATUS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'ACTIONS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                    rows: recentVehicles.map((vehicle) {
                      return DataRow(
                        cells: [
                          // 1. Highlighted Vehicle Number Badge
                          DataCell(
                            _buildVehicleNumberBadge(vehicle.vehicleNumber),
                          ),
                          // 2. Company
                          DataCell(
                            Text(
                              vehicle.company,
                              style: AppTextStyles.tableCellBold.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          // 3. Type Pill
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                vehicle.type,
                                style: const TextStyle(
                                  color: AppColors.charcoal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          // 4. Brand & Model
                          DataCell(
                            Text(
                              '${vehicle.brand} ${vehicle.model}',
                              style: AppTextStyles.tableCell.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ),
                          // 5. Semantic Status Badge
                          DataCell(StatusBadge(status: vehicle.status)),
                          // 6. Action Button (Edit)
                          DataCell(
                            Tooltip(
                              message: 'Edit Vehicle',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () =>
                                      router.navigateToEditVehicle(vehicle),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.actionEditBg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.actionEditBorder,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: AppColors.corporateBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleNumberBadge(String vehicleNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.plateBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.plateBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_car_rounded,
            size: 14,
            color: AppColors.deepBlue,
          ),
          const SizedBox(width: 6),
          Text(
            vehicleNumber,
            style: const TextStyle(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double width;
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SummaryCard({
    required this.width,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: AppTextStyles.h1.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
