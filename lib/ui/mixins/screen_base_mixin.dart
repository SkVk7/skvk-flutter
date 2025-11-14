/// Screen Base Mixin
///
/// Provides common functionality for all screens including:
/// - Background gradient setup
/// - Theme detection
/// - Common screen utilities
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart';

/// Mixin for common screen functionality
mixin ScreenBaseMixin<T extends StatefulWidget> on State<T> {
  /// Get background gradient based on current theme
  LinearGradient getBackgroundGradient({
    bool isEvening = false,
    bool useSacredFire = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
      isEvening: isEvening,
      useSacredFire: useSacredFire,
    );
  }

  /// Check if current theme is dark
  bool get isDarkTheme => Theme.of(context).brightness == Brightness.dark;

  /// Get decorated container with background gradient
  Widget getDecoratedContainer({
    required Widget child,
    bool isEvening = false,
    bool useSacredFire = false,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: getBackgroundGradient(
          isEvening: isEvening,
          useSacredFire: useSacredFire,
        ),
      ),
      child: child,
    );
  }
}
