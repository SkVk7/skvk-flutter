/// Astrology Business Service
///
/// This service acts as the business layer interface for astrology operations.
/// It uses the AstrologyFacade to handle all timezone conversions and
/// provides a clean API for the UI layer.
///
/// Design Pattern: Service Layer + Facade Pattern
/// Responsibilities:
/// - Handle business logic for astrology operations
/// - Manage user preferences and settings
/// - Provide clean API for UI layer
/// - Handle error scenarios and user feedback
library;

import 'dart:async';
import '../../../astrology/core/facades/astrology_facade.dart';
import '../../../astrology/core/entities/astrology_entities.dart';
import '../../../astrology/core/enums/astrology_enums.dart';
import '../../../astrology/core/interfaces/astrology_logger_interface.dart';

/// Business service for astrology operations
class AstrologyBusinessService {
  static AstrologyBusinessService? _instance;
  final AstrologyFacade _astrologyFacade;
  final AstrologyLoggerInterface _logger;

  // User preferences cache
  final Map<String, dynamic> _userPreferences = {};
  final Map<String, String> _userTimezones = {};

  AstrologyBusinessService._(this._astrologyFacade, this._logger);

  /// Factory constructor with dependency injection
  factory AstrologyBusinessService.create({
    required AstrologyFacade astrologyFacade,
    required AstrologyLoggerInterface logger,
  }) {
    return AstrologyBusinessService._(astrologyFacade, logger);
  }

