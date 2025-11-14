/// Theme Helpers
///
/// Helper utilities to access theme properties using Flutter's Theme.of(context)
/// This replaces the old ThemeProperties class
library;

import 'package:flutter/material.dart';

/// Helper class to access theme properties
/// Replaces the old ThemeProperties class
class ThemeHelpers {
  /// Get primary color from theme
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Get secondary color from theme
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  /// Get background color from theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Get surface color from theme
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get card color from theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  /// Get primary text color from theme
  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get secondary text color from theme
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Get tertiary text color from theme
  static Color getTertiaryTextColor(BuildContext context) {
    return Theme.of(context)
        .colorScheme
        .onSurfaceVariant
        .withValues(alpha: 0.7);
  }

  /// Get hint text color from theme
  static Color getHintTextColor(BuildContext context) {
    return Theme.of(context)
        .colorScheme
        .onSurfaceVariant
        .withValues(alpha: 0.6);
  }

  /// Get border color from theme
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  /// Get divider color from theme
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  /// Get shadow color from theme
  static Color getShadowColor(BuildContext context) {
    return Theme.of(context).shadowColor;
  }

  /// Get error color from theme
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Get app bar text color from theme
  static Color getAppBarTextColor(BuildContext context) {
    return Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;
  }

  /// Get app bar background color from theme
  static Color getAppBarBackgroundColor(BuildContext context) {
    return Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;
  }

  /// Get primary gradient (simple gradient using primary color)
  static LinearGradient getPrimaryGradient(BuildContext context) {
    final primary = getPrimaryColor(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary,
        primary.withValues(alpha: 0.8),
      ],
    );
  }

  /// Get secondary gradient (simple gradient using secondary color)
  static LinearGradient getSecondaryGradient(BuildContext context) {
    final secondary = getSecondaryColor(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        secondary,
        secondary.withValues(alpha: 0.8),
      ],
    );
  }

  /// Get accent gradient (simple gradient using tertiary color)
  static LinearGradient getAccentGradient(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        tertiary,
        tertiary.withValues(alpha: 0.8),
      ],
    );
  }

  /// Check if dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get transparent color (Colors.transparent)
  static Color getTransparentColor(BuildContext context) {
    return const Color.fromARGB(0, 0, 0, 0);
  }

  /// Get success color (green from color scheme or default)
  static Color getSuccessColor(BuildContext context) {
    // Try to get from color scheme, fallback to green
    return Theme.of(context).colorScheme.tertiaryContainer;
  }

  /// Get text color (alias for primary text color)
  static Color getTextColor(BuildContext context) {
    return getPrimaryTextColor(context);
  }

  /// Get surface container color
  static Color getSurfaceContainerColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  /// Get surface container high color
  static Color getSurfaceContainerHighColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  /// Get elevated shadows (returns list of BoxShadow)
  static List<BoxShadow> getElevatedShadows(BuildContext context,
      {double elevation = 2.0,}) {
    return [
      BoxShadow(
        color: Theme.of(context).shadowColor.withValues(alpha: 0.3),
        blurRadius: elevation * 4,
        offset: Offset(0, elevation * 2),
      ),
    ];
  }
}
