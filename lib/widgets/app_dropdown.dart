import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Standardized Dropdown Field component matching VMS form styles.
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final String? hint;
  final bool isRequired;
  final IconData? prefixIcon;
  final String? errorText;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hint,
    this.isRequired = false,
    this.prefixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.fieldLabel),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          style: AppTextStyles.bodyMedium,
          hint: hint != null
              ? Text(
                  hint!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                )
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.textSecondary)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ],
    );
  }
}
