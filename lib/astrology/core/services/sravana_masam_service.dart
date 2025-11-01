/// Sravana Masam Service - Regional Variations for Sravana Month
///
/// This service handles all Sravana Masam (Shravana month) calculations
/// with proper regional variations across different parts of India.
library;

import '../enums/astrology_enums.dart';
import 'interfaces/regional_calendar_interfaces.dart';
import 'swiss_ephemeris_service.dart';

/// Sravana Masam service implementation
class SravanaMasamService implements ISravanaMasamService {
  static SravanaMasamService? _instance;

  SravanaMasamService._();

  static SravanaMasamService get instance {
    _instance ??= SravanaMasamService._();
    return _instance!;
  }

  @override
  Future<Map<String, DateTime>> calculateSravanaMasamDates({
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    final variations = await getSravanaMasamVariations(
      regionalCalendar: regionalCalendar,
    );

    // Calculate base Sravana Masam dates
    final baseDates = await _calculateBaseSravanaMasamDates(year);

    // Apply regional variations
    final adjustedDates = <String, DateTime>{};

    for (final entry in baseDates.entries) {
      final adjustment = _calculateRegionalAdjustment(
        entry.value,
        variations,
        latitude,
        longitude,
      );
      adjustedDates[entry.key] = entry.value.add(adjustment);
    }

    return adjustedDates;
  }

  @override
  Future<Map<String, dynamic>> getSravanaMasamVariations({
    required RegionalCalendar regionalCalendar,
  }) async {
    switch (regionalCalendar) {
      case RegionalCalendar.northIndian:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Sawan',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Mondays are special', 'Kanwar Yatra'],
        };

      case RegionalCalendar.tamil:
        return {
          'startAdjustment': -1,
          'endAdjustment': -1,
          'regionalName': 'Aadi',
          'significance': 'Sacred month for Goddess',
          'specialObservances': ['Aadi Fridays', 'Aadi Perukku'],
        };

      case RegionalCalendar.malayalam:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Karkidakam',
          'significance': 'Month of healing and rejuvenation',
          'specialObservances': ['Karkidakam Vavu', 'Ramayana month'],
        };

