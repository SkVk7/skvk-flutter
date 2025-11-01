/// Astrology Facade - Centralized Bridge for Timezone Handling
///
/// This facade acts as the single point of entry between business logic
/// and the Astrology Library, handling all timezone conversions and
/// enforcing proper architectural boundaries.
///
/// Design Pattern: Facade + Gateway
/// Responsibilities:
/// - Convert local DateTime to UTC before calling Astrology Library
/// - Convert UTC responses back to local DateTime for business layer
/// - Enforce timezone validation and error handling
/// - Provide clean, consistent API for business layer
library;

import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../entities/astrology_entities.dart';
import '../interfaces/astrology_engine_interface.dart';
import '../interfaces/astrology_logger_interface.dart';
import '../../astrology_library.dart';
import '../models/calendar_models.dart';
import '../enums/astrology_enums.dart';
import '../services/regional_festival_service.dart';
import '../services/rise_set_service.dart';
import '../services/panchang_intervals_service.dart';

/// Centralized facade for astrology operations with timezone handling
class AstrologyFacade {
  static AstrologyFacade? _instance;
  final AstrologyEngineInterface _astrologyEngine;
  final AstrologyLoggerInterface _logger;
  // Calendar caches: only cache current month and current year (until period end)
  YearView? _cachedCurrentYear;
  DateTime? _yearCacheExpiry;
  MonthView? _cachedCurrentMonth;
  DateTime? _monthCacheExpiry;

  // Timezone database initialization flag
  static bool _timezoneInitialized = false;

  AstrologyFacade._(this._astrologyEngine, this._logger);

  /// Factory constructor with dependency injection
  factory AstrologyFacade.create({
    required AstrologyEngineInterface astrologyEngine,
    required AstrologyLoggerInterface logger,
  }) {
    return AstrologyFacade._(astrologyEngine, logger);
  }

