import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/vehicle.dart';
import 'app_button.dart';

/// Modal dialog for confirming vehicle deletion.
class ConfirmationDialog extends StatelessWidget {
  final Vehicle vehicle;

  const ConfirmationDialog({super.key, required this.vehicle});

  static Future<bool> show(
    BuildContext context, {
    required Vehicle vehicle,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(vehicle: vehicle),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header with Warning Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.redBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.red,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Delete Vehicle', style: AppTextStyles.h2),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Message Body
            const Text(
              'Are you sure you want to permanently delete this vehicle from the management system? This action cannot be undone.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Vehicle Details Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softGray,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Vehicle No: ', style: AppTextStyles.caption),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.plateBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.plateBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          vehicle.vehicleNumber,
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Vehicle: ', style: AppTextStyles.caption),
                      Text(
                        '${vehicle.brand} ${vehicle.model} (${vehicle.type})',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Company: ', style: AppTextStyles.caption),
                      Text(vehicle.company, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: 'Delete Vehicle',
                  icon: Icons.delete_outline_rounded,
                  variant: AppButtonVariant.danger,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
