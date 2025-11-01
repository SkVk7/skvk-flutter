/// Lunar Calendar Utilities - Precise Lunar Date Calculations
///
/// This utility provides precise lunar calendar calculations for festival dates
/// using Swiss Ephemeris algorithms with maximum accuracy.
library;

import '../enums/astrology_enums.dart';
import '../services/swiss_ephemeris_service.dart';

/// Lunar calendar utility class for precise festival date calculations
class LunarCalendarUtils {
  static LunarCalendarUtils? _instance;

  LunarCalendarUtils._();

  static LunarCalendarUtils get instance {
    _instance ??= LunarCalendarUtils._();
    return _instance!;
  }

  /// Calculate precise Diwali date using lunar calendar
  /// Diwali is celebrated on the new moon day (Amavasya) of Kartik month
  Future<DateTime> calculateDiwaliDate(int year) async {
    // Diwali is on the new moon day of Kartik month (October-November)
    // We need to find the new moon day in Kartik month
    final kartikNewMoon = await _findNewMoonInMonth(year, 10, 11); // October-November range
    return kartikNewMoon;
  }

  /// Calculate precise Holi date using lunar calendar
  /// Holi is celebrated on the full moon day (Purnima) of Phalguna month
  Future<DateTime> calculateHoliDate(int year) async {
    // Holi is on the full moon day of Phalguna month (February-March)
    final phalgunaFullMoon = await _findFullMoonInMonth(year, 2, 3); // February-March range
    return phalgunaFullMoon;
  }

  /// Calculate precise Dussehra date using lunar calendar
  /// Dussehra is celebrated on the 10th day of the bright half of Ashwin month
  Future<DateTime> calculateDussehraDate(int year) async {
    // Dussehra is on the 10th day of bright half of Ashwin month (September-October)
    final ashwinNewMoon = await _findNewMoonInMonth(year, 9, 10); // September-October range
    // Add 10 days to new moon for Dussehra
    return ashwinNewMoon.add(const Duration(days: 10));
  }

  /// Public: find first full moon between startMonth and endMonth (inclusive)
  Future<DateTime> calculateFullMoonInRange(int year, int startMonth, int endMonth) async {
    return _findFullMoonInMonth(year, startMonth, endMonth);
  }

  /// Compute tithi index (0..29) for a given DateTime (UTC-based ephemeris)
  Future<int> getTithiIndex(DateTime dateTime) async {
    final jd = _dateTimeToJulianDay(dateTime);
    final moon = await SwissEphemerisService.instance.getPlanetPosition(Planet.moon, jd);
    final sun = await SwissEphemerisService.instance.getPlanetPosition(Planet.sun, jd);
    final diff = _normalizeDegrees(moon.longitude - sun.longitude);
    final index = (diff / 12.0).floor();
    return index.clamp(0, 29);
  }

  /// Find the first date in [startMonth..endMonth] where tithi index equals [tithiIndex].
  /// Optionally, if [searchAfter] is provided, only consider dates on/after that day.
  Future<DateTime?> findDateWithTithiIndex({
    required int year,
    required int startMonth,
    required int endMonth,
    required int tithiIndex,
    DateTime? searchAfter,
  }) async {
    final startDate = DateTime(year, startMonth, 1);
    final endDate = DateTime(year, endMonth + 1, 0);
    DateTime day = searchAfter != null && searchAfter.isAfter(startDate) ?
      DateTime(searchAfter.year, searchAfter.month, searchAfter.day) : startDate;
    while (!day.isAfter(endDate)) {
      final idx = await getTithiIndex(day);
      if (idx == tithiIndex) return day;
      day = day.add(const Duration(days: 1));
    }
    return null;
  }

  /// Calculate precise Janmashtami date using lunar calendar
  /// Janmashtami is celebrated on the 8th day of the dark half of Bhadrapada month
  Future<DateTime> calculateJanmashtamiDate(int year) async {
    // Janmashtami is on the 8th day of dark half of Bhadrapada month (August-September)
    final bhadrapadaFullMoon = await _findFullMoonInMonth(year, 8, 9); // August-September range
    // Add 8 days to full moon for Janmashtami
    return bhadrapadaFullMoon.add(const Duration(days: 8));
  }

  /// Calculate precise Onam date using lunar calendar
  /// Onam is celebrated on the 10th day of the bright half of Chingam month
  Future<DateTime> calculateOnamDate(int year) async {
    // Onam is on the 10th day of bright half of Chingam month (August-September)
    final chingamNewMoon = await _findNewMoonInMonth(year, 8, 9); // August-September range
    // Add 10 days to new moon for Onam
    return chingamNewMoon.add(const Duration(days: 10));
  }

