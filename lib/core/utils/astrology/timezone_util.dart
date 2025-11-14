/// Timezone Utility
///
/// Handles timezone conversions between local and UTC datetime.
library;

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Timezone utility for datetime conversions
class TimezoneUtil {
  static bool _initialized = false;

  /// Initialize timezone database
  static Future<void> initialize() async {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  /// Get timezone location
  static tz.Location _getLocation(String timezoneId) {
    if (!_initialized) {
      throw StateError(
        'TimezoneUtil not initialized. Call initialize() first.',
      );
    }
    try {
      return tz.getLocation(timezoneId);
    } on Exception {
      throw ArgumentError('Invalid timezone ID: $timezoneId');
    }
  }

  /// Convert local DateTime to UTC
  static DateTime convertLocalToUTC(DateTime localDateTime, String timezoneId) {
    final location = _getLocation(timezoneId);
    final tzDateTime = tz.TZDateTime(
      location,
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
      localDateTime.hour,
      localDateTime.minute,
      localDateTime.second,
      localDateTime.millisecond,
      localDateTime.microsecond,
    );
    return tzDateTime.toUtc();
  }

  /// Convert UTC DateTime to local timezone
  static DateTime convertUTCToLocal(DateTime utcDateTime, String timezoneId) {
    final location = _getLocation(timezoneId);
    final tzDateTime = tz.TZDateTime.from(utcDateTime, location);
    return DateTime(
      tzDateTime.year,
      tzDateTime.month,
      tzDateTime.day,
      tzDateTime.hour,
      tzDateTime.minute,
      tzDateTime.second,
      tzDateTime.millisecond,
      tzDateTime.microsecond,
    );
  }

  /// Validate timezone ID
  static bool isValidTimezone(String timezoneId) {
    if (!_initialized) {
      return false;
    }
    try {
      tz.getLocation(timezoneId);
      return true;
    } on Exception {
      return false;
    }
  }

  /// Get timezone from location (latitude, longitude)
  static String getTimezoneFromLocation(double latitude, double longitude) {
    if (latitude >= 6.0 &&
        latitude <= 37.0 &&
        longitude >= 68.0 &&
        longitude <= 97.0) {
      return 'Asia/Kolkata';
    }
    if (latitude >= 32.0 &&
        latitude <= 49.0 &&
        longitude >= -125.0 &&
        longitude <= -114.0) {
      return 'America/Los_Angeles';
    }
    if (latitude >= 50.0 &&
        latitude <= 61.0 &&
        longitude >= -8.0 &&
        longitude <= 2.0) {
      return 'Europe/London';
    }
    return 'UTC';
  }
}
