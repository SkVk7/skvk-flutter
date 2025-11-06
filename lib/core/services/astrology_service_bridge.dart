/// Astrology Service Bridge
///
/// Central facade for all astrology API calls.
/// Ensures proper UTC-local datetime conversions and no direct API calls.
library;

import 'package:flutter/foundation.dart';
import 'astrology_api_service.dart';
import '../utils/timezone_util.dart';

/// Astrology Service Bridge
///
/// Single entry point for all astrology API calls.
/// Handles timezone conversions (local ↔ UTC) automatically.
class AstrologyServiceBridge {
  static AstrologyServiceBridge? _instance;
  final AstrologyApiService _apiService;

  AstrologyServiceBridge._(this._apiService);

  /// Factory constructor
  factory AstrologyServiceBridge.create({
    AstrologyApiService? apiService,
  }) {
    return AstrologyServiceBridge._(
      apiService ?? AstrologyApiService.instance,
    );
  }

  /// Get singleton instance
  static AstrologyServiceBridge get instance {
    _instance ??= AstrologyServiceBridge.create();
    return _instance!;
  }

  /// Get full birth chart from API
  ///
  /// Converts local datetime to UTC before API call.
  /// Returns Map<String, dynamic> with full birth chart.
  /// Always fetches full birth chart (for user's own data).
  /// Minimal birth chart for compatibility is handled internally by compatibility API.
  Future<Map<String, dynamic>> getBirthData({
    required DateTime localBirthDateTime,
    required String timezoneId,
    required double latitude,
    required double longitude,
    String ayanamsha = "lahiri",
    String houseSystem = "placidus",
  }) async {
    try {
      // Validate timezone
      if (!TimezoneUtil.isValidTimezone(timezoneId)) {
        throw ArgumentError('Invalid timezone: $timezoneId');
      }

      // Convert local datetime to UTC
      final utcBirthDateTime = TimezoneUtil.convertLocalToUTC(
        localBirthDateTime,
        timezoneId,
      );

      // Call API with UTC datetime (always fetches full birth chart for user's own data)
      final response = await _apiService.getBirthData(
        utcBirthDateTime: utcBirthDateTime,
        latitude: latitude,
        longitude: longitude,
        timezoneId: timezoneId,
        ayanamsha: ayanamsha,
        houseSystem: houseSystem,
      );

      // Convert UTC timestamps in response to local
      return _convertResponseToLocal(response, timezoneId);
    } catch (e) {
      debugPrint('Error in getBirthData: $e');
      rethrow;
    }
  }

  /// Calculate compatibility from API
  ///
  /// Converts local datetimes to UTC before API call.
  /// Returns Map<String, dynamic> with compatibility scores.
  /// The API internally handles birth chart fetching and caching - no need to fetch separately.
  Future<Map<String, dynamic>> calculateCompatibility({
    required DateTime localPerson1BirthDateTime,
    required String person1TimezoneId,
    required double person1Latitude,
    required double person1Longitude,
    required DateTime localPerson2BirthDateTime,
    required String person2TimezoneId,
    required double person2Latitude,
    required double person2Longitude,
    String ayanamsha = "lahiri",
    String houseSystem = "placidus",
  }) async {
    try {
      // Validate timezones
      if (!TimezoneUtil.isValidTimezone(person1TimezoneId)) {
        throw ArgumentError('Invalid person1 timezone: $person1TimezoneId');
      }
      if (!TimezoneUtil.isValidTimezone(person2TimezoneId)) {
        throw ArgumentError('Invalid person2 timezone: $person2TimezoneId');
      }

      // Convert local datetimes to UTC for API call
      final utcPerson1BirthDateTime = TimezoneUtil.convertLocalToUTC(
            localPerson1BirthDateTime,
        person1TimezoneId,
          );

      final utcPerson2BirthDateTime = TimezoneUtil.convertLocalToUTC(
            localPerson2BirthDateTime,
              person2TimezoneId,
            );

      // Call compatibility API directly with groom/bride data
      // The API will internally check cache and fetch birth charts if needed
      final response = await _apiService.calculateCompatibility(
        groomDateOfBirth: utcPerson1BirthDateTime.toIso8601String().split('T')[0],
        groomTimeOfBirth: utcPerson1BirthDateTime.toIso8601String().split('T')[1].split('.')[0],
        groomLatitude: person1Latitude,
        groomLongitude: person1Longitude,
        groomTimezoneId: person1TimezoneId,
        brideDateOfBirth: utcPerson2BirthDateTime.toIso8601String().split('T')[0],
        brideTimeOfBirth: utcPerson2BirthDateTime.toIso8601String().split('T')[1].split('.')[0],
        brideLatitude: person2Latitude,
        brideLongitude: person2Longitude,
        brideTimezoneId: person2TimezoneId,
        ayanamsha: ayanamsha,
        houseSystem: houseSystem,
      );

      // Convert UTC timestamps in response to local
      // Groom birth data should use groom's timezone, bride birth data should use bride's timezone
      return _convertCompatibilityResponseToLocal(response, person1TimezoneId, person2TimezoneId);
    } catch (e) {
      debugPrint('Error in calculateCompatibility: $e');
      rethrow;
    }
  }