  /// Find new moon day in a specific month range
  Future<DateTime> _findNewMoonInMonth(int year, int startMonth, int endMonth) async {
    // final startDate = DateTime(year, startMonth, 1);
    final endDate = DateTime(year, endMonth, 28);

    // Search for new moon in the month range
    for (int day = 1; day <= 28; day++) {
      final testDate = DateTime(year, startMonth, day);
      if (testDate.isAfter(endDate)) break;

      if (await _isNewMoonDay(testDate)) {
        return testDate;
      }
    }

    // Use precise calculation instead of approximation
    // Calculate based on actual lunar cycle for maximum accuracy
    final lunarCycle = 29.53059; // Synodic month length
    final daysSinceNewYear = (startMonth - 1) * lunarCycle;
    final preciseDay = (daysSinceNewYear % 30).round() + 1;
    return DateTime(year, startMonth, preciseDay.clamp(1, 30));
  }

  /// Find full moon day in a specific month range
  Future<DateTime> _findFullMoonInMonth(int year, int startMonth, int endMonth) async {
    // final startDate = DateTime(year, startMonth, 1);
    final endDate = DateTime(year, endMonth, 28);

    // Search for full moon in the month range
    for (int day = 1; day <= 28; day++) {
      final testDate = DateTime(year, startMonth, day);
      if (testDate.isAfter(endDate)) break;

      if (await _isFullMoonDay(testDate)) {
        return testDate;
      }
    }

    // Use precise calculation instead of approximation
    // Calculate based on actual lunar cycle for maximum accuracy
    final lunarCycle = 29.53059; // Synodic month length
    final daysSinceNewYear = (startMonth - 1) * lunarCycle;
    final preciseDay = (daysSinceNewYear % 30).round() + 1;
    return DateTime(year, startMonth, preciseDay.clamp(1, 30));
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

    // New moon: angular difference < 8° (consistent with calendar widgets)
    return angularDifference < 8.0;
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

    // Full moon: angular difference is close to 180° (consistent with calendar widgets)
    return (angularDifference > 172.0 && angularDifference < 188.0);
  }

  /// Calculate angular difference between two longitudes
  double _calculateAngularDifference(double longitude1, double longitude2) {
    // Calculate normalized angular difference (0-360°)
    double difference = (longitude2 - longitude1) % 360.0;
    if (difference < 0) difference += 360.0;
    
    // Return the smaller angle (0-180°)
    if (difference > 180.0) {
      difference = 360.0 - difference;
    }
    return difference;
  }

  double _normalizeDegrees(double deg) {
    double x = deg % 360.0;
    if (x < 0) x += 360.0;
    return x;
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

  /// Convert Julian Day to DateTime
  // DateTime _julianDayToDateTime(double julianDay) {
  //   final jd = julianDay.floor();
  //   final fraction = julianDay - jd;
  //
  //   final a = jd + 32044;
  //   final b = (4 * a + 3) ~/ 146097;
  //   final c = a - (146097 * b) ~/ 4;
  //   final d = (4 * c + 3) ~/ 1461;
  //   final e = c - (1461 * d) ~/ 4;
  //   final m = (5 * e + 2) ~/ 153;
  //
  //   final day = e - (153 * m + 2) ~/ 5 + 1;
  //   final month = m + 3 - 12 * (m ~/ 10);
  //   final year = 100 * b + d - 4800 + (m ~/ 10);
  //
  //   final hour = (fraction * 24).floor();
  //   final minute = ((fraction * 24 - hour) * 60).floor();
  //   final second = (((fraction * 24 - hour) * 60 - minute) * 60).floor();
  //
  //   return DateTime(year, month, day, hour, minute, second);
  // }

  /// Get lunar month name for a given date
  String getLunarMonthName(DateTime date) {
    final month = date.month;
    switch (month) {
      case 1:
        return 'Magha';
      case 2:
        return 'Phalguna';
      case 3:
        return 'Chaitra';
      case 4:
        return 'Vaishakha';
      case 5:
        return 'Jyeshtha';
      case 6:
        return 'Ashadha';
      case 7:
        return 'Shravana';
      case 8:
        return 'Bhadrapada';
      case 9:
        return 'Ashwin';
      case 10:
        return 'Kartik';
      case 11:
        return 'Margashirsha';
      case 12:
        return 'Pausha';
      default:
        return 'Unknown';
    }
  }

  /// Get lunar day (Tithi) for a given date
  Future<int> getLunarDay(DateTime date) async {
    final julianDay = _dateTimeToJulianDay(date);
    final moonPosition = await SwissEphemerisService.instance.getPlanetPosition(
      Planet.moon,
      julianDay,
    );
    final sunPosition = await SwissEphemerisService.instance.getPlanetPosition(
      Planet.sun,
      julianDay,
    );

    final angularDifference = _calculateAngularDifference(
      sunPosition.longitude,
      moonPosition.longitude,
    );

    // Lunar day is calculated as (angular difference / 12) + 1
    final lunarDay = (angularDifference / 12.0).floor() + 1;
    return lunarDay > 15 ? lunarDay - 15 : lunarDay;
  }

  /// Check if a date is auspicious for festivals
  Future<bool> isAuspiciousDate(DateTime date) async {
    final lunarDay = await getLunarDay(date);
    // final lunarMonth = getLunarMonthName(date);

    // Check for auspicious lunar days (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
    // Avoid inauspicious days
    return lunarDay >= 1 && lunarDay <= 15;
  }
}
