/// Theme System - Centralized Theme Management
///
/// This file provides a comprehensive theme system with
/// color palettes, typography, and theme management.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tokens/design_tokens.dart' as tokens;

/// Centralized theme system
class ThemeSystem {
  static ThemeSystem? _instance;
  static ThemeSystem get instance => _instance ??= ThemeSystem._();

  ThemeSystem._();

  /// Get light theme
  static ThemeData get lightTheme => _buildLightTheme();

  /// Get dark theme
  static ThemeData get darkTheme => _buildDarkTheme();

  /// Build light theme with authentic Hindu traditional colors and modern aesthetics
  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFF8F0), // Morning Sky Base
      colorScheme: const ColorScheme.light(
        // Primary Hindu Colors - Saffron (Sacred Fire)
        primary: Color(0xFFE65100), // Deep Saffron Orange (Sacred Fire)
        onPrimary: Color(0xFFFFFFFF), // Pure white for maximum contrast

        // Secondary Hindu Colors - Sacred Green (Nature/Life)
        secondary: Color(0xFF2E7D32), // Sacred Green (Nature/Life)
        onSecondary: Color(0xFFFFFFFF), // Pure white for maximum contrast

        // Tertiary Hindu Colors - Royal Purple (Spirituality)
        tertiary: Color(0xFF6A1B9A), // Royal Purple (Spirituality)
        onTertiary: Color(0xFFFFFFFF), // Pure white for maximum contrast

        // Surface Colors - Sacred White (Purity)
        surface: Color(0xFFFFFFFF), // Sacred White (Purity)
        onSurface: Color(0xFF1A1A1A), // Sacred Black (Contrast)

        // Container Colors - Sacred Earth Tones
        surfaceContainer: Color(0xFFFFF8E1), // Sacred Earth (Light Saffron)
        surfaceContainerHigh: Color(0xFFFFF3E0), // Sacred Earth (Medium Saffron)
        surfaceContainerHighest: Color(0xFFFFE0B2), // Sacred Earth (Deep Saffron)
        surfaceContainerLow: Color(0xFFFFFBF5), // Sacred Cream
        surfaceContainerLowest: Color(0xFFFFF8F0), // Sacred Light Cream

        // Variant Colors - Sacred Text
        onSurfaceVariant: Color(0xFF424242), // Sacred Gray (Readable)

        // Error Colors - Sacred Red (Warning/Protection)
        error: Color(0xFFD32F2F), // Sacred Red (Warning/Protection)
        onError: Color(0xFFFFFFFF), // Pure white for maximum contrast

        // Outline Colors - Sacred Gold (Divine)
        outline: Color(0xFFD97706), // Sacred Gold (Divine)
        outlineVariant: Color(0xFFE0E0E0), // Sacred Light Gray

        // Shadow and Overlay
        shadow: Color(0xFF000000), // Sacred Black Shadow
        scrim: Color(0xFF000000), // Sacred Black Overlay
      ),
      textTheme: _buildTextTheme(tokens.DesignTokens.lightTextColors),
      appBarTheme: _buildAppBarTheme(tokens.DesignTokens.lightAppBarColors),
      cardTheme: _buildCardTheme(tokens.DesignTokens.lightCardColors),
      elevatedButtonTheme: _buildElevatedButtonTheme(tokens.DesignTokens.lightButtonColors),
      inputDecorationTheme: _buildInputDecorationTheme(tokens.DesignTokens.lightInputColors),
      timePickerTheme: _buildTimePickerTheme(tokens.DesignTokens.lightButtonColors),
    );
  }

  /// Build dark theme with authentic Hindu traditional colors and modern aesthetics
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black Base
      colorScheme: const ColorScheme.dark(
        // Primary Hindu Colors - Saffron (Sacred Fire) with black blend
        primary: Color(0xFFFF6B35), // Vibrant Saffron Orange with black blend
        onPrimary: Color(0xFF000000), // Sacred Black for maximum contrast

        // Secondary Hindu Colors - Sacred Green (Nature/Life) with black blend
        secondary: Color(0xFF2E7D32), // Deep Sacred Green with black blend
        onSecondary: Color(0xFFFFFFFF), // Pure white for maximum contrast

        // Tertiary Hindu Colors - Royal Purple (Spirituality) with black blend
        tertiary: Color(0xFF6A1B9A), // Deep Royal Purple with black blend
        onTertiary: Color(0xFFFFFFFF), // Pure white for maximum contrast

        // Surface Colors - Pure Black (Cosmic)
        surface: Color(0xFF000000), // Pure Black (Cosmic)
        onSurface: Color(0xFFFFFFFF), // Sacred White (Contrast)

        // Container Colors - Black with subtle blends
        surfaceContainer: Color(0xFF0D1117), // Black with subtle blue blend
        surfaceContainerHigh: Color(0xFF1A1A1A), // Black with subtle gray blend
        surfaceContainerHighest: Color(0xFF2D2D2D), // Black with more gray blend
        surfaceContainerLow: Color(0xFF000000), // Pure Black
        surfaceContainerLowest: Color(0xFF000000), // Pure Black

        // Variant Colors - Sacred Text with high contrast
        onSurfaceVariant: Color(0xFFE0E0E0), // Light Gray for high contrast

        // Error Colors - Sacred Red (Warning/Protection) with black blend
        error: Color(0xFFD32F2F), // Deep Red with black blend
        onError: Color(0xFFFFFFFF), // Pure white for maximum contrast

        // Outline Colors - Sacred Saffron (Divine) with black blend
        outline: Color(0xFFFF6B35), // Vibrant Saffron with black blend
        outlineVariant: Color(0xFF333333), // Dark Gray with black blend

        // Shadow and Overlay
        shadow: Color(0xFF000000), // Sacred Black Shadow
        scrim: Color(0xFF000000), // Sacred Black Overlay
      ),
      textTheme: _buildTextTheme(tokens.DesignTokens.darkTextColors),
      appBarTheme: _buildAppBarTheme(tokens.DesignTokens.darkAppBarColors),
      cardTheme: _buildCardTheme(tokens.DesignTokens.darkCardColors),
      elevatedButtonTheme: _buildElevatedButtonTheme(tokens.DesignTokens.darkButtonColors),
      inputDecorationTheme: _buildInputDecorationTheme(tokens.DesignTokens.darkInputColors),
      timePickerTheme: _buildTimePickerTheme(tokens.DesignTokens.darkButtonColors),
    );
  }

  /// Build text theme
  static TextTheme _buildTextTheme(Map<String, Color> textColors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.displayLarge,
        fontWeight: tokens.DesignTokens.fontWeights.bold,
        color: textColors['primary'],
      ),
      displayMedium: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.displayMedium,
        fontWeight: tokens.DesignTokens.fontWeights.bold,
        color: textColors['primary'],
      ),
      displaySmall: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.displaySmall,
        fontWeight: tokens.DesignTokens.fontWeights.bold,
        color: textColors['primary'],
      ),
      headlineLarge: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.headlineLarge,
        fontWeight: tokens.DesignTokens.fontWeights.semiBold,
        color: textColors['primary'],
      ),
      headlineMedium: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.headlineMedium,
        fontWeight: tokens.DesignTokens.fontWeights.semiBold,
        color: textColors['primary'],
      ),
      headlineSmall: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.headlineSmall,
        fontWeight: tokens.DesignTokens.fontWeights.semiBold,
        color: textColors['primary'],
      ),
      titleLarge: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.titleLarge,
        fontWeight: tokens.DesignTokens.fontWeights.semiBold,
        color: textColors['primary'],
      ),
      titleMedium: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.titleMedium,
        fontWeight: tokens.DesignTokens.fontWeights.medium,
        color: textColors['primary'],
      ),
      titleSmall: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.titleSmall,
        fontWeight: tokens.DesignTokens.fontWeights.medium,
        color: textColors['primary'],
      ),
      bodyLarge: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.bodyLarge,
        fontWeight: tokens.DesignTokens.fontWeights.regular,
        color: textColors['primary'],
      ),
      bodyMedium: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.bodyMedium,
        fontWeight: tokens.DesignTokens.fontWeights.regular,
        color: textColors['primary'],
      ),
      bodySmall: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.bodySmall,
        fontWeight: tokens.DesignTokens.fontWeights.regular,
        color: textColors['secondary'],
      ),
      labelLarge: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.labelLarge,
        fontWeight: tokens.DesignTokens.fontWeights.medium,
        color: textColors['primary'],
      ),
      labelMedium: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.labelMedium,
        fontWeight: tokens.DesignTokens.fontWeights.medium,
        color: textColors['secondary'],
      ),
      labelSmall: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.labelSmall,
        fontWeight: tokens.DesignTokens.fontWeights.medium,
        color: textColors['secondary'],
      ),
    );
  }

  /// Build app bar theme
  static AppBarTheme _buildAppBarTheme(Map<String, Color> appBarColors) {
    return AppBarTheme(
      backgroundColor: appBarColors['background'],
      foregroundColor: appBarColors['foreground'],
      elevation: tokens.DesignTokens.elevations.appBar,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: tokens.DesignTokens.fontSizes.titleLarge,
        fontWeight: tokens.DesignTokens.fontWeights.semiBold,
        color: appBarColors['foreground'],
      ),
    );
  }

  /// Build card theme
  static CardThemeData _buildCardTheme(Map<String, Color> cardColors) {
    return CardThemeData(
      color: cardColors['background'],
      elevation: tokens.DesignTokens.elevations.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.DesignTokens.borderRadius.card),
      ),
      margin: EdgeInsets.all(tokens.DesignTokens.spacing.card),
    );
  }

  /// Build elevated button theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme(Map<String, Color> buttonColors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColors['primary'],
        foregroundColor: buttonColors['onPrimary'],
        elevation: tokens.DesignTokens.elevations.button,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.DesignTokens.spacing.buttonHorizontal,
          vertical: tokens.DesignTokens.spacing.buttonVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.DesignTokens.borderRadius.button),
        ),
      ),
    );
  }

  /// Build input decoration theme
  static InputDecorationTheme _buildInputDecorationTheme(Map<String, Color> inputColors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: inputColors['background'],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.DesignTokens.borderRadius.input),
        borderSide: BorderSide(color: inputColors['border']!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.DesignTokens.borderRadius.input),
        borderSide: BorderSide(color: inputColors['border']!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.DesignTokens.borderRadius.input),
        borderSide: BorderSide(color: inputColors['focused']!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.DesignTokens.borderRadius.input),
        borderSide: BorderSide(color: inputColors['error']!),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.DesignTokens.spacing.inputHorizontal,
        vertical: tokens.DesignTokens.spacing.inputVertical,
      ),
    );
  }

  /// Build time picker theme with Hindu traditional colors
  static TimePickerThemeData _buildTimePickerTheme(Map<String, Color> buttonColors) {
    return TimePickerThemeData(
      backgroundColor: buttonColors['background'] ?? const Color(0xFF1A1A1A),
      hourMinuteTextColor: buttonColors['onPrimary'] ?? Colors.white,
      hourMinuteColor: buttonColors['primary'] ?? const Color(0xFFE65100),
      dayPeriodTextColor: buttonColors['onPrimary'] ?? Colors.white,
      dayPeriodColor: buttonColors['primary'] ?? const Color(0xFFE65100),
      dialHandColor: buttonColors['primary'] ?? const Color(0xFFE65100),
      dialTextColor: buttonColors['onPrimary'] ?? Colors.white,
      entryModeIconColor: buttonColors['primary'] ?? const Color(0xFFE65100),
      helpTextStyle: TextStyle(
        color: buttonColors['onPrimary'] ?? Colors.white,
        fontSize: 12,
      ),
      hourMinuteTextStyle: TextStyle(
        color: buttonColors['onPrimary'] ?? Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      dayPeriodTextStyle: TextStyle(
        color: buttonColors['onPrimary'] ?? Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      dialTextStyle: TextStyle(
        color: buttonColors['onPrimary'] ?? Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Theme provider for state management
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

/// Theme notifier for managing theme state
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

/// Theme extensions for custom colors
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.background,
    required this.error,
    required this.warning,
    required this.success,
    required this.info,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color background;
  final Color error;
  final Color warning;
  final Color success;
  final Color info;

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? surface,
    Color? background,
    Color? error,
    Color? warning,
    Color? success,
    Color? info,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Theme utilities
class ThemeUtils {
  /// Get app colors from context
  static AppColors appColors(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ??
        const AppColors(
          primary: Colors.blue,
          secondary: Colors.grey,
          accent: Colors.orange,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.red,
          warning: Colors.orange,
          success: Colors.green,
          info: Colors.blue,
        );
  }

  /// Check if dark mode is enabled
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get contrast color
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Check if two colors have sufficient contrast ratio
  static bool hasSufficientContrast(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();

    final lighter =
        foregroundLuminance > backgroundLuminance ? foregroundLuminance : backgroundLuminance;
    final darker =
        foregroundLuminance > backgroundLuminance ? backgroundLuminance : foregroundLuminance;

    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    return contrastRatio >= 4.5; // WCAG AA standard
  }

  /// Get high contrast text color for a given background
  static Color getHighContrastTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    // Use pure white or black for maximum contrast
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }
}

/// Centralized theme properties provider
class ThemeProperties {
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getSurfaceContainerColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainer;
  }

  static Color getSurfaceContainerHighColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHigh;
  }

  static Color getSurfaceContainerHighestColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getCardSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainer;
  }

  static Color getCardTertiaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHigh;
  }

  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color getTertiaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round());
  }

  static Color getHintTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round());
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline.withAlpha((0.3 * 255).round());
  }

  static Color getShadowColor(BuildContext context) {
    return ThemeUtils.isDarkMode(context) ? Colors.black54 : Colors.black12;
  }

  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  static Color getSuccessColor(BuildContext context) {
    return Colors.green;
  }

  static Color getTransparentColor(BuildContext context) {
    return Colors.transparent;
  }

  static LinearGradient getPrimaryGradient(BuildContext context) {
    final primary = getPrimaryColor(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary,
        primary.withAlpha((0.8 * 255).round()),
      ],
    );
  }

  static LinearGradient getSecondaryGradient(BuildContext context) {
    final secondary = getSecondaryColor(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        secondary,
        secondary.withAlpha((0.8 * 255).round()),
      ],
    );
  }

  static LinearGradient getAccentGradient(BuildContext context) {
    final accent = Theme.of(context).colorScheme.tertiary;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent,
        accent.withAlpha((0.8 * 255).round()),
      ],
    );
  }

  /// Get circular shadow effects for consistent hover animations
  static List<BoxShadow> getCircularShadows(
    BuildContext context, {
    Color? shadowColor,
    double intensity = 1.0,
    bool isHovered = false,
  }) {
    final primaryColor = getPrimaryColor(context);
    final color = shadowColor ?? primaryColor;
    final hoverMultiplier = isHovered ? 1.5 : 1.0;
    final alphaMultiplier = intensity * hoverMultiplier;

    return [
      // Primary shadow - soft and circular
      BoxShadow(
        color: color.withAlpha((20 * alphaMultiplier).round()),
        blurRadius: 4 * hoverMultiplier,
        offset: Offset(0, 2 * hoverMultiplier),
      ),
      // Secondary shadow - larger and more diffused
      BoxShadow(
        color: color.withAlpha((10 * alphaMultiplier).round()),
        blurRadius: 8 * hoverMultiplier,
        offset: Offset(0, 4 * hoverMultiplier),
      ),
      // Tertiary shadow - very soft and wide
      BoxShadow(
        color: color.withAlpha((5 * alphaMultiplier).round()),
        blurRadius: 16 * hoverMultiplier,
        offset: Offset(0, 8 * hoverMultiplier),
      ),
    ];
  }

  /// Get elevated shadow effects for cards and elevated components
  static List<BoxShadow> getElevatedShadows(
    BuildContext context, {
    Color? shadowColor,
    double elevation = 1.0,
  }) {
    final primaryColor = getPrimaryColor(context);
    final color = shadowColor ?? primaryColor;

    return [
      // Primary shadow - soft and circular
      BoxShadow(
        color: color.withAlpha((15 * elevation).round()),
        blurRadius: 6 * elevation,
        offset: Offset(0, 3 * elevation),
      ),
      // Secondary shadow - larger and more diffused
      BoxShadow(
        color: color.withAlpha((8 * elevation).round()),
        blurRadius: 12 * elevation,
        offset: Offset(0, 6 * elevation),
      ),
      // Tertiary shadow - very soft and wide
      BoxShadow(
        color: color.withAlpha((4 * elevation).round()),
        blurRadius: 24 * elevation,
        offset: Offset(0, 12 * elevation),
      ),
    ];
  }

  /// Get text color for the current theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ??
        (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black);
  }

  /// Get text selection theme
  static TextSelectionThemeData getTextSelectionTheme(BuildContext context) {
    return Theme.of(context).textSelectionTheme;
  }

  /// Get input decoration theme
  static InputDecorationTheme getInputDecorationTheme(BuildContext context) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }

  /// Get icon theme
  static IconThemeData getIconTheme(BuildContext context) {
    return Theme.of(context).iconTheme;
  }

  /// Get primary icon theme
  static IconThemeData getPrimaryIconTheme(BuildContext context) {
    return Theme.of(context).primaryIconTheme;
  }

  /// Get slider theme
  static SliderThemeData getSliderTheme(BuildContext context) {
    return Theme.of(context).sliderTheme;
  }

  /// Get tab bar theme
  static TabBarTheme getTabBarTheme(BuildContext context) {
    return TabBarTheme(
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  /// Get tooltip theme
  static TooltipThemeData getTooltipTheme(BuildContext context) {
    return Theme.of(context).tooltipTheme;
  }

  /// Get card theme
  static CardTheme getCardTheme(BuildContext context) {
    return CardTheme(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Get chip theme
  static ChipThemeData getChipTheme(BuildContext context) {
    return Theme.of(context).chipTheme;
  }

  /// Get app bar theme
  static AppBarTheme getAppBarTheme(BuildContext context) {
    return AppBarTheme(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    );
  }

  /// Get bottom navigation bar theme
  static BottomNavigationBarThemeData getBottomNavigationBarTheme(BuildContext context) {
    return Theme.of(context).bottomNavigationBarTheme;
  }

  /// Get elevated button theme
  static ElevatedButtonThemeData getElevatedButtonTheme(BuildContext context) {
    return Theme.of(context).elevatedButtonTheme;
  }

  /// Get outlined button theme
  static OutlinedButtonThemeData getOutlinedButtonTheme(BuildContext context) {
    return Theme.of(context).outlinedButtonTheme;
  }

  /// Get text button theme
  static TextButtonThemeData getTextButtonTheme(BuildContext context) {
    return Theme.of(context).textButtonTheme;
  }

  /// Get floating action button theme
  static FloatingActionButtonThemeData getFloatingActionButtonTheme(BuildContext context) {
    return Theme.of(context).floatingActionButtonTheme;
  }

  /// Get navigation bar theme
  static NavigationBarThemeData getNavigationBarTheme(BuildContext context) {
    return Theme.of(context).navigationBarTheme;
  }

  /// Get navigation rail theme
  static NavigationRailThemeData getNavigationRailTheme(BuildContext context) {
    return Theme.of(context).navigationRailTheme;
  }

  /// Get drawer theme
  static DrawerThemeData getDrawerTheme(BuildContext context) {
    return Theme.of(context).drawerTheme;
  }

  /// Get list tile theme
  static ListTileThemeData getListTileTheme(BuildContext context) {
    return Theme.of(context).listTileTheme;
  }

  /// Get switch theme
  static SwitchThemeData getSwitchTheme(BuildContext context) {
    return Theme.of(context).switchTheme;
  }

  /// Get radio theme
  static RadioThemeData getRadioTheme(BuildContext context) {
    return Theme.of(context).radioTheme;
  }

  /// Get checkbox theme
  static CheckboxThemeData getCheckboxTheme(BuildContext context) {
    return Theme.of(context).checkboxTheme;
  }

  /// Get dialog theme
  static DialogTheme getDialogTheme(BuildContext context) {
    return DialogTheme(
      backgroundColor: Theme.of(context).colorScheme.surface,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      contentTextStyle: Theme.of(context).textTheme.bodyMedium,
    );
  }

  /// Get banner theme
  static MaterialBannerThemeData getBannerTheme(BuildContext context) {
    return MaterialBannerThemeData(
      backgroundColor: Theme.of(context).colorScheme.surface,
      contentTextStyle: Theme.of(context).textTheme.bodyMedium,
    );
  }

  /// Get snack bar theme
  static SnackBarThemeData getSnackBarTheme(BuildContext context) {
    return Theme.of(context).snackBarTheme;
  }

  /// Get bottom sheet theme
  static BottomSheetThemeData getBottomSheetTheme(BuildContext context) {
    return Theme.of(context).bottomSheetTheme;
  }

  /// Get time picker theme
  static TimePickerThemeData getTimePickerTheme(BuildContext context) {
    return Theme.of(context).timePickerTheme;
  }

  /// Get date picker theme
  static DatePickerThemeData getDatePickerTheme(BuildContext context) {
    return Theme.of(context).datePickerTheme;
  }

  /// Get data table theme
  static DataTableThemeData getDataTableTheme(BuildContext context) {
    return Theme.of(context).dataTableTheme;
  }

  /// Get expansion tile theme
  static ExpansionTileThemeData getExpansionTileTheme(BuildContext context) {
    return Theme.of(context).expansionTileTheme;
  }

  /// Get progress indicator theme
  static ProgressIndicatorThemeData getProgressIndicatorTheme(BuildContext context) {
    return Theme.of(context).progressIndicatorTheme;
  }

  /// Get segmented button theme
  static SegmentedButtonThemeData getSegmentedButtonTheme(BuildContext context) {
    return Theme.of(context).segmentedButtonTheme;
  }

  /// Get menu theme
  static MenuThemeData getMenuTheme(BuildContext context) {
    return Theme.of(context).menuTheme;
  }

  /// Get menu bar theme
  static MenuBarThemeData getMenuBarTheme(BuildContext context) {
    return Theme.of(context).menuBarTheme;
  }

  /// Get menu button theme
  static MenuButtonThemeData getMenuButtonTheme(BuildContext context) {
    return Theme.of(context).menuButtonTheme;
  }

  /// Get popup menu theme
  static PopupMenuThemeData getPopupMenuTheme(BuildContext context) {
    return Theme.of(context).popupMenuTheme;
  }

  /// Get search bar theme
  static SearchBarThemeData getSearchBarTheme(BuildContext context) {
    return Theme.of(context).searchBarTheme;
  }

  /// Get search view theme
  static SearchViewThemeData getSearchViewTheme(BuildContext context) {
    return Theme.of(context).searchViewTheme;
  }

  /// Get badge theme
  static BadgeThemeData getBadgeTheme(BuildContext context) {
    return Theme.of(context).badgeTheme;
  }

  /// Get divider theme
  static DividerThemeData getDividerTheme(BuildContext context) {
    return Theme.of(context).dividerTheme;
  }

  /// Get scrollbar theme
  static ScrollbarThemeData getScrollbarTheme(BuildContext context) {
    return Theme.of(context).scrollbarTheme;
  }

  /// Get app bar text color (white for contrast against primary color)
  static Color getAppBarTextColor(BuildContext context) {
    return Colors.white;
  }
}
