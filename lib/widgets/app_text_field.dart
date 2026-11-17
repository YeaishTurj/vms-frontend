import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Standardized Form Input Field for VMS forms.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool isRequired;
  final bool enabled;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.isRequired = false,
    this.enabled = true,
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
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
      ],
    );
  }
}
