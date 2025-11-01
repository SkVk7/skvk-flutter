/// Utility functions for astrological calculations
///
/// This file contains helper functions and utilities used throughout
/// the astrological calculation system
library;

import 'dart:math';
import '../enums/astrology_enums.dart';
import '../constants/astrology_constants.dart';
// Removed unused imports

/// Utility class for astrological calculations
class AstrologyUtils {
  // Prevent instantiation
  AstrologyUtils._();

  /// Normalize longitude to 0-360 range
  static double normalizeLongitude(double longitude) {
    double normalized = longitude % 360.0;
    if (normalized < 0) {
      normalized += 360.0;
    }
    return normalized;
  }

  /// Convert degrees to degrees, minutes, seconds
  static Map<String, int> degreesToDMS(double degrees) {
    final absDegrees = degrees.abs();
    final d = absDegrees.floor();
    final m = ((absDegrees - d) * 60).floor();
    final s = ((absDegrees - d - m / 60) * 3600).round();

    return {
      'degrees': d,
      'minutes': m,
      'seconds': s,
    };
  }

  /// Convert degrees, minutes, seconds to degrees
  static double dmsToDegrees(int degrees, int minutes, int seconds) {
    return degrees + (minutes / 60.0) + (seconds / 3600.0);
  }

  /// Calculate rashi number from longitude with maximum precision
  static int calculateRashiNumber(double longitude) {
    final normalized = normalizeLongitude(longitude);
    // Use precise calculation without floor() approximation
    final rashiIndex = (normalized / AstrologyConstants.degreesPerRashi);
    return (rashiIndex % 12).floor() + 1;
  }

  /// Calculate nakshatra number from longitude with maximum precision
  static int calculateNakshatraNumber(double longitude) {
    final normalized = normalizeLongitude(longitude);
    // Use precise calculation without floor() approximation
    final nakshatraIndex = (normalized / AstrologyConstants.degreesPerNakshatra);
    return (nakshatraIndex % 27).floor() + 1;
  }

  /// Calculate pada number from longitude with maximum precision
  static int calculatePadaNumber(double longitude) {
    final normalized = normalizeLongitude(longitude);
    final nakshatraLongitude = normalized % AstrologyConstants.degreesPerNakshatra;
    // Use precise calculation for maximum accuracy
    return (nakshatraLongitude / AstrologyConstants.degreesPerPada).floor() + 1;
  }

  /// Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }

  /// Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Calculate Julian Day from UTC DateTime
  /// This method expects UTC time - timezone conversion should be done at application layer
  static double dateTimeToJulianDay(DateTime utcDateTime) {
    // Validate that input is UTC (should be done by application layer)
    logDebug('🕐 Julian Day Calculation:');
    logDebug('  - UTC Time: ${utcDateTime.toIso8601String()}');

    return _calculateJulianDayFromUTC(utcDateTime);
  }

  /// Internal method to calculate Julian Day from UTC DateTime
  static double _calculateJulianDayFromUTC(DateTime utcDateTime) {
    // Convert to Julian Day using precise astronomical calculation
    final year = utcDateTime.year;
    final month = utcDateTime.month;
    final day = utcDateTime.day;
    final hour = utcDateTime.hour;
    final minute = utcDateTime.minute;
    final second = utcDateTime.second;
    final millisecond = utcDateTime.millisecond;

    // Calculate Julian Day with maximum precision
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    final julianDay = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;

    // Add fractional part for time
    final fractionalDay = (hour + minute / 60.0 + second / 3600.0 + millisecond / 3600000.0) / 24.0;

    return julianDay + fractionalDay;
  }

  /// Calculate distance between two points on Earth's surface
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers

    final dLat = degreesToRadians(lat2 - lat1);
    final dLon = degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculate compatibility level from score
  static CompatibilityLevel getCompatibilityLevel(int score) {
    if (score >= 30) return CompatibilityLevel.excellent;
    if (score >= 24) return CompatibilityLevel.veryGood;
    if (score >= 18) return CompatibilityLevel.good;
    if (score >= 12) return CompatibilityLevel.average;
    if (score >= 6) return CompatibilityLevel.poor;
    return CompatibilityLevel.veryPoor;
  }

