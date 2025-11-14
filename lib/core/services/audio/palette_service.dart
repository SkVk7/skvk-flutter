/// Palette Service
///
/// Extracts color palette from cover art images using palette_generator
library;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';

/// Palette Colors - Extracted color palette from image
class PaletteColors {
  const PaletteColors({
    this.dominant,
    this.vibrant,
    this.lightVibrant,
    this.darkVibrant,
    this.muted,
    this.lightMuted,
    this.darkMuted,
    this.isDark = false,
  });
  final Color? dominant;
  final Color? vibrant;
  final Color? lightVibrant;
  final Color? darkVibrant;
  final Color? muted;
  final Color? lightMuted;
  final Color? darkMuted;
  final bool isDark;

  /// Get best color for lyric highlighting
  /// Tries vibrant first, then dominant, then lightVibrant, then fallback
  Color getHighlightColor(Color fallback) {
    // Try vibrant (highest population)
    if (vibrant != null) {
      return vibrant!;
    }
    // Try dominant
    if (dominant != null) {
      return dominant!;
    }
    // Try lightVibrant
    if (lightVibrant != null) {
      return lightVibrant!;
    }
    // Fallback
    return fallback;
  }
}

/// Palette Service - Extracts colors from images
class PaletteService {
  static const Duration _timeout = Duration(seconds: 10);

  /// Extract color palette from image URL
  ///
  /// Downloads image, extracts palette, and returns PaletteColors
  /// Falls back to default colors if extraction fails
  static Future<PaletteColors> extractColors(
    String imageUrl, {
    Color fallback = const Color(0xFFF38F31), // Saffron accent
  }) async {
    if (imageUrl.isEmpty) {
      return const PaletteColors();
    }

    try {
      // Download image
      final response = await http.get(Uri.parse(imageUrl)).timeout(_timeout);

      if (response.statusCode != 200) {
        await LoggingHelper.logError(
          'Failed to download image: ${response.statusCode}',
          source: 'PaletteService',
        );
        return const PaletteColors();
      }

      final imageProvider = MemoryImage(response.bodyBytes);

      // Generate palette
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
      );

      // Determine if image is dark
      final isDark = _isImageDark(paletteGenerator);

      return PaletteColors(
        dominant: paletteGenerator.dominantColor?.color,
        vibrant: paletteGenerator.vibrantColor?.color,
        lightVibrant: paletteGenerator.lightVibrantColor?.color,
        darkVibrant: paletteGenerator.darkVibrantColor?.color,
        muted: paletteGenerator.mutedColor?.color,
        lightMuted: paletteGenerator.lightMutedColor?.color,
        darkMuted: paletteGenerator.darkMutedColor?.color,
        isDark: isDark,
      );
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to extract colors from image: $imageUrl',
        source: 'PaletteService',
        error: e,
      );
      return const PaletteColors();
    }
  }

  /// Check if image is dark based on dominant color
  static bool _isImageDark(PaletteGenerator generator) {
    final dominant = generator.dominantColor?.color;
    if (dominant == null) return false;

    final luminance = (0.299 * (dominant.r * 255.0).round() +
            0.587 * (dominant.g * 255.0).round() +
            0.114 * (dominant.b * 255.0).round()) /
        255;

    return luminance < 0.5;
  }

  /// Adjust color brightness for contrast
  ///
  /// If image is dark, lighten color by 12%
  /// If image is light, darken color by 12%
  static Color adjustColorForContrast(Color color, {required bool isDark}) {
    if (isDark) {
      // Lighten by 12%
      final r = (color.r * 255.0).round();
      final g = (color.g * 255.0).round();
      final b = (color.b * 255.0).round();
      return Color.fromRGBO(
        (r + (255 - r) * 0.12).clamp(0, 255).toInt(),
        (g + (255 - g) * 0.12).clamp(0, 255).toInt(),
        (b + (255 - b) * 0.12).clamp(0, 255).toInt(),
        color.a,
      );
    } else {
      // Darken by 12%
      final r = (color.r * 255.0).round();
      final g = (color.g * 255.0).round();
      final b = (color.b * 255.0).round();
      return Color.fromRGBO(
        (r * 0.88).clamp(0, 255).toInt(),
        (g * 0.88).clamp(0, 255).toInt(),
        (b * 0.88).clamp(0, 255).toInt(),
        color.a,
      );
    }
  }
}