  /// Get predictions from API
  ///
  /// Converts local datetime to UTC before API call.
  /// Returns Map<String, dynamic> with predictions data.
  Future<Map<String, dynamic>> getPredictions({
    required DateTime localBirthDateTime,
    required String birthTimezoneId,
    required double birthLatitude,
    required double birthLongitude,
    required DateTime localTargetDateTime,
    required String targetTimezoneId,
    required double currentLatitude,
    required double currentLongitude,
    required String predictionType,
    String ayanamsha = "lahiri",
    String houseSystem = "placidus",
  }) async {
    try {
      // Validate timezones
      if (!TimezoneUtil.isValidTimezone(birthTimezoneId)) {
        throw ArgumentError('Invalid birth timezone: $birthTimezoneId');
      }
      if (!TimezoneUtil.isValidTimezone(targetTimezoneId)) {
        throw ArgumentError('Invalid target timezone: $targetTimezoneId');
      }

      // Convert local birth datetime to UTC
      final utcBirthDateTime = TimezoneUtil.convertLocalToUTC(
        localBirthDateTime,
        birthTimezoneId,
      );
      final birthDateTime = utcBirthDateTime.toIso8601String();

      // Convert local target datetime to UTC for targetDate
      final utcTargetDateTime = TimezoneUtil.convertLocalToUTC(
        localTargetDateTime,
        targetTimezoneId,
      );
      final targetDate = utcTargetDateTime.toIso8601String().split('T')[0];

      // Call API with birth data and current location
      final response = await _apiService.getPredictions(
        birthDateTime: birthDateTime,
        birthLatitude: birthLatitude,
        birthLongitude: birthLongitude,
        currentLatitude: currentLatitude,
        currentLongitude: currentLongitude,
        predictionType: predictionType,
        targetDate: targetDate,
        ayanamsha: ayanamsha,
        houseSystem: houseSystem,
      );

      // Convert UTC timestamps in response to local
      return _convertResponseToLocal(response, targetTimezoneId);
    } catch (e) {
      debugPrint('Error in getPredictions: $e');
      rethrow;
    }
  }

  /// Get calendar year from API
  ///
  /// Returns Map<String, dynamic> with year calendar data.
  /// Ayanamsha is required for accurate nakshatra calculations (sidereal zodiac).
  /// House system is NOT needed for calendar calculations.
  Future<Map<String, dynamic>> getCalendarYear({
    required int year,
    required String region,
    required double latitude,
    required double longitude,
    required String timezoneId,
    String ayanamsha = "lahiri",
  }) async {
    try {
      // Validate timezone
      if (!TimezoneUtil.isValidTimezone(timezoneId)) {
        throw ArgumentError('Invalid timezone: $timezoneId');
      }

      // Call API (ayanamsha required for nakshatra calculations)
      final response = await _apiService.getCalendarYear(
        year: year,
        region: region,
        latitude: latitude,
        longitude: longitude,
        timezoneId: timezoneId,
        ayanamsha: ayanamsha,
      );

      // Convert UTC timestamps in response to local
      return _convertResponseToLocal(response, timezoneId);
    } catch (e) {
      debugPrint('Error in getCalendarYear: $e');
      rethrow;
    }
  }

  /// Get calendar month from API
  ///
  /// Returns Map<String, dynamic> with month calendar data.
  /// Ayanamsha is required for accurate nakshatra, tithi, yoga, karana calculations (sidereal zodiac).
  /// House system is NOT needed for calendar calculations.
  Future<Map<String, dynamic>> getCalendarMonth({
    required int year,
    required int month,
    required String region,
    required double latitude,
    required double longitude,
    required String timezoneId,
    String ayanamsha = "lahiri",
  }) async {
    try {
      // Validate timezone
      if (!TimezoneUtil.isValidTimezone(timezoneId)) {
        throw ArgumentError('Invalid timezone: $timezoneId');
      }

      // Call API (ayanamsha required for nakshatra, tithi, yoga, karana calculations)
      final response = await _apiService.getCalendarMonth(
        year: year,
        month: month,
        region: region,
        latitude: latitude,
        longitude: longitude,
        timezoneId: timezoneId,
        ayanamsha: ayanamsha,
      );

      // Convert UTC timestamps in response to local
      return _convertResponseToLocal(response, timezoneId);
    } catch (e) {
      debugPrint('Error in getCalendarMonth: $e');
      rethrow;
    }
  }

