/// Regional Calendar Info Service - Calendar Metadata Management
///
/// This service handles all regional calendar metadata and information
/// following the Single Responsibility Principle.
library;

import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';
import 'interfaces/regional_calendar_interfaces.dart';

/// Regional calendar info service implementation
class RegionalCalendarInfoService implements IRegionalCalendarInfoService {
  static RegionalCalendarInfoService? _instance;
  final Map<RegionalCalendar, RegionalCalendarInfo> _calendarInfo = {};

  RegionalCalendarInfoService._() {
    _initializeCalendarInfo();
  }

  static RegionalCalendarInfoService get instance {
    _instance ??= RegionalCalendarInfoService._();
    return _instance!;
  }

  @override
  Future<RegionalCalendarInfo> getCalendarInfo(RegionalCalendar calendar) async {
    return _calendarInfo[calendar] ?? _calendarInfo[RegionalCalendar.universal]!;
  }

  @override
  Future<List<RegionalCalendarInfo>> getAllCalendars() async {
    return _calendarInfo.values.toList();
  }

  @override
  Future<List<RegionalCalendarInfo>> getCalendarsForRegion(String region) async {
    final calendars = <RegionalCalendarInfo>[];

    for (final calendar in _calendarInfo.values) {
      if (calendar.region.toLowerCase().contains(region.toLowerCase()) ||
          region.toLowerCase().contains(calendar.region.toLowerCase())) {
        calendars.add(calendar);
      }
    }

    return calendars;
  }

  /// Initialize calendar information
  void _initializeCalendarInfo() {
    // Universal Calendar
    _calendarInfo[RegionalCalendar.universal] = RegionalCalendarInfo(
      calendar: RegionalCalendar.universal,
      name: 'Universal Calendar',
      region: 'All Regions',
      description: 'Universal calendar for all regions',
      characteristics: [CalendarCharacteristics.lunisolar],
      regionalVariations: {},
      calculatedAt: DateTime.now().toUtc(),
    );

    // North Indian Calendars
    _initializeNorthIndianCalendars();

    // South Indian Calendars
    _initializeSouthIndianCalendars();

    // East Indian Calendars
    _initializeEastIndianCalendars();

    // West Indian Calendars
    _initializeWestIndianCalendars();

    // Central Indian Calendars
    _initializeCentralIndianCalendars();

    // Special Regional Calendars
    _initializeSpecialRegionalCalendars();
  }

