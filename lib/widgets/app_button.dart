import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum AppButtonVariant {
  primary,   // Corporate Blue (#5B9BD5)
  secondary, // White with border
  danger,    // Red (#D32F2F)
}

/// Standardized VMS button component.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.corporateBlue;
        fg = AppColors.white;
        border = BorderSide.none;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.white;
        fg = AppColors.charcoal;
        border = const BorderSide(color: AppColors.border, width: 1);
        break;
      case AppButtonVariant.danger:
        bg = AppColors.red;
        fg = AppColors.white;
        border = BorderSide.none;
        break;
    }

    final isButtonDisabled = onPressed == null || isLoading;

    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.button.copyWith(color: fg),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isButtonDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isButtonDisabled ? AppColors.border : bg,
            borderRadius: BorderRadius.circular(6),
            border: border != BorderSide.none ? Border.fromBorderSide(border!) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