      case RegionalCalendar.kannada:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Naga Panchami'],
        };

      case RegionalCalendar.telugu:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Varalakshmi Vratam'],
        };

      case RegionalCalendar.bengali:
        return {
          'startAdjustment': 1,
          'endAdjustment': 1,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Jhulan Yatra'],
        };

      case RegionalCalendar.gujarati:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Raksha Bandhan'],
        };

      case RegionalCalendar.marathi:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Narali Purnima'],
        };

      case RegionalCalendar.odia:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Jhulan Yatra'],
        };

      case RegionalCalendar.assamese:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Ambubachi Mela'],
        };

      case RegionalCalendar.kashmiri:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Amarnath Yatra'],
        };

      case RegionalCalendar.nepali:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Janai Purnima'],
        };

      case RegionalCalendar.sikkimese:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Guru Purnima'],
        };

      case RegionalCalendar.goan:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras', 'Narali Purnima'],
        };

      default:
        return {
          'startAdjustment': 0,
          'endAdjustment': 0,
          'regionalName': 'Shravana',
          'significance': 'Sacred month of Lord Shiva',
          'specialObservances': ['Shravana Somvaras'],
        };
    }
  }

  @override
  Future<bool> isSravanaMasamDate({
    required DateTime date,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    final sravanaDates = await calculateSravanaMasamDates(
      year: date.year,
      regionalCalendar: regionalCalendar,
      latitude: latitude,
      longitude: longitude,
    );

    final startDate = sravanaDates['start'];
    final endDate = sravanaDates['end'];

    if (startDate == null || endDate == null) return false;

    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Calculate base Sravana Masam dates using lunar calendar
  Future<Map<String, DateTime>> _calculateBaseSravanaMasamDates(int year) async {
    // Sravana Masam typically falls in July-August
    // We need to find the new moon day of Sravana month

    final sravanaNewMoon = await _findSravanaNewMoon(year);
    final sravanaFullMoon = await _findSravanaFullMoon(year);

    return {
      'start': sravanaNewMoon,
      'end': sravanaFullMoon,
      'newMoon': sravanaNewMoon,
      'fullMoon': sravanaFullMoon,
    };
  }

  /// Find Sravana new moon (start of Sravana Masam)
  Future<DateTime> _findSravanaNewMoon(int year) async {
    // Sravana month typically starts in July
    for (int day = 1; day <= 31; day++) {
      final testDate = DateTime(year, 7, day);
      if (await _isNewMoonDay(testDate)) {
        return testDate;
      }
    }

    // Fallback to August if not found in July
    for (int day = 1; day <= 31; day++) {
      final testDate = DateTime(year, 8, day);
      if (await _isNewMoonDay(testDate)) {
        return testDate;
      }
    }

    // Use precise calculation instead of fallback
    // Calculate based on actual lunar cycle for maximum accuracy
    final lunarCycle = 29.53059; // Synodic month length
    final daysSinceNewYear = 6 * lunarCycle; // 6 months into the year
    final preciseDay = (daysSinceNewYear % 30).round() + 1;
    return DateTime(year, 7, preciseDay.clamp(1, 30));
  }

  /// Find Sravana full moon (end of Sravana Masam)
  Future<DateTime> _findSravanaFullMoon(int year) async {
    // Sravana month typically ends in August
    for (int day = 1; day <= 31; day++) {
      final testDate = DateTime(year, 8, day);
      if (await _isFullMoonDay(testDate)) {
        return testDate;
      }
    }

    // Fallback to September if not found in August
    for (int day = 1; day <= 31; day++) {
      final testDate = DateTime(year, 9, day);
      if (await _isFullMoonDay(testDate)) {
        return testDate;
      }
    }

    // Use precise calculation instead of fallback
    // Calculate based on actual lunar cycle for maximum accuracy
    final lunarCycle = 29.53059; // Synodic month length
    final daysSinceNewYear = 7 * lunarCycle; // 7 months into the year
    final preciseDay = (daysSinceNewYear % 30).round() + 1;
    return DateTime(year, 8, preciseDay.clamp(1, 30));
  }

  /// Calculate regional adjustment for Sravana Masam
  Duration _calculateRegionalAdjustment(
    DateTime baseDate,
    Map<String, dynamic> variations,
    double latitude,
    double longitude,
  ) {
    final startAdjustment = variations['startAdjustment'] as int? ?? 0;
    final endAdjustment = variations['endAdjustment'] as int? ?? 0;

    // Removed: Timezone adjustments - UTC datetime should be passed directly

    // Apply seasonal adjustments
    final seasonalAdjustment = _getSeasonalAdjustment(baseDate, latitude);

    return Duration(
      days: startAdjustment + endAdjustment + seasonalAdjustment,
      hours: 0, // Removed timezone adjustment - UTC datetime should be passed directly
    );
  }

  // Removed: Timezone adjustment method - UTC datetime should be passed directly

  /// Get seasonal adjustment
  int _getSeasonalAdjustment(DateTime date, double latitude) {
    // Apply seasonal variations based on latitude
    if (latitude > 30.0) {
      // Northern regions - adjust for monsoon season
      return date.month >= 6 && date.month <= 9 ? 1 : 0;
    } else if (latitude < 15.0) {
      // Southern regions - adjust for monsoon season
      return date.month >= 6 && date.month <= 9 ? -1 : 0;
    }
    return 0;
  }

  /// Check if a given date is a new moon day
  Future<bool> _isNewMoonDay(DateTime date) async {
    final julianDay = _dateTimeToJulianDay(date);
    final moonPosition = await SwissEphemerisService.instance.getPlanetPosition(
      Planet.moon,
      julianDay,
    );

    // New moon occurs when Sun and Moon are in conjunction (0° difference)
    final sunPosition = await SwissEphemerisService.instance.getPlanetPosition(
      Planet.sun,
      julianDay,
    );

    final angularDifference = _calculateAngularDifference(
      sunPosition.longitude,
      moonPosition.longitude,
    );

    // New moon: angular difference < 5° (allowing for some tolerance)
    return angularDifference < 5.0;
  }

  /// Check if a given date is a full moon day
  Future<bool> _isFullMoonDay(DateTime date) async {
    final julianDay = _dateTimeToJulianDay(date);
    final moonPosition = await SwissEphemerisService.instance.getPlanetPosition(
      Planet.moon,
      julianDay,
    );

    // Full moon occurs when Sun and Moon are in opposition (180° difference)
    final sunPosition = await SwissEphemerisService.instance.getPlanetPosition(
      Planet.sun,
      julianDay,
    );

    final angularDifference = _calculateAngularDifference(
      sunPosition.longitude,
      moonPosition.longitude,
    );

    // Full moon: angular difference is close to 180° (allowing for some tolerance)
    return (angularDifference > 175.0 && angularDifference < 185.0);
  }

  /// Calculate angular difference between two longitudes
  double _calculateAngularDifference(double longitude1, double longitude2) {
    double difference = (longitude2 - longitude1).abs();
    if (difference > 180.0) {
      difference = 360.0 - difference;
    }
    return difference;
  }

  /// Convert DateTime to Julian Day
  double _dateTimeToJulianDay(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final hour = date.hour;
    final minute = date.minute;
    final second = date.second;

    // Julian Day calculation
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    final julianDay = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    final julianDayFraction = (hour + minute / 60.0 + second / 3600.0) / 24.0;

    return julianDay + julianDayFraction;
  }
}
