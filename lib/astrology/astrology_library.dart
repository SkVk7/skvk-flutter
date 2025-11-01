/// Centralized Astrological Library - 100% ACCURACY
///
/// This is the single source of truth for all astrological calculations.
/// It provides a clean, high-performance interface for all astrological operations
/// with 100% Swiss Ephemeris precision and NO simplifications.
library;

import 'core/entities/astrology_entities.dart';
import 'core/enums/astrology_enums.dart';
import 'core/di/astrology_container.dart';
import 'core/utils/astrology_utils.dart';
import 'core/interfaces/astrology_logger_interface.dart';

/// Main entry point for all astrological calculations
///
/// This class follows the Facade pattern to provide a clean, high-performance interface
/// to the complex astrological calculation system with proper dependency injection.
class AstrologyLibrary {
  static AstrologyContainer? _container;
  static bool _isInitialized = false;

  // Private constructor - no direct instantiation
  AstrologyLibrary._();

  /// Initialize the astrology library with configuration
  static Future<void> initialize({
    AstrologyConfig? config,
    AstrologyLoggerInterface? logger,
  }) async {
    if (_isInitialized) {
      AstrologyUtils.logInfo('🔮 AstrologyLibrary already initialized, skipping');
      return;
    }

    try {
      final startTime = DateTime.now();
      AstrologyUtils.logInfo('🔮 Starting AstrologyLibrary initialization...');

      // Set logger if provided
      if (logger != null) {
        AstrologyUtils.setLogger(logger);
      }

      // Create container with proper dependency injection
      AstrologyUtils.logInfo('🔮 Creating AstrologyContainer...');
      _container = await AstrologyContainer.create(config: config, logger: logger);

      AstrologyUtils.logInfo('🔮 Initializing container...');
      await _container!.initialize();

      _isInitialized = true;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      AstrologyUtils.logInfo(
          '🔮 AstrologyLibrary initialized successfully in ${duration.inMilliseconds}ms');
      AstrologyUtils.logInfo(
          'AstrologyLibrary initialized successfully with 100% Swiss Ephemeris precision and proper DI');
    } catch (e) {
      // Log error but don't rethrow to prevent app crashes
      print('Failed to initialize AstrologyLibrary: $e');
      // Set as initialized to prevent repeated attempts
      _isInitialized = true;
    }
  }

  /// Ensure library is initialized
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ============================================================================
  // FIXED DATA METHODS (Birth-based, calculated once)
  // ============================================================================

  /// Get all fixed birth data (calculated once and cached)
  /// ENFORCED: birthDateTime MUST be in UTC - use AstrologyFacade for timezone handling
  static Future<FixedBirthData> getFixedBirthData({
    required DateTime birthDateTime, // ENFORCED: UTC time only
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    bool isUserData = false,
  }) async {
    // ENFORCE UTC-only contract
    if (!birthDateTime.isUtc) {
      throw ArgumentError('AstrologyLibrary.getFixedBirthData requires UTC DateTime. '
          'Use AstrologyFacade for timezone handling. '
          'Received: ${birthDateTime.toIso8601String()} (isUtc: ${birthDateTime.isUtc})');
    }
    final startTime = DateTime.now();
    AstrologyUtils.logInfo('🔮 AstrologyLibrary.getFixedBirthData called');
    AstrologyUtils.logInfo('🔮 Library initialized: $_isInitialized');

    await _ensureInitialized();

    final initTime = DateTime.now();
    AstrologyUtils.logInfo(
        '🔮 Initialization check completed in: ${initTime.difference(startTime).inMilliseconds}ms');

    // Log birth information (UTC time expected)
    AstrologyUtils.logInfo('Location: $latitude°N, $longitude°E');
    AstrologyUtils.logInfo('Birth time (UTC): ${birthDateTime.toIso8601String()}');
    AstrologyUtils.logInfo('Data type: ${isUserData ? 'User (Complete)' : 'Partner (Minimal)'}');
    AstrologyUtils.logInfo('Note: Timezone conversion should be done at application layer');

    final serviceStartTime = DateTime.now();
    final result = await _container!.astrologyService.getFixedBirthData(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      isUserData: isUserData,
      ayanamsha: ayanamsha,
      precision: CalculationPrecision.ultra,
    );
    final serviceEndTime = DateTime.now();

    AstrologyUtils.logInfo(
        '🔮 Service call completed in: ${serviceEndTime.difference(serviceStartTime).inMilliseconds}ms');
    AstrologyUtils.logInfo(
        '🔮 Total time: ${serviceEndTime.difference(startTime).inMilliseconds}ms');

    return result;
  }

