import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_vehicle_data.dart';
import '../../models/vehicle.dart';
import '../../routing/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Reusable Form Screen for creating or modifying vehicle entity details.
class VehicleFormScreen extends StatefulWidget {
  final Vehicle? initialVehicle;

  const VehicleFormScreen({
    super.key,
    this.initialVehicle,
  });

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _vinController;
  late TextEditingController _plateController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;
  late TextEditingController _driverController;
  late TextEditingController _notesController;

  late VehicleType _selectedType;
  late FuelType _selectedFuelType;
  late VehicleStatus _selectedStatus;

  bool get _isEditMode => widget.initialVehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.initialVehicle;

    _vinController = TextEditingController(text: v?.vin ?? '');
    _plateController = TextEditingController(text: v?.licensePlate ?? '');
    _makeController = TextEditingController(text: v?.make ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(text: v?.year.toString() ?? '2024');
    _mileageController = TextEditingController(text: v?.mileage.toString() ?? '0');
    _driverController = TextEditingController(text: v?.assignedDriver ?? '');
    _notesController = TextEditingController(text: v?.notes ?? '');

    _selectedType = v?.type ?? VehicleType.sedan;
    _selectedFuelType = v?.fuelType ?? FuelType.petrol;
    _selectedStatus = v?.status ?? VehicleStatus.active;
  }

  @override
  void dispose() {
    _vinController.dispose();
    _plateController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _driverController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final mockData = MockVehicleData();
    final router = AppRouter();

    final year = int.tryParse(_yearController.text.trim()) ?? 2024;
    final mileage = int.tryParse(_mileageController.text.trim()) ?? 0;

    if (_isEditMode) {
      final updated = widget.initialVehicle!.copyWith(
        vin: _vinController.text.trim(),
        licensePlate: _plateController.text.trim(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        type: _selectedType,
        fuelType: _selectedFuelType,
        mileage: mileage,
        status: _selectedStatus,
        assignedDriver: _driverController.text.trim().isEmpty
            ? 'Unassigned'
            : _driverController.text.trim(),
        notes: _notesController.text.trim(),
      );
      mockData.updateVehicle(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle ${updated.id} updated successfully.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
    } else {
      final newId = 'VMS-${100 + mockData.totalVehicles + 1}';
      final newVehicle = Vehicle(
        id: newId,
        vin: _vinController.text.trim(),
        licensePlate: _plateController.text.trim(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        type: _selectedType,
        fuelType: _selectedFuelType,
        mileage: mileage,
        status: _selectedStatus,
        assignedDriver: _driverController.text.trim().isEmpty
            ? 'Unassigned'
            : _driverController.text.trim(),
        lastServiceDate: DateTime.now(),
        notes: _notesController.text.trim(),
      );
      mockData.addVehicle(newVehicle);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle $newId registered successfully into fleet.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
    }

    router.navigateTo(AppScreen.vehicles);
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back to Inventory',
                    onPressed: () => router.navigateTo(AppScreen.vehicles),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditMode
                            ? 'Edit Vehicle — ${widget.initialVehicle!.displayName}'
                            : 'Register New Fleet Vehicle',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isEditMode
                            ? 'Update operational details, driver assignment, and status.'
                            : 'Enter required registration attributes to add unit to fleet directory.',
                        style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Container
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section 1: Identification
                      Text('1. VEHICLE IDENTIFICATION & REGISTRATION',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          )),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'License Plate / Registration No. *',
                              hint: 'e.g., DHK-METRO-GA-1234',
                              controller: _plateController,
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Plate number is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Vehicle Identification Number (VIN) *',
                              hint: '17-character VIN',
                              controller: _vinController,
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'VIN is required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Specifications
                      Text('2. SPECIFICATIONS & CLASSIFICATION',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          )),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Manufacturer / Make *',
                              hint: 'e.g., Toyota, Ford, Tesla',
                              controller: _makeController,
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Make is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Model *',
                              hint: 'e.g., Camry, F-150, Model 3',
                              controller: _modelController,
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Model is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 140,
                            child: AppTextField(
                              label: 'Model Year *',
                              hint: '2024',
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Required';
                                final parsed = int.tryParse(val.trim());
                                if (parsed == null || parsed < 1990 || parsed > 2030) {
                                  return 'Invalid year';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Type, Fuel Type, and Status Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: _FormDropdown<VehicleType>(
                              label: 'Vehicle Body Type',
                              value: _selectedType,
                              items: VehicleType.values
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedType = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormDropdown<FuelType>(
                              label: 'Power / Fuel System',
                              value: _selectedFuelType,
                              items: FuelType.values
                                  .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedFuelType = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormDropdown<VehicleStatus>(
                              label: 'Operational Status',
                              value: _selectedStatus,
                              items: VehicleStatus.values
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedStatus = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Operations & Assignment
                      Text('3. FLEET DEPLOYMENT & METRICS',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          )),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Current Odometer (km)',
                              hint: 'e.g., 25000',
                              controller: _mileageController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Assigned Driver / Staff',
                              hint: 'Leave blank if unassigned pool car',
                              controller: _driverController,
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Internal Maintenance & Dispatch Notes',
                        hint: 'Record any mechanical conditions, route restrictions, or equipment packages.',
                        controller: _notesController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            label: 'Cancel',
                            variant: AppButtonVariant.outlined,
                            onPressed: () => router.navigateTo(AppScreen.vehicles),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            label: _isEditMode ? 'Update Vehicle Record' : 'Save & Register Unit',
                            icon: Icons.check_circle_outline_rounded,
                            variant: AppButtonVariant.primary,
                            onPressed: _handleSave,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FormDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
            border: Border.all(color: AppColors.inputBorder, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              style: AppTextStyles.bodyMedium,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
