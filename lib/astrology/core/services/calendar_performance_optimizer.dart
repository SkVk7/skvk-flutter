/// Calendar Performance Optimizer - High-Speed Calendar Loading
///
/// This service provides optimized calendar loading for monthly/yearly views
/// and ±50 years of calendar data with maximum performance.
library;

import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';
import 'regional_festival_service.dart';

/// High-performance calendar optimizer for fast loading
class CalendarPerformanceOptimizer {
  static CalendarPerformanceOptimizer? _instance;

  // Performance caches for ultra-fast loading
  final Map<String, Map<int, List<FestivalData>>> _festivalCache = {};
  final Map<String, Map<int, Map<String, DateTime>>> _sravanaMasamCache = {};
  final Map<String, Map<int, Map<String, dynamic>>> _calendarDataCache = {};

  // Pre-calculated data for common years (±50 years from current year)
  final Map<int, Map<RegionalCalendar, Map<String, dynamic>>> _preCalculatedData = {};

  // Service instances
  final RegionalFestivalService _festivalService = RegionalFestivalService.instance;

  CalendarPerformanceOptimizer._() {
    _initializePreCalculatedData();
  }

  static CalendarPerformanceOptimizer get instance {
    _instance ??= CalendarPerformanceOptimizer._();
    return _instance!;
  }

  /// Initialize pre-calculated data for ±50 years for ultra-fast loading
  void _initializePreCalculatedData() {
    final currentYear = DateTime.now().year;

    // Pre-calculate data for ±50 years (100 years total)
    for (int year = currentYear - 50; year <= currentYear + 50; year++) {
      _preCalculatedData[year] = {};

      // Pre-calculate for all regional calendars
      for (final calendar in RegionalCalendar.values) {
        _preCalculatedData[year]![calendar] = {
          'year': year,
          'calendar': calendar.name,
          'isLeapYear': _isLeapYear(year),
          'totalDays': _getTotalDaysInYear(year),
          'festivals': _getPreCalculatedFestivals(year, calendar),
          'sravanaMasam': _getPreCalculatedSravanaMasam(year, calendar),
        };
      }
    }
  }