  /// Get singleton instance
  static AstrologyBusinessService get instance {
    if (_instance == null) {
      throw StateError('AstrologyBusinessService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Initialize the business service
  static Future<void> initialize({
    required AstrologyFacade astrologyFacade,
    required AstrologyLoggerInterface logger,
  }) async {
    _instance = AstrologyBusinessService._(astrologyFacade, logger);

    await _instance!._logger.info(
      'AstrologyBusinessService initialized',
      source: 'AstrologyBusinessService',
    );
  }

  // ============================================================================
  // USER PREFERENCE MANAGEMENT
  // ============================================================================

  /// Set user timezone preference
  Future<void> setUserTimezone(String userId, String timezoneId) async {
    _userTimezones[userId] = timezoneId;

    await _logger.info(
      'User timezone set',
      source: 'AstrologyBusinessService',
      metadata: {
        'userId': userId,
        'timezone': timezoneId,
      },
    );
  }

  /// Get user timezone preference
  String getUserTimezone(String userId) {
    return _userTimezones[userId] ?? 'UTC';
  }

  /// Set user astrology preferences
  Future<void> setUserPreferences(String userId, Map<String, dynamic> preferences) async {
    _userPreferences[userId] = preferences;

    await _logger.info(
      'User preferences set',
      source: 'AstrologyBusinessService',
      metadata: {
        'userId': userId,
        'preferences': preferences,
      },
    );
  }

  /// Get user astrology preferences
  Map<String, dynamic> getUserPreferences(String userId) {
    return _userPreferences[userId] ?? {};
  }

  // ============================================================================
  // ASTROLOGY OPERATIONS
  // ============================================================================

  /// Get user's birth chart with automatic timezone handling
  Future<FixedBirthData> getUserBirthChart({
    required String userId,
    required DateTime localBirthDateTime,
    required double latitude,
    required double longitude,
    AyanamshaType? ayanamsha,
  }) async {
    await _logger.info(
      'Getting user birth chart',
      source: 'AstrologyBusinessService',
      metadata: {
        'userId': userId,
        'localBirthDateTime': localBirthDateTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Get user's timezone preference
    final timezoneId = getUserTimezone(userId);

    // Get user's ayanamsha preference
    final userAyanamsha = ayanamsha ??
        (getUserPreferences(userId)['ayanamsha'] as AyanamshaType?) ??
        AyanamshaType.lahiri;

    // Call facade with timezone handling
    final result = await _astrologyFacade.getFixedBirthData(
      localBirthDateTime: localBirthDateTime,
      timezoneId: timezoneId,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: userAyanamsha,
      isUserData: true,
    );

    await _logger.info(
      'Successfully retrieved user birth chart',
      source: 'AstrologyBusinessService',
      metadata: {'userId': userId},
    );

    return result;
  }

  /// Get partner's minimal birth data for matching
  Future<Map<String, dynamic>> getPartnerBirthData({
    required String partnerId,
    required DateTime localBirthDateTime,
    required double latitude,
    required double longitude,
    AyanamshaType? ayanamsha,
  }) async {
    await _logger.info(
      'Getting partner birth data',
      source: 'AstrologyBusinessService',
      metadata: {
        'partnerId': partnerId,
        'localBirthDateTime': localBirthDateTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Get partner's timezone (default to UTC if not set)
    final timezoneId = getUserTimezone(partnerId);

    // Get partner's ayanamsha preference
    final partnerAyanamsha = ayanamsha ??
        (getUserPreferences(partnerId)['ayanamsha'] as AyanamshaType?) ??
        AyanamshaType.lahiri;

    // Call facade with timezone handling
    final result = await _astrologyFacade.getMinimalBirthData(
      localBirthDateTime: localBirthDateTime,
      timezoneId: timezoneId,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: partnerAyanamsha,
    );

    await _logger.info(
      'Successfully retrieved partner birth data',
      source: 'AstrologyBusinessService',
      metadata: {'partnerId': partnerId},
    );

    return result;
  }

  /// Calculate compatibility between two users
  Future<CompatibilityResult> calculateCompatibility({
    required String user1Id,
    required DateTime user1LocalBirthDateTime,
    required double user1Latitude,
    required double user1Longitude,
    required String user2Id,
    required DateTime user2LocalBirthDateTime,
    required double user2Latitude,
    required double user2Longitude,
    CalculationPrecision? precision,
  }) async {
    await _logger.info(
      'Calculating compatibility',
      source: 'AstrologyBusinessService',
      metadata: {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'user1LocalBirth': user1LocalBirthDateTime.toIso8601String(),
        'user2LocalBirth': user2LocalBirthDateTime.toIso8601String(),
      },
    );

    // Get user timezones
    final user1Timezone = getUserTimezone(user1Id);
    final user2Timezone = getUserTimezone(user2Id);

    // Get precision preference
    final userPrecision = precision ??
        (getUserPreferences(user1Id)['precision'] as CalculationPrecision?) ??
        CalculationPrecision.ultra;

    // Call facade with timezone handling
    final result = await _astrologyFacade.calculateCompatibility(
      localPerson1BirthDateTime: user1LocalBirthDateTime,
      person1TimezoneId: user1Timezone,
      person1Latitude: user1Latitude,
      person1Longitude: user1Longitude,
      localPerson2BirthDateTime: user2LocalBirthDateTime,
      person2TimezoneId: user2Timezone,
      person2Latitude: user2Latitude,
      person2Longitude: user2Longitude,
      precision: userPrecision,
    );

    await _logger.info(
      'Successfully calculated compatibility',
      source: 'AstrologyBusinessService',
      metadata: {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'totalScore': result.overallScore,
      },
    );

    return result;
  }

  /// Calculate planetary positions for a specific date
  Future<PlanetaryPositions> calculatePlanetaryPositions({
    required String userId,
    required DateTime localDateTime,
    required double latitude,
    required double longitude,
    CalculationPrecision? precision,
  }) async {
    await _logger.info(
      'Calculating planetary positions',
      source: 'AstrologyBusinessService',
      metadata: {
        'userId': userId,
        'localDateTime': localDateTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Get user's timezone
    final timezoneId = getUserTimezone(userId);

    // Get precision preference
    final userPrecision = precision ??
        (getUserPreferences(userId)['precision'] as CalculationPrecision?) ??
        CalculationPrecision.ultra;

    // Call facade with timezone handling
    final result = await _astrologyFacade.calculatePlanetaryPositions(
      localDateTime: localDateTime,
      timezoneId: timezoneId,
      latitude: latitude,
      longitude: longitude,
      precision: userPrecision,
    );

    await _logger.info(
      'Successfully calculated planetary positions',
      source: 'AstrologyBusinessService',
      metadata: {'userId': userId},
    );

    return result;
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get timezone from location
  Future<String> getTimezoneFromLocation(double latitude, double longitude) async {
    return await _astrologyFacade.getTimezoneFromLocation(latitude, longitude);
  }

  /// Get all available timezones
  List<String> getAvailableTimezones() {
    return _astrologyFacade.getAvailableTimezones();
  }

  /// Check if timezone supports DST
  Future<bool> timezoneSupportsDST(String timezoneId) async {
    return await _astrologyFacade.timezoneSupportsDST(timezoneId);
  }

  /// Validate user input
  Future<bool> validateUserInput({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Validate date range
      if (birthDateTime.year < 1900 || birthDateTime.year > 2100) {
        await _logger.warning(
          'Invalid birth year: ${birthDateTime.year}',
          source: 'AstrologyBusinessService',
        );
        return false;
      }

      // Validate latitude
      if (latitude < -90.0 || latitude > 90.0) {
        await _logger.warning(
          'Invalid latitude: $latitude',
          source: 'AstrologyBusinessService',
        );
        return false;
      }

      // Validate longitude
      if (longitude < -180.0 || longitude > 180.0) {
        await _logger.warning(
          'Invalid longitude: $longitude',
          source: 'AstrologyBusinessService',
        );
        return false;
      }

      return true;
    } catch (e) {
      await _logger.error(
        'Error validating user input: $e',
        source: 'AstrologyBusinessService',
      );
      return false;
    }
  }

  /// Get user's astrology summary
  Future<Map<String, dynamic>> getUserAstrologySummary({
    required String userId,
    required DateTime localBirthDateTime,
    required double latitude,
    required double longitude,
  }) async {
    await _logger.info(
      'Getting user astrology summary',
      source: 'AstrologyBusinessService',
      metadata: {
        'userId': userId,
        'localBirthDateTime': localBirthDateTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Validate input
    if (!await validateUserInput(
      birthDateTime: localBirthDateTime,
      latitude: latitude,
      longitude: longitude,
    )) {
      throw ArgumentError('Invalid user input');
    }

    // Get birth chart
    final birthChart = await getUserBirthChart(
      userId: userId,
      localBirthDateTime: localBirthDateTime,
      latitude: latitude,
      longitude: longitude,
    );

    // Get current planetary positions
    final currentPositions = await calculatePlanetaryPositions(
      userId: userId,
      localDateTime: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    );

    final summary = {
      'userId': userId,
      'birthChart': birthChart,
      'currentPositions': currentPositions,
      'calculatedAt': DateTime.now().toIso8601String(),
    };

    await _logger.info(
      'Successfully generated user astrology summary',
      source: 'AstrologyBusinessService',
      metadata: {'userId': userId},
    );

    return summary;
  }
}
