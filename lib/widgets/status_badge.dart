import 'package:flutter/material.dart';

import '../core/theme/app_text_styles.dart';
import '../models/vehicle.dart';

/// Clean, professional pill badge indicating vehicle operational status.
class StatusBadge extends StatelessWidget {
  final VehicleStatus status;
  final bool showDot;

  const StatusBadge({super.key, required this.status, this.showDot = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6.5,
              height: 6.5,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.label,
            style: AppTextStyles.badge.copyWith(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