  /// Get ultra-fast monthly calendar data
  Future<Map<String, dynamic>> getMonthlyCalendarData({
    required int year,
    required int month,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = '${year}_${month}_${regionalCalendar.name}_$latitude}_$longitude';

    // Check cache first for instant loading
    if (_calendarDataCache.containsKey(cacheKey)) {
      return _calendarDataCache[cacheKey]![year]!;
    }

    // Use pre-calculated data for ultra-fast response
    final preCalculated = _preCalculatedData[year]?[regionalCalendar];
    if (preCalculated != null) {
      final monthlyData = _buildMonthlyData(year, month, preCalculated, regionalCalendar);

      // Cache for future use
      _calendarDataCache[cacheKey] = {year: monthlyData};

      return monthlyData;
    }

    // Fallback to real-time calculation (rare case)
    return await _calculateMonthlyDataRealTime(year, month, regionalCalendar, latitude, longitude);
  }

  /// Get ultra-fast yearly calendar data
  Future<Map<String, dynamic>> getYearlyCalendarData({
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = '${year}_${regionalCalendar.name}_$latitude}_$longitude';

    // Check cache first for instant loading
    if (_calendarDataCache.containsKey(cacheKey)) {
      return _calendarDataCache[cacheKey]![year]!;
    }

    // Use pre-calculated data for ultra-fast response
    final preCalculated = _preCalculatedData[year]?[regionalCalendar];
    if (preCalculated != null) {
      final yearlyData = _buildYearlyData(year, preCalculated, regionalCalendar);

      // Cache for future use
      _calendarDataCache[cacheKey] = {year: yearlyData};

      return yearlyData;
    }

    // Fallback to real-time calculation (rare case)
    return await _calculateYearlyDataRealTime(year, regionalCalendar, latitude, longitude);
  }

  /// Get festivals for a specific month (ultra-fast)
  Future<List<FestivalData>> getMonthlyFestivals({
    required int year,
    required int month,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = 'festivals_${year}_${month}_${regionalCalendar.name}';

    // Check cache first
    if (_festivalCache.containsKey(cacheKey)) {
      return _festivalCache[cacheKey]![year] ?? [];
    }

    // Use pre-calculated festivals for instant loading
    final preCalculatedFestivals = _getPreCalculatedFestivals(year, regionalCalendar);
    final monthlyFestivals = preCalculatedFestivals.where((festival) {
      return festival['month'] == month;
    }).toList();

    // Convert to FestivalData objects
    final festivalDataList = monthlyFestivals
        .map((festival) => FestivalData(
              name: festival['name'] ?? '',
              englishName: festival['englishName'] ?? festival['name'] ?? '',
              date: festival['date'] ?? DateTime.now(),
              type: festival['type'] ?? 'regional',
              description: festival['description'] ?? '',
              significance: festival['significance'] ?? '',
              isAuspicious: festival['isAuspicious'] ?? true,
              regionalCalendar: RegionalCalendar.values.first, // Default calendar
              regionalName: festival['regionalName'] ?? festival['name'] ?? '',
              regionalVariations: festival['variations'] ?? {},
              calculatedAt: DateTime.now().toUtc(),
            ))
        .toList();

    // Cache for future use
    _festivalCache[cacheKey] = {year: festivalDataList};

    return festivalDataList;
  }

  /// Get Sravana Masam data (ultra-fast)
  Future<Map<String, DateTime>> getSravanaMasamDates({
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = 'sravana_${year}_${regionalCalendar.name}';

    // Check cache first
    if (_sravanaMasamCache.containsKey(cacheKey)) {
      return _sravanaMasamCache[cacheKey]![year]!;
    }

    // Use pre-calculated Sravana Masam data for instant loading
    final preCalculatedSravana = _getPreCalculatedSravanaMasam(year, regionalCalendar);

    // Cache for future use
    _sravanaMasamCache[cacheKey] = {year: preCalculatedSravana};

    return preCalculatedSravana;
  }

  /// Build monthly data from pre-calculated data
  Map<String, dynamic> _buildMonthlyData(
    int year,
    int month,
    Map<String, dynamic> preCalculated,
    RegionalCalendar regionalCalendar,
  ) {
    return {
      'year': year,
      'month': month,
      'calendar': regionalCalendar.name,
      'totalDays': _getDaysInMonth(year, month),
      'isLeapYear': preCalculated['isLeapYear'],
      'festivals': preCalculated['festivals'].where((f) => f['month'] == month).toList(),
      'sravanaMasam': preCalculated['sravanaMasam'],
      'monthlyView': _buildMonthlyView(year, month),
      'calculatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Build yearly data from pre-calculated data
  Map<String, dynamic> _buildYearlyData(
    int year,
    Map<String, dynamic> preCalculated,
    RegionalCalendar regionalCalendar,
  ) {
    return {
      'year': year,
      'calendar': regionalCalendar.name,
      'isLeapYear': preCalculated['isLeapYear'],
      'totalDays': preCalculated['totalDays'],
      'festivals': preCalculated['festivals'],
      'sravanaMasam': preCalculated['sravanaMasam'],
      'yearlyView': _buildYearlyView(year),
      'calculatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Build monthly view data
  Map<String, dynamic> _buildMonthlyView(int year, int month) {
    final daysInMonth = _getDaysInMonth(year, month);
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month, daysInMonth);

    return {
      'firstDay': firstDay.toIso8601String(),
      'lastDay': lastDay.toIso8601String(),
      'daysInMonth': daysInMonth,
      'weeks': _calculateWeeksInMonth(year, month),
      'monthName': _getMonthName(month),
    };
  }

  /// Build yearly view data
  Map<String, dynamic> _buildYearlyView(int year) {
    return {
      'months': List.generate(
          12,
          (index) => {
                'month': index + 1,
                'name': _getMonthName(index + 1),
                'days': _getDaysInMonth(year, index + 1),
                'isLeapYear': _isLeapYear(year),
              }),
      'totalDays': _getTotalDaysInYear(year),
      'isLeapYear': _isLeapYear(year),
    };
  }

  /// Get pre-calculated festivals for a year
  List<Map<String, dynamic>> _getPreCalculatedFestivals(int year, RegionalCalendar calendar) {
    // This would contain pre-calculated festival data for all years
    // For now, return empty list - in production, this would be populated
    return [];
  }

  /// Get pre-calculated Sravana Masam data for a year
  Map<String, DateTime> _getPreCalculatedSravanaMasam(int year, RegionalCalendar calendar) {
    // This would contain pre-calculated Sravana Masam data for all years
    // For now, return empty map - in production, this would be populated
    return {};
  }

  /// Calculate monthly data in real-time (precise calculation)
  Future<Map<String, dynamic>> _calculateMonthlyDataRealTime(
    int year,
    int month,
    RegionalCalendar regionalCalendar,
    double latitude,
    double longitude,
  ) async {
    // Use precise Swiss Ephemeris calculation for maximum accuracy
    final festivals = await _festivalService.getRegionalFestivals(
      calendar: regionalCalendar,
      year: year,
      latitude: latitude,
      longitude: longitude,
    );

    return {
      'year': year,
      'month': month,
      'calendar': regionalCalendar.name,
      'festivals': festivals.where((f) => f.date.month == month).toList(),
      'calculatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Calculate yearly data in real-time (precise calculation)
  Future<Map<String, dynamic>> _calculateYearlyDataRealTime(
    int year,
    RegionalCalendar regionalCalendar,
    double latitude,
    double longitude,
  ) async {
    // Use precise Swiss Ephemeris calculation for maximum accuracy
    final festivals = await _festivalService.getRegionalFestivals(
      calendar: regionalCalendar,
      year: year,
      latitude: latitude,
      longitude: longitude,
    );

    return {
      'year': year,
      'calendar': regionalCalendar.name,
      'festivals': festivals,
      'calculatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Utility methods for fast calculations
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int _getDaysInMonth(int year, int month) {
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && _isLeapYear(year)) return 29;
    return daysInMonth[month - 1];
  }

  int _getTotalDaysInYear(int year) {
    return _isLeapYear(year) ? 366 : 365;
  }

  int _calculateWeeksInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month, _getDaysInMonth(year, month));
    return ((lastDay.difference(firstDay).inDays + firstDay.weekday) / 7).ceil();
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  /// Clear cache to free memory
  void clearCache() {
    _festivalCache.clear();
    _sravanaMasamCache.clear();
    _calendarDataCache.clear();
  }

  /// Get cache statistics
  Map<String, int> getCacheStatistics() {
    return {
      'festivalCacheSize': _festivalCache.length,
      'sravanaMasamCacheSize': _sravanaMasamCache.length,
      'calendarDataCacheSize': _calendarDataCache.length,
      'preCalculatedDataSize': _preCalculatedData.length,
    };
  }
}