  /// Get timezone from location
  static String getTimezoneFromLocation(double latitude, double longitude) {
    return TimezoneUtil.getTimezoneFromLocation(latitude, longitude);
  }

  /// Convert compatibility response timestamps from UTC to local timezones
  /// Groom birth data uses groom's timezone, bride birth data uses bride's timezone
  Map<String, dynamic> _convertCompatibilityResponseToLocal(
    Map<String, dynamic> response,
    String groomTimezoneId,
    String brideTimezoneId,
  ) {
    final converted = Map<String, dynamic>.from(response);

    // Convert groom birth data to groom's timezone
    if (converted.containsKey('groomBirthData')) {
      final groomBirthData = converted['groomBirthData'] as Map<String, dynamic>?;
      if (groomBirthData != null) {
        converted['groomBirthData'] = _convertResponseToLocal(groomBirthData, groomTimezoneId);
      }
    }

    // Convert bride birth data to bride's timezone
    if (converted.containsKey('brideBirthData')) {
      final brideBirthData = converted['brideBirthData'] as Map<String, dynamic>?;
      if (brideBirthData != null) {
        converted['brideBirthData'] = _convertResponseToLocal(brideBirthData, brideTimezoneId);
      }
    }

    // Convert other timestamps (calculatedAt, etc.) to groom's timezone (default)
    if (converted.containsKey('calculatedAt')) {
      final utcString = converted['calculatedAt'] as String?;
      if (utcString != null) {
        try {
          final utcDateTime = DateTime.parse(utcString);
          final localDateTime = TimezoneUtil.convertUTCToLocal(utcDateTime, groomTimezoneId);
          converted['calculatedAt'] = localDateTime.toIso8601String();
        } catch (e) {
          debugPrint('Error converting calculatedAt: $e');
        }
      }
    }

    return converted;
  }

  /// Convert API response timestamps from UTC to local timezone
  Map<String, dynamic> _convertResponseToLocal(
    Map<String, dynamic> response,
    String timezoneId,
  ) {
    final converted = Map<String, dynamic>.from(response);

    // Convert birthDateTime if present
    if (converted.containsKey('birthDateTime')) {
      final utcString = converted['birthDateTime'] as String;
      try {
        final utcDateTime = DateTime.parse(utcString);
        final localDateTime = TimezoneUtil.convertUTCToLocal(utcDateTime, timezoneId);
        converted['birthDateTime'] = localDateTime.toIso8601String();
      } catch (e) {
        debugPrint('Error converting birthDateTime: $e');
      }
    }

    // Convert calculatedAt if present
    if (converted.containsKey('calculatedAt')) {
      final utcString = converted['calculatedAt'] as String?;
      if (utcString != null) {
        try {
          final utcDateTime = DateTime.parse(utcString);
          final localDateTime = TimezoneUtil.convertUTCToLocal(utcDateTime, timezoneId);
          converted['calculatedAt'] = localDateTime.toIso8601String();
        } catch (e) {
          debugPrint('Error converting calculatedAt: $e');
        }
      }
    }

    // Convert calendar-specific date/time fields
    _convertCalendarDateFields(converted, timezoneId);

    // Recursively convert nested objects
    converted.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        converted[key] = _convertResponseToLocal(value, timezoneId);
      } else if (value is List) {
        converted[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _convertResponseToLocal(item, timezoneId);
          }
          return item;
        }).toList();
      }
    });

    return converted;
  }

  /// Convert calendar-specific date fields from UTC to local timezone
  /// Handles: date, sunrise, sunset, moonrise, moonset, and other time fields
  void _convertCalendarDateFields(Map<String, dynamic> data, String timezoneId) {
    // List of calendar date/time fields that need conversion
    final dateTimeFields = [
      'date',
      'sunrise',
      'sunset',
      'moonrise',
      'moonset',
      'sunriseTime',
      'sunsetTime',
      'moonriseTime',
      'moonsetTime',
      'startTime',
      'endTime',
      'time',
    ];

    for (final field in dateTimeFields) {
      if (data.containsKey(field)) {
        final value = data[field];
        if (value is String && value.isNotEmpty) {
          try {
            final utcDateTime = DateTime.parse(value);
            final localDateTime = TimezoneUtil.convertUTCToLocal(utcDateTime, timezoneId);
            data[field] = localDateTime.toIso8601String();
          } catch (e) {
            // If parsing fails, it might not be a datetime field - skip silently
            // (could be a date string like "2024-01-15" which doesn't need conversion)
          }
        } else if (value is DateTime) {
          try {
            final localDateTime = TimezoneUtil.convertUTCToLocal(value, timezoneId);
            data[field] = localDateTime.toIso8601String();
          } catch (e) {
            debugPrint('Error converting $field DateTime: $e');
          }
        }
      }
    }
  }
}

