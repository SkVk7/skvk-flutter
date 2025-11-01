/// New Theme Provider
///
/// A robust theme management solution using AsyncNotifier for reliable state management.
/// Default theme is set to follow the device system theme (light/dark mode).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hindu_theme.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

// Theme state
class ThemeState {
  final AppThemeMode mode;
  final bool isDarkMode;

  const ThemeState({
    required this.mode,
    required this.isDarkMode,
  });

  ThemeMode get themeMode {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeState copyWith({
    AppThemeMode? mode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState && other.mode == mode && other.isDarkMode == isDarkMode;
  }

  @override
  int get hashCode => mode.hashCode ^ isDarkMode.hashCode;

  @override
  String toString() => 'ThemeState(mode: $mode, isDarkMode: $isDarkMode)';
}

// Theme notifier using AsyncNotifier for robust state management
class ThemeNotifier extends AsyncNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_mode';

  @override
  Future<ThemeState> build() async {
    // Load theme from storage on initialization
    return await _loadThemeFromStorage();
  }

  bool _getIsDarkMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  Future<ThemeState> _loadThemeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Default to system theme if no preference is stored
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      final mode = AppThemeMode.values[themeIndex];
      final isDarkMode = _getIsDarkMode(mode);

      return ThemeState(mode: mode, isDarkMode: isDarkMode);
    } catch (e) {
      // Always fallback to system theme on error
      return ThemeState(mode: AppThemeMode.system, isDarkMode: _getIsDarkMode(AppThemeMode.system));
    }
  }

  Future<void> _saveThemeToStorage(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      // Silently fail if storage is not available
      // Theme will still work with system default
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final isDarkMode = _getIsDarkMode(mode);
    final newState = ThemeState(mode: mode, isDarkMode: isDarkMode);

    // Update state immediately
    state = AsyncValue.data(newState);

    // Save to storage in background
    await _saveThemeToStorage(mode);
  }

  Future<void> toggleTheme() async {
    final currentState = state.value;
    if (currentState == null) return;

    final newMode = currentState.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> refreshTheme() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadThemeFromStorage());
  }

  /// Refresh theme when system theme changes
  Future<void> refreshSystemTheme() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Only refresh if current mode is system
    if (currentState.mode == AppThemeMode.system) {
      final isDarkMode = _getIsDarkMode(AppThemeMode.system);
      final newState = ThemeState(mode: AppThemeMode.system, isDarkMode: isDarkMode);
      state = AsyncValue.data(newState);
    }
  }
}

// Main theme notifier provider
final themeNotifierProvider = AsyncNotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});

// Convenience providers for easy access
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) => state.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});

final isDarkModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) => state.isDarkMode,
    loading: () => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
    error: (_, __) =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
  );
});

final currentThemeModeProvider = Provider<AppThemeMode>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) => state.mode,
    loading: () => AppThemeMode.system,
    error: (_, __) => AppThemeMode.system,
  );
});

