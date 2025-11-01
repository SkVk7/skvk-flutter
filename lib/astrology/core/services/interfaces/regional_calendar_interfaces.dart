/// Regional Calendar Service Interfaces
///
/// This file contains all the interfaces for regional calendar services,
/// following the Interface Segregation Principle (ISP) from SOLID principles.
library;

import '../../entities/astrology_entities.dart';
import '../../enums/astrology_enums.dart';

/// Core regional calendar service interface
abstract class IRegionalCalendarService {
  /// Get available regional calendars for a location
  Future<List<RegionalCalendarInfo>> getAvailableRegionalCalendars({
    required double latitude,
    required double longitude,
  });

  /// Get regional calendar information
  Future<RegionalCalendarInfo> getRegionalCalendarInfo({
    required RegionalCalendar calendar,
  });
}

/// Regional festival service interface
abstract class IRegionalFestivalService {
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

  /// Get festivals for a specific calendar
  Future<List<FestivalData>> getRegionalFestivals({
    required RegionalCalendar calendar,
    required int year,
    required double latitude,
    required double longitude,
  });
}

/// Sravana Masam service interface
abstract class ISravanaMasamService {
  /// Calculate Sravana Masam dates with regional variations
  Future<Map<String, DateTime>> calculateSravanaMasamDates({
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  });

  /// Get Sravana Masam regional variations
  Future<Map<String, dynamic>> getSravanaMasamVariations({
    required RegionalCalendar regionalCalendar,
  });

  /// Check if a date falls within Sravana Masam
  Future<bool> isSravanaMasamDate({
    required DateTime date,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  });
}

/// Regional calendar info service interface
abstract class IRegionalCalendarInfoService {
  /// Get calendar information
  Future<RegionalCalendarInfo> getCalendarInfo(RegionalCalendar calendar);

  /// Get all available calendars
  Future<List<RegionalCalendarInfo>> getAllCalendars();

  /// Get calendars for region
  Future<List<RegionalCalendarInfo>> getCalendarsForRegion(String region);
}

/// Regional variation service interface
abstract class IRegionalVariationService {
  /// Get regional variations for a festival
  Future<Map<String, dynamic>> getFestivalVariations({
    required String festivalName,
    required RegionalCalendar regionalCalendar,
  });

  /// Calculate regional adjustments
  Future<Duration> calculateRegionalAdjustment({
    required DateTime baseDate,
    required Map<String, dynamic> variations,
    required double latitude,
    required double longitude,
    RegionalCalendar? regionalCalendar,
  });

  /// Get timezone adjustment
  Future<int> getTimezoneAdjustment({
    required double latitude,
    required double longitude,
  });
}
