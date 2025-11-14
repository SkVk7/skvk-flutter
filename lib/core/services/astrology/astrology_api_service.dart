/// Astrology API Service
///
/// HTTP client service for astrology API calls.
/// Returns raw JSON (Map<String, dynamic>) - no enum parsing.
///
/// NOTE: This service should NOT be called directly.
/// Use AstrologyServiceBridge instead for proper timezone handling.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:skvk_application/core/config/app_config.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/shared/cache_service.dart';

/// Astrology API Service
///
/// Provides methods to call astrology API endpoints.
/// All methods return Map<String, dynamic> (raw JSON).
class AstrologyApiService {
  AstrologyApiService._({
    required this.baseUrl,
    required http.Client client,
    required CacheService cache,
  })  : _client = client,
        _cache = cache;

  /// Factory constructor
  factory AstrologyApiService.create({
    String? baseUrl,
    http.Client? client,
    CacheService? cache,
  }) {
    final apiBaseUrl = baseUrl ?? AppConfig.current.apiBaseUrl;
    return AstrologyApiService._(
      baseUrl: apiBaseUrl,
      client: client ?? http.Client(),
      cache: cache ?? CacheService.instance(),
    );
  }

  /// Get singleton instance
  factory AstrologyApiService.instance() {
    return _instance ??= AstrologyApiService.create();
  }
  static AstrologyApiService? _instance;
  final String baseUrl;
  final http.Client _client;
  final CacheService _cache;

