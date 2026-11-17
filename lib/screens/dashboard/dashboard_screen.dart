import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_vehicle_data.dart';
import '../../models/vehicle.dart';
import '../../routing/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

/// Executive Overview Fleet Dashboard.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = MockVehicleData();
    final router = AppRouter();

    return ListenableBuilder(
      listenable: mockData,
      builder: (context, _) {
        final totalVehicles = mockData.totalVehicles;
        final activeVehicles = mockData.countActive;
        final inServiceVehicles = mockData.countInService;
        final maintenanceVehicles = mockData.countMaintenance;
        final totalMileage = mockData.totalFleetMileage;
        final recentVehicles = mockData.vehicles.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Action Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fleet Operations Command',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time operational status, maintenance readiness, and vehicle assignments.',
                        style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Register Vehicle',
                    icon: Icons.add,
                    variant: AppButtonVariant.primary,
                    onPressed: () => router.navigateTo(AppScreen.vehicleCreate),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'View Inventory',
                    icon: Icons.list_alt_rounded,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => router.navigateTo(AppScreen.vehicles),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // KPI Metric Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final cardWidth = isWide
                      ? (constraints.maxWidth - (3 * 16)) / 4
                      : (constraints.maxWidth - 16) / 2;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MetricCard(
                        width: cardWidth,
                        title: 'Total Fleet',
                        value: '$totalVehicles',
                        unit: 'Vehicles registered',
                        icon: Icons.directions_car_filled,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primaryContainer,
                      ),
                      _MetricCard(
                        width: cardWidth,
                        title: 'Ready / Active',
                        value: '$activeVehicles',
                        unit: 'Available for dispatch',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: AppColors.statusActive,
                        iconBg: AppColors.statusActiveBg,
                      ),
                      _MetricCard(
                        width: cardWidth,
                        title: 'In Service',
                        value: '$inServiceVehicles',
                        unit: 'Currently on route',
                        icon: Icons.near_me_outlined,
                        iconColor: AppColors.statusInService,
                        iconBg: AppColors.statusInServiceBg,
                      ),
                      _MetricCard(
                        width: cardWidth,
                        title: 'In Maintenance',
                        value: '$maintenanceVehicles',
                        unit: 'Service bay inspection',
                        icon: Icons.build_circle_outlined,
                        iconColor: AppColors.statusMaintenance,
                        iconBg: AppColors.statusMaintenanceBg,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Summary Banner: Total Mileage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.speed_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aggregate Fleet Odometer', style: AppTextStyles.subtitle),
                        Text(
                          '${_formatNumber(totalMileage)} km recorded across all operational units',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '100% Telemetry Active',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Fleet Units Section
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          const Text('Recently Updated Fleet Units', style: AppTextStyles.h3),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: const Text('View All'),
                            onPressed: () => router.navigateTo(AppScreen.vehicles),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('VEHICLE / ID')),
                          DataColumn(label: Text('PLATE NUMBER')),
                          DataColumn(label: Text('TYPE')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ODOMETER')),
                          DataColumn(label: Text('ASSIGNED DRIVER')),
                          DataColumn(label: Text('ACTION')),
                        ],
                        rows: recentVehicles.map((vehicle) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(vehicle.displayName, style: AppTextStyles.tableCellBold),
                                    Text(vehicle.id, style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              DataCell(Text(vehicle.licensePlate, style: AppTextStyles.tableCell)),
                              DataCell(Text(vehicle.type.label, style: AppTextStyles.tableCell)),
                              DataCell(StatusBadge(status: vehicle.status)),
                              DataCell(Text('${_formatNumber(vehicle.mileage)} km', style: AppTextStyles.tableCell)),
                              DataCell(Text(vehicle.assignedDriver, style: AppTextStyles.tableCell)),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                  tooltip: 'Edit Vehicle',
                                  onPressed: () => router.navigateToEditVehicle(vehicle),
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

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class _MetricCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _MetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
