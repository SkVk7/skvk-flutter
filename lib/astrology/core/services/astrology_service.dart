/// Astrology Service - Clean Business Logic Layer
///
/// This service provides a clean interface between the business layer and
/// the astrology engine, ensuring proper decoupling and dependency injection.
library;

import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';
import '../interfaces/astrology_engine_interface.dart';
import 'swiss_ephemeris_service.dart';

/// Interface for astrology service
abstract class AstrologyServiceInterface {
  /// Get fixed birth data for a person
  Future<FixedBirthData> getFixedBirthData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    bool isUserData = true,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Get minimal birth data for kundali matching (optimized for partners)
  /// Only calculates Rashi, Nakshatra, and Pada - much faster than full birth chart
  Future<Map<String, dynamic>> getMinimalBirthData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Calculate compatibility between two persons
  Future<CompatibilityResult> calculateCompatibility({
    required FixedBirthData person1,
    required FixedBirthData person2,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Get detailed matching analysis with individual koota scores
  Future<DetailedMatchingResult> getDetailedMatching({
    required FixedBirthData person1,
    required FixedBirthData person2,
  });

  /// Get current dasha information
  Future<DashaData> getCurrentDasha({
    required FixedBirthData birthData,
    DateTime? currentDateTime,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Calculate planetary positions
  Future<PlanetaryPositions> calculatePlanetaryPositions({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });
}

/// Astrology service implementation
///
/// This service acts as a clean interface between the business layer
/// and the astrology engine, providing proper dependency injection
/// and error handling.
class AstrologyService implements AstrologyServiceInterface {
  final AstrologyEngineInterface _engine;

  AstrologyService({
    required AstrologyEngineInterface engine,
    required SwissEphemerisServiceInterface swissEphemerisService,
  }) : _engine = engine;

  @override
  Future<FixedBirthData> getFixedBirthData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    bool isUserData = true,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    try {
      return await _engine.calculateFixedBirthData(
        birthDateTime: birthDateTime,
        latitude: latitude,
        longitude: longitude,
        isUserData: isUserData,
        ayanamsha: ayanamsha,
        precision: precision,
      );
    } catch (e) {
      // Use consistent error handling - throw specific exception types
      if (e is AstrologyServiceException) {
        rethrow;
      }
      throw AstrologyServiceException('Failed to calculate fixed birth data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMinimalBirthData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    try {
      // Calculate only the essential data needed for kundali matching
      final futures = await Future.wait([
        _engine.calculateRashi(
          dateTime: birthDateTime,
          latitude: latitude,
          longitude: longitude,
          ayanamsha: ayanamsha,
          precision: precision,
        ),
        _engine.calculateNakshatra(
          dateTime: birthDateTime,
          latitude: latitude,
          longitude: longitude,
          ayanamsha: ayanamsha,
          precision: precision,
        ),
        _engine.calculatePada(
          dateTime: birthDateTime,
          latitude: latitude,
          longitude: longitude,
          ayanamsha: ayanamsha,
          precision: precision,
        ),
      ]);

      final rashi = futures[0] as RashiData;
      final nakshatra = futures[1] as NakshatraData;
      final pada = futures[2] as PadaData;

      return {
        'rashi': rashi,
        'nakshatra': nakshatra,
        'pada': pada,
        'birthDateTime': birthDateTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'calculatedAt': DateTime.now().toUtc().toIso8601String(),
      };
    } catch (e) {
      throw AstrologyServiceException('Failed to calculate minimal birth data: $e');
    }
  }

  @override
  Future<CompatibilityResult> calculateCompatibility({
    required FixedBirthData person1,
    required FixedBirthData person2,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    try {
      return await _engine.calculateCompatibility(
        person1: person1,
        person2: person2,
        precision: precision,
      );
    } catch (e) {
      throw AstrologyServiceException('Failed to calculate compatibility: $e');
    }
  }

  @override
  Future<DetailedMatchingResult> getDetailedMatching({
    required FixedBirthData person1,
    required FixedBirthData person2,
  }) async {
    try {
      return await _engine.getDetailedMatching(
        person1: person1,
        person2: person2,
      );
    } catch (e) {
      throw AstrologyServiceException('Failed to get detailed matching: $e');
    }
  }

  @override
  Future<DashaData> getCurrentDasha({
    required FixedBirthData birthData,
    DateTime? currentDateTime,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    try {
      return await _engine.calculateDasha(
        birthDateTime: birthData.birthDateTime,
        birthNakshatra: birthData.nakshatra,
        currentDateTime: currentDateTime ?? DateTime.now().toUtc(),
        precision: precision,
      );
    } catch (e) {
      throw AstrologyServiceException('Failed to calculate dasha: $e');
    }
  }

  @override
  Future<PlanetaryPositions> calculatePlanetaryPositions({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    try {
      return await _engine.calculatePlanetaryPositions(
        dateTime: dateTime,
        latitude: latitude,
        longitude: longitude,
        precision: precision,
      );
    } catch (e) {
      throw AstrologyServiceException('Failed to calculate planetary positions: $e');
    }
  }
}

/// Exception for astrology service errors
class AstrologyServiceException implements Exception {
  final String message;

  AstrologyServiceException(this.message);

  @override
  String toString() => 'AstrologyServiceException: $message';
}

// Factory removed - using dependency injection container instead
