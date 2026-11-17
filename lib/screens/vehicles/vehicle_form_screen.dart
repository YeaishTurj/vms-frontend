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
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';

/// Reusable vehicle form component for both Registering and Editing vehicle records.
/// Features a 2-column desktop grid, 1-column responsive layout, required-field
/// validation, duplicate vehicle number detection, and corporate blue/white styling.
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
  String? _formError;
  bool _isDuplicateError = false;
  Map<String, String>? _fieldErrors;
  bool _isSubmitting = false;

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

    // In edit mode, load fresh vehicle data by ID from the backend to ensure latest state
    if (v != null && v.id.isNotEmpty) {
      VehicleRepository().fetchVehicleById(v.id).then((fresh) {
        if (fresh != null && mounted) {
          setState(() {
            _vehicleNumberController.text = fresh.vehicleNumber;
            _companyController.text = fresh.company;
            _brandController.text = fresh.brand;
            _modelController.text = fresh.model;
            _selectedType = fresh.type;
            _selectedStatus = fresh.status;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _companyController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _formError = null;
      _isDuplicateError = false;
      _fieldErrors = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final repository = VehicleRepository();
    final router = AppRouter();
    final vehicleNumber = _vehicleNumberController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      if (_isEditMode) {
        // Update existing record via PUT /vehicles/{id}
        final updated = widget.initialVehicle!.copyWith(
          id: widget.initialVehicle!.id, // Preserve correct vehicle ID
          vehicleNumber: vehicleNumber,
          company: _companyController.text.trim(),
          type: _selectedType ?? 'Sedan',
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          status: _selectedStatus ?? VehicleStatus.active,
        );
        await repository.updateVehicle(updated);
        await repository.fetchVehicles(page: repository.currentPage);

        if (mounted) {
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
                  Text('Vehicle ${updated.vehicleNumber} updated successfully.'),
                ],
              ),
              backgroundColor: AppColors.charcoal,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          );
          router.navigateTo(AppScreen.vehicles);
        }
      } else {
        // Register new record via POST /vehicles
        final newVehicle = Vehicle(
          id: '',
          vehicleNumber: vehicleNumber,
          company: _companyController.text.trim(),
          type: _selectedType ?? 'Sedan',
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          status: _selectedStatus ?? VehicleStatus.active,
        );
        final created = await repository.registerVehicle(newVehicle);
        await repository.fetchVehicles(page: 0);

        if (mounted) {
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
                  Text(
                    'Vehicle ${created.vehicleNumber} registered successfully.',
                  ),
                ],
              ),
              backgroundColor: AppColors.charcoal,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          );
          router.navigateTo(AppScreen.vehicles);
        }
      }
    } on ApiException catch (e) {
      if (!mounted) return;

      if (e.isDuplicate) {
        setState(() {
          _isDuplicateError = true;
          _formError = e.message;
          _fieldErrors = null;
        });
      } else if (e.isNotFound) {
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
        router.navigateTo(AppScreen.vehicles);
      } else if (e.isValidationError) {
        setState(() {
          _isDuplicateError = false;
          _formError = e.message;
          _fieldErrors = e.fieldErrors;
        });
      } else {
        setState(() {
          _isDuplicateError = false;
          _formError = e.message;
          _fieldErrors = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDuplicateError = false;
          _formError = 'Operation failed: ${e.toString()}';
          _fieldErrors = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.contentPadding),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header with Back Button and Title
              _buildPageHeader(router, isMobile),
              const SizedBox(height: 24),

              // White Form Card Container
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section Header inside Card
                      _buildCardHeader(),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 24),

                      // Backend Validation / Duplicate Error Banner
                      if (_formError != null) ...[
                        _buildErrorBanner(),
                        const SizedBox(height: 24),
                      ],

                      // Responsive Form Grid (2-column desktop, 1-column mobile/tablet)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 640;

                          if (isDesktop) {
                            return _buildDesktopGrid();
                          } else {
                            return _buildMobileGrid();
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 24),

                      // Form Actions: Primary Save & Secondary Cancel
                      _buildActionButtons(router, isMobile),
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

  Widget _buildPageHeader(AppRouter router, bool isMobile) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => router.navigateTo(AppScreen.vehicles),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.deepBlue,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _isEditMode ? 'Edit Vehicle' : 'Register Vehicle',
                    style: AppTextStyles.h1,
                  ),
                  if (_isEditMode &&
                      widget.initialVehicle != null &&
                      !isMobile) ...[
                    const SizedBox(width: 12),
                    _buildVehicleNumberBadge(
                      widget.initialVehicle!.vehicleNumber,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _isEditMode
                    ? 'Update vehicle specifications, fleet assignment, and operational status.'
                    : 'Fill in the required information to register a new vehicle into the fleet.',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.plateBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.plateBorder, width: 1),
          ),
          child: const Icon(
            Icons.directions_car_filled_rounded,
            color: AppColors.deepBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? 'Vehicle Specifications'
                  : 'New Vehicle Registration',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.deepBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'All fields marked with an asterisk (*) are required.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: AppColors.red,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isDuplicateError
                      ? 'Duplicate Vehicle Number Detected'
                      : (_fieldErrors != null
                          ? 'Validation Failed'
                          : 'Error Saving Vehicle'),
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formError ?? 'An unexpected error occurred.',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (_fieldErrors != null && _fieldErrors!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ..._fieldErrors!.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '• ${entry.key}: ${entry.value}',
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
  }

  Widget _buildDesktopGrid() {
    return Column(
      children: [
        // Row 1: Vehicle Number (Left) & Company (Right)
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
                errorText: _isDuplicateError
                    ? 'Vehicle number already registered'
                    : _fieldErrors?['vehicleNumber'],
                onChanged: (_) {
                  if (_formError != null || _isDuplicateError || _fieldErrors != null) {
                    setState(() {
                      _formError = null;
                      _isDuplicateError = false;
                      _fieldErrors = null;
                    });
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vehicle Number is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: AppTextField(
                label: 'Company',
                hint: 'e.g., Apex Logistics',
                controller: _companyController,
                isRequired: true,
                prefixIcon: Icons.business_outlined,
                errorText: _fieldErrors?['company'],
                onChanged: (_) {
                  if (_fieldErrors?['company'] != null) {
                    setState(() => _fieldErrors!.remove('company'));
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Company is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Row 2: Vehicle Type (Left) & Brand (Right)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppDropdown<String>(
                label: 'Vehicle Type',
                value: _selectedType,
                isRequired: true,
                prefixIcon: Icons.category_outlined,
                items: Vehicle.commonTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please select a vehicle type';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: AppTextField(
                label: 'Brand',
                hint: 'e.g., Toyota, Ford, Volvo',
                controller: _brandController,
                isRequired: true,
                prefixIcon: Icons.branding_watermark_outlined,
                errorText: _fieldErrors?['brand'],
                onChanged: (_) {
                  if (_fieldErrors?['brand'] != null) {
                    setState(() => _fieldErrors!.remove('brand'));
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Brand is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Row 3: Model (Left) & Status (Right)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'Model',
                hint: 'e.g., Camry, F-150, Sprinter',
                controller: _modelController,
                isRequired: true,
                prefixIcon: Icons.directions_car_outlined,
                errorText: _fieldErrors?['model'],
                onChanged: (_) {
                  if (_fieldErrors?['model'] != null) {
                    setState(() => _fieldErrors!.remove('model'));
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Model is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: AppDropdown<VehicleStatus>(
                label: 'Status',
                value: _selectedStatus,
                isRequired: true,
                prefixIcon: Icons.toggle_on_outlined,
                items: VehicleStatus.values.map((status) {
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
                onChanged: (val) => setState(() => _selectedStatus = val),
                validator: (val) {
                  if (val == null) {
                    return 'Please select an operational status';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileGrid() {
    return Column(
      children: [
        AppTextField(
          label: 'Vehicle Number',
          hint: 'e.g., DM-GA-11-2041',
          controller: _vehicleNumberController,
          isRequired: true,
          prefixIcon: Icons.pin_outlined,
          errorText: _isDuplicateError
              ? 'Vehicle number already registered'
              : _fieldErrors?['vehicleNumber'],
          onChanged: (_) {
            if (_formError != null || _isDuplicateError || _fieldErrors != null) {
              setState(() {
                _formError = null;
                _isDuplicateError = false;
                _fieldErrors = null;
              });
            }
          },
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Vehicle Number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: 'Company',
          hint: 'e.g., Apex Logistics',
          controller: _companyController,
          isRequired: true,
          prefixIcon: Icons.business_outlined,
          errorText: _fieldErrors?['company'],
          onChanged: (_) {
            if (_fieldErrors?['company'] != null) {
              setState(() => _fieldErrors!.remove('company'));
            }
          },
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Company is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AppDropdown<String>(
          label: 'Vehicle Type',
          value: _selectedType,
          isRequired: true,
          prefixIcon: Icons.category_outlined,
          items: Vehicle.commonTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (val) => setState(() => _selectedType = val),
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please select a vehicle type';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: 'Brand',
          hint: 'e.g., Toyota, Ford',
          controller: _brandController,
          isRequired: true,
          prefixIcon: Icons.branding_watermark_outlined,
          errorText: _fieldErrors?['brand'],
          onChanged: (_) {
            if (_fieldErrors?['brand'] != null) {
              setState(() => _fieldErrors!.remove('brand'));
            }
          },
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Brand is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: 'Model',
          hint: 'e.g., Camry, F-150',
          controller: _modelController,
          isRequired: true,
          prefixIcon: Icons.directions_car_outlined,
          errorText: _fieldErrors?['model'],
          onChanged: (_) {
            if (_fieldErrors?['model'] != null) {
              setState(() => _fieldErrors!.remove('model'));
            }
          },
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Model is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AppDropdown<VehicleStatus>(
          label: 'Status',
          value: _selectedStatus,
          isRequired: true,
          prefixIcon: Icons.toggle_on_outlined,
          items: VehicleStatus.values.map((status) {
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
          onChanged: (val) => setState(() => _selectedStatus = val),
          validator: (val) {
            if (val == null) {
              return 'Please select an operational status';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppRouter router, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: _isEditMode ? 'Save Changes' : 'Save Vehicle',
            icon: Icons.check_circle_outline_rounded,
            variant: AppButtonVariant.primary,
            isLoading: _isSubmitting,
            fullWidth: true,
            onPressed: _handleSave,
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => router.navigateTo(AppScreen.vehicles),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.secondary,
          onPressed: () => router.navigateTo(AppScreen.vehicles),
        ),
        const SizedBox(width: 14),
        AppButton(
          label: _isEditMode ? 'Save Changes' : 'Save Vehicle',
          icon: Icons.check_circle_outline_rounded,
          variant: AppButtonVariant.primary,
          isLoading: _isSubmitting,
          onPressed: _handleSave,
        ),
      ],
    );
  }

  Widget _buildVehicleNumberBadge(String vehicleNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