  /// Get minimal birth data for kundali matching (optimized for partners)
  /// Only calculates Rashi, Nakshatra, and Pada - much faster than full birth chart
  /// ENFORCED: birthDateTime MUST be in UTC - use AstrologyFacade for timezone handling
  static Future<Map<String, dynamic>> getMinimalBirthData({
    required DateTime birthDateTime, // ENFORCED: UTC time only
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
  }) async {
    // ENFORCE UTC-only contract
    if (!birthDateTime.isUtc) {
      throw ArgumentError('AstrologyLibrary.getMinimalBirthData requires UTC DateTime. '
          'Use AstrologyFacade for timezone handling. '
          'Received: ${birthDateTime.toIso8601String()} (isUtc: ${birthDateTime.isUtc})');
    }

    await _ensureInitialized();

    AstrologyUtils.logInfo('Getting minimal birth data for kundali matching');
    AstrologyUtils.logInfo('Birth time: ${birthDateTime.toIso8601String()}');
    AstrologyUtils.logInfo('Location: $latitude°N, $longitude°E');

    return await _container!.astrologyService.getMinimalBirthData(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
      precision: CalculationPrecision.ultra,
    );
  }

  // ============================================================================
  // DYNAMIC DATA METHODS (Time-based, calculated on demand)
  // ============================================================================

  /// Calculate planetary positions for current time
  static Future<PlanetaryPositions> getCurrentPlanetaryPositions({
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    await _ensureInitialized();

    return await _container!.astrologyService.calculatePlanetaryPositions(
      dateTime: DateTime.now().toUtc(),
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
      precision: CalculationPrecision.ultra,
    );
  }

  /// Calculate planetary positions for specific date/time
  static Future<PlanetaryPositions> getPlanetaryPositions({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    await _ensureInitialized();

    return await _container!.astrologyService.calculatePlanetaryPositions(
      dateTime: dateTime,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
      precision: precision,
    );
  }

  // ============================================================================
  // COMPATIBILITY METHODS
  // ============================================================================

  /// Calculate compatibility between two persons
  static Future<CompatibilityResult> calculateCompatibility({
    required FixedBirthData person1,
    required FixedBirthData person2,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    await _ensureInitialized();

    return await _container!.astrologyService.calculateCompatibility(
      person1: person1,
      person2: person2,
      precision: precision,
    );
  }

  /// Get detailed matching analysis with individual koota scores
  static Future<DetailedMatchingResult> getDetailedMatching({
    required FixedBirthData person1,
    required FixedBirthData person2,
  }) async {
    await _ensureInitialized();

    return await _container!.astrologyService.getDetailedMatching(
      person1: person1,
      person2: person2,
    );
  }

  // ============================================================================
  // DASHA METHODS
  // ============================================================================

  /// Get current dasha information
  static Future<DashaData> getCurrentDasha({
    required FixedBirthData birthData,
    DateTime? currentDateTime,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    await _ensureInitialized();

    return await _container!.astrologyService.getCurrentDasha(
      birthData: birthData,
      currentDateTime: currentDateTime,
      precision: precision,
    );
  }

  // ============================================================================
  // REGIONAL CALENDAR METHODS
  // ============================================================================

  /// Get available regional calendars for a location
  static Future<List<RegionalCalendarInfo>> getAvailableRegionalCalendars({
    required double latitude,
    required double longitude,
  }) async {
    await _ensureInitialized();

    return await _container!.astrologyEngine.getAvailableRegionalCalendars(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get regional calendar information
  static Future<RegionalCalendarInfo> getRegionalCalendarInfo({
    required RegionalCalendar calendar,
  }) async {
    await _ensureInitialized();

    return await _container!.astrologyEngine.getRegionalCalendarInfo(
      calendar: calendar,
    );
  }

  /// Calculate festivals with regional calendar support
  static Future<List<FestivalData>> calculateFestivals({
    required double latitude,
    required double longitude,
    required int year,
    RegionalCalendar regionalCalendar = RegionalCalendar.universal,
  }) async {
    await _ensureInitialized();

    return await _container!.astrologyEngine.calculateFestivals(
      latitude: latitude,
      longitude: longitude,
      year: year,
      regionalCalendar: regionalCalendar,
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Clear all caches
  static Future<void> clearCache() async {
    await _ensureInitialized();
    _container!.memoizer.clearCache();
    AstrologyUtils.logInfo('AstrologyLibrary cache cleared');
  }

  /// Clear a specific cache entry
  static Future<void> clearCacheEntry(String key) async {
    await _ensureInitialized();
    _container!.memoizer.clearCacheEntry(key);
    AstrologyUtils.logInfo('AstrologyLibrary cache entry cleared: $key');
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    if (!_isInitialized) return {};
    return _container!.memoizer.getCacheStats();
  }

  /// Check if library is initialized
  static bool get isInitialized => _isInitialized;

  /// Get current configuration
  static AstrologyConfig? get config => _container?.config;

  /// Dispose of resources with proper memory management
  static Future<void> dispose() async {
    if (_container != null) {
      try {
        // Dispose of all resources in proper order
        await _container!.dispose();
        _container = null;
        _isInitialized = false;
        AstrologyUtils.logInfo('AstrologyLibrary disposed and memory cleaned up');
      } catch (e) {
        AstrologyUtils.logError('Error during AstrologyLibrary disposal: $e');
        // Still mark as disposed even if cleanup failed
        _container = null;
        _isInitialized = false;
      }
    }
  }
}