  /// Get full birth chart from API
  ///
  /// Returns Map<String, dynamic> with full birth chart
  /// Always fetches full birth chart (for user's own data)
  /// Minimal birth chart for compatibility is handled internally by compatibility API
  Future<Map<String, dynamic>> getBirthData({
    required DateTime utcBirthDateTime,
    required double latitude,
    required double longitude,
    required String timezoneId,
    String ayanamsha = 'lahiri',
    String houseSystem = 'placidus',
  }) async {
    try {
      final cacheKey = 'birth_data_${utcBirthDateTime.toIso8601String()}_'
          '${latitude}_${longitude}_${ayanamsha}_$houseSystem';

      final cachedData = _cache.get(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      final dateOfBirth = utcBirthDateTime.toIso8601String().split('T')[0];
      final timeOfBirth =
          utcBirthDateTime.toIso8601String().split('T')[1].split('.')[0];

      // Prepare query parameters (API always returns complete full birth chart)
      final queryParameters = {
        'dateOfBirth': dateOfBirth,
        'timeOfBirth': timeOfBirth,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'timezoneId': timezoneId,
        'ayanamsha': ayanamsha,
        'houseSystem': houseSystem,
      };

      // Make API call with GET request
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/astrology/full-birth-chart').replace(
          queryParameters: queryParameters,
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Cache full birth chart data (user's own data)
        // Cache for 1 year - this is the user's own data
        _cache.set(
          cacheKey,
          data,
          duration: const Duration(days: 365), // 1 year, but can be extended
          cacheType: CacheType.userBirthData,
        );

        return data;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError('Error getting birth data: $e',
          error: e, stackTrace: stackTrace, source: 'AstrologyApiService',);
      rethrow;
    }
  }

  /// Calculate compatibility from API
  ///
  /// Returns Map<String, dynamic> with compatibility scores
  /// The API internally handles birth chart fetching and caching
  Future<Map<String, dynamic>> calculateCompatibility({
    required String groomDateOfBirth,
    required String groomTimeOfBirth,
    required double groomLatitude,
    required double groomLongitude,
    required String brideDateOfBirth,
    required String brideTimeOfBirth,
    required double brideLatitude,
    required double brideLongitude,
    String? groomTimezoneId,
    String? brideTimezoneId,
    String ayanamsha = 'lahiri',
    String houseSystem = 'placidus',
  }) async {
    try {
      final cacheKey = 'compatibility_${groomDateOfBirth}_${groomTimeOfBirth}_'
          '${brideDateOfBirth}_${brideTimeOfBirth}_${ayanamsha}_$houseSystem';

      final cachedData = _cache.get(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      // Prepare query parameters
      final queryParameters = {
        'groomDateOfBirth': groomDateOfBirth,
        'groomTimeOfBirth': groomTimeOfBirth,
        'groomLatitude': groomLatitude.toString(),
        'groomLongitude': groomLongitude.toString(),
        'brideDateOfBirth': brideDateOfBirth,
        'brideTimeOfBirth': brideTimeOfBirth,
        'brideLatitude': brideLatitude.toString(),
        'brideLongitude': brideLongitude.toString(),
        'ayanamsha': ayanamsha,
        'houseSystem': houseSystem,
      };

      if (groomTimezoneId != null && groomTimezoneId.isNotEmpty) {
        queryParameters['groomTimezoneId'] = groomTimezoneId;
      }
      if (brideTimezoneId != null && brideTimezoneId.isNotEmpty) {
        queryParameters['brideTimezoneId'] = brideTimezoneId;
      }

      // Make API call with GET request
      // The backend will internally check cache and fetch birth charts if needed
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/astrology/compatibility').replace(
          queryParameters: queryParameters,
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data.containsKey('code') && data.containsKey('message')) {
          final errorMessage =
              data['userMessage'] ?? data['message'] ?? 'Unknown API error';
          await LoggingHelper.logWarning(
              'API returned error in 200 response: $errorMessage',
              source: 'AstrologyApiService',);
          throw Exception('API error: $errorMessage');
        }

        // Cache only compatibility result
        // Groom/bride birth chart data is handled internally by compatibility API
        // We only cache compatibility results, not individual birth charts
        _cache.set(
          cacheKey,
          data,
          duration: const Duration(days: 30),
          cacheType: CacheType.compatibility,
        );

        return data;
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage =
              errorData['userMessage'] ?? errorData['message'] ?? response.body;
          throw Exception('API error: ${response.statusCode} - $errorMessage');
        } on Exception {
          throw Exception(
            'API error: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError('Error calculating compatibility: $e',
          error: e, stackTrace: stackTrace, source: 'AstrologyApiService',);
      rethrow;
    }
  }

  /// Get predictions from API
  ///
  /// Returns Map<String, dynamic> with predictions data
  Future<Map<String, dynamic>> getPredictions({
    required String birthDateTime,
    required double birthLatitude,
    required double birthLongitude,
    required double currentLatitude,
    required double currentLongitude,
    required String predictionType,
    String? targetDate,
    String ayanamsha = 'lahiri',
    String houseSystem = 'placidus',
  }) async {
    try {
      final cacheKey = 'predictions_${birthDateTime}_${birthLatitude}_'
          '${birthLongitude}_${currentLatitude}_${currentLongitude}_${predictionType}_'
          '${targetDate ?? 'none'}_${ayanamsha}_$houseSystem';

      final cachedData = _cache.get(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      // Prepare query parameters
      final queryParameters = {
        'birthDateTime': birthDateTime,
        'birthLatitude': birthLatitude.toString(),
        'birthLongitude': birthLongitude.toString(),
        'currentLatitude': currentLatitude.toString(),
        'currentLongitude': currentLongitude.toString(),
        'predictionType': predictionType,
        'ayanamsha': ayanamsha,
        'houseSystem': houseSystem,
      };

      if (targetDate != null && targetDate.isNotEmpty) {
        queryParameters['targetDate'] = targetDate;
      }

      // Make API call with GET request
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/astrology/predictions').replace(
          queryParameters: queryParameters,
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Cache response based on prediction type
        // Daily predictions: cache for 24 hours (same for entire day)
        // Hourly predictions: cache for 1 hour (same for that hour)
        // Transit predictions: cache for 6 hours (transits don't change instantly)
        final cacheDuration = _getPredictionCacheDuration(predictionType);
        _cache.set(
          cacheKey,
          data,
          duration: cacheDuration,
        );

        return data;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError('Error getting predictions: $e',
          error: e, stackTrace: stackTrace, source: 'AstrologyApiService',);
      rethrow;
    }
  }

  /// Get calendar year from API
  ///
  /// Returns Map<String, dynamic> with year calendar data
  /// Ayanamsha is required for accurate nakshatra calculations (sidereal zodiac)
  /// House system is NOT needed for calendar calculations
  Future<Map<String, dynamic>> getCalendarYear({
    required int year,
    required String region,
    required double latitude,
    required double longitude,
    required String timezoneId,
    String ayanamsha = 'lahiri',
  }) async {
    try {
      final cacheKey =
          'year_${year}_${region}_${latitude}_${longitude}_${timezoneId}_$ayanamsha';

      final cachedData = _cache.get(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      // Make API call
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/calendar/year').replace(
          queryParameters: {
            'year': year.toString(),
            'region': region,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'timezoneId': timezoneId,
            'ayanamsha': ayanamsha,
          },
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Cache response
        // Calendar year - cache for 1 year (static data)
        _cache.set(
          cacheKey,
          data,
          duration: const Duration(days: 365),
          cacheType: CacheType.calendar,
        );

        return data;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError('Error getting calendar year: $e',
          error: e, stackTrace: stackTrace, source: 'AstrologyApiService',);
      rethrow;
    }
  }

  /// Get calendar month from API
  ///
  /// Returns Map<String, dynamic> with month calendar data
  /// Ayanamsha is required for accurate nakshatra, tithi, yoga, karana calculations (sidereal zodiac)
  /// House system is NOT needed for calendar calculations
  Future<Map<String, dynamic>> getCalendarMonth({
    required int year,
    required int month,
    required String region,
    required double latitude,
    required double longitude,
    required String timezoneId,
    String ayanamsha = 'lahiri',
  }) async {
    try {
      final cacheKey =
          'month_${year}_${month}_${region}_${latitude}_${longitude}_${timezoneId}_$ayanamsha';

      final cachedData = _cache.get(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      // Make API call
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/calendar/month').replace(
          queryParameters: {
            'year': year.toString(),
            'month': month.toString(),
            'region': region,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'timezoneId': timezoneId,
            'ayanamsha': ayanamsha,
          },
        ),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Cache response
        // Calendar month - cache for 24 hours (can be extended for past months)
        _cache.set(
          cacheKey,
          data,
          duration: const Duration(hours: 24),
          cacheType: CacheType.calendar,
        );

        return data;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError('Error getting calendar month: $e',
          error: e, stackTrace: stackTrace, source: 'AstrologyApiService',);
      rethrow;
    }
  }

  /// Get cache duration for prediction type
  /// Daily and dasha predictions cached for 1 day to reduce corner case scenarios
  Duration _getPredictionCacheDuration(String predictionType) {
    switch (predictionType.toLowerCase()) {
      case 'daily':
      case 'day':
        return const Duration(
          hours: 24,
        ); // Same prediction for entire day - 1 API call per day
      case 'dasha':
      case 'dashas':
        return const Duration(
          hours: 24,
        ); // Cache for 1 day to reduce corner case scenarios
      case 'hourly':
      case 'hour':
        return const Duration(hours: 1); // Same prediction for that hour
      case 'transit':
      case 'transits':
        return const Duration(
          hours: 24,
        ); // Transit predictions - cache for 24 hours
      default:
        return const Duration(
          hours: 24,
        ); // Default: 24 hours (1 API call per day)
    }
  }
}
