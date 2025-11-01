/// Traditional Astrological Background Gradients
///
/// Provides beautiful blended backgrounds that reflect traditional astrological aesthetics:
/// - Light Theme: Morning/Evening Sky with warm saffron and golden tones
/// - Dark Theme: Deep Sea with Night Stars and mystical cosmic colors
library;

import 'package:flutter/material.dart';

class BackgroundGradients {
  /// Morning Sky Gradient for Light Theme
  /// Represents the sacred dawn with saffron and golden tones
  static const LinearGradient morningSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF8F0), // Sacred Dawn Light (Top)
      Color(0xFFFFF1E6), // Warm Morning Glow
      Color(0xFFFFE0B2), // Golden Sunrise
      Color(0xFFFFD54F), // Sacred Saffron Light
      Color(0xFFFFB74D), // Deep Saffron
      Color(0xFFFF8A65), // Vibrant Saffron
      Color(0xFFFF6B35), // Sacred Fire Orange
    ],
    stops: [0.0, 0.2, 0.4, 0.6, 0.7, 0.85, 1.0],
  );

  /// Evening Sky Gradient for Light Theme
  /// Represents the sacred dusk with purple and orange tones
  static const LinearGradient eveningSky = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF8F0), // Sacred Evening Light
      Color(0xFFFFE0B2), // Golden Dusk
      Color(0xFFFFB74D), // Warm Orange
      Color(0xFFFF8A65), // Deep Orange
      Color(0xFF9C27B0), // Royal Purple
      Color(0xFF6A1B9A), // Deep Purple
      Color(0xFF4A148C), // Mystical Purple
    ],
    stops: [0.0, 0.15, 0.3, 0.5, 0.7, 0.85, 1.0],
  );

  /// Deep Sea Gradient for Dark Theme
  /// Represents the mystical ocean depths with orange and black blend
  static const LinearGradient deepSea = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A0E1A), // Deep Cosmic Black (Top)
      Color(0xFF1A0A0A), // Dark Orange-Black
      Color(0xFF2A0F0F), // Deep Orange-Black
      Color(0xFF3A1A0A), // Mystical Orange-Black
      Color(0xFF4A2A0A), // Deep Orange-Black
      Color(0xFF5A3A0A), // Orange-Black Depths
      Color(0xFF6A4A0A), // Sacred Orange-Black
    ],
    stops: [0.0, 0.2, 0.4, 0.6, 0.7, 0.85, 1.0],
  );

  /// Night Stars Gradient for Dark Theme
  /// Represents the cosmic night sky with orange and black blend
  static const LinearGradient nightStars = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E1A), // Deep Cosmic Black
      Color(0xFF1A0A0A), // Dark Orange-Black
      Color(0xFF2A0F0F), // Mystical Orange-Black
      Color(0xFF3A1A0A), // Deep Orange-Black
      Color(0xFF4A2A0A), // Royal Orange-Black
      Color(0xFF5A3A0A), // Cosmic Orange-Black
      Color(0xFF6A4A0A), // Mystical Orange-Black
    ],
    stops: [0.0, 0.15, 0.3, 0.5, 0.7, 0.85, 1.0],
  );

  /// Sacred Fire Gradient (Saffron)
  /// Represents the sacred fire element in Hindu tradition
  static const LinearGradient sacredFire = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF8F0), // Sacred Light
      Color(0xFFFFE0B2), // Golden Light
      Color(0xFFFFB74D), // Sacred Saffron
      Color(0xFFFF8A65), // Deep Saffron
      Color(0xFFFF6B35), // Sacred Fire
      Color(0xFFE65100), // Deep Sacred Fire
    ],
    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
  );

  /// Cosmic Ocean Gradient
  /// Represents the mystical ocean with cosmic elements
  static const LinearGradient cosmicOcean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E1A), // Deep Cosmic Black
      Color(0xFF1A1A2E), // Dark Navy
      Color(0xFF2D1B69), // Mystical Purple
      Color(0xFF1E40AF), // Ocean Blue
      Color(0xFF2563EB), // Sacred Blue
      Color(0xFF3B82F6), // Cosmic Blue
    ],
    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
  );

  /// Get the appropriate background gradient based on theme and time
  static LinearGradient getBackgroundGradient({
    required bool isDark,
    bool isEvening = false,
    bool useSacredFire = false,
  }) {
    if (useSacredFire) {
      return sacredFire;
    }

    if (isDark) {
      return isEvening ? nightStars : deepSea;
    } else {
      return isEvening ? eveningSky : morningSky;
    }
  }

  /// Get a subtle background gradient for cards and containers
  static LinearGradient getCardBackgroundGradient({
    required bool isDark,
    bool isSubtle = true,
  }) {
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isSubtle
            ? [
                const Color(0xFF1A1A2E).withAlpha(200),
                const Color(0xFF16213E).withAlpha(150),
                const Color(0xFF0F3460).withAlpha(100),
              ]
            : [
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
              ],
        stops: const [0.0, 0.5, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isSubtle
            ? [
                const Color(0xFFFFF8F0).withAlpha(200),
                const Color(0xFFFFF1E6).withAlpha(150),
                const Color(0xFFFFE0B2).withAlpha(100),
              ]
            : [
                const Color(0xFFFFF8F0),
                const Color(0xFFFFF1E6),
                const Color(0xFFFFE0B2),
              ],
        stops: const [0.0, 0.5, 1.0],
      );
    }
  }

  /// Get a vibrant accent gradient for special elements
  static LinearGradient getAccentGradient({
    required bool isDark,
    bool isPrimary = true,
  }) {
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isPrimary
            ? [
                const Color(0xFFFF8A65), // Sacred Saffron
                const Color(0xFFFF6B35), // Sacred Fire
                const Color(0xFFE65100), // Deep Sacred Fire
              ]
            : [
                const Color(0xFF8B5CF6), // Cosmic Purple
                const Color(0xFFA855F7), // Mystical Violet
                const Color(0xFF9C27B0), // Royal Purple
              ],
        stops: const [0.0, 0.5, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isPrimary
            ? [
                const Color(0xFFFFB74D), // Sacred Saffron
                const Color(0xFFFF8A65), // Deep Saffron
                const Color(0xFFFF6B35), // Sacred Fire
              ]
            : [
                const Color(0xFF9C27B0), // Royal Purple
                const Color(0xFF6A1B9A), // Deep Purple
                const Color(0xFF4A148C), // Mystical Purple
              ],
        stops: const [0.0, 0.5, 1.0],
      );
    }
  }
}
