/// Regional Calendar Service - Comprehensive Regional Calendar Support
///
/// This service provides comprehensive support for all regional calendars
/// across India, ensuring accurate festival calculations based on regional
/// variations and traditions.
///
/// This service has been refactored to follow SOLID principles and uses
/// the Facade pattern to coordinate between specialized services.
library;

import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';
import 'regional_calendar_service_refactored.dart';

/// Regional calendar service interface
abstract class RegionalCalendarServiceInterface {
  /// Get available regional calendars for a location
  Future<List<RegionalCalendarInfo>> getAvailableRegionalCalendars({
    required double latitude,
    required double longitude,
  });

  /// Get regional calendar information
  Future<RegionalCalendarInfo> getRegionalCalendarInfo({
    required RegionalCalendar calendar,
  });

  /// Calculate festival date with regional variations
  Future<DateTime> calculateRegionalFestivalDate({
    required String festivalName,
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  });

  /// Get regional festival variations
  Future<Map<String, dynamic>> getRegionalFestivalVariations({
    required String festivalName,
    required RegionalCalendar regionalCalendar,
  });
}

/// Regional calendar service implementation
///
/// This service now delegates to the refactored service that follows
/// SOLID principles and proper design patterns.
class RegionalCalendarService implements RegionalCalendarServiceInterface {
  static RegionalCalendarService? _instance;
  final RegionalCalendarServiceRefactored _refactoredService;

  RegionalCalendarService._() : _refactoredService = RegionalCalendarServiceRefactored.instance;

  static RegionalCalendarService get instance {
    _instance ??= RegionalCalendarService._();
    return _instance!;
  }

  @override
  Future<List<RegionalCalendarInfo>> getAvailableRegionalCalendars({
    required double latitude,
    required double longitude,
  }) async {
    return await _refactoredService.getAvailableRegionalCalendars(
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<RegionalCalendarInfo> getRegionalCalendarInfo({
    required RegionalCalendar calendar,
  }) async {
    return await _refactoredService.getRegionalCalendarInfo(calendar: calendar);
  }

  /// Calculate festival date with regional variations
  @override
  Future<DateTime> calculateRegionalFestivalDate({
    required String festivalName,
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    return await _refactoredService.calculateRegionalFestivalDate(
      festivalName: festivalName,
      year: year,
      regionalCalendar: regionalCalendar,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get regional festival variations
  @override
  Future<Map<String, dynamic>> getRegionalFestivalVariations({
    required String festivalName,
    required RegionalCalendar regionalCalendar,
  }) async {
    return await _refactoredService.getRegionalFestivalVariations(
      festivalName: festivalName,
      regionalCalendar: regionalCalendar,
    );
  }

  /// Get festivals for a specific calendar
  Future<List<FestivalData>> getRegionalFestivals({
    required RegionalCalendar calendar,
    required int year,
    required double latitude,
    required double longitude,
  }) async {
    return await _refactoredService.getRegionalFestivals(
      calendar: calendar,
      year: year,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Calculate Sravana Masam dates with regional variations
  Future<Map<String, DateTime>> calculateSravanaMasamDates({
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    return await _refactoredService.calculateSravanaMasamDates(
      year: year,
      regionalCalendar: regionalCalendar,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get Sravana Masam regional variations
  Future<Map<String, dynamic>> getSravanaMasamVariations({
    required RegionalCalendar regionalCalendar,
  }) async {
    return await _refactoredService.getSravanaMasamVariations(
      regionalCalendar: regionalCalendar,
    );
  }

  /// Check if a date falls within Sravana Masam
  Future<bool> isSravanaMasamDate({
    required DateTime date,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    return await _refactoredService.isSravanaMasamDate(
      date: date,
      regionalCalendar: regionalCalendar,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get all available calendars
  Future<List<RegionalCalendarInfo>> getAllCalendars() async {
    return await _refactoredService.getAllCalendars();
  }

  /// Get calendars for a specific region
  Future<List<RegionalCalendarInfo>> getCalendarsForRegion(String region) async {
    return await _refactoredService.getCalendarsForRegion(region);
  }

  /// Calculate regional adjustment
  Future<Duration> calculateRegionalAdjustment({
    required DateTime baseDate,
    required Map<String, dynamic> variations,
    required double latitude,
    required double longitude,
    RegionalCalendar? regionalCalendar,
  }) async {
    return await _refactoredService.calculateRegionalAdjustment(
      baseDate: baseDate,
      variations: variations,
      latitude: latitude,
      longitude: longitude,
      regionalCalendar: regionalCalendar,
    );
  }

  /// Get timezone adjustment
  Future<int> getTimezoneAdjustment({
    required double latitude,
    required double longitude,
  }) async {
    return await _refactoredService.getTimezoneAdjustment(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