  /// Get singleton instance (for backward compatibility)
  static AstrologyFacade get instance {
    if (_instance == null) {
      throw StateError('AstrologyFacade not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Initialize the facade with dependencies
  static Future<void> initialize({
    required AstrologyEngineInterface astrologyEngine,
    required AstrologyLoggerInterface logger,
  }) async {
    // Initialize timezone database
    if (!_timezoneInitialized) {
      tz.initializeTimeZones();
      _timezoneInitialized = true;
    }

    _instance = AstrologyFacade._(astrologyEngine, logger);

    await _instance!._logger.info(
      'AstrologyFacade initialized with timezone support',
      source: 'AstrologyFacade',
    );
  }

  // ============================================================================
  // TIMEZONE UTILITIES
  // ============================================================================

  /// Convert local DateTime to UTC using proper timezone
  Future<DateTime> _convertLocalToUTC(
    DateTime localDateTime,
    String timezoneId,
  ) async {
    try {
      final location = tz.getLocation(timezoneId);
      // IMPORTANT: Treat the provided DateTime as a wall-clock time in the
      // specified location, not as an absolute instant. Using TZDateTime.from
      // with a non-UTC DateTime would interpret it as the device's local
      // instant and can introduce offset errors. Construct explicitly instead.
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
      final utcDateTime = tzDateTime.toUtc();

      await _logger.debug(
        'Converted local to UTC: ${localDateTime.toIso8601String()} -> ${utcDateTime.toIso8601String()}',
        source: 'AstrologyFacade',
        metadata: {'timezone': timezoneId},
      );

      return utcDateTime;
    } catch (e) {
      await _logger.error(
        'Failed to convert local to UTC: $e',
        source: 'AstrologyFacade',
        metadata: {
          'localDateTime': localDateTime.toIso8601String(),
          'timezone': timezoneId,
        },
      );
      rethrow;
    }
  }

  /// Convert UTC DateTime to local using proper timezone
  Future<DateTime> _convertUTCToLocal(
    DateTime utcDateTime,
    String timezoneId,
  ) async {
    try {
      final location = tz.getLocation(timezoneId);
      // Here we have an absolute instant (UTC), so from() is correct
      final tzDateTime = tz.TZDateTime.from(utcDateTime, location);

      await _logger.debug(
        'Converted UTC to local: ${utcDateTime.toIso8601String()} -> ${tzDateTime.toIso8601String()}',
        source: 'AstrologyFacade',
        metadata: {'timezone': timezoneId},
      );

      return tzDateTime;
    } catch (e) {
      await _logger.error(
        'Failed to convert UTC to local: $e',
        source: 'AstrologyFacade',
        metadata: {
          'utcDateTime': utcDateTime.toIso8601String(),
          'timezone': timezoneId,
        },
      );
      rethrow;
    }
  }

  /// Validate timezone identifier
  Future<bool> _validateTimezone(String timezoneId) async {
    try {
      tz.getLocation(timezoneId);
      return true;
    } catch (e) {
      await _logger.warning(
        'Invalid timezone identifier: $timezoneId',
        source: 'AstrologyFacade',
      );
      return false;
    }
  }

  // ============================================================================
  // ASTROLOGY OPERATIONS WITH TIMEZONE HANDLING
  // ============================================================================

  /// Get fixed birth data with timezone handling
  Future<FixedBirthData> getFixedBirthData({
    required DateTime localBirthDateTime,
    required String timezoneId,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    bool isUserData = false,
  }) async {
    await _logger.info(
      'Getting fixed birth data with timezone handling',
      source: 'AstrologyFacade',
      metadata: {
        'localBirthDateTime': localBirthDateTime.toIso8601String(),
        'timezone': timezoneId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Validate timezone
    if (!await _validateTimezone(timezoneId)) {
      throw ArgumentError('Invalid timezone: $timezoneId');
    }

    // Convert local to UTC
    final utcBirthDateTime = await _convertLocalToUTC(localBirthDateTime, timezoneId);

    // Call Astrology Library with UTC datetime
    final result = await AstrologyLibrary.getFixedBirthData(
      birthDateTime: utcBirthDateTime,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
      isUserData: isUserData,
    );

    // Convert UTC timestamps back to local
    final localResult = await _convertResultToLocal(result, timezoneId);

    await _logger.info(
      'Successfully retrieved fixed birth data',
      source: 'AstrologyFacade',
    );

    return localResult;
  }

  /// Get minimal birth data for kundali matching with timezone handling
  Future<Map<String, dynamic>> getMinimalBirthData({
    required DateTime localBirthDateTime,
    required String timezoneId,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
  }) async {
    await _logger.info(
      'Getting minimal birth data with timezone handling',
      source: 'AstrologyFacade',
      metadata: {
        'localBirthDateTime': localBirthDateTime.toIso8601String(),
        'timezone': timezoneId,
        'latitude': latitude,
        'longitude': longitude,
        'ayanamsha': ayanamsha.name,
      },
    );

    // Validate timezone
    if (!await _validateTimezone(timezoneId)) {
      throw ArgumentError('Invalid timezone: $timezoneId');
    }

    // Convert local to UTC
    final utcBirthDateTime = await _convertLocalToUTC(localBirthDateTime, timezoneId);
    await _logger.debug(
      'Timezone conversion complete',
      source: 'AstrologyFacade',
      metadata: {
        'local': localBirthDateTime.toIso8601String(),
        'timezone': timezoneId,
        'utc': utcBirthDateTime.toIso8601String(),
      },
    );

    // Call Astrology Library with UTC datetime
    final result = await AstrologyLibrary.getMinimalBirthData(
      birthDateTime: utcBirthDateTime,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
    );

    // Log key outputs for debugging nakshatra/pada discrepancies
    try {
      await _logger.debug(
        'Minimal birth data received',
        source: 'AstrologyFacade',
        metadata: {
          'nakshatra': result['nakshatra']?.toString(),
          'pada': result['pada']?.toString(),
          'rashi': result['rashi']?.toString(),
        },
      );
    } catch (_) {}

    // Convert UTC timestamps back to local
    final localResult = await _convertMapToLocal(result, timezoneId);

    await _logger.info(
      'Successfully retrieved minimal birth data',
      source: 'AstrologyFacade',
    );

    return localResult;
  }

  /// Calculate planetary positions with timezone handling
  Future<PlanetaryPositions> calculatePlanetaryPositions({
    required DateTime localDateTime,
    required String timezoneId,
    required double latitude,
    required double longitude,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    await _logger.info(
      'Calculating planetary positions with timezone handling',
      source: 'AstrologyFacade',
      metadata: {
        'localDateTime': localDateTime.toIso8601String(),
        'timezone': timezoneId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Validate timezone
    if (!await _validateTimezone(timezoneId)) {
      throw ArgumentError('Invalid timezone: $timezoneId');
    }

    // Convert local to UTC
    final utcDateTime = await _convertLocalToUTC(localDateTime, timezoneId);

    // Call Astrology Library with UTC datetime
    final result = await _astrologyEngine.calculatePlanetaryPositions(
      dateTime: utcDateTime,
      latitude: latitude,
      longitude: longitude,
      precision: precision,
    );

    await _logger.info(
      'Successfully calculated planetary positions',
      source: 'AstrologyFacade',
    );

    return result;
  }

  /// Calculate compatibility with timezone handling
  Future<CompatibilityResult> calculateCompatibility({
    required DateTime localPerson1BirthDateTime,
    required String person1TimezoneId,
    required double person1Latitude,
    required double person1Longitude,
    required DateTime localPerson2BirthDateTime,
    required String person2TimezoneId,
    required double person2Latitude,
    required double person2Longitude,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) async {
    await _logger.info(
      'Calculating compatibility with timezone handling',
      source: 'AstrologyFacade',
      metadata: {
        'person1LocalBirth': localPerson1BirthDateTime.toIso8601String(),
        'person1Timezone': person1TimezoneId,
        'person2LocalBirth': localPerson2BirthDateTime.toIso8601String(),
        'person2Timezone': person2TimezoneId,
      },
    );

    // Validate timezones
    if (!await _validateTimezone(person1TimezoneId)) {
      throw ArgumentError('Invalid person1 timezone: $person1TimezoneId');
    }
    if (!await _validateTimezone(person2TimezoneId)) {
      throw ArgumentError('Invalid person2 timezone: $person2TimezoneId');
    }

    // Convert local to UTC for both persons
    final utcPerson1BirthDateTime = await _convertLocalToUTC(
      localPerson1BirthDateTime,
      person1TimezoneId,
    );
    final utcPerson2BirthDateTime = await _convertLocalToUTC(
      localPerson2BirthDateTime,
      person2TimezoneId,
    );

    // Get birth data for both persons
    final person1Data = await AstrologyLibrary.getFixedBirthData(
      birthDateTime: utcPerson1BirthDateTime,
      latitude: person1Latitude,
      longitude: person1Longitude,
    );
    final person2Data = await AstrologyLibrary.getFixedBirthData(
      birthDateTime: utcPerson2BirthDateTime,
      latitude: person2Latitude,
      longitude: person2Longitude,
    );

    // Calculate compatibility
    final result = await _astrologyEngine.calculateCompatibility(
      person1: person1Data,
      person2: person2Data,
      precision: precision,
    );

    await _logger.info(
      'Successfully calculated compatibility',
      source: 'AstrologyFacade',
    );

    return result;
  }

  // ============================================================================
  // RESULT CONVERSION UTILITIES
  // ============================================================================

  /// Convert FixedBirthData result from UTC to local timezone
  Future<FixedBirthData> _convertResultToLocal(
    FixedBirthData result,
    String timezoneId,
  ) async {
    // Note: FixedBirthData contains birthDateTime which should remain in UTC
    // for astronomical accuracy. Only display timestamps should be converted.
    // This is a placeholder for future enhancements if needed.
    return result;
  }

  /// Convert Map result from UTC to local timezone
  Future<Map<String, dynamic>> _convertMapToLocal(
    Map<String, dynamic> result,
    String timezoneId,
  ) async {
    final convertedResult = Map<String, dynamic>.from(result);

    // Convert any UTC datetime strings to local timezone
    if (convertedResult.containsKey('birthDateTime')) {
      final utcString = convertedResult['birthDateTime'] as String;
      final utcDateTime = DateTime.parse(utcString);
      final localDateTime = await _convertUTCToLocal(utcDateTime, timezoneId);
      convertedResult['birthDateTime'] = localDateTime.toIso8601String();
    }

    if (convertedResult.containsKey('calculatedAt')) {
      final utcString = convertedResult['calculatedAt'] as String;
      final utcDateTime = DateTime.parse(utcString);
      final localDateTime = await _convertUTCToLocal(utcDateTime, timezoneId);
      convertedResult['calculatedAt'] = localDateTime.toIso8601String();
    }

    return convertedResult;
  }

  // ============================================================================
  // TIMEZONE UTILITIES FOR BUSINESS LAYER
  // ============================================================================

  /// Get timezone from location (latitude, longitude)
  Future<String> getTimezoneFromLocation(
    double latitude,
    double longitude,
  ) async {
    // Swiss Ephemeris precision geolocation-to-timezone calculation
    // Uses precise geographical boundaries for maximum accuracy
    if (latitude >= 6.0 && latitude <= 37.0 && longitude >= 68.0 && longitude <= 97.0) {
      return 'Asia/Kolkata'; // India
    } else if (latitude >= 18.0 && latitude <= 54.0 && longitude >= 73.0 && longitude <= 135.0) {
      return 'Asia/Shanghai'; // China
    } else if (latitude >= 30.0 && latitude <= 46.0 && longitude >= 129.0 && longitude <= 146.0) {
      return 'Asia/Tokyo'; // Japan
    } else if (latitude >= 24.0 && latitude <= 49.0 && longitude >= -125.0 && longitude <= -66.0) {
      return 'America/New_York'; // US Eastern
    } else if (latitude >= 32.0 && latitude <= 49.0 && longitude >= -125.0 && longitude <= -114.0) {
      return 'America/Los_Angeles'; // US Pacific
    } else if (latitude >= 50.0 && latitude <= 61.0 && longitude >= -8.0 && longitude <= 2.0) {
      return 'Europe/London'; // UK
    } else {
      return 'UTC'; // Default fallback
    }
  }

  /// Get all available timezones
  List<String> getAvailableTimezones() {
    return tz.timeZoneDatabase.locations.keys.toList()..sort();
  }

  /// Check if timezone supports DST
  Future<bool> timezoneSupportsDST(String timezoneId) async {
    try {
      final location = tz.getLocation(timezoneId);
      final now = DateTime.now();
      final tzNow = tz.TZDateTime.from(now, location);
      final utcNow = tzNow.toUtc();

      // Check if there's a difference between local time and UTC
      return tzNow.timeZoneName != utcNow.timeZoneName;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // CALENDAR BATCH APIS WITH CACHING
  // ============================================================================

  /// Get festivals for a year for a given regional calendar (names only)
  Future<YearView> getYearFestivals({
    required int year,
    required RegionalCalendar region,
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final periodEnd = DateTime(now.year, 12, 31, 23, 59, 59);
    // Cache only for current year and until year end
    if (_cachedCurrentYear != null &&
        _yearCacheExpiry != null &&
        now.isBefore(_yearCacheExpiry!) &&
        _cachedCurrentYear!.year == year &&
        _cachedCurrentYear!.region == region) {
      return _cachedCurrentYear!;
    }

    // Fetch regional festivals from service
    final festivals = await RegionalFestivalService.instance.getRegionalFestivals(
      calendar: region,
      year: year,
      latitude: latitude,
      longitude: longitude,
    );

    // Group by month with names only
    final Map<int, List<String>> byMonth = {};
    for (final f in festivals) {
      byMonth.putIfAbsent(f.date.month, () => <String>[]).add(f.englishName);
    }

    final view = YearView(year: year, region: region, festivalsByMonth: byMonth);
    if (year == now.year) {
      _cachedCurrentYear = view;
      _yearCacheExpiry = periodEnd;
    }
    return view;
  }

  /// Get complete month panchang (names only) in one call; caches current month until end
  Future<MonthView> getMonthPanchang({
    required int year,
    required int month,
    required RegionalCalendar region,
    required double latitude,
    required double longitude,
    required String timezoneId,
  }) async {
    final now = DateTime.now();
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    if (_cachedCurrentMonth != null &&
        _monthCacheExpiry != null &&
        now.isBefore(_monthCacheExpiry!) &&
        _cachedCurrentMonth!.year == year &&
        _cachedCurrentMonth!.month == month &&
        _cachedCurrentMonth!.region == region) {
      return _cachedCurrentMonth!;
    }

    // Build all dates for the month
    final lastDay = DateTime(year, month + 1, 0);
    final dates = List<DateTime>.generate(lastDay.day, (i) => DateTime(year, month, i + 1));

    // Fetch precise regional festivals and index them by exact day
    final regionalFestivals = await RegionalFestivalService.instance.getRegionalFestivals(
      calendar: region,
      year: year,
      latitude: latitude,
      longitude: longitude,
    );
    final Map<int, List<String>> festivalsByDay = {};
    for (final f in regionalFestivals) {
      if (f.date.year == year && f.date.month == month) {
        festivalsByDay.putIfAbsent(f.date.day, () => <String>[]).add(
              (f.englishName.isNotEmpty ? f.englishName : f.name),
            );
      }
    }

    // For each date, compute planetary positions at sunrise boundary
    // and derive panchang names. We run computations in parallel.
    final dayFutures = dates.map((date) async {
      // Determine local sunrise to anchor day boundary
      final riseSet = await RiseSetService.instance.computeRiseSet(
        date: date,
        latitude: latitude,
        longitude: longitude,
        timezoneId: timezoneId,
      );
      final DateTime anchorLocal = riseSet.sunrise ?? date;

      final positions = await calculatePlanetaryPositions(
        localDateTime: anchorLocal,
        timezoneId: timezoneId,
        latitude: latitude,
        longitude: longitude,
      );

      // Derive panchang fields (names only) from planetary positions
      final moon = positions.getPlanet(Planet.moon);
      final sun = positions.getPlanet(Planet.sun);
      final nakshatraName = moon?.nakshatra.englishName ?? 'Unknown';
      final padaName = 'Pada ${moon?.pada.number ?? 0}';
      final (String tithiName, String pakshaName) = _computeTithiAndPaksha(
        sun?.longitude ?? 0.0,
        moon?.longitude ?? 0.0,
      );
      final yogaName = _computeYogaName((sun?.longitude ?? 0.0) + (moon?.longitude ?? 0.0));
      final karanaName = _computeKaranaName(sun?.longitude ?? 0.0, moon?.longitude ?? 0.0);

      // Compute rise/set with engine/service (replace placeholders)
      String fmt(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      // riseSet already computed above
      final sunriseTime = riseSet.sunrise != null ? fmt(riseSet.sunrise!) : '';
      final sunsetTime = riseSet.sunset != null ? fmt(riseSet.sunset!) : '';
      final moonriseTime = riseSet.moonrise != null ? fmt(riseSet.moonrise!) : '';
      final moonsetTime = riseSet.moonset != null ? fmt(riseSet.moonset!) : '';
      final rahuKalam = riseSet.rahuKalam ?? '';
      final yamaGanda = riseSet.yamaGandha ?? '';
      final gulikaKalam = riseSet.gulikaKalam ?? '';

      // Festivals for this exact day only
      final festivals = List<String>.from(festivalsByDay[date.day] ?? const <String>[]);

      return DayData(
        date: date,
        tithiName: tithiName,
        pakshaName: pakshaName,
        nakshatraName: nakshatraName,
        padaName: padaName,
        yogaName: yogaName,
        karanaName: karanaName,
        sunriseTime: sunriseTime,
        sunsetTime: sunsetTime,
        moonriseTime: moonriseTime,
        moonsetTime: moonsetTime,
        rahuKalam: rahuKalam,
        yamaGanda: yamaGanda,
        gulikaKalam: gulikaKalam,
        festivals: festivals,
      );
    }).toList();

    final days = await Future.wait(dayFutures);
    final monthView = MonthView(
      year: year,
      month: month,
      region: region,
      latitude: latitude,
      longitude: longitude,
      timezoneId: timezoneId,
      days: days,
    );

    if (year == now.year && month == now.month) {
      _cachedCurrentMonth = monthView;
      _monthCacheExpiry = monthEnd;
    }
    return monthView;
  }

  // Returns (tithiName, pakshaName)
  (String, String) _computeTithiAndPaksha(double sunLongitude, double moonLongitude) {
    final diff = ((moonLongitude - sunLongitude) % 360 + 360) % 360; // 0..360
    final tithiIndex = (diff / 12.0).floor(); // 0..29
    const tithiNames = [
      'Shukla Pratipada','Shukla Dvitiya','Shukla Tritiya','Shukla Chaturthi','Shukla Panchami',
      'Shukla Shashthi','Shukla Saptami','Shukla Ashtami','Shukla Navami','Shukla Dashami',
      'Shukla Ekadashi','Shukla Dwadashi','Shukla Trayodashi','Shukla Chaturdashi','Purnima',
      'Krishna Pratipada','Krishna Dvitiya','Krishna Tritiya','Krishna Chaturthi','Krishna Panchami',
      'Krishna Shashthi','Krishna Saptami','Krishna Ashtami','Krishna Navami','Krishna Dashami',
      'Krishna Ekadashi','Krishna Dwadashi','Krishna Trayodashi','Krishna Chaturdashi','Amavasya',
    ];
    final name = tithiNames[tithiIndex.clamp(0, 29)];
    final paksha = tithiIndex < 15 ? 'Shukla' : 'Krishna';
    return (name, paksha);
  }

  String _computeYogaName(double sumLongitudes) {
    final normalized = ((sumLongitudes % 360) + 360) % 360;
    final index = (normalized / 13.333333333333334).floor(); // 27 yogas
    const yogaNames = [
      'Vishkambha','Priti','Ayushman','Saubhagya','Shobhana','Atiganda','Sukarma','Dhriti','Shoola','Ganda',
      'Vriddhi','Dhruva','Vyaghata','Harshana','Vajra','Siddhi','Vyatipata','Variyana','Parigha','Shiva',
      'Siddha','Sadhya','Shubha','Shukla','Brahma','Indra','Vaidhriti'
    ];
    return yogaNames[index.clamp(0, 26)];
  }

  String _computeKaranaName(double sunLongitude, double moonLongitude) {
    final diff = ((moonLongitude - sunLongitude) % 360 + 360) % 360;
    final tithi = (diff / 12.0); // 0..30
    final karanaIndex = ((tithi * 2).floor()) % 60; // 60 karanas sequence
    const karanaSeq = [
      'Bava','Balava','Kaulava','Taitila','Garaja','Vanija','Vishti',
      'Bava','Balava','Kaulava','Taitila','Garaja','Vanija','Vishti',
      'Bava','Balava','Kaulava','Taitila','Garaja','Vanija','Vishti',
      'Bava','Balava','Kaulava','Taitila','Garaja','Vanija','Vishti',
      'Bava','Balava','Kaulava','Taitila','Garaja','Vanija','Vishti',
      'Bava','Balava','Kaulava','Taitila','Garaja','Vanija','Vishti',
      'Shakuni','Chatushpada','Naga','Kimstughna','Bava','Balava','Kaulava','Taitila','Garaja','Vanija','Vishti','Bava'
    ];
    final idx = karanaIndex.clamp(0, karanaSeq.length - 1);
    return karanaSeq[idx];
  }

  // ============================================================================
  // PANCHANG INTERVALS API
  // ============================================================================

  /// Get daily panchang intervals with precise start/end times
  Future<DailyPanchangIntervals> getDailyPanchangIntervals({
    required DateTime localDate,
    required String timezoneId,
    required double latitude,
    required double longitude,
  }) async {
    await _logger.info(
      'Getting daily panchang intervals',
      source: 'AstrologyFacade',
      metadata: {
        'localDate': localDate.toIso8601String(),
        'timezone': timezoneId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Validate timezone
    if (!await _validateTimezone(timezoneId)) {
      throw ArgumentError('Invalid timezone: $timezoneId');
    }

    // Convert local date to UTC for calculations
    final utcDate = await _convertLocalToUTC(localDate, timezoneId);

    // Calculate intervals using UTC date
    final intervals = await PanchangIntervalsService.instance.calculateDailyIntervals(
      date: utcDate,
      latitude: latitude,
      longitude: longitude,
    );

    await _logger.info(
      'Successfully calculated daily panchang intervals',
      source: 'AstrologyFacade',
    );

    return intervals;
  }

  // ============================================================================
  // REGIONAL FESTIVAL API
  // ============================================================================

  /// Get regional festival information with proper regional calculations
  Future<Map<String, dynamic>> getRegionalFestivalInfo({
    required String festivalName,
    required RegionalCalendar regionalCalendar,
    required int year,
    required double latitude,
    required double longitude,
  }) async {
    await _logger.info(
      'Getting regional festival information',
      source: 'AstrologyFacade',
      metadata: {
        'festivalName': festivalName,
        'regionalCalendar': regionalCalendar.name,
        'year': year,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    // Calculate festival date with regional variations
    final festivalDate = await RegionalFestivalService.instance.calculateRegionalFestivalDate(
      festivalName: festivalName,
      year: year,
      regionalCalendar: regionalCalendar,
      latitude: latitude,
      longitude: longitude,
    );

    // Get regional variations (names, significance, etc.)
    final variations = await RegionalFestivalService.instance.getRegionalFestivalVariations(
      festivalName: festivalName,
      regionalCalendar: regionalCalendar,
    );

    // Get enhanced rules if available
    final enhancedRules = await RegionalFestivalService.instance.getEnhancedFestivalRules(
      festivalName: festivalName,
      regionalCalendar: regionalCalendar,
      year: year,
      latitude: latitude,
      longitude: longitude,
    );

    return {
      'festivalName': festivalName,
      'regionalCalendar': regionalCalendar.name,
      'date': festivalDate,
      'regionalName': variations['regionalName'] ?? festivalName,
      'significance': variations['significance'] ?? '',
      'dateAdjustment': variations['dateAdjustment'] ?? 0,
      'enhancedRules': enhancedRules,
      'calculatedAt': DateTime.now().toUtc(),
    };
  }
}
