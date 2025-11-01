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

  final double displayLarge = 57.0;
  final double displayMedium = 45.0;
  final double displaySmall = 36.0;
  final double headlineLarge = 32.0;
  final double headlineMedium = 28.0;
  final double headlineSmall = 24.0;
  final double titleLarge = 22.0;
  final double titleMedium = 16.0;
  final double titleSmall = 14.0;
  final double bodyLarge = 16.0;
  final double bodyMedium = 14.0;
  final double bodySmall = 12.0;
  final double labelLarge = 14.0;
  final double labelMedium = 12.0;
  final double labelSmall = 11.0;
}

/// Font weights
class FontWeights {
  const FontWeights();

  final FontWeight thin = FontWeight.w100;
  final FontWeight extraLight = FontWeight.w200;
  final FontWeight light = FontWeight.w300;
  final FontWeight regular = FontWeight.w400;
  final FontWeight medium = FontWeight.w500;
  final FontWeight semiBold = FontWeight.w600;
  final FontWeight bold = FontWeight.w700;
  final FontWeight extraBold = FontWeight.w800;
  final FontWeight black = FontWeight.w900;
}

/// Spacing values
class Spacing {
  const Spacing();

  final double xs = 4.0;
  final double sm = 8.0;
  final double md = 16.0;
  final double lg = 24.0;
  final double xl = 32.0;
  final double xxl = 48.0;
  final double xxxl = 64.0;

  // Component specific spacing
  final double card = 16.0;
  final double buttonHorizontal = 24.0;
  final double buttonVertical = 12.0;
  final double inputHorizontal = 16.0;
  final double inputVertical = 12.0;
}

/// Border radius values
class AppBorderRadius {
  const AppBorderRadius();

  final double xs = 2.0;
  final double sm = 4.0;
  final double md = 8.0;
  final double lg = 12.0;
  final double xl = 16.0;
  final double xxl = 24.0;
  final double full = 999.0;

  // Component specific border radius
  final double card = 12.0;
  final double button = 8.0;
  final double input = 8.0;
}

/// Elevation values
class Elevations {
  const Elevations();

  final double none = 0.0;
  final double xs = 1.0;
  final double sm = 2.0;
  final double md = 4.0;
  final double lg = 8.0;
  final double xl = 16.0;
  final double xxl = 24.0;

  // Component specific elevations
  final double appBar = 4.0;
  final double card = 2.0;
  final double button = 2.0;
  final double dialog = 24.0;
  final double bottomSheet = 16.0;
}

/// Animation durations
class AnimationDurations {
  const AnimationDurations();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Component specific durations
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

  // Component specific curves
  static const Curve button = Curves.easeOut;
  static const Curve card = Curves.easeInOut;
  static const Curve page = Curves.fastOutSlowIn;
  static const Curve modal = Curves.easeInOut;
}
