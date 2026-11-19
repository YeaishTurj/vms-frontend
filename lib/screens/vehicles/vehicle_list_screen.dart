import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/vehicle.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/services/api_exception.dart';
import '../../routing/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

/// Professional, enterprise-grade vehicle list screen integrated with Spring Boot REST API.
/// Supports backend pagination, search, status filters, loading states, and live CRUD operations.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  VehicleStatus? _statusFilter;
  String? _typeFilter;

  int _currentPage = 0;
  int _rowsPerPage = 8;

  @override
  void initState() {
    super.initState();
    final router = AppRouter();
    final initialQuery = router.globalSearchQuery;
    if (initialQuery != null && initialQuery.isNotEmpty) {
      _searchController.text = initialQuery;
      router.clearGlobalSearchQuery();
    }
    router.addListener(_onRouterChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VehicleRepository().fetchVehicles(page: 0, size: 100);
    });
  }

  void _onRouterChanged() {
    final query = AppRouter().globalSearchQuery;
    if (query != null && query.isNotEmpty && query != _searchController.text) {
      setState(() {
        _searchController.text = query;
        _currentPage = 0;
      });
      AppRouter().clearGlobalSearchQuery();
    }
  }

  @override
  void dispose() {
    AppRouter().removeListener(_onRouterChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = null;
      _typeFilter = null;
      _currentPage = 0;
    });
  }

  Future<void> _handleDelete(
    BuildContext context,
    VehicleRepository repository,
    Vehicle vehicle,
  ) async {
    final confirmed = await ConfirmationDialog.show(context, vehicle: vehicle);
    if (!confirmed || !context.mounted) return;

    try {
      await repository.deleteVehicle(vehicle.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text('Vehicle ${vehicle.vehicleNumber} deleted successfully.'),
              ],
            ),
            backgroundColor: AppColors.charcoal,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(e.message)),
              ],
            ),
            backgroundColor: AppColors.charcoal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('Delete failed: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.charcoal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = VehicleRepository();
    final router = AppRouter();
    final isMobile = Responsive.isMobile(context);

    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();

        // 1. Filter all loaded fleet vehicles based on search query & dropdown filters
        final filteredList = repository.vehicles.where((v) {
          final matchesQuery =
              query.isEmpty ||
              v.vehicleNumber.toLowerCase().contains(query) ||
              v.company.toLowerCase().contains(query) ||
              v.brand.toLowerCase().contains(query) ||
              v.model.toLowerCase().contains(query) ||
              v.type.toLowerCase().contains(query);

          final matchesStatus =
              _statusFilter == null || v.status == _statusFilter;
          final matchesType =
              _typeFilter == null ||
              v.type.toLowerCase() == _typeFilter!.toLowerCase();

          return matchesQuery && matchesStatus && matchesType;
        }).toList();

        final hasActiveFilters =
            query.isNotEmpty || _statusFilter != null || _typeFilter != null;

        // 2. Compute dynamic pagination on the filtered fleet list
        final totalFiltered = filteredList.length;
        final totalPages = (totalFiltered / _rowsPerPage).ceil();
        final safeTotalPages = totalPages > 0 ? totalPages : 1;
        final safeCurrentPage = _currentPage.clamp(0, safeTotalPages - 1);

        final startIndex = safeCurrentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage).clamp(0, totalFiltered);
        final pagedList = startIndex < totalFiltered
            ? filteredList.sublist(startIndex, endIndex)
            : <Vehicle>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header: Title, Count Badge & Register Vehicle Button
              _buildScreenHeader(
                router: router,
                totalCount: repository.totalCount,
                totalFiltered: totalFiltered,
                hasActiveFilters: hasActiveFilters,
                isMobile: isMobile,
              ),
              const SizedBox(height: 24),

              // Filter & Search Controls Toolbar
              _buildFilterToolbar(hasActiveFilters, isMobile),
              const SizedBox(height: 24),

              // White Content Card Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: _buildCardContent(
                  context: context,
                  repository: repository,
                  pagedList: pagedList,
                  totalFiltered: totalFiltered,
                  safeCurrentPage: safeCurrentPage,
                  safeTotalPages: safeTotalPages,
                  startIndex: startIndex,
                  endIndex: endIndex,
                  hasActiveFilters: hasActiveFilters,
                  router: router,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardContent({
    required BuildContext context,
    required VehicleRepository repository,
    required List<Vehicle> pagedList,
    required int totalFiltered,
    required int safeCurrentPage,
    required int safeTotalPages,
    required int startIndex,
    required int endIndex,
    required bool hasActiveFilters,
    required AppRouter router,
    required bool isMobile,
  }) {
    // 1. Initial Full Loading State
    if (repository.isLoading && repository.vehicles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.corporateBlue,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Connecting to VMS Backend & Loading Vehicles...',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
      );
    }

    // 2. Connection / Error State with Retry
    if (repository.errorMessage != null && repository.vehicles.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Backend Connection Notice',
        description:
            '${repository.errorMessage}\n\nNote: Render free tier services sleep after inactivity and take ~45–60s on first load to wake up. Tap below to retry.',
        actionLabel: 'Retry Connection',
        onAction: () => repository.fetchVehicles(page: 0, size: 100),
      );
    }

    // 3. Empty List States (when no records match the filter)
    if (totalFiltered == 0) {
      return _buildEmptyState(hasActiveFilters, router);
    }

    // 4. Data Layout & Pagination Footer
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (repository.isLoading)
          const LinearProgressIndicator(
            color: AppColors.corporateBlue,
            backgroundColor: AppColors.tableHeaderBg,
            minHeight: 2,
          ),

        if (repository.errorMessage != null && repository.vehicles.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.redBg,
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: AppColors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repository.errorMessage!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => repository.fetchVehicles(
                    page: 0,
                    size: 100,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (isMobile)
          _buildMobileCardList(context, pagedList, repository, router)
        else
          _buildDesktopTable(context, pagedList, repository, router),

        const Divider(color: AppColors.border, height: 1),

        // Filtered & Paginated Footer
        _buildPaginationFooter(
          totalElements: totalFiltered,
          currentPage: safeCurrentPage,
          totalPages: safeTotalPages,
          startIndex: startIndex,
          endIndex: endIndex,
          isMobile: isMobile,
          onPrevious: safeCurrentPage > 0
              ? () => setState(() => _currentPage = safeCurrentPage - 1)
              : null,
          onNext: safeCurrentPage < safeTotalPages - 1
              ? () => setState(() => _currentPage = safeCurrentPage + 1)
              : null,
          onRowsPerPageChanged: (val) {
            if (val != null) {
              setState(() {
                _rowsPerPage = val;
                _currentPage = 0;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildScreenHeader({
    required AppRouter router,
    required int totalCount,
    required int totalFiltered,
    required bool hasActiveFilters,
    required bool isMobile,
  }) {
    final countLabel = hasActiveFilters
        ? '$totalFiltered of $totalCount'
        : '$totalCount Total';

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Vehicles', style: AppTextStyles.h1),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.corporateBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  countLabel,
                  style: const TextStyle(
                    color: AppColors.deepBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage, search and inspect all registered fleet vehicles.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 12),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Vehicles', style: AppTextStyles.h1),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.corporateBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    countLabel,
                    style: const TextStyle(
                      color: AppColors.deepBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage, search and inspect all registered fleet vehicles.',
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

  Widget _buildFilterToolbar(bool hasActiveFilters, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 1. Search Field
          SizedBox(
            width: isMobile ? double.infinity : 320,
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() => _currentPage = 0),
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search by Number, Company, Brand...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _currentPage = 0);
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: AppColors.tableHeaderBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),

          // 2. Status Filter Dropdown
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.tableHeaderBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<VehicleStatus?>(
                    value: _statusFilter,
                    hint: const Text(
                      'All Statuses',
                      style: AppTextStyles.bodyMedium,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'All Statuses',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      ...VehicleStatus.values.map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label, style: AppTextStyles.bodyMedium),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _statusFilter = val;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. Type Filter Dropdown
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.tableHeaderBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_car_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _typeFilter,
                    hint: const Text(
                      'All Types',
                      style: AppTextStyles.bodyMedium,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'All Types',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      ...Vehicle.commonTypes.map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t, style: AppTextStyles.bodyMedium),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _typeFilter = val;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 4. Clear Filters Action
          if (hasActiveFilters)
            TextButton.icon(
              icon: const Icon(
                Icons.restart_alt_rounded,
                size: 16,
                color: AppColors.red,
              ),
              label: const Text(
                'Clear Filters',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              onPressed: _clearFilters,
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<Vehicle> vehicles,
    VehicleRepository repository,
    AppRouter router,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth < 920 ? 920 : constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
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
                    'BRAND',
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
                    'MODEL',
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
              rows: vehicles.map((vehicle) {
                return DataRow(
                  cells: [
                    DataCell(_buildVehicleNumberBadge(vehicle.vehicleNumber)),
                    DataCell(
                      Text(
                        vehicle.company,
                        style: AppTextStyles.tableCellBold.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
                    DataCell(
                      Text(
                        vehicle.brand,
                        style: AppTextStyles.tableCell.copyWith(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        vehicle.model,
                        style: AppTextStyles.tableCell.copyWith(fontSize: 13),
                      ),
                    ),
                    DataCell(StatusBadge(status: vehicle.status)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit Vehicle',
                            color: AppColors.corporateBlue,
                            bgColor: AppColors.actionEditBg,
                            borderColor: AppColors.actionEditBorder,
                            onTap: () => router.navigateToEditVehicle(vehicle),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Delete Vehicle',
                            color: AppColors.red,
                            bgColor: AppColors.actionDeleteBg,
                            borderColor: AppColors.actionDeleteBorder,
                            onTap: () =>
                                _handleDelete(context, repository, vehicle),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileCardList(
    BuildContext context,
    List<Vehicle> vehicles,
    VehicleRepository repository,
    AppRouter router,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildVehicleNumberBadge(vehicle.vehicleNumber),
                  StatusBadge(status: vehicle.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDetailItem('Company', vehicle.company)),
                  Expanded(child: _buildDetailItem('Type', vehicle.type)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildDetailItem('Brand', vehicle.brand)),
                  Expanded(child: _buildDetailItem('Model', vehicle.model)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.borderLight, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit Vehicle',
                    color: AppColors.corporateBlue,
                    bgColor: AppColors.actionEditBg,
                    borderColor: AppColors.actionEditBorder,
                    onTap: () => router.navigateToEditVehicle(vehicle),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete Vehicle',
                    color: AppColors.red,
                    bgColor: AppColors.actionDeleteBg,
                    borderColor: AppColors.actionDeleteBorder,
                    onTap: () => _handleDelete(context, repository, vehicle),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasActiveFilters, AppRouter router) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: hasActiveFilters ? 'No Matching Vehicles' : 'No Vehicles Found',
      description: hasActiveFilters
          ? 'No fleet records matched your current search criteria. Try modifying your search or clearing active filters.'
          : 'There are currently no vehicles registered in the backend fleet system.',
      actionLabel: hasActiveFilters ? 'Reset Filters' : 'Register Vehicle',
      onAction: hasActiveFilters
          ? _clearFilters
          : () => router.navigateTo(AppScreen.registerVehicle),
    );
  }

  Widget _buildPaginationFooter({
    required int totalElements,
    required int currentPage,
    required int totalPages,
    required int startIndex,
    required int endIndex,
    required bool isMobile,
    required VoidCallback? onPrevious,
    required VoidCallback? onNext,
    required ValueChanged<int?> onRowsPerPageChanged,
  }) {
    final startNumber = totalElements == 0 ? 0 : startIndex + 1;
    final endNumber = endIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $startNumber to $endNumber of $totalElements vehicles',
            style: AppTextStyles.bodySmall,
          ),
          Row(
            children: [
              if (!isMobile) ...[
                const Text('Rows: ', style: AppTextStyles.caption),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _rowsPerPage,
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5')),
                      DropdownMenuItem(value: 8, child: Text('8')),
                      DropdownMenuItem(value: 12, child: Text('12')),
                    ],
                    onChanged: onRowsPerPageChanged,
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Previous Page Button
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                tooltip: 'Previous Page',
                onPressed: onPrevious,
              ),

              Text(
                'Page ${currentPage + 1} of $totalPages',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Next Page Button
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                tooltip: 'Next Page',
                onPressed: onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
