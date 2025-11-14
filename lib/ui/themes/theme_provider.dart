/// Theme Provider
///
/// A robust theme management solution using AsyncNotifier for reliable state management.
/// Supports Light, Dark, and System themes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/ui/themes/app_themes.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme state
@immutable
class ThemeState {
  const ThemeState({
    required this.mode,
    required this.isDarkMode,
  });
  final AppThemeMode mode;
  final bool isDarkMode;

  ThemeMode get themeMode {
    if (mode == AppThemeMode.system) {
      return ThemeMode.system;
    }
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// Get the current theme data
  ThemeData get theme {
    return AppThemes.getTheme(isDark: isDarkMode);
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
    return other is ThemeState &&
        other.mode == mode &&
        other.isDarkMode == isDarkMode;
  }

  @override
  int get hashCode => mode.hashCode ^ isDarkMode.hashCode;

  @override
  String toString() => 'ThemeState(mode: $mode, isDarkMode: $isDarkMode)';
}

/// Theme notifier using AsyncNotifier for robust state management
class ThemeNotifier extends AsyncNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_mode';

  @override
  Future<ThemeState> build() async {
    return _loadThemeFromStorage();
  }

  /// Determine if dark mode based on theme mode
  bool _getIsDarkMode(AppThemeMode mode) {
    if (mode == AppThemeMode.dark) return true;
    if (mode == AppThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    // Light mode
    return false;
  }

  Future<ThemeState> _loadThemeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      final mode = AppThemeMode.values[themeIndex];
      final isDarkMode = _getIsDarkMode(mode);

      return ThemeState(
        mode: mode,
        isDarkMode: isDarkMode,
      );
    } on Exception {
      return const ThemeState(
        mode: AppThemeMode.system,
        isDarkMode: false,
      );
    }
  }

  Future<void> _saveThemeToStorage(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } on Exception {
      // Silently fail if storage is not available
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    final isDarkMode = _getIsDarkMode(mode);
    final newState = ThemeState(
      mode: mode,
      isDarkMode: isDarkMode,
    );

    state = AsyncValue.data(newState);
    await _saveThemeToStorage(mode);
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    final currentState = state.value;
    if (currentState == null) return;

    AppThemeMode newMode;
    if (currentState.mode == AppThemeMode.system) {
      newMode =
          currentState.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    } else {
      newMode =
          currentState.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    }

    final isDarkMode = _getIsDarkMode(newMode);
    final newState = ThemeState(
      mode: newMode,
      isDarkMode: isDarkMode,
    );

    state = AsyncValue.data(newState);
    await _saveThemeToStorage(newMode);
  }

  /// Refresh theme from storage
  Future<void> refreshTheme() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadThemeFromStorage);
  }

  /// Refresh theme when system theme changes
  Future<void> refreshSystemTheme() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.mode == AppThemeMode.system) {
      final isDarkMode = _getIsDarkMode(AppThemeMode.system);
      final newState = ThemeState(
        mode: AppThemeMode.system,
        isDarkMode: isDarkMode,
      );
      state = AsyncValue.data(newState);
    }
  }
}

// Main theme notifier provider
final themeNotifierProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeState>(() {
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

final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) => state.theme,
    loading: () => AppThemes.lightTheme,
    error: (_, __) => AppThemes.lightTheme,
  );
});

final isDarkModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) => state.isDarkMode,
    loading: () =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark,
    error: (_, __) =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark,
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
