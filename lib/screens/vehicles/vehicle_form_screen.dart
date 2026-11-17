import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_vehicle_data.dart';
import '../../models/vehicle.dart';
import '../../routing/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';

/// Reusable vehicle form component for both Registering and Editing vehicle records.
class VehicleFormScreen extends StatefulWidget {
  final Vehicle? initialVehicle;

  const VehicleFormScreen({super.key, this.initialVehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _vehicleNumberController;
  late TextEditingController _companyController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;

  String? _selectedType;
  VehicleStatus? _selectedStatus;
  String? _duplicateError;

  bool get _isEditMode => widget.initialVehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.initialVehicle;

    _vehicleNumberController = TextEditingController(
      text: v?.vehicleNumber ?? '',
    );
    _companyController = TextEditingController(text: v?.company ?? '');
    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');

    _selectedType = v?.type ?? Vehicle.commonTypes.first;
    _selectedStatus = v?.status ?? VehicleStatus.active;
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _companyController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() => _duplicateError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final mockData = MockVehicleData();
    final router = AppRouter();
    final vehicleNumber = _vehicleNumberController.text.trim();

    // Validate duplicate vehicle number against local mock state
    final isDuplicate = mockData.isVehicleNumberDuplicate(
      vehicleNumber,
      excludeId: widget.initialVehicle?.id,
    );

    if (isDuplicate) {
      setState(() {
        _duplicateError =
            'Vehicle Number "$vehicleNumber" is already registered to another vehicle.';
      });
      return;
    }

    if (_isEditMode) {
      // Update existing record
      final updated = widget.initialVehicle!.copyWith(
        vehicleNumber: vehicleNumber,
        company: _companyController.text.trim(),
        type: _selectedType ?? 'Sedan',
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        status: _selectedStatus ?? VehicleStatus.active,
      );
      mockData.updateVehicle(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vehicle ${updated.vehicleNumber} updated successfully.',
          ),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Register new record
      final newId = 'vms-${DateTime.now().millisecondsSinceEpoch % 10000}';
      final newVehicle = Vehicle(
        id: newId,
        vehicleNumber: vehicleNumber,
        company: _companyController.text.trim(),
        type: _selectedType ?? 'Sedan',
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        status: _selectedStatus ?? VehicleStatus.active,
      );
      mockData.addVehicle(newVehicle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vehicle ${newVehicle.vehicleNumber} registered successfully.',
          ),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    router.navigateTo(AppScreen.vehicles);
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.contentPadding),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header with Back Button and Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.deepBlue,
                    ),
                    tooltip: 'Back to Vehicles',
                    onPressed: () => router.navigateTo(AppScreen.vehicles),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditMode ? 'Edit Vehicle' : 'Register Vehicle',
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isEditMode
                            ? 'Update vehicle specifications and current operational status.'
                            : 'Fill in the required information to register a new vehicle into the fleet.',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Container Card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Duplicate Number Error Banner
                      if (_duplicateError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.redBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: AppColors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _duplicateError!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Form Grid (Responsive 2-column on desktop, 1-column on smaller viewports)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 640;

                          if (isDesktop) {
                            return Column(
                              children: [
                                // Row 1: Vehicle Number & Company
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Vehicle Number',
                                        hint: 'e.g., DM-GA-11-2041',
                                        controller: _vehicleNumberController,
                                        isRequired: true,
                                        prefixIcon: Icons.pin_outlined,
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'Vehicle Number is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Company',
                                        hint: 'e.g., Apex Logistics',
                                        controller: _companyController,
                                        isRequired: true,
                                        prefixIcon: Icons.business_outlined,
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'Company name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Row 2: Type & Brand
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AppDropdown<String>(
                                        label: 'Vehicle Type',
                                        value: _selectedType,
                                        isRequired: true,
                                        items: Vehicle.commonTypes.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          );
                                        }).toList(),
                                        onChanged: (val) =>
                                            setState(() => _selectedType = val),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Please select a vehicle type';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Brand',
                                        hint: 'e.g., Toyota, Ford, Volvo',
                                        controller: _brandController,
                                        isRequired: true,
                                        prefixIcon:
                                            Icons.branding_watermark_outlined,
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'Brand is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Row 3: Model & Status
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Model',
                                        hint: 'e.g., Camry, F-150, Sprinter',
                                        controller: _modelController,
                                        isRequired: true,
                                        prefixIcon:
                                            Icons.directions_car_outlined,
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'Model is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: AppDropdown<VehicleStatus>(
                                        label: 'Status',
                                        value: _selectedStatus,
                                        isRequired: true,
                                        items: VehicleStatus.values.map((
                                          status,
                                        ) {
                                          return DropdownMenuItem(
                                            value: status,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: status.color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(status.label),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) => setState(
                                          () => _selectedStatus = val,
                                        ),
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Please select a status';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // Mobile / Tablet single column layout
                            return Column(
                              children: [
                                AppTextField(
                                  label: 'Vehicle Number',
                                  hint: 'e.g., DM-GA-11-2041',
                                  controller: _vehicleNumberController,
                                  isRequired: true,
                                  prefixIcon: Icons.pin_outlined,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Vehicle Number is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Company',
                                  hint: 'e.g., Apex Logistics',
                                  controller: _companyController,
                                  isRequired: true,
                                  prefixIcon: Icons.business_outlined,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Company is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppDropdown<String>(
                                  label: 'Vehicle Type',
                                  value: _selectedType,
                                  isRequired: true,
                                  items: Vehicle.commonTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedType = val),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Brand',
                                  hint: 'e.g., Toyota, Ford',
                                  controller: _brandController,
                                  isRequired: true,
                                  prefixIcon: Icons.branding_watermark_outlined,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Brand is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Model',
                                  hint: 'e.g., Camry, F-150',
                                  controller: _modelController,
                                  isRequired: true,
                                  prefixIcon: Icons.directions_car_outlined,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Model is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppDropdown<VehicleStatus>(
                                  label: 'Status',
                                  value: _selectedStatus,
                                  isRequired: true,
                                  items: VehicleStatus.values.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(status.label),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedStatus = val),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      // Form Buttons (Save and Cancel)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            label: 'Cancel',
                            variant: AppButtonVariant.secondary,
                            onPressed: () =>
                                router.navigateTo(AppScreen.vehicles),
                          ),
                          const SizedBox(width: 14),
                          AppButton(
                            label: _isEditMode
                                ? 'Save Changes'
                                : 'Save Vehicle',
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
