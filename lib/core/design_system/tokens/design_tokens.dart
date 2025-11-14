/// Design Tokens - Centralized Design Constants
///
/// This file contains all design tokens including colors, typography,
/// spacing, and other design constants.
library;

import 'package:flutter/material.dart';

/// Design tokens for the application
class DesignTokens {
  // Colors
  static const Color primaryColor = Color(0xFF6B46C1);
  static const Color secondaryColor = Color(0xFF9333EA);
  static const Color accentColor = Color(0xFFEC4899);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);

  // Light theme colors - Authentic Hindu traditional colors with high contrast
  static const Map<String, Color> lightTextColors = {
    'primary': Color(0xFF1A1A1A), // Sacred Black for maximum contrast
    'secondary': Color(0xFF424242), // Sacred Gray for high contrast
    'tertiary': Color(0xFF616161), // Sacred Medium Gray for good contrast
    'disabled': Color(0xFF9E9E9E), // Sacred Light Gray for disabled text
  };

  static const Map<String, Color> lightAppBarColors = {
    'background': Color(0xFFE65100), // Deep Saffron Orange (Sacred Fire)
    'foreground': Color(0xFFFFFFFF), // Sacred White for maximum contrast
  };

  static const Map<String, Color> lightCardColors = {
    'background': Color(0xFFFFFFFF), // Sacred White (Purity)
    'backgroundSecondary': Color(0xFFFFF8E1), // Sacred Earth (Light Saffron)
    'backgroundTertiary': Color(0xFFFFF3E0), // Sacred Earth (Medium Saffron)
    'border': Color(0xFFD97706), // Sacred Gold (Divine)
    'borderSecondary': Color(0xFFE0E0E0), // Sacred Light Gray
  };

  static const Map<String, Color> lightButtonColors = {
    'primary': Color(0xFFE65100), // Deep Saffron Orange (Sacred Fire)
    'onPrimary': Color(0xFFFFFFFF), // Sacred White for maximum contrast
    'secondary': Color(0xFF2E7D32), // Sacred Green (Nature/Life)
    'onSecondary': Color(0xFFFFFFFF), // Sacred White for maximum contrast
  };

  static const Map<String, Color> lightInputColors = {
    'background': Color(0xFFFFFBF0), // Sacred Saffron Cream
    'border': Color(0xFFD97706), // Sacred Gold (Divine)
    'focused': Color(0xFFE65100), // Deep Saffron Orange for focus
    'error': Color(0xFFD32F2F), // Sacred Red for errors
  };

  // Dark theme colors - Pure black with vibrant Hindu traditional color blends
  static const Map<String, Color> darkTextColors = {
    'primary': Color(0xFFFFFFFF), // Sacred White for maximum contrast
    'secondary': Color(0xFFE0E0E0), // Light Gray for high contrast
    'tertiary': Color(0xFFB0B0B0), // Medium Gray for good contrast
    'disabled': Color(0xFF757575), // Dark Gray for disabled text
  };

  static const Map<String, Color> darkAppBarColors = {
    'background': Color(0xFF000000), // Pure Black
    'foreground': Color(0xFFFFFFFF), // Sacred White for maximum contrast
  };

  static const Map<String, Color> darkCardColors = {
    'background': Color(0xFF000000), // Pure Black
    'backgroundSecondary': Color(0xFF0D1117), // Black with subtle blue blend
    'backgroundTertiary': Color(0xFF1A1A1A), // Black with subtle gray blend
    'border': Color(0xFFFF6B35), // Vibrant Saffron Orange
    'borderSecondary': Color(0xFF333333), // Dark Gray with black blend
  };

  static const Map<String, Color> darkButtonColors = {
    'primary': Color(0xFFFF6B35), // Vibrant Saffron Orange
    'onPrimary': Color(0xFF000000), // Sacred Black for maximum contrast
    'secondary': Color(0xFF2E7D32), // Deep Sacred Green
    'onSecondary': Color(0xFFFFFFFF), // Pure white for maximum contrast
  };

  static const Map<String, Color> darkInputColors = {
    'background': Color(0xFF000000), // Pure Black
    'border': Color(0xFFFF6B35), // Vibrant Saffron Orange
    'focused': Color(0xFFFF6B35), // Vibrant Saffron for focus
    'error': Color(0xFFD32F2F), // Deep Red for errors
  };

  // Typography
  static const FontSizes fontSizes = FontSizes();
  static const FontWeights fontWeights = FontWeights();

  // Spacing
  static const Spacing spacing = Spacing();

  // Border radius
  static const AppBorderRadius borderRadius = AppBorderRadius();

  // Elevations
  static const Elevations elevations = Elevations();

  // Animation durations
  static const AnimationDurations animationDurations = AnimationDurations();

  // Animation curves
  static const AnimationCurves animationCurves = AnimationCurves();
}

/// Font sizes
class FontSizes {
  const FontSizes();

  double get displayLarge => 57;
  double get displayMedium => 45;
  double get displaySmall => 36;
  double get headlineLarge => 32;
  double get headlineMedium => 28;
  double get headlineSmall => 24;
  double get titleLarge => 22;
  double get titleMedium => 16;
  double get titleSmall => 14;
  double get bodyLarge => 16;
  double get bodyMedium => 14;
  double get bodySmall => 12;
  double get labelLarge => 14;
  double get labelMedium => 12;
  double get labelSmall => 11;
}

/// Font weights
class FontWeights {
  const FontWeights();

  FontWeight get thin => FontWeight.w100;
  FontWeight get extraLight => FontWeight.w200;
  FontWeight get light => FontWeight.w300;
  FontWeight get regular => FontWeight.w400;
  FontWeight get medium => FontWeight.w500;
  FontWeight get semiBold => FontWeight.w600;
  FontWeight get bold => FontWeight.w700;
  FontWeight get extraBold => FontWeight.w800;
  FontWeight get black => FontWeight.w900;
}

/// Spacing values
class Spacing {
  const Spacing();

  double get xs => 4;
  double get sm => 8;
  double get md => 16;
  double get lg => 24;
  double get xl => 32;
  double get xxl => 48;
  double get xxxl => 64;

  double get card => 16;
  double get buttonHorizontal => 24;
  double get buttonVertical => 12;
  double get inputHorizontal => 16;
  double get inputVertical => 12;
}

/// Border radius values
class AppBorderRadius {
  const AppBorderRadius();

  double get xs => 2;
  double get sm => 4;
  double get md => 8;
  double get lg => 12;
  double get xl => 16;
  double get xxl => 24;
  double get full => 999;

  double get card => 12;
  double get button => 8;
  double get input => 8;
}

/// Elevation values
class Elevations {
  const Elevations();

  double get none => 0;
  double get xs => 1;
  double get sm => 2;
  double get md => 4;
  double get lg => 8;
  double get xl => 16;
  double get xxl => 24;

  double get appBar => 4;
  double get card => 2;
  double get button => 2;
  double get dialog => 24;
  double get bottomSheet => 16;
}

/// Animation durations
class AnimationDurations {
  const AnimationDurations();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  static const Duration button = Duration(milliseconds: 150);
  static const Duration card = Duration(milliseconds: 200);
  static const Duration page = Duration(milliseconds: 300);
  static const Duration modal = Duration(milliseconds: 400);
}

/// Animation curves
class AnimationCurves {
  const AnimationCurves();

  static const Curve linear = Curves.linear;
  static const Curve ease = Curves.ease;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;

  static const Curve button = Curves.easeOut;
  static const Curve card = Curves.easeInOut;
  static const Curve page = Curves.fastOutSlowIn;
  static const Curve modal = Curves.easeInOut;
}
