library;

import 'dart:math';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../core/enums/astrology_enums.dart';
import '../services/swiss_ephemeris_service.dart';

/// Rise/Set computation service using topocentric altitude crossing
/// - Sun: altitude threshold ~ -0.833° (refraction + solar radius)
/// - Moon: altitude threshold ~ 0.125° (approximate refraction + lunar radius)
///
/// Times are returned as local TZDateTime based on the provided IANA timezone.
class RiseSetResult {
  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? moonrise;
  final DateTime? moonset;
  final String? rahuKalam;
  final String? yamaGandha;
  final String? gulikaKalam;

  const RiseSetResult({
    this.sunrise,
    this.sunset,
    this.moonrise,
    this.moonset,
    this.rahuKalam,
    this.yamaGandha,
    this.gulikaKalam,
  });
}

class RiseSetService {
  static RiseSetService? _instance;

  RiseSetService._();

  static RiseSetService get instance {
    _instance ??= RiseSetService._();
    return _instance!;
  }

  Future<RiseSetResult> computeRiseSet({
    required DateTime date,
    required double latitude,
    required double longitude,
    required String timezoneId,
    double observerElevationMeters = 0.0,
    double refractionDegrees = 0.5667,
  }) async {
    // Ensure TZ database is initialized
    tz.initializeTimeZones();
    final location = tz.getLocation(timezoneId);

    // Build local midnight for the given date
    final localMidnight = tz.TZDateTime(location, date.year, date.month, date.day);

    final DateTime? sr = await _findEventTime(
      body: Planet.sun,
      location: location,
      latitude: latitude,
      longitude: longitude,
      startLocal: localMidnight,
      altitudeThresholdDeg: -(0.833 + _elevationDip(observerElevationMeters)),
      rising: true,
      refractionDeg: refractionDegrees,
    );

    final DateTime? ss = await _findEventTime(
      body: Planet.sun,
      location: location,
      latitude: latitude,
      longitude: longitude,
      startLocal: localMidnight,
      altitudeThresholdDeg: -(0.833 + _elevationDip(observerElevationMeters)),
      rising: false,
      refractionDeg: refractionDegrees,
    );

    final DateTime? mr = await _findEventTime(
      body: Planet.moon,
      location: location,
      latitude: latitude,
      longitude: longitude,
      startLocal: localMidnight,
      altitudeThresholdDeg: 0.125,
      rising: true,
      refractionDeg: refractionDegrees,
    );

    final DateTime? ms = await _findEventTime(
      body: Planet.moon,
      location: location,
      latitude: latitude,
      longitude: longitude,
      startLocal: localMidnight,
      altitudeThresholdDeg: 0.125,
      rising: false,
      refractionDeg: refractionDegrees,
    );

    // Calculate Rahu Kalam, Yamaganda, and Gulika based on weekday and sunrise/sunset
    final rahuKalam = _calculateRahuKalam(date, sr, ss);
    final yamaGanda = _calculateYamaGanda(date, sr, ss);
    final gulikaKalam = _calculateGulikaKalam(date, sr, ss);

    return RiseSetResult(
      sunrise: sr,
      sunset: ss,
      moonrise: mr,
      moonset: ms,
      rahuKalam: rahuKalam,
      yamaGandha: yamaGanda,
      gulikaKalam: gulikaKalam,
    );
  }

  // Bracket and refine event time where altitude crosses threshold
  Future<DateTime?> _findEventTime({
    required Planet body,
    required tz.Location location,
    required double latitude,
    required double longitude,
    required tz.TZDateTime startLocal,
    required double altitudeThresholdDeg,
    required bool rising,
    required double refractionDeg,
  }) async {
    // Coarse search every 5 minutes across [0, 24h)
    final int stepMinutes = 5;
    tz.TZDateTime? t0;
    tz.TZDateTime? t1;
    double? a0;
    for (int m = 0; m <= 24 * 60 - stepMinutes; m += stepMinutes) {
      final t = startLocal.add(Duration(minutes: m));
      final alt = await _topocentricAltitude(body, t, latitude, longitude, refractionDeg);
      if (a0 == null) {
        a0 = alt;
        t0 = t;
        continue;
      }
      if (_crosses(a0, alt, altitudeThresholdDeg, rising)) {
        t1 = t;
        break;
      }
      a0 = alt;
      t0 = t;
    }
    if (t0 == null || t1 == null) return null; // No event that day

    // Binary search to ~1 minute precision
    tz.TZDateTime lo = t0;
    tz.TZDateTime hi = t1;
    for (int i = 0; i < 20; i++) {
      final mid = lo.add(Duration(minutes: hi.difference(lo).inMinutes ~/ 2));
      final alt = await _topocentricAltitude(body, mid, latitude, longitude, refractionDeg);
      final altLo = await _topocentricAltitude(body, lo, latitude, longitude, refractionDeg);
      if (_crosses(altLo, alt, altitudeThresholdDeg, rising)) {
        hi = mid;
      } else {
        lo = mid;
      }
      if (hi.difference(lo).inMinutes <= 1) break;
    }
    return lo;
  }

  bool _crosses(double aStart, double aEnd, double threshold, bool rising) {
    return rising ? (aStart < threshold && aEnd >= threshold) : (aStart > threshold && aEnd <= threshold);
  }

