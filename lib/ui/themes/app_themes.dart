/// App Themes Manager
///
/// Centralized access to unified theme definitions
/// Supports Light, Dark, and System modes
library;

import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Centralized theme accessor
class AppThemes {
  /// Unified light theme
  static ThemeData get lightTheme => LightTheme.theme;

  /// Unified dark theme
  static ThemeData get darkTheme => DarkTheme.theme;

  /// Get theme based on brightness
  static ThemeData getTheme(bool isDark) {
    return isDark ? darkTheme : lightTheme;
  }
}

