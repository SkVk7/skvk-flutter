/// Regional Calendar Service - Refactored with SOLID Principles
///
/// This is the main coordinator service that uses the Facade pattern
/// to provide a unified interface to all regional calendar functionality.
library;

import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';
import 'interfaces/regional_calendar_interfaces.dart';
import 'regional_calendar_info_service.dart';
import 'regional_festival_service.dart';
import 'regional_variation_service.dart';
import 'sravana_masam_service.dart';

/// Refactored regional calendar service implementation
///
/// This service follows the Facade pattern and coordinates between
/// multiple specialized services, following SOLID principles.
class RegionalCalendarServiceRefactored implements IRegionalCalendarService {
  static RegionalCalendarServiceRefactored? _instance;

  // Dependency injection - following Dependency Inversion Principle
  final IRegionalCalendarInfoService _calendarInfoService;
  final IRegionalFestivalService _festivalService;
  final IRegionalVariationService _variationService;
  final ISravanaMasamService _sravanaMasamService;

  RegionalCalendarServiceRefactored._({
    required IRegionalCalendarInfoService calendarInfoService,
    required IRegionalFestivalService festivalService,
    required IRegionalVariationService variationService,
    required ISravanaMasamService sravanaMasamService,
  })  : _calendarInfoService = calendarInfoService,
        _festivalService = festivalService,
        _variationService = variationService,
        _sravanaMasamService = sravanaMasamService;

  /// Factory constructor for dependency injection
  factory RegionalCalendarServiceRefactored.create({
    IRegionalCalendarInfoService? calendarInfoService,
    IRegionalFestivalService? festivalService,
    IRegionalVariationService? variationService,
    ISravanaMasamService? sravanaMasamService,
  }) {
    return RegionalCalendarServiceRefactored._(
      calendarInfoService: calendarInfoService ?? RegionalCalendarInfoService.instance,
      festivalService: festivalService ?? RegionalFestivalService.instance,
      variationService: variationService ?? RegionalVariationService.instance,
      sravanaMasamService: sravanaMasamService ?? SravanaMasamService.instance,
    );
  }

  /// Singleton instance with default dependencies
  static RegionalCalendarServiceRefactored get instance {
    _instance ??= RegionalCalendarServiceRefactored.create();
    return _instance!;
  }

  @override
  Future<List<RegionalCalendarInfo>> getAvailableRegionalCalendars({
    required double latitude,
    required double longitude,
  }) async {
    final availableCalendars = <RegionalCalendarInfo>[];

    // Determine region based on coordinates
    final region = _determineRegion(latitude, longitude);

    // Get calendars for the region
    final regionalCalendars = await _calendarInfoService.getCalendarsForRegion(region);
    availableCalendars.addAll(regionalCalendars);

    // Always add universal calendar
    final universalCalendar =
        await _calendarInfoService.getCalendarInfo(RegionalCalendar.universal);
    if (!availableCalendars.contains(universalCalendar)) {
      availableCalendars.add(universalCalendar);
    }

    return availableCalendars;
  }

  @override
  Future<RegionalCalendarInfo> getRegionalCalendarInfo({
    required RegionalCalendar calendar,
  }) async {
    return await _calendarInfoService.getCalendarInfo(calendar);
  }

  /// Calculate festival date with regional variations
  Future<DateTime> calculateRegionalFestivalDate({
    required String festivalName,
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    return await _festivalService.calculateRegionalFestivalDate(
      festivalName: festivalName,
      year: year,
      regionalCalendar: regionalCalendar,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get regional festival variations
  Future<Map<String, dynamic>> getRegionalFestivalVariations({
    required String festivalName,
    required RegionalCalendar regionalCalendar,
  }) async {
    return await _variationService.getFestivalVariations(
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
    return await _festivalService.getRegionalFestivals(
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
    return await _sravanaMasamService.calculateSravanaMasamDates(
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
    return await _sravanaMasamService.getSravanaMasamVariations(
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
    return await _sravanaMasamService.isSravanaMasamDate(
      date: date,
      regionalCalendar: regionalCalendar,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get all available calendars
  Future<List<RegionalCalendarInfo>> getAllCalendars() async {
    return await _calendarInfoService.getAllCalendars();
  }

  /// Get calendars for a specific region
  Future<List<RegionalCalendarInfo>> getCalendarsForRegion(String region) async {
    return await _calendarInfoService.getCalendarsForRegion(region);
  }

  /// Calculate regional adjustment
  Future<Duration> calculateRegionalAdjustment({
    required DateTime baseDate,
    required Map<String, dynamic> variations,
    required double latitude,
    required double longitude,
    RegionalCalendar? regionalCalendar,
  }) async {
    return await _variationService.calculateRegionalAdjustment(
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
    return await _variationService.getTimezoneAdjustment(
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Determine region based on coordinates
  String _determineRegion(double latitude, double longitude) {
    // North India
    if (latitude >= 28.0 && latitude <= 37.0 && longitude >= 74.0 && longitude <= 84.0) {
      return 'north';
    }

    // South India
    if (latitude >= 8.0 && latitude <= 20.0 && longitude >= 76.0 && longitude <= 80.0) {
      return 'south';
    }

    // East India
    if (latitude >= 20.0 && latitude <= 30.0 && longitude >= 85.0 && longitude <= 97.0) {
      return 'east';
    }

    // West India
    if (latitude >= 15.0 && latitude <= 25.0 && longitude >= 68.0 && longitude <= 76.0) {
      return 'west';
    }

    // Central India
    if (latitude >= 20.0 && latitude <= 26.0 && longitude >= 74.0 && longitude <= 85.0) {
      return 'central';
    }

    // Special regions
    if (latitude >= 32.0 && latitude <= 37.0 && longitude >= 74.0 && longitude <= 80.0) {
      return 'special'; // Kashmir
    }

    return 'universal';
  }
}