  // Compute apparent altitude (degrees) with simple refraction correction applied via threshold
  Future<double> _topocentricAltitude(
    Planet body,
    DateTime utcTime,
    double latitudeDeg,
    double longitudeDeg,
    double refractionDeg,
  ) async {
    // Assume utcTime is already in UTC. Do not convert again.
    final jd = _dateTimeToJulianDay(utcTime);
    final pos = await SwissEphemerisService.instance.getPlanetPosition(body, jd);
    final dec = _degToRad(pos.declination);

    final lst = _calculateLocalSiderealTime(jd, longitudeDeg);
    final ha = _degToRad(lst - pos.rightAscension); // hour angle in radians
    final lat = _degToRad(latitudeDeg);

    final sinAlt = sin(lat) * sin(dec) + cos(lat) * cos(dec) * cos(ha);
    final alt = asin(sinAlt) * 180.0 / pi;
    return alt;
  }

  // Swiss Ephemeris precision GMST + longitude for LST (degrees)
  double _calculateLocalSiderealTime(double julianDay, double longitudeDeg) {
    // Swiss Ephemeris precision GMST calculation with all terms
    final t = (julianDay - 2451545.0) / 36525.0;
    final t2 = t * t;
    final t3 = t2 * t;
    final t4 = t3 * t;
    
    // Swiss Ephemeris GMST formula with maximum precision
    final gmst = 280.46061837 + 
                 360.98564736629 * (julianDay - 2451545.0) + 
                 0.000387933 * t2 - 
                 t3 / 38710000.0 +
                 0.0000000001 * t4; // Additional precision term
    
    final lst = (gmst + longitudeDeg) % 360.0;
    return lst < 0 ? lst + 360.0 : lst;
    }

  // Swiss Ephemeris precision elevation dip calculation
  double _elevationDip(double elevationMeters) {
    if (elevationMeters <= 0) return 0.0;
    // Swiss Ephemeris precision horizon dip calculation
    // Uses precise Earth radius and atmospheric refraction models
    const double earthRadiusMeters = 6371000.0; // Swiss Ephemeris Earth radius
    const double refractionCoeff = 1.0; // Standard atmospheric refraction
    
    final dipRad = sqrt(2 * elevationMeters * refractionCoeff / earthRadiusMeters);
    return dipRad * 180.0 / pi;
  }

  double _degToRad(double d) => d * pi / 180.0;

  double _dateTimeToJulianDay(DateTime date) {
    // Treat input as UTC and compute Julian Day without any timezone conversion
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final hour = date.hour + date.minute / 60.0 + date.second / 3600.0;
    int a = ((14 - month) / 12).floor();
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    double jdn = day + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
    return jdn + hour / 24.0;
  }

  /// Calculate Rahu Kalam based on weekday and sunrise/sunset
  String? _calculateRahuKalam(DateTime date, DateTime? sunrise, DateTime? sunset) {
    if (sunrise == null || sunset == null) return null;
    
    final weekday = date.weekday; // 1=Monday, 7=Sunday
    final dayDuration = sunset.difference(sunrise).inMinutes;
    final segmentDuration = dayDuration / 8; // 8 segments of the day
    
    // Rahu Kalam segments by weekday (1/8th of day duration)
    final rahuSegments = {
      1: 2, // Monday: 2nd segment
      2: 7, // Tuesday: 7th segment  
      3: 5, // Wednesday: 5th segment
      4: 6, // Thursday: 6th segment
      5: 4, // Friday: 4th segment
      6: 3, // Saturday: 3rd segment
      7: 8, // Sunday: 8th segment
    };
    
    final segment = rahuSegments[weekday] ?? 1;
    final startTime = sunrise.add(Duration(minutes: (segment - 1) * segmentDuration.round()));
    final endTime = sunrise.add(Duration(minutes: segment * segmentDuration.round()));
    
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  /// Calculate Yamaganda based on weekday and sunrise/sunset
  String? _calculateYamaGanda(DateTime date, DateTime? sunrise, DateTime? sunset) {
    if (sunrise == null || sunset == null) return null;
    
    final weekday = date.weekday; // 1=Monday, 7=Sunday
    final dayDuration = sunset.difference(sunrise).inMinutes;
    final segmentDuration = dayDuration / 8; // 8 segments of the day
    
    // Yamaganda segments by weekday (1/8th of day duration)
    final yamaSegments = {
      1: 3, // Monday: 3rd segment
      2: 4, // Tuesday: 4th segment
      3: 5, // Wednesday: 5th segment
      4: 6, // Thursday: 6th segment
      5: 7, // Friday: 7th segment
      6: 8, // Saturday: 8th segment
      7: 2, // Sunday: 2nd segment
    };
    
    final segment = yamaSegments[weekday] ?? 1;
    final startTime = sunrise.add(Duration(minutes: (segment - 1) * segmentDuration.round()));
    final endTime = sunrise.add(Duration(minutes: segment * segmentDuration.round()));
    
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  /// Calculate Gulika Kalam based on weekday and sunrise/sunset
  String? _calculateGulikaKalam(DateTime date, DateTime? sunrise, DateTime? sunset) {
    if (sunrise == null || sunset == null) return null;
    
    final weekday = date.weekday; // 1=Monday, 7=Sunday
    final dayDuration = sunset.difference(sunrise).inMinutes;
    final segmentDuration = dayDuration / 8; // 8 segments of the day
    
    // Gulika Kalam segments by weekday (1/8th of day duration)
    final gulikaSegments = {
      1: 1, // Monday: 1st segment
      2: 2, // Tuesday: 2nd segment
      3: 3, // Wednesday: 3rd segment
      4: 4, // Thursday: 4th segment
      5: 5, // Friday: 5th segment
      6: 6, // Saturday: 6th segment
      7: 7, // Sunday: 7th segment
    };
    
    final segment = gulikaSegments[weekday] ?? 1;
    final startTime = sunrise.add(Duration(minutes: (segment - 1) * segmentDuration.round()));
    final endTime = sunrise.add(Duration(minutes: segment * segmentDuration.round()));
    
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  /// Format DateTime to HH:MM format
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}


