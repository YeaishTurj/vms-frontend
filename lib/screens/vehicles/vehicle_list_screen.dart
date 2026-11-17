import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_vehicle_data.dart';
import '../../models/vehicle.dart';
import '../../routing/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

/// Full-featured, responsive vehicle list screen with search, filters, pagination, and CRUD actions.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  VehicleStatus? _statusFilter;
  String? _typeFilter;

  // Pagination state
  int _currentPage = 1;
  int _rowsPerPage = 8;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = null;
      _typeFilter = null;
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mockData = MockVehicleData();
    final router = AppRouter();

    return ListenableBuilder(
      listenable: mockData,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();

        // 1. Filter records
        final filteredList = mockData.vehicles.where((v) {
          final matchesQuery = query.isEmpty ||
              v.vehicleNumber.toLowerCase().contains(query) ||
              v.company.toLowerCase().contains(query) ||
              v.brand.toLowerCase().contains(query) ||
              v.model.toLowerCase().contains(query);

          final matchesStatus =
              _statusFilter == null || v.status == _statusFilter;
          final matchesType =
              _typeFilter == null || v.type.toLowerCase() == _typeFilter!.toLowerCase();

          return matchesQuery && matchesStatus && matchesType;
        }).toList();

        // 2. Pagination calculations
        final totalRecords = filteredList.length;
        final totalPages = (totalRecords / _rowsPerPage).ceil().clamp(1, 9999);
        if (_currentPage > totalPages) {
          _currentPage = totalPages;
        }

        final startIndex = (_currentPage - 1) * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage).clamp(0, totalRecords);
        final paginatedList = totalRecords > 0
            ? filteredList.sublist(startIndex, endIndex)
            : <Vehicle>[];

        final hasActiveFilters = query.isNotEmpty || _statusFilter != null || _typeFilter != null;

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
                      const Text('Vehicles', style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text(
                        'Manage, search and inspect all registered enterprise vehicles.',
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
              const SizedBox(height: 20),

              // Filter & Search Toolbar Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search Field
                    SizedBox(
                      width: 320,
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() => _currentPage = 1),
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search by Number, Company, Brand, Model...',
                          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _currentPage = 1);
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),

                    // Status Filter Dropdown
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border, width: 1),
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
                          onChanged: (val) {
                            setState(() {
                              _statusFilter = val;
                              _currentPage = 1;
                            });
                          },
                        ),
                      ),
                    ),

                    // Type Filter Dropdown
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _typeFilter,
                          hint: const Text('Type: All', style: AppTextStyles.bodyMedium),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Type: All', style: AppTextStyles.bodyMedium),
                            ),
                            ...Vehicle.commonTypes.map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text('Type: $t', style: AppTextStyles.bodyMedium),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _typeFilter = val;
                              _currentPage = 1;
                            });
                          },
                        ),
                      ),
                    ),

                    // Clear Filters Action
                    if (hasActiveFilters)
                      TextButton.icon(
                        icon: const Icon(Icons.filter_alt_off_outlined, size: 16, color: AppColors.red),
                        label: const Text(
                          'Clear Filters',
                          style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _clearFilters,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Table Content Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: totalRecords == 0
                    ? EmptyState(
                        icon: Icons.search_off_rounded,
                        title: hasActiveFilters ? 'No Matching Vehicles' : 'No Vehicles Found',
                        description: hasActiveFilters
                            ? 'No vehicle records matched your search query or filter options.'
                            : 'There are currently no vehicles registered in the system.',
                        actionLabel: hasActiveFilters ? 'Reset Filters' : 'Register Vehicle',
                        onAction: hasActiveFilters
                            ? _clearFilters
                            : () => router.navigateTo(AppScreen.registerVehicle),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('VEHICLE NUMBER')),
                                DataColumn(label: Text('COMPANY')),
                                DataColumn(label: Text('TYPE')),
                                DataColumn(label: Text('BRAND')),
                                DataColumn(label: Text('MODEL')),
                                DataColumn(label: Text('STATUS')),
                                DataColumn(label: Text('ACTIONS')),
                              ],
                              rows: paginatedList.map((vehicle) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        vehicle.vehicleNumber,
                                        style: AppTextStyles.tableCellBold.copyWith(
                                          color: AppColors.deepBlue,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(vehicle.company, style: AppTextStyles.tableCell)),
                                    DataCell(Text(vehicle.type, style: AppTextStyles.tableCell)),
                                    DataCell(Text(vehicle.brand, style: AppTextStyles.tableCell)),
                                    DataCell(Text(vehicle.model, style: AppTextStyles.tableCell)),
                                    DataCell(StatusBadge(status: vehicle.status)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Edit Action Button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                              color: AppColors.corporateBlue,
                                            ),
                                            tooltip: 'Edit Vehicle',
                                            onPressed: () => router.navigateToEditVehicle(vehicle),
                                          ),
                                          // Delete Action Button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: AppColors.red,
                                            ),
                                            tooltip: 'Delete Vehicle',
                                            onPressed: () async {
                                              final confirmed = await ConfirmationDialog.show(
                                                context,
                                                vehicle: vehicle,
                                              );
                                              if (confirmed) {
                                                mockData.deleteVehicle(vehicle.id);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Vehicle ${vehicle.vehicleNumber} deleted successfully.',
                                                      ),
                                                      backgroundColor: AppColors.charcoal,
                                                      duration: const Duration(seconds: 3),
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
                          const Divider(height: 1),

                          // Pagination Footer
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${startIndex + 1} to $endIndex of $totalRecords vehicles',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Row(
                                  children: [
                                    // Rows Per Page Dropdown
                                    Row(
                                      children: [
                                        const Text('Rows: ', style: AppTextStyles.caption),
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: _rowsPerPage,
                                            items: const [
                                              DropdownMenuItem(value: 5, child: Text('5')),
                                              DropdownMenuItem(value: 8, child: Text('8')),
                                              DropdownMenuItem(value: 12, child: Text('12')),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() {
                                                  _rowsPerPage = val;
                                                  _currentPage = 1;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),

                                    // Previous Page Button
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left_rounded),
                                      tooltip: 'Previous Page',
                                      onPressed: _currentPage > 1
                                          ? () => setState(() => _currentPage--)
                                          : null,
                                    ),
                                    Text(
                                      'Page $_currentPage of $totalPages',
                                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    // Next Page Button
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right_rounded),
                                      tooltip: 'Next Page',
                                      onPressed: _currentPage < totalPages
                                          ? () => setState(() => _currentPage++)
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
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
