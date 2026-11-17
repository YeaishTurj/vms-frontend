import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_vehicle_data.dart';
import '../../routing/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

/// Clean corporate Dashboard Screen displaying fleet summary cards and quick overview.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = MockVehicleData();
    final router = AppRouter();

    return ListenableBuilder(
      listenable: mockData,
      builder: (context, _) {
        final totalCount = mockData.totalCount;
        final activeCount = mockData.activeCount;
        final inactiveCount = mockData.inactiveCount;
        final maintenanceCount = mockData.maintenanceCount;
        final recentVehicles = mockData.vehicles.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header: Title (Top Left) & Main Action (Top Right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard',
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Overview of enterprise fleet status and operational readiness.',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                  AppButton(
                    label: 'Register Vehicle',
                    icon: Icons.add_box_rounded,
                    variant: AppButtonVariant.primary,
                    onPressed: () => router.navigateTo(AppScreen.registerVehicle),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Cards Grid (Total, Active, Inactive, Under Maintenance)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 900;
                  final cardWidth = isDesktop
                      ? (constraints.maxWidth - (3 * 16)) / 4
                      : (constraints.maxWidth - 16) / 2;

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
                        bgColor: const Color(0xFFE9F1F8),
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
                        title: 'Vehicles Under Maintenance',
                        count: maintenanceCount,
                        icon: Icons.build_circle_outlined,
                        color: AppColors.amber,
                        bgColor: AppColors.amberBg,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Recent Fleet Activity Section
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Fleet Vehicles',
                            style: AppTextStyles.h3,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.corporateBlue),
                            label: const Text(
                              'View All Vehicles',
                              style: TextStyle(color: AppColors.corporateBlue, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => router.navigateTo(AppScreen.vehicles),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Table View
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('VEHICLE NUMBER')),
                          DataColumn(label: Text('COMPANY')),
                          DataColumn(label: Text('TYPE')),
                          DataColumn(label: Text('BRAND & MODEL')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: recentVehicles.map((vehicle) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  vehicle.vehicleNumber,
                                  style: AppTextStyles.tableCellBold.copyWith(color: AppColors.deepBlue),
                                ),
                              ),
                              DataCell(Text(vehicle.company, style: AppTextStyles.tableCell)),
                              DataCell(Text(vehicle.type, style: AppTextStyles.tableCell)),
                              DataCell(Text('${vehicle.brand} ${vehicle.model}', style: AppTextStyles.tableCell)),
                              DataCell(StatusBadge(status: vehicle.status)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.corporateBlue),
                                      tooltip: 'Edit Vehicle',
                                      onPressed: () => router.navigateToEditVehicle(vehicle),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
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
