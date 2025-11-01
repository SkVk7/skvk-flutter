/// Calendar models for batch month/year fetches
library;

import '../enums/astrology_enums.dart';

/// One day of panchang/festival info (names only for user readability)
class DayData {
  final DateTime date; // local date
  final String tithiName;
  final String pakshaName;
  final String nakshatraName;
  final String padaName;
  final String yogaName;
  final String karanaName;
  final String sunriseTime; // formatted, local time
  final String sunsetTime; // formatted, local time
  final String moonriseTime;
  final String moonsetTime;
  final String rahuKalam;
  final String yamaGanda;
  final String gulikaKalam;
  final List<String> festivals; // names only

  const DayData({
    required this.date,
    required this.tithiName,
    required this.pakshaName,
    required this.nakshatraName,
    required this.padaName,
    required this.yogaName,
    required this.karanaName,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.moonriseTime,
    required this.moonsetTime,
    required this.rahuKalam,
    required this.yamaGanda,
    required this.gulikaKalam,
    required this.festivals,
  });
}

/// One month view: all days in month with panchang + festivals (names only)
class MonthView {
  final int year;
  final int month; // 1-12
  final RegionalCalendar region;
  final double latitude;
  final double longitude;
  final String timezoneId; // IANA
  final List<DayData> days;

  const MonthView({
    required this.year,
    required this.month,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    required this.days,
  });
}

/// One year view: festivals grouped by month + optional cached month views
class YearView {
  final int year;
  final RegionalCalendar region;
  final Map<int, List<String>> festivalsByMonth; // month -> festival names
  final Map<int, MonthView> months; // cached month views as they are loaded

  const YearView({
    required this.year,
    required this.region,
    required this.festivalsByMonth,
    this.months = const {},
  });

  YearView copyWith({Map<int, MonthView>? months}) {
    return YearView(
      year: year,
      region: region,
      festivalsByMonth: festivalsByMonth,
      months: months ?? this.months,
    );
  }
}


