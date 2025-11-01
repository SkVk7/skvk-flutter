/// Theme Migration Helper
///
/// This file provides utilities to help migrate from old theme system
/// to the centralized design system.
library;

import '../theme/theme_system.dart';
import '../responsive/responsive_system.dart';
import 'package:flutter/material.dart';

/// Migration helper for theme properties
class ThemeMigrationHelper {
  /// Get primary color (replaces new_theme.primaryColorProvider)
  static Color getPrimaryColor(BuildContext context) {
    return ThemeProperties.getPrimaryColor(context);
  }

  /// Get secondary color (replaces new_theme.secondaryColorProvider)
  static Color getSecondaryColor(BuildContext context) {
    return ThemeProperties.getSecondaryColor(context);
  }

  /// Get background color (replaces new_theme.backgroundColorProvider)
  static Color getBackgroundColor(BuildContext context) {
    return ThemeProperties.getBackgroundColor(context);
  }

  /// Get surface color (replaces new_theme.surfaceColorProvider)
  static Color getSurfaceColor(BuildContext context) {
    return ThemeProperties.getSurfaceColor(context);
  }

  /// Get card color (replaces new_theme.cardColorProvider)
  static Color getCardColor(BuildContext context) {
    return ThemeProperties.getCardColor(context);
  }

  /// Get primary text color (replaces new_theme.primaryTextColorProvider)
  static Color getPrimaryTextColor(BuildContext context) {
    return ThemeProperties.getPrimaryTextColor(context);
  }

  /// Get secondary text color (replaces new_theme.secondaryTextColorProvider)
  static Color getSecondaryTextColor(BuildContext context) {
    return ThemeProperties.getSecondaryTextColor(context);
  }

  /// Get tertiary text color (replaces new_theme.tertiaryTextColorProvider)
  static Color getTertiaryTextColor(BuildContext context) {
    return ThemeProperties.getTertiaryTextColor(context);
  }

  /// Get hint text color (replaces new_theme.hintTextColorProvider)
  static Color getHintTextColor(BuildContext context) {
    return ThemeProperties.getHintTextColor(context);
  }

  /// Get border color (replaces new_theme.borderColorProvider)
  static Color getBorderColor(BuildContext context) {
    return ThemeProperties.getBorderColor(context);
  }

  /// Get divider color (replaces new_theme.dividerColorProvider)
  static Color getDividerColor(BuildContext context) {
    return ThemeProperties.getDividerColor(context);
  }

  /// Get shadow color (replaces new_theme.shadowColorProvider)
  static Color getShadowColor(BuildContext context) {
    return ThemeProperties.getShadowColor(context);
  }

  /// Get error color (replaces new_theme.errorColorProvider)
  static Color getErrorColor(BuildContext context) {
    return ThemeProperties.getErrorColor(context);
  }

  /// Get primary gradient (replaces new_theme.primaryGradientProvider)
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return ThemeProperties.getPrimaryGradient(context);
  }

  /// Get secondary gradient (replaces new_theme.secondaryGradientProvider)
  static LinearGradient getSecondaryGradient(BuildContext context) {
    return ThemeProperties.getSecondaryGradient(context);
  }

  /// Get accent gradient (replaces new_theme.accentGradientProvider)
  static LinearGradient getAccentGradient(BuildContext context) {
    return ThemeProperties.getAccentGradient(context);
  }

  /// Check if dark mode (replaces new_theme.isDarkModeProvider)
  static bool isDarkMode(BuildContext context) {
    return ThemeUtils.isDarkMode(context);
  }
}

/// Migration helper for responsive sizing
class ResponsiveMigrationHelper {
  /// Get responsive padding (replaces ResponsiveSystem.padding)
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return ResponsiveSystem.padding(context);
  }

  /// Get responsive margin (replaces ResponsiveSystem.margin)
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return ResponsiveSystem.margin(context);
  }

  /// Get responsive font size (replaces ResponsiveSystem.fontSize)
  static double getResponsiveFontSize(BuildContext context, {required double baseSize}) {
    return ResponsiveSystem.fontSize(context, baseSize: baseSize);
  }

  /// Get responsive icon size (replaces ResponsiveSystem.iconSize)
  static double getResponsiveIconSize(BuildContext context, {required double baseSize}) {
    return ResponsiveSystem.iconSize(context, baseSize: baseSize);
  }

  /// Get responsive spacing (replaces ResponsiveSystem.spacing)
  static double getResponsiveSpacing(BuildContext context, {required double baseSpacing}) {
    return ResponsiveSystem.spacing(context, baseSpacing: baseSpacing);
  }

  /// Get responsive border radius (replaces ResponsiveSystem.borderRadius)
  static double getResponsiveBorderRadius(BuildContext context, {required double baseRadius}) {
    return ResponsiveSystem.borderRadius(context, baseRadius: baseRadius);
  }

  /// Get responsive elevation (replaces ResponsiveSystem.elevation)
  static double getResponsiveElevation(BuildContext context, {required double baseElevation}) {
    return ResponsiveSystem.elevation(context, baseElevation: baseElevation);
  }

  /// Get responsive text style (replaces ResponsiveSystem.textStyle)
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: ResponsiveSystem.fontSize(context, baseSize: baseFontSize),
      fontWeight: fontWeight,
      color: color,
    );
  }
}
