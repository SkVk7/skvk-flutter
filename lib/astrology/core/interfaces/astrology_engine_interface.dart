/// Core interface for astrological calculation engines
///
/// This interface defines the contract for all astrological calculation engines
/// following the Dependency Inversion Principle
library;

import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';
import '../../cache/astrology_cache_manager.dart';

/// Abstract interface for astrological calculation engines
abstract class AstrologyEngineInterface {
  /// Initialize the engine with configuration
  Future<void> initialize(AstrologyConfig config);

  /// Calculate planetary positions for a given date/time/location
  Future<PlanetaryPositions> calculatePlanetaryPositions({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Calculate house positions for a given date/time/location
  Future<HousePositions> calculateHousePositions({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    HouseSystem houseSystem = HouseSystem.placidus,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Calculate nakshatra for a given date/time/location
  Future<NakshatraData> calculateNakshatra({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Calculate rashi for a given date/time/location
  Future<RashiData> calculateRashi({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Calculate pada for a given date/time/location
  Future<PadaData> calculatePada({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Calculate dasha information
  Future<DashaData> calculateDasha({
    required DateTime birthDateTime,
    required NakshatraData birthNakshatra,
    required DateTime currentDateTime,
    CalculationPrecision precision = CalculationPrecision.ultra,
  });

  /// Calculate all fixed birth data
  Future<FixedBirthData> calculateFixedBirthData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    bool isUserData = true,
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

  /// Get current planetary transits
  Future<List<TransitData>> getCurrentTransits({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    DateTime? targetDate,
  });

  /// Calculate festival dates
  Future<List<FestivalData>> calculateFestivals({
    required int year,
    required double latitude,
    required double longitude,
    RegionalCalendar regionalCalendar = RegionalCalendar.universal,
  });

  /// Get available regional calendars for a location
  Future<List<RegionalCalendarInfo>> getAvailableRegionalCalendars({
    required double latitude,
    required double longitude,
  });

  /// Get regional calendar information
  Future<RegionalCalendarInfo> getRegionalCalendarInfo({
    required RegionalCalendar calendar,
  });

  /// Dispose resources
  Future<void> dispose();
}

/// Interface for fixed birth data calculations
abstract class FixedDataEngineInterface {
  /// Calculate all fixed birth data
  Future<FixedBirthData> calculateFixedBirthData({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  });

  /// Calculate birth chart
  Future<BirthChart> calculateBirthChart({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  });

  /// Calculate dasha periods
  Future<List<DashaPeriod>> calculateDashaPeriods({
    required DateTime birthDateTime,
    required int nakshatraNumber,
    required int padaNumber,
  });
}

/// Interface for dynamic data calculations
abstract class DynamicDataEngineInterface {
  /// Get current planetary positions
  Future<PlanetaryPositions> getCurrentPlanetaryPositions({
    required double latitude,
    required double longitude,
    DateTime? targetDate,
  });

  /// Get current transits
  Future<List<TransitData>> getCurrentTransits({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    DateTime? targetDate,
  });

  /// Get current festivals
  Future<List<FestivalData>> getCurrentFestivals({
    required double latitude,
    required double longitude,
    DateTime? targetDate,
  });

  /// Get auspicious times (Muhurta)
  Future<List<MuhurtaData>> getAuspiciousTimes({
    required DateTime date,
    required double latitude,
    required double longitude,
  });

  /// Get detailed matching analysis with individual koota scores
  Future<DetailedMatchingResult> getDetailedMatching({
    required FixedBirthData person1,
    required FixedBirthData person2,
  });
}

/// Interface for kundali matching
abstract class KundaliMatchingEngineInterface {
  /// Perform Ashta Koota matching
  Future<AshtaKootaResult> performAshtaKootaMatching({
    required FixedBirthData person1,
    required FixedBirthData person2,
  });

  /// Calculate compatibility score
  Future<CompatibilityResult> calculateCompatibility({
    required FixedBirthData person1,
    required FixedBirthData person2,
  });
}

/// Interface for caching
abstract class AstrologyCacheInterface {
  /// Initialize the cache
  Future<void> initialize();

  /// Get cached data
  Future<T?> getCachedData<T>(String key);

  /// Set cached data
  Future<void> setCachedData<T>(String key, T data,
      {Duration? ttl, bool isUserData = false, CacheRetentionPolicy? retentionPolicy});

  /// Clear cache
  Future<void> clearCache();

  /// Clear specific cache entry
  Future<void> clearCacheEntry(String key);

  /// Check if cache exists
  Future<bool> hasCachedData(String key);

  /// Clear partner cache
  Future<void> clearPartnerCache();

  /// Get cache statistics
  Map<String, dynamic> getCacheStats();

  /// Get partner cache statistics
  Map<String, dynamic> getPartnerCacheStats();
}