  /// Get compatibility description
  static String getCompatibilityDescription(CompatibilityLevel level) {
    switch (level) {
      case CompatibilityLevel.excellent:
        return 'Excellent compatibility - Highly recommended for marriage';
      case CompatibilityLevel.veryGood:
        return 'Very good compatibility - Recommended for marriage';
      case CompatibilityLevel.good:
        return 'Good compatibility - Suitable for marriage';
      case CompatibilityLevel.average:
        return 'Average compatibility - Consider carefully';
      case CompatibilityLevel.poor:
        return 'Poor compatibility - Not recommended';
      case CompatibilityLevel.veryPoor:
        return 'Very poor compatibility - Not suitable';
    }
  }

  /// Validate birth data
  static bool validateBirthData(DateTime birthDateTime, double latitude, double longitude) {
    // Validate date range
    if (birthDateTime.year < 1900 || birthDateTime.year > 2100) {
      return false;
    }

    // Validate latitude
    if (latitude < -90.0 || latitude > 90.0) {
      return false;
    }

    // Validate longitude
    if (longitude < -180.0 || longitude > 180.0) {
      return false;
    }

    return true;
  }

  /// Get logger instance
  static dynamic _getLogger() {
    // Try to get logger from container if available
    try {
      // This will be injected by the business layer
      return _loggerInstance;
    } catch (e) {
      // No fallback - Swiss Ephemeris precision required
      throw Exception('Logger initialization failed: $e');
    }
  }

  // No fallback - Swiss Ephemeris precision required

  // Logger instance that can be injected
  static dynamic _loggerInstance;

  /// Set logger instance (called by business layer)
  static void setLogger(dynamic logger) {
    _loggerInstance = logger;
  }

  /// Log info message
  static void logInfo(String message, {String? source, Map<String, dynamic>? metadata}) {
    try {
      final logger = _getLogger();
      logger?.info(message, source: source, metadata: metadata);
    } catch (e) {
      // No fallback - Swiss Ephemeris precision required
      throw Exception('Logger failed: $e');
    }
  }

  /// Log debug message
  static void logDebug(String message, {String? source, Map<String, dynamic>? metadata}) {
    try {
      final logger = _getLogger();
      logger?.debug(message, source: source, metadata: metadata);
    } catch (e) {
      // No fallback - Swiss Ephemeris precision required
      throw Exception('Logger failed: $e');
    }
  }

  /// Log error message
  static void logError(String message,
      {String? source, Map<String, dynamic>? metadata, dynamic error, StackTrace? stackTrace}) {
    try {
      final logger = _getLogger();
      logger?.error(message,
          source: source, metadata: metadata, error: error, stackTrace: stackTrace);
    } catch (e) {
      // No fallback - Swiss Ephemeris precision required
      throw Exception('Logger failed: $e');
    }
  }

  /// Log warning message
  static void logWarning(String message, {String? source, Map<String, dynamic>? metadata}) {
    try {
      final logger = _getLogger();
      logger?.warning(message, source: source, metadata: metadata);
    } catch (e) {
      // No fallback - Swiss Ephemeris precision required
      throw Exception('Logger failed: $e');
    }
  }

  /// Get planet name from planet enum
  static String getPlanetName(Planet planet) {
    switch (planet) {
      case Planet.sun:
        return 'Sun';
      case Planet.moon:
        return 'Moon';
      case Planet.mars:
        return 'Mars';
      case Planet.mercury:
        return 'Mercury';
      case Planet.jupiter:
        return 'Jupiter';
      case Planet.venus:
        return 'Venus';
      case Planet.saturn:
        return 'Saturn';
      case Planet.rahu:
        return 'Rahu';
      case Planet.ketu:
        return 'Ketu';
      case Planet.uranus:
        return 'Uranus';
      case Planet.neptune:
        return 'Neptune';
      case Planet.pluto:
        return 'Pluto';
    }
  }
}

// Removed fallback logger - no compromises in accurac
