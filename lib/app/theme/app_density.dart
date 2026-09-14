import 'package:flutter/material.dart';

/// Shared spacing rules for keeping the dashboard information-dense without
/// shrinking accessibility text or changing desktop typography.
abstract final class AppDensity {
  static const mobileBreakpoint = 600.0;
  static const desktopBreakpoint = 900.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool compactMobile(BuildContext context) =>
      isMobile(context) && MediaQuery.textScalerOf(context).scale(1) <= 1.4;

  // Insets and relationships have different jobs. Keep labels near their
  // metadata, give card borders breathing room, and separate form outlines.
  static double tinyGap(BuildContext context) => isMobile(context) ? 2 : 4;
  static double pagePadding(BuildContext context) => isMobile(context) ? 6 : 10;
  static double cardPadding(BuildContext context) => isMobile(context) ? 8 : 12;
  static double sectionGap(BuildContext context) => isMobile(context) ? 10 : 12;
  static double controlGap(BuildContext context) => isMobile(context) ? 4 : 8;
  static double formGap(BuildContext context) => isMobile(context) ? 10 : 12;
  static double dialogInset(BuildContext context) => isMobile(context) ? 8 : 20;
  static double controlHeight(BuildContext context) {
    if (!isMobile(context)) return 36;
    return MediaQuery.textScalerOf(context).scale(1) <= 1.4 ? 36 : 44;
  }
}