  /// Initialize North Indian calendars
  void _initializeNorthIndianCalendars() {
    _calendarInfo[RegionalCalendar.northIndian] = RegionalCalendarInfo(
      calendar: RegionalCalendar.northIndian,
      name: 'North Indian Calendar',
      region: 'North India',
      description: 'Vikram Samvat based calendar used in North India',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.punjabi] = RegionalCalendarInfo(
      calendar: RegionalCalendar.punjabi,
      name: 'Punjabi Calendar',
      region: 'Punjab',
      description: 'Punjabi calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chet
        'festivalAdjustment': 1,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.himachali] = RegionalCalendarInfo(
      calendar: RegionalCalendar.himachali,
      name: 'Himachali Calendar',
      region: 'Himachal Pradesh',
      description: 'Himachali calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.uttarakhandi] = RegionalCalendarInfo(
      calendar: RegionalCalendar.uttarakhandi,
      name: 'Uttarakhandi Calendar',
      region: 'Uttarakhand',
      description: 'Uttarakhandi calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.rajasthani] = RegionalCalendarInfo(
      calendar: RegionalCalendar.rajasthani,
      name: 'Rajasthani Calendar',
      region: 'Rajasthan',
      description: 'Rajasthani calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.haryanvi] = RegionalCalendarInfo(
      calendar: RegionalCalendar.haryanvi,
      name: 'Haryanvi Calendar',
      region: 'Haryana',
      description: 'Haryanvi calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );
  }

  /// Initialize South Indian calendars
  void _initializeSouthIndianCalendars() {
    _calendarInfo[RegionalCalendar.southIndian] = RegionalCalendarInfo(
      calendar: RegionalCalendar.southIndian,
      name: 'South Indian Calendar',
      region: 'South India',
      description: 'Saka calendar based system used in South India',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': -1,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Raman',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.tamil] = RegionalCalendarInfo(
      calendar: RegionalCalendar.tamil,
      name: 'Tamil Calendar',
      region: 'Tamil Nadu',
      description: 'Tamil calendar with unique regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 4, // Chithirai
        'festivalAdjustment': -2,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Krishnamurti',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.malayalam] = RegionalCalendarInfo(
      calendar: RegionalCalendar.malayalam,
      name: 'Malayalam Calendar',
      region: 'Kerala',
      description: 'Malayalam calendar used in Kerala',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 4, // Medam
        'festivalAdjustment': -1,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Krishnamurti',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.kannada] = RegionalCalendarInfo(
      calendar: RegionalCalendar.kannada,
      name: 'Kannada Calendar',
      region: 'Karnataka',
      description: 'Kannada calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': -1,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Raman',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.telugu] = RegionalCalendarInfo(
      calendar: RegionalCalendar.telugu,
      name: 'Telugu Calendar',
      region: 'Andhra Pradesh',
      description: 'Telugu calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': -1,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Raman',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );
  }

  /// Initialize East Indian calendars
  void _initializeEastIndianCalendars() {
    _calendarInfo[RegionalCalendar.bengali] = RegionalCalendarInfo(
      calendar: RegionalCalendar.bengali,
      name: 'Bengali Calendar',
      region: 'West Bengal',
      description: 'Bengali calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 4, // Boishakh
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Yukteshwar',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.odia] = RegionalCalendarInfo(
      calendar: RegionalCalendar.odia,
      name: 'Odia Calendar',
      region: 'Odisha',
      description: 'Odia calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 4, // Baisakh
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.assamese] = RegionalCalendarInfo(
      calendar: RegionalCalendar.assamese,
      name: 'Assamese Calendar',
      region: 'Assam',
      description: 'Assamese calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 4, // Bohag
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.manipuri] = RegionalCalendarInfo(
      calendar: RegionalCalendar.manipuri,
      name: 'Manipuri Calendar',
      region: 'Manipur',
      description: 'Manipuri calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 4, // Sajibu
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );
  }

  /// Initialize West Indian calendars
  void _initializeWestIndianCalendars() {
    _calendarInfo[RegionalCalendar.gujarati] = RegionalCalendarInfo(
      calendar: RegionalCalendar.gujarati,
      name: 'Gujarati Calendar',
      region: 'Gujarat',
      description: 'Gujarati calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 10, // Kartik
        'festivalAdjustment': 1,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.marathi] = RegionalCalendarInfo(
      calendar: RegionalCalendar.marathi,
      name: 'Marathi Calendar',
      region: 'Maharashtra',
      description: 'Marathi calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.konkani] = RegionalCalendarInfo(
      calendar: RegionalCalendar.konkani,
      name: 'Konkani Calendar',
      region: 'Goa',
      description: 'Konkani calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );
  }

  /// Initialize Central Indian calendars
  void _initializeCentralIndianCalendars() {
    _calendarInfo[RegionalCalendar.chhattisgarhi] = RegionalCalendarInfo(
      calendar: RegionalCalendar.chhattisgarhi,
      name: 'Chhattisgarhi Calendar',
      region: 'Chhattisgarh',
      description: 'Chhattisgarhi calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.madhyaPradeshi] = RegionalCalendarInfo(
      calendar: RegionalCalendar.madhyaPradeshi,
      name: 'Madhya Pradeshi Calendar',
      region: 'Madhya Pradesh',
      description: 'Madhya Pradeshi calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );
  }

  /// Initialize Special Regional calendars
  void _initializeSpecialRegionalCalendars() {
    _calendarInfo[RegionalCalendar.kashmiri] = RegionalCalendarInfo(
      calendar: RegionalCalendar.kashmiri,
      name: 'Kashmiri Calendar',
      region: 'Jammu & Kashmir',
      description: 'Kashmiri calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.nepali] = RegionalCalendarInfo(
      calendar: RegionalCalendar.nepali,
      name: 'Nepali Calendar',
      region: 'Nepal',
      description: 'Nepali calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.75,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.sikkimese] = RegionalCalendarInfo(
      calendar: RegionalCalendar.sikkimese,
      name: 'Sikkimese Calendar',
      region: 'Sikkim',
      description: 'Sikkimese calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );

    _calendarInfo[RegionalCalendar.goan] = RegionalCalendarInfo(
      calendar: RegionalCalendar.goan,
      name: 'Goan Calendar',
      region: 'Goa',
      description: 'Goan calendar with regional variations',
      characteristics: [
        CalendarCharacteristics.lunisolar,
        CalendarCharacteristics.regionalVariation
      ],
      regionalVariations: {
        'newYearMonth': 3, // Chaitra
        'festivalAdjustment': 0,
        'timezoneOffset': 5.5,
        'ayanamsha': 'Lahiri',
        'lunarMonthStart': 'newMoon',
      },
      calculatedAt: DateTime.now().toUtc(),
    );
  }
}
