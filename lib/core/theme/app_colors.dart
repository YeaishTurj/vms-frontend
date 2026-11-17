import 'package:flutter/material.dart';

/// Corporate Blue & White Design System Color Palette for VMS.
class AppColors {
  AppColors._();

  // Primary Corporate Blue Palette
  static const Color primary = Color(0xFF1E3A8A); // Corporate Navy Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Active Blue
  static const Color primaryDark = Color(0xFF172554); // Deep Navy
  static const Color primaryContainer = Color(0xFFDBEAFE); // Soft Blue Tint
  static const Color onPrimaryContainer = Color(0xFF1E40AF);

  // Secondary & Neutral Slates
  static const Color secondary = Color(0xFF475569); // Slate Grey
  static const Color secondaryLight = Color(0xFF94A3B8);
  static const Color secondaryContainer = Color(0xFFF1F5F9);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Clean Canvas Background
  static const Color surface = Color(0xFFFFFFFF); // Pure White Cards & Panels
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Light Gray Surface
  static const Color sidebarBackground = Color(0xFF0F172A); // Dark Executive Sidebar
  static const Color sidebarSelected = Color(0xFF1E293B); // Sidebar Active Item
  static const Color sidebarText = Color(0xFF94A3B8); // Sidebar Muted Text
  static const Color sidebarTextActive = Color(0xFFFFFFFF); // Sidebar Active Text

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Subtle Border
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Charcoal Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Indicator Colors
  // Active / Ready
  static const Color statusActive = Color(0xFF16A34A);
  static const Color statusActiveBg = Color(0xFFDCFCE7);

  // In Service / On Route
  static const Color statusInService = Color(0xFF2563EB);
  static const Color statusInServiceBg = Color(0xFFDBEAFE);

  // Maintenance Required
  static const Color statusMaintenance = Color(0xFFD97706);
  static const Color statusMaintenanceBg = Color(0xFFFEF3C7);

  // Inactive / Retired
  static const Color statusInactive = Color(0xFFDC2626);
  static const Color statusInactiveBg = Color(0xFFFEE2E2);

  // Form Field Accents
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFCBD5E1);
  static const Color inputFocusBorder = Color(0xFF2563EB);
  static const Color inputErrorBorder = Color(0xFFEF4444);
}
