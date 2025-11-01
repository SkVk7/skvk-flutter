/// Hindu Traditional Theme
///
/// This file contains the complete theme configuration for the application
/// following Hindu traditional aesthetics and colors
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class HinduTheme {
  // Hindu Traditional Color Palette - Light Theme
  static const Color primarySaffron =
      Color(0xFFBF360C); // Much darker saffron for AA compliance (4.5:1+)
  static const Color primaryRed = Color(0xFFB71C1C); // Deep red for better contrast
  static const Color primaryGold = Color(0xFFD84315); // Much darker gold for AA compliance (4.5:1+)
  static const Color primaryMaroon = Color(0xFF4A148C); // Deep maroon for better contrast
  static const Color primaryOrange = Color(0xFFE65100); // Deep orange for better contrast
  static const Color primaryCream = Color(0xFFFFFBF0); // Warmer cream background
  static const Color primaryBrown = Color(0xFF5D4037); // Rich brown for better contrast
  static const Color primaryYellow = Color(0xFFF9A825); // Rich yellow for better contrast

  // Secondary Colors - Light Theme
  static const Color secondaryBlue = Color(0xFF1565C0); // Deep blue for better contrast
  static const Color secondaryGreen = Color(0xFF2E7D32); // Deep green for better contrast
  static const Color secondaryPurple = Color(0xFF6A1B9A); // Deep purple for better contrast
  static const Color secondaryTeal = Color(0xFF00695C); // Deep teal for better contrast

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFFFFBF0); // Warm cream background
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white surface
  static const Color surfaceVariantLight = Color(0xFFFFF8E1); // Light cream variant
  static const Color textLight = Color(0xFF1B1B1B); // Near black for maximum contrast
  static const Color textSecondaryLight = Color(0xFF424242); // Dark gray for secondary text
  static const Color textTertiaryLight = Color(0xFF616161); // Medium gray for tertiary text
  static const Color borderLight = Color(0xFFE0E0E0); // Light border
  static const Color dividerLight = Color(0xFFE0E0E0); // Light divider

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212); // True dark background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark surface
  static const Color surfaceVariantDark = Color(0xFF2C2C2C); // Dark surface variant
  static const Color textDark = Color(0xFFFFFFFF); // Pure white text
  static const Color textSecondaryDark = Color(0xFFB3B3B3); // Light gray for secondary text
  static const Color textTertiaryDark = Color(0xFF8A8A8A); // Medium gray for tertiary text
  static const Color borderDark = Color(0xFF3A3A3A); // Dark border
  static const Color dividerDark = Color(0xFF3A3A3A); // Dark divider

  // Accent Colors for Dark Theme
  static const Color accentSaffronDark = Color(0xFFFF8A65); // Lighter saffron for dark theme
  static const Color accentGoldDark = Color(0xFFFFB74D); // Lighter gold for dark theme
  static const Color accentRedDark = Color(0xFFEF5350); // Lighter red for dark theme

  // Backward compatibility properties
  static const Color textSecondary = textSecondaryLight; // For backward compatibility

  // Gradient Colors - Light Theme
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySaffron, primaryOrange, primaryGold],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryCream, surfaceLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, primaryMaroon],
  );

  // Gradient Colors - Dark Theme
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentSaffronDark, primaryOrange, accentGoldDark],
  );

  static const LinearGradient secondaryGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceDark, surfaceVariantDark],
  );

  static const LinearGradient accentGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentRedDark, primaryMaroon],
  );

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primarySaffron,
        secondary: primaryGold,
        tertiary: primaryRed,
        surface: backgroundLight,
        surfaceContainerHighest: surfaceVariantLight,
        error: primaryRed,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onTertiary: Colors.white,
        onSurface: textLight,
        onSurfaceVariant: textSecondaryLight,
        onError: Colors.white,
        outline: borderLight,
        outlineVariant: dividerLight,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primarySaffron,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        color: surfaceLight,
        shadowColor: primarySaffron.withAlpha((0.15 * 255).round()),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySaffron,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primarySaffron.withAlpha((0.3 * 255).round()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primarySaffron,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primarySaffron,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: primarySaffron, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: primaryRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: GoogleFonts.poppins(
          color: textSecondaryLight,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.poppins(
          color: textTertiaryLight,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.poppins(
          color: primaryRed,
          fontSize: 12,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: textLight,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: textLight,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          color: textSecondaryLight,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textLight,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textLight,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondaryLight,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: primarySaffron,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerLight,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primarySaffron,
        unselectedItemColor: textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primarySaffron,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariantLight,
        selectedColor: primarySaffron,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: textLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primarySaffron,
        linearTrackColor: surfaceVariantLight,
        circularTrackColor: surfaceVariantLight,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primarySaffron;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primarySaffron.withAlpha((0.5 * 255).round());
          }
          return Colors.grey.withAlpha((0.3 * 255).round());
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primarySaffron;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primarySaffron;
          }
          return Colors.grey;
        }),
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: accentSaffronDark,
        secondary: accentGoldDark,
        tertiary: accentRedDark,
        surface: backgroundDark,
        surfaceContainerHighest: surfaceVariantDark,
        error: accentRedDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onTertiary: Colors.black,
        onSurface: textDark,
        onSurfaceVariant: textSecondaryDark,
        onError: Colors.black,
        outline: borderDark,
        outlineVariant: dividerDark,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textDark,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark, size: 24),
        actionsIconTheme: const IconThemeData(color: textDark, size: 24),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        color: surfaceDark,
        shadowColor: accentSaffronDark.withAlpha((0.15 * 255).round()),
        surfaceTintColor: Colors.transparent,
      ),

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: textDark,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          color: textSecondaryDark,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondaryDark,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentSaffronDark,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentSaffronDark,
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: accentSaffronDark.withAlpha((0.3 * 255).round()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentSaffronDark,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: accentSaffronDark,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: accentSaffronDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: accentRedDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: accentRedDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: GoogleFonts.poppins(
          color: textSecondaryDark,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.poppins(
          color: textTertiaryDark,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.poppins(
          color: accentRedDark,
          fontSize: 12,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: accentSaffronDark,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerDark,
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentSaffronDark,
        foregroundColor: Colors.black,
        elevation: 4,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariantDark,
        selectedColor: accentSaffronDark,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: textDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentSaffronDark,
        linearTrackColor: surfaceVariantDark,
        circularTrackColor: surfaceVariantDark,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentSaffronDark;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentSaffronDark.withAlpha((0.5 * 255).round());
          }
          return Colors.grey.withAlpha((0.3 * 255).round());
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentSaffronDark;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentSaffronDark;
          }
          return Colors.grey;
        }),
      ),
    );
  }

  /// Get gradient decoration for containers (Light Theme)
  static BoxDecoration get primaryGradientDecoration {
    return const BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    );
  }

  /// Get secondary gradient decoration for containers (Light Theme)
  static BoxDecoration get secondaryGradientDecoration {
    return const BoxDecoration(
      gradient: secondaryGradient,
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    );
  }

  /// Get accent gradient decoration for containers (Light Theme)
  static BoxDecoration get accentGradientDecoration {
    return const BoxDecoration(
      gradient: accentGradient,
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    );
  }

  /// Get gradient decoration for containers (Dark Theme)
  static BoxDecoration get primaryGradientDecorationDark {
    return const BoxDecoration(
      gradient: primaryGradientDark,
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    );
  }

  /// Get secondary gradient decoration for containers (Dark Theme)
  static BoxDecoration get secondaryGradientDecorationDark {
    return const BoxDecoration(
      gradient: secondaryGradientDark,
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    );
  }

  /// Get accent gradient decoration for containers (Dark Theme)
  static BoxDecoration get accentGradientDecorationDark {
    return const BoxDecoration(
      gradient: accentGradientDark,
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    );
  }

  /// Get shadow decoration (Light Theme)
  static List<BoxShadow> get defaultShadow {
    return [
      BoxShadow(
        color: primarySaffron.withAlpha((0.1 * 255).round()),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Get elevated shadow decoration (Light Theme)
  static List<BoxShadow> get elevatedShadow {
    return [
      BoxShadow(
        color: primarySaffron.withAlpha((0.2 * 255).round()),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Get shadow decoration (Dark Theme)
  static List<BoxShadow> get defaultShadowDark {
    return [
      BoxShadow(
        color: accentSaffronDark.withAlpha((0.15 * 255).round()),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Get elevated shadow decoration (Dark Theme)
  static List<BoxShadow> get elevatedShadowDark {
    return [
      BoxShadow(
        color: accentSaffronDark.withAlpha((0.25 * 255).round()),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
