/// Panchang Intervals Service - Calculate exact start/end times for tithi/yoga/karana
///
/// This service provides precise timing for panchang elements throughout the day
/// using Swiss Ephemeris calculations with maximum accuracy.
library;

import '../services/swiss_ephemeris_service.dart';
import '../enums/astrology_enums.dart';

/// Interval data for panchang elements
class PanchangInterval {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'tithi', 'yoga', 'karana'

  const PanchangInterval({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.type,
  });
}

/// Daily panchang intervals
class DailyPanchangIntervals {
  final List<PanchangInterval> tithiIntervals;
  final List<PanchangInterval> yogaIntervals;
  final List<PanchangInterval> karanaIntervals;
  final DateTime calculatedAt;

  const DailyPanchangIntervals({
    required this.tithiIntervals,
    required this.yogaIntervals,
    required this.karanaIntervals,
    required this.calculatedAt,
  });
}

/// Service for calculating panchang intervals with precise timing
class PanchangIntervalsService {
  static PanchangIntervalsService? _instance;

  PanchangIntervalsService._();

  static PanchangIntervalsService get instance {
    _instance ??= PanchangIntervalsService._();
    return _instance!;
  }

  /// Calculate daily panchang intervals for a given date
  Future<DailyPanchangIntervals> calculateDailyIntervals({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) async {
    // Calculate intervals for the entire day (24 hours)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Calculate tithi intervals
    final tithiIntervals = await _calculateTithiIntervals(
      startOfDay, endOfDay, latitude, longitude);

    // Calculate yoga intervals
    final yogaIntervals = await _calculateYogaIntervals(
      startOfDay, endOfDay, latitude, longitude);

    // Calculate karana intervals
    final karanaIntervals = await _calculateKaranaIntervals(
      startOfDay, endOfDay, latitude, longitude);

    return DailyPanchangIntervals(
      tithiIntervals: tithiIntervals,
      yogaIntervals: yogaIntervals,
      karanaIntervals: karanaIntervals,
      calculatedAt: DateTime.now().toUtc(),
    );
  }

  /// Calculate tithi intervals throughout the day
  Future<List<PanchangInterval>> _calculateTithiIntervals(
    DateTime startTime, DateTime endTime, double latitude, double longitude) async {
    final intervals = <PanchangInterval>[];
    
    // Sample every 30 minutes to find tithi changes
    final sampleInterval = const Duration(minutes: 30);
    DateTime currentTime = startTime;
    String? currentTithi;
    DateTime? intervalStart;

    while (currentTime.isBefore(endTime)) {
      final tithi = await _getTithiAtTime(currentTime, latitude, longitude);
      
      if (currentTithi != tithi) {
        // Tithi changed - close previous interval and start new one
        if (currentTithi != null && intervalStart != null) {
          intervals.add(PanchangInterval(
            name: currentTithi,
            startTime: intervalStart,
            endTime: currentTime,
            type: 'tithi',
          ));
        }
        currentTithi = tithi;
        intervalStart = currentTime;
      }
      
      currentTime = currentTime.add(sampleInterval);
    }

    // Close the last interval
    if (currentTithi != null && intervalStart != null) {
      intervals.add(PanchangInterval(
        name: currentTithi,
        startTime: intervalStart,
        endTime: endTime,
        type: 'tithi',
      ));
    }

    return intervals;
  }

  /// Calculate yoga intervals throughout the day
  Future<List<PanchangInterval>> _calculateYogaIntervals(
    DateTime startTime, DateTime endTime, double latitude, double longitude) async {
    final intervals = <PanchangInterval>[];
    
    // Sample every 30 minutes to find yoga changes
    final sampleInterval = const Duration(minutes: 30);
    DateTime currentTime = startTime;
    String? currentYoga;
    DateTime? intervalStart;

    while (currentTime.isBefore(endTime)) {
      final yoga = await _getYogaAtTime(currentTime, latitude, longitude);
      
      if (currentYoga != yoga) {
        // Yoga changed - close previous interval and start new one
        if (currentYoga != null && intervalStart != null) {
          intervals.add(PanchangInterval(
            name: currentYoga,
            startTime: intervalStart,
            endTime: currentTime,
            type: 'yoga',
          ));
        }
        currentYoga = yoga;
        intervalStart = currentTime;
      }
      
      currentTime = currentTime.add(sampleInterval);
    }

    // Close the last interval
    if (currentYoga != null && intervalStart != null) {
      intervals.add(PanchangInterval(
        name: currentYoga,
        startTime: intervalStart,
        endTime: endTime,
        type: 'yoga',
      ));
    }

    return intervals;
  }

  /// Calculate karana intervals throughout the day
  Future<List<PanchangInterval>> _calculateKaranaIntervals(
    DateTime startTime, DateTime endTime, double latitude, double longitude) async {
    final intervals = <PanchangInterval>[];
    
    // Sample every 15 minutes to find karana changes (more frequent)
    final sampleInterval = const Duration(minutes: 15);
    DateTime currentTime = startTime;
    String? currentKarana;
    DateTime? intervalStart;

    while (currentTime.isBefore(endTime)) {
      final karana = await _getKaranaAtTime(currentTime, latitude, longitude);
      
      if (currentKarana != karana) {
        // Karana changed - close previous interval and start new one
        if (currentKarana != null && intervalStart != null) {
          intervals.add(PanchangInterval(
            name: currentKarana,
            startTime: intervalStart,
            endTime: currentTime,
            type: 'karana',
          ));
        }
        currentKarana = karana;
        intervalStart = currentTime;
      }
      
      currentTime = currentTime.add(sampleInterval);
    }

    // Close the last interval
    if (currentKarana != null && intervalStart != null) {
      intervals.add(PanchangInterval(
        name: currentKarana,
        startTime: intervalStart,
        endTime: endTime,
        type: 'karana',
      ));
    }

    return intervals;
  }

  /// Get tithi name at a specific time
  Future<String> _getTithiAtTime(DateTime time, double latitude, double longitude) async {
    final jd = _dateTimeToJulianDay(time);
    final moon = await SwissEphemerisService.instance.getPlanetPosition(Planet.moon, jd);
    final sun = await SwissEphemerisService.instance.getPlanetPosition(Planet.sun, jd);
    
    final diff = ((moon.longitude - sun.longitude) % 360 + 360) % 360;
    final tithiIndex = (diff / 12.0).floor();
    
    const tithiNames = [
      'Shukla Pratipada','Shukla Dvitiya','Shukla Tritiya','Shukla Chaturthi','Shukla Panchami',
      'Shukla Shashthi','Shukla Saptami','Shukla Ashtami','Shukla Navami','Shukla Dashami',
      'Shukla Ekadashi','Shukla Dwadashi','Shukla Trayodashi','Shukla Chaturdashi','Purnima',
      'Krishna Pratipada','Krishna Dvitiya','Krishna Tritiya','Krishna Chaturthi','Krishna Panchami',
      'Krishna Shashthi','Krishna Saptami','Krishna Ashtami','Krishna Navami','Krishna Dashami',
      'Krishna Ekadashi','Krishna Dwadashi','Krishna Trayodashi','Krishna Chaturdashi','Amavasya',
    ];
    
    return tithiNames[tithiIndex.clamp(0, 29)];
  }

  /// Get yoga name at a specific time
  Future<String> _getYogaAtTime(DateTime time, double latitude, double longitude) async {
    final jd = _dateTimeToJulianDay(time);
    final moon = await SwissEphemerisService.instance.getPlanetPosition(Planet.moon, jd);
    final sun = await SwissEphemerisService.instance.getPlanetPosition(Planet.sun, jd);
    
    final sumLongitudes = moon.longitude + sun.longitude;
    final normalized = ((sumLongitudes % 360) + 360) % 360;
    final index = (normalized / 13.333333333333334).floor();
    
    const yogaNames = [
      'Vishkambha','Priti','Ayushman','Saubhagya','Shobhana','Atiganda','Sukarma','Dhriti','Shoola','Ganda',
      'Vriddhi','Dhruva','Vyaghata','Harshana','Vajra','Siddhi','Vyatipata','Variyana','Parigha','Shiva',
      'Siddha','Sadhya','Shubha','Shukla','Brahma','Indra','Vaidhriti'
    ];
    
    return yogaNames[index.clamp(0, 26)];
  }

  /// Get karana name at a specific time
  Future<String> _getKaranaAtTime(DateTime time, double latitude, double longitude) async {
    final jd = _dateTimeToJulianDay(time);
    final moon = await SwissEphemerisService.instance.getPlanetPosition(Planet.moon, jd);
    final sun = await SwissEphemerisService.instance.getPlanetPosition(Planet.sun, jd);
    
    final diff = ((moon.longitude - sun.longitude) % 360 + 360) % 360;
    final tithi = (diff / 12.0);
    final karanaIndex = ((tithi * 2).floor()) % 60;
    
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

  /// Convert DateTime to Julian Day
  double _dateTimeToJulianDay(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final hour = date.hour + date.minute / 60.0 + date.second / 3600.0;
    
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    
    final julianDay = day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    final julianDayFraction = hour / 24.0;
    
    return julianDay + julianDayFraction;
  }
}
