/// Centralized Timezone Conversion Service
///
/// This service provides a SINGLE point of timezone conversion for the entire application.
/// All timezone conversions should go through this service to ensure consistency.
library;

import 'package:skvk_application/core/logging/app_logger.dart';

/// Centralized timezone conversion service
///
/// This service ensures that all timezone conversions happen in one place,
/// preventing multiple conversions and ensuring consistency across the application.
class CentralizedTimezoneService {
  CentralizedTimezoneService._();

  factory CentralizedTimezoneService.instance() {
    return _instance ??= CentralizedTimezoneService._();
  }
  static CentralizedTimezoneService? _instance;

  final _logger = AppLogger();

  /// Convert local birth time to UTC based on birth location
  /// This is the ONLY method that should be used for timezone conversion
  ///
  /// [localTime] - The local birth time
  /// [longitude] - Birth longitude
  /// [latitude] - Birth latitude (optional, for enhanced timezone handling)
  ///
  /// Returns UTC datetime that can be passed to Astrology library
  DateTime convertLocalToUTC(
    DateTime localTime,
    double longitude, [
    double? latitude,
  ]) {
    // Use enhanced timezone handling if latitude is provided
    if (latitude != null) {
      return _convertLocalToUTCEnhanced(localTime, longitude, latitude);
    }

    // Basic timezone conversion using longitude only
    return _convertLocalToUTCBasic(localTime, longitude);
  }

  /// Basic timezone conversion using longitude only
  DateTime _convertLocalToUTCBasic(DateTime localTime, double longitude) {
    final offsetHours = longitude / 15.0;
    final offsetMinutes = (offsetHours * 60).round();

    final utcTime = localTime.subtract(Duration(minutes: offsetMinutes));

    // Log the conversion for debugging
    _logger
      ..debug(
        'Basic Timezone Conversion:',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'Local Time: ${localTime.toIso8601String()}',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'Longitude: $longitude°E',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'Offset: ${offsetHours.toStringAsFixed(2)} hours',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'UTC Time: ${utcTime.toIso8601String()}',
        source: 'CentralizedTimezoneService',
      );

    return utcTime;
  }

  /// Enhanced timezone conversion with regional corrections
  DateTime _convertLocalToUTCEnhanced(
    DateTime localTime,
    double longitude,
    double latitude,
  ) {
    final baseOffsetHours = longitude / 15.0;

    // Apply regional timezone corrections
    double regionalCorrection = 0;

    // India Standard Time (IST) - UTC+5:30
    if (longitude >= 68.0 &&
        longitude <= 97.0 &&
        latitude >= 6.0 &&
        latitude <= 37.0) {
      regionalCorrection = 5.5; // IST is UTC+5:30
    }
    // China Standard Time (CST) - UTC+8
    else if (longitude >= 73.0 &&
        longitude <= 135.0 &&
        latitude >= 18.0 &&
        latitude <= 54.0) {
      regionalCorrection = 8.0; // CST is UTC+8
    }
    // Japan Standard Time (JST) - UTC+9
    else if (longitude >= 129.0 &&
        longitude <= 146.0 &&
        latitude >= 30.0 &&
        latitude <= 46.0) {
      regionalCorrection = 9.0; // JST is UTC+9
    }
    // US Eastern Time (EST/EDT) - UTC-5/-4
    else if (longitude >= -85.0 &&
        longitude <= -66.0 &&
        latitude >= 24.0 &&
        latitude <= 49.0) {
      regionalCorrection =
          -5.0; // EST is UTC-5 (DST handling not implemented yet)
    }
    // US Pacific Time (PST/PDT) - UTC-8/-7
    else if (longitude >= -125.0 &&
        longitude <= -114.0 &&
        latitude >= 32.0 &&
        latitude <= 49.0) {
      regionalCorrection =
          -8.0; // PST is UTC-8 (DST handling not implemented yet)
    }
    // UK Time (GMT/BST) - UTC+0/+1
    else if (longitude >= -8.0 &&
        longitude <= 2.0 &&
        latitude >= 50.0 &&
        latitude <= 61.0) {
      regionalCorrection =
          0.0; // GMT is UTC+0 (DST handling not implemented yet)
    }

    // Use regional correction if available, otherwise use calculated offset
    final finalOffsetHours =
        regionalCorrection != 0.0 ? regionalCorrection : baseOffsetHours;
    final finalOffsetMinutes = (finalOffsetHours * 60).round();

    final utcTime = localTime.subtract(Duration(minutes: finalOffsetMinutes));

    // Log the conversion for debugging
    _logger
      ..debug(
        'Enhanced Timezone Conversion:',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'Local Time: ${localTime.toIso8601String()}',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'Location: $latitude°N, $longitude°E',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'Regional Correction: ${regionalCorrection != 0.0 ? regionalCorrection.toString() : "None"}',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'Final Offset: ${finalOffsetHours.toStringAsFixed(2)} hours',
        source: 'CentralizedTimezoneService',
      )
      ..debug(
        'UTC Time: ${utcTime.toIso8601String()}',
        source: 'CentralizedTimezoneService',
      );

    return utcTime;
  }

  /// Convert local birth time to UTC for astrology calculations
  /// This is the standard method to use across all business logic
  ///
  /// [localTime] - The local birth time
  /// [longitude] - Birth longitude
  /// [latitude] - Birth latitude
  ///
  /// Returns UTC datetime ready for Astrology library
  DateTime convertForAstrology(
    DateTime localTime,
    double longitude,
    double latitude,
  ) {
    return convertLocalToUTC(localTime, longitude, latitude);
  }

  /// Get timezone name from coordinates
  String getTimezoneName(double longitude, double latitude) {
    // India Standard Time (IST) - UTC+5:30
    if (longitude >= 68.0 &&
        longitude <= 97.0 &&
        latitude >= 6.0 &&
        latitude <= 37.0) {
      return 'Asia/Kolkata';
    }
    // China Standard Time (CST) - UTC+8
    else if (longitude >= 73.0 &&
        longitude <= 135.0 &&
        latitude >= 18.0 &&
        latitude <= 54.0) {
      return 'Asia/Shanghai';
    }
    // Japan Standard Time (JST) - UTC+9
    else if (longitude >= 129.0 &&
        longitude <= 146.0 &&
        latitude >= 30.0 &&
        latitude <= 46.0) {
      return 'Asia/Tokyo';
    }
    // US Eastern Time (EST/EDT) - UTC-5/-4
    else if (longitude >= -85.0 &&
        longitude <= -66.0 &&
        latitude >= 24.0 &&
        latitude <= 49.0) {
      return 'America/New_York';
    }
    // US Pacific Time (PST/PDT) - UTC-8/-7
    else if (longitude >= -125.0 &&
        longitude <= -114.0 &&
        latitude >= 32.0 &&
        latitude <= 49.0) {
      return 'America/Los_Angeles';
    }
    // UK Time (GMT/BST) - UTC+0/+1
    else if (longitude >= -8.0 &&
        longitude <= 2.0 &&
        latitude >= 50.0 &&
        latitude <= 61.0) {
      return 'Europe/London';
    }

    // Default to calculated offset
    final offsetHours = longitude / 15.0;
    final roundedOffset = offsetHours.round();
    return roundedOffset >= 0 ? 'UTC+$roundedOffset' : 'UTC$roundedOffset';
  }

  /// Calculate timezone offset in minutes from longitude
  int calculateTimezoneOffset(double longitude) {
    final offsetHours = longitude / 15.0;
    return (offsetHours * 60).round();
  }
}