// Theme state provider (alias for compatibility)
final themeStateProvider = Provider<ThemeState?>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) => state,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Comprehensive theme properties provider
final themePropertiesProvider = Provider<Map<String, dynamic>>((ref) {
  final themeState = ref.watch(themeNotifierProvider);

  return themeState.when(
    data: (state) => {
      // Colors
      'backgroundColor': state.isDarkMode ? HinduTheme.backgroundDark : HinduTheme.backgroundLight,
      'surfaceColor': state.isDarkMode ? HinduTheme.surfaceDark : HinduTheme.surfaceLight,
      'surfaceVariantColor':
          state.isDarkMode ? HinduTheme.surfaceVariantDark : HinduTheme.surfaceVariantLight,
      'cardColor': state.isDarkMode ? HinduTheme.surfaceDark : HinduTheme.surfaceLight,
      'primaryTextColor': state.isDarkMode ? HinduTheme.textDark : HinduTheme.textLight,
      'secondaryTextColor':
          state.isDarkMode ? HinduTheme.textSecondaryDark : HinduTheme.textSecondaryLight,
      'tertiaryTextColor':
          state.isDarkMode ? HinduTheme.textTertiaryDark : HinduTheme.textTertiaryLight,
      'hintTextColor':
          state.isDarkMode ? HinduTheme.textTertiaryDark : HinduTheme.textTertiaryLight,
      'borderColor': state.isDarkMode ? HinduTheme.borderDark : HinduTheme.borderLight,
      'dividerColor': state.isDarkMode ? HinduTheme.dividerDark : HinduTheme.dividerLight,
      'shadowColor': state.isDarkMode ? Colors.black54 : Colors.black12,
      'primaryColor': state.isDarkMode ? HinduTheme.accentSaffronDark : HinduTheme.primarySaffron,
      'secondaryColor': state.isDarkMode ? HinduTheme.accentGoldDark : HinduTheme.primaryGold,
      'errorColor': state.isDarkMode ? HinduTheme.accentRedDark : HinduTheme.primaryRed,

      // Gradients
      'primaryGradient':
          state.isDarkMode ? HinduTheme.primaryGradientDark : HinduTheme.primaryGradient,
      'secondaryGradient':
          state.isDarkMode ? HinduTheme.secondaryGradientDark : HinduTheme.secondaryGradient,
      'accentGradient':
          state.isDarkMode ? HinduTheme.accentGradientDark : HinduTheme.accentGradient,

      // Theme mode
      'isDarkMode': state.isDarkMode,
      'themeMode': state.mode,
    },
    loading: () {
      // Default system theme properties - check system brightness
      final isSystemDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      return {
        'backgroundColor': isSystemDark ? HinduTheme.backgroundDark : HinduTheme.backgroundLight,
        'surfaceColor': isSystemDark ? HinduTheme.surfaceDark : HinduTheme.surfaceLight,
        'surfaceVariantColor':
            isSystemDark ? HinduTheme.surfaceVariantDark : HinduTheme.surfaceVariantLight,
        'cardColor': isSystemDark ? HinduTheme.surfaceDark : HinduTheme.surfaceLight,
        'primaryTextColor': isSystemDark ? HinduTheme.textDark : HinduTheme.textLight,
        'secondaryTextColor':
            isSystemDark ? HinduTheme.textSecondaryDark : HinduTheme.textSecondaryLight,
        'tertiaryTextColor':
            isSystemDark ? HinduTheme.textTertiaryDark : HinduTheme.textTertiaryLight,
        'hintTextColor': isSystemDark ? HinduTheme.textTertiaryDark : HinduTheme.textTertiaryLight,
        'borderColor': isSystemDark ? HinduTheme.borderDark : HinduTheme.borderLight,
        'dividerColor': isSystemDark ? HinduTheme.dividerDark : HinduTheme.dividerLight,
        'shadowColor': isSystemDark ? Colors.black54 : Colors.black12,
        'primaryColor': isSystemDark ? HinduTheme.accentSaffronDark : HinduTheme.primarySaffron,
        'secondaryColor': isSystemDark ? HinduTheme.accentGoldDark : HinduTheme.primaryGold,
        'errorColor': isSystemDark ? HinduTheme.accentRedDark : HinduTheme.primaryRed,
        'primaryGradient':
            isSystemDark ? HinduTheme.primaryGradientDark : HinduTheme.primaryGradient,
        'secondaryGradient':
            isSystemDark ? HinduTheme.secondaryGradientDark : HinduTheme.secondaryGradient,
        'accentGradient': isSystemDark ? HinduTheme.accentGradientDark : HinduTheme.accentGradient,
        'isDarkMode': isSystemDark,
        'themeMode': AppThemeMode.system,
      };
    },
    error: (_, __) {
      // Default system theme properties on error - check system brightness
      final isSystemDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      return {
        'backgroundColor': isSystemDark ? HinduTheme.backgroundDark : HinduTheme.backgroundLight,
        'surfaceColor': isSystemDark ? HinduTheme.surfaceDark : HinduTheme.surfaceLight,
        'surfaceVariantColor':
            isSystemDark ? HinduTheme.surfaceVariantDark : HinduTheme.surfaceVariantLight,
        'cardColor': isSystemDark ? HinduTheme.surfaceDark : HinduTheme.surfaceLight,
        'primaryTextColor': isSystemDark ? HinduTheme.textDark : HinduTheme.textLight,
        'secondaryTextColor':
            isSystemDark ? HinduTheme.textSecondaryDark : HinduTheme.textSecondaryLight,
        'tertiaryTextColor':
            isSystemDark ? HinduTheme.textTertiaryDark : HinduTheme.textTertiaryLight,
        'hintTextColor': isSystemDark ? HinduTheme.textTertiaryDark : HinduTheme.textTertiaryLight,
        'borderColor': isSystemDark ? HinduTheme.borderDark : HinduTheme.borderLight,
        'dividerColor': isSystemDark ? HinduTheme.dividerDark : HinduTheme.dividerLight,
        'shadowColor': isSystemDark ? Colors.black54 : Colors.black12,
        'primaryColor': isSystemDark ? HinduTheme.accentSaffronDark : HinduTheme.primarySaffron,
        'secondaryColor': isSystemDark ? HinduTheme.accentGoldDark : HinduTheme.primaryGold,
        'errorColor': isSystemDark ? HinduTheme.accentRedDark : HinduTheme.primaryRed,
        'primaryGradient':
            isSystemDark ? HinduTheme.primaryGradientDark : HinduTheme.primaryGradient,
        'secondaryGradient':
            isSystemDark ? HinduTheme.secondaryGradientDark : HinduTheme.secondaryGradient,
        'accentGradient': isSystemDark ? HinduTheme.accentGradientDark : HinduTheme.accentGradient,
        'isDarkMode': isSystemDark,
        'themeMode': AppThemeMode.system,
      };
    },
  );
});

