import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_vehicle_data.dart';
import '../../models/vehicle.dart';
import '../../routing/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/status_badge.dart';

/// Full-featured data table view for the fleet vehicle registry.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  VehicleStatus? _statusFilter;
  VehicleType? _typeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockData = MockVehicleData();
    final router = AppRouter();

    return ListenableBuilder(
      listenable: mockData,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();

        final filteredVehicles = mockData.vehicles.where((v) {
          final matchesQuery = query.isEmpty ||
              v.licensePlate.toLowerCase().contains(query) ||
              v.make.toLowerCase().contains(query) ||
              v.model.toLowerCase().contains(query) ||
              v.vin.toLowerCase().contains(query) ||
              v.id.toLowerCase().contains(query) ||
              v.assignedDriver.toLowerCase().contains(query);

          final matchesStatus =
              _statusFilter == null || v.status == _statusFilter;
          final matchesType = _typeFilter == null || v.type == _typeFilter;

          return matchesQuery && matchesStatus && matchesType;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vehicle Inventory Directory', style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text(
                        'Total units registered: ${mockData.totalVehicles} | Displaying: ${filteredVehicles.length}',
                        style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Register New Vehicle',
                    icon: Icons.add_rounded,
                    variant: AppButtonVariant.primary,
                    onPressed: () => router.navigateTo(AppScreen.vehicleCreate),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter & Search Bar Toolbar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search Input
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search by Plate, Make, Model, VIN, or Driver...',
                          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),

                    // Status Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.inputBorder, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<VehicleStatus?>(
                          value: _statusFilter,
                          hint: const Text('Status: All', style: AppTextStyles.bodyMedium),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Status: All', style: AppTextStyles.bodyMedium),
                            ),
                            ...VehicleStatus.values.map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text('Status: ${s.label}', style: AppTextStyles.bodyMedium),
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() => _statusFilter = val),
                        ),
                      ),
                    ),

                    // Type Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.inputBorder, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<VehicleType?>(
                          value: _typeFilter,
                          hint: const Text('Type: All', style: AppTextStyles.bodyMedium),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Type: All', style: AppTextStyles.bodyMedium),
                            ),
                            ...VehicleType.values.map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text('Type: ${t.label}', style: AppTextStyles.bodyMedium),
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() => _typeFilter = val),
                        ),
                      ),
                    ),

                    // Reset Filters
                    if (_searchController.text.isNotEmpty ||
                        _statusFilter != null ||
                        _typeFilter != null)
                      TextButton.icon(
                        icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                        label: const Text('Clear Filters'),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _statusFilter = null;
                            _typeFilter = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data Table Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: filteredVehicles.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text('No vehicles match your search criteria', style: AppTextStyles.h3),
                            const SizedBox(height: 6),
                            Text(
                              'Try adjusting your search query or reset the filters.',
                              style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('FLEET ID')),
                            DataColumn(label: Text('REGISTRATION')),
                            DataColumn(label: Text('MAKE & MODEL')),
                            DataColumn(label: Text('YEAR / TYPE')),
                            DataColumn(label: Text('FUEL')),
                            DataColumn(label: Text('ODOMETER')),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('DRIVER')),
                            DataColumn(label: Text('ACTIONS')),
                          ],
                          rows: filteredVehicles.map((vehicle) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    vehicle.id,
                                    style: AppTextStyles.tableCellBold.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(vehicle.licensePlate, style: AppTextStyles.tableCellBold),
                                      Text('VIN: ${vehicle.vin.substring(0, 10)}...', style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text('${vehicle.make} ${vehicle.model}', style: AppTextStyles.tableCell),
                                ),
                                DataCell(
                                  Text('${vehicle.year} • ${vehicle.type.label}', style: AppTextStyles.tableCell),
                                ),
                                DataCell(
                                  Text(vehicle.fuelType.label, style: AppTextStyles.tableCell),
                                ),
                                DataCell(
                                  Text('${_formatNumber(vehicle.mileage)} km', style: AppTextStyles.tableCell),
                                ),
                                DataCell(
                                  StatusBadge(status: vehicle.status),
                                ),
                                DataCell(
                                  Text(vehicle.assignedDriver, style: AppTextStyles.tableCell),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                        tooltip: 'Edit Vehicle',
                                        onPressed: () => router.navigateToEditVehicle(vehicle),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.statusInactive),
                                        tooltip: 'Decommission Vehicle',
                                        onPressed: () async {
                                          final confirmed = await ConfirmationDialog.show(
                                            context,
                                            title: 'Decommission Vehicle',
                                            message:
                                                'Are you sure you want to remove ${vehicle.displayName} (${vehicle.licensePlate}) from the active fleet inventory?',
                                            confirmLabel: 'Delete Vehicle',
                                            isDestructive: true,
                                          );
                                          if (confirmed) {
                                            mockData.deleteVehicle(vehicle.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Vehicle ${vehicle.id} removed successfully.'),
                                                  backgroundColor: AppColors.textPrimary,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
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
