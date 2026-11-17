import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive Layout Utility for Desktop-First Web Architecture.
class Responsive extends StatelessWidget {
  final Widget desktop;
  final Widget? tablet;
  final Widget? mobile;

  const Responsive({
    super.key,
    required this.desktop,
    this.tablet,
    this.mobile,
  });

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.desktopBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.tabletBreakpoint &&
        width < AppConstants.desktopBreakpoint;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= AppConstants.desktopBreakpoint) {
      return desktop;
    } else if (width >= AppConstants.tabletBreakpoint && tablet != null) {
      return tablet!;
    } else if (mobile != null) {
      return mobile!;
    } else {
      return desktop;
    }
  }
}
