import 'package:flutter/material.dart';

/// Exact corporate color palette specified for the Vehicle Management System (VMS).
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color deepBlue = Color(
    0xFF1F4E79,
  ); // Navigation & important headings
  static const Color corporateBlue = Color(
    0xFF5B9BD5,
  ); // Primary buttons & selected elements
  static const Color softGray = Color(0xFFF5F7FA); // Application background
  static const Color white = Color(
    0xFFFFFFFF,
  ); // Cards, tables & form containers
  static const Color charcoal = Color(
    0xFF1F2937,
  ); // Primary typography & dark accents

  // Status & Semantic Colors
  static const Color green = Color(0xFF2E7D32); // Active & success status
  static const Color greenBg = Color(0xFFE8F5E9); // Light green container
  static const Color red = Color(
    0xFFD32F2F,
  ); // Inactive, delete & error messages
  static const Color redBg = Color(0xFFFFEBEE); // Light red container
  static const Color amber = Color(0xFFE65100); // Under Maintenance status
  static const Color amberBg = Color(0xFFFFF3E0); // Light amber container

  // Neutral Tones
  static const Color border = Color(0xFFE5E7EB); // Card & table border
  static const Color borderLight = Color(0xFFF3F4F6); // Subtle dividers
  static const Color textPrimary = Color(0xFF1F2937); // Charcoal
  static const Color textSecondary = Color(0xFF4B5563); // Muted gray text
  static const Color textMuted = Color(
    0xFF9CA3AF,
  ); // Placeholder & disabled text

  // Navigation Colors
  static const Color sidebarBackground = Color(0xFF1F4E79); // Deep blue sidebar
  static const Color sidebarActiveItem = Color(
    0xFF5B9BD5,
  ); // Corporate blue active
  static const Color sidebarHover = Color(0xFF285E8E);
  static const Color sidebarText = Color(0xFFD1D5DB);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
}
