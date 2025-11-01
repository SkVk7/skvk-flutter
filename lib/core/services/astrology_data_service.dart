/// Astrology Data Service
///
/// Decoupled service that fetches astrology data from centralized cache
/// without being tightly coupled to user data
library;

import '../../astrology/astrology_library.dart';
import '../../astrology/core/entities/astrology_entities.dart';
import '../../astrology/core/enums/astrology_enums.dart';
import '../utils/either.dart';
import '../errors/failures.dart';
import '../logging/logging_helper.dart';

/// Service for fetching astrology data from centralized cache
class AstrologyDataService {
  static AstrologyDataService? _instance;

  // Private constructor for singleton
  AstrologyDataService._();

  /// Get singleton instance
  static AstrologyDataService get instance {
    _instance ??= AstrologyDataService._();
    return _instance!;
  }

  /// Get user's birth data from centralized cache
  Future<Result<FixedBirthData>> getUserBirthData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
  }) async {
    try {
      final birthData = await AstrologyLibrary.getFixedBirthData(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        ayanamsha: ayanamsha,
        isUserData: true,
      );

      return ResultHelper.success(birthData);
    } catch (e) {
      LoggingHelper.logError('Failed to get user birth data',
          source: 'AstrologyDataService', error: e);
      return ResultHelper.failure(
        CalculationFailure(message: 'Failed to get user birth data: ${e.toString()}'),
      );
    }
  }

  /// Get partner's birth data from centralized cache
  Future<Result<FixedBirthData>> getPartnerBirthData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
  }) async {
    try {
      final birthData = await AstrologyLibrary.getFixedBirthData(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        ayanamsha: ayanamsha,
        isUserData: false, // This is partner data
      );

      return ResultHelper.success(birthData);
    } catch (e) {
      LoggingHelper.logError('Failed to get partner birth data',
          source: 'AstrologyDataService', error: e);
      return ResultHelper.failure(
        CalculationFailure(message: 'Failed to get partner birth data: ${e.toString()}'),
      );
    }
  }

  /// Get current planetary positions
  Future<Result<PlanetaryPositions>> getCurrentPlanetaryPositions({
    required double latitude,
    required double longitude,
    DateTime? targetDate,
  }) async {
    try {
      final positions = targetDate != null
          ? await AstrologyLibrary.getPlanetaryPositions(
              dateTime: targetDate,
              latitude: latitude,
              longitude: longitude,
            )
          : await AstrologyLibrary.getCurrentPlanetaryPositions(
              latitude: latitude,
              longitude: longitude,
            );

      return ResultHelper.success(positions);
    } catch (e) {
      LoggingHelper.logError('Failed to get current planetary positions',
          source: 'AstrologyDataService', error: e);
      return ResultHelper.failure(
        CalculationFailure(message: 'Failed to get current planetary positions: ${e.toString()}'),
      );
    }
  }

  /// Get kundali matching result
  Future<Result<CompatibilityResult>> getKundaliMatching({
    required FixedBirthData person1,
    required FixedBirthData person2,
  }) async {
    try {
      final result = await AstrologyLibrary.calculateCompatibility(
        person1: person1,
        person2: person2,
      );

      return ResultHelper.success(result);
    } catch (e) {
      LoggingHelper.logError('Failed to get kundali matching',
          source: 'AstrologyDataService', error: e);
      return ResultHelper.failure(
        CalculationFailure(message: 'Failed to get kundali matching: ${e.toString()}'),
      );
    }
  }

  /// Clear astrology cache
  Future<Result<void>> clearAstrologyCache() async {
    try {
      await AstrologyLibrary.clearCache();
      return ResultHelper.success(null);
    } catch (e) {
      LoggingHelper.logError('Failed to clear astrology cache',
          source: 'AstrologyDataService', error: e);
      return ResultHelper.failure(
        CacheFailure(message: 'Failed to clear astrology cache: ${e.toString()}'),
      );
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return AstrologyLibrary.getCacheStats();
  }
}
