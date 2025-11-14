/// App Themes Manager
///
/// Centralized access to unified theme definitions
/// Supports Light, Dark, and System modes
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/themes/dark_theme.dart';
import 'package:skvk_application/ui/themes/light_theme.dart';

/// Centralized theme accessor
class AppThemes {
  /// Unified light theme
  static ThemeData get lightTheme => LightTheme.theme;

  /// Unified dark theme
  static ThemeData get darkTheme => DarkTheme.theme;

  /// Get theme based on brightness
  static ThemeData getTheme({required bool isDark}) {
    return isDark ? darkTheme : lightTheme;
  }
}