// Convenience providers for specific theme properties
final backgroundColorProvider = Provider<Color>((ref) {
  final properties = ref.watch(themePropertiesProvider);
  return properties['backgroundColor'] as Color;
});

final surfaceColorProvider = Provider<Color>((ref) {
  final properties = ref.watch(themePropertiesProvider);
  return properties['surfaceColor'] as Color;
});

final cardColorProvider = Provider<Color>((ref) {
  final properties = ref.watch(themePropertiesProvider);
  return properties['cardColor'] as Color;
});

final primaryTextColorProvider = Provider<Color>((ref) {
  final properties = ref.watch(themePropertiesProvider);
  return properties['primaryTextColor'] as Color;
});

final secondaryTextColorProvider = Provider<Color>((ref) {
  final properties = ref.watch(themePropertiesProvider);
  return properties['secondaryTextColor'] as Color;
});

final primaryGradientProvider = Provider<LinearGradient>((ref) {
  final properties = ref.watch(themePropertiesProvider);
  return properties['primaryGradient'] as LinearGradient;
});

final secondaryGradientProvider = Provider<LinearGradient>((ref) {
  final properties = ref.watch(themePropertiesProvider);
  return properties['secondaryGradient'] as LinearGradient;
});

final primaryColorProvider = Provider<Color>((ref) {
  final properties = ref.watch(themePropertiesProvider);
  return properties['primaryColor'] as Color;
});

// Theme manager for backward compatibility
class NewThemeManager {
  Future<void> setThemeMode(AppThemeMode mode, WidgetRef ref) async {
    final notifier = ref.read(themeNotifierProvider.notifier);
    await notifier.setThemeMode(mode);
  }

  Future<void> toggleTheme(WidgetRef ref) async {
    final notifier = ref.read(themeNotifierProvider.notifier);
    await notifier.toggleTheme();
  }

  Future<void> refreshTheme(WidgetRef ref) async {
    final notifier = ref.read(themeNotifierProvider.notifier);
    await notifier.refreshTheme();
  }

  Future<void> refreshSystemTheme(WidgetRef ref) async {
    final notifier = ref.read(themeNotifierProvider.notifier);
    await notifier.refreshSystemTheme();
  }
}

// Theme manager provider
final newThemeManagerProvider = Provider<NewThemeManager>((ref) {
  return NewThemeManager();
});
