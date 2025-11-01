// Benchmark: Generate our planetary positions for accuracy comparison
// Usage:
//   dart run tool/benchmarks/compare_accuracy.dart --out build/our_positions.csv \
//     --dates 2020-01-01,2022-06-15,2024-12-31 \
//     --times 00:00,06:00,12:00,18:00 \
//     --locs 28.6139,77.2090;40.7128,-74.0060;51.5074,-0.1278 \
//     --timezone Asia/Kolkata
// Optionally later, compare against a reference CSV produced from the official Swiss Ephemeris.

import 'dart:io';

import 'package:skvk_application/astrology/engines/astrology_engine.dart';
import 'package:skvk_application/astrology/core/entities/astrology_entities.dart';
import 'package:skvk_application/astrology/core/enums/astrology_enums.dart';

Future<void> main(List<String> args) async {
  final argMap = _parseArgs(args);

  final outPath = argMap['out'] ?? 'build/our_positions.csv';
  final timezone = argMap['timezone'] ?? 'UTC';

  final dates = _parseDates(argMap['dates']);
  final times = _parseTimes(argMap['times']);
  final locations = _parseLocations(argMap['locs']);

  if (dates.isEmpty || times.isEmpty || locations.isEmpty) {
    stderr.writeln('Provide --dates, --times, and --locs.');
    exitCode = 2;
    return;
  }

  // Ensure output directory exists
  await File(outPath).parent.create(recursive: true);

  final engine = AstrologyEngine();
  engine.initialize(const AstrologyConfig(
    precision: CalculationPrecision.ultra,
    ayanamsha: AyanamshaType.lahiri,
    houseSystem: HouseSystem.placidus,
    swissEphemerisEnabled: false,
    cacheEnabled: false,
    timezone: 'UTC',
  ));

  final sink = File(outPath).openWrite();
  sink.writeln(_csv([
    'datetime_utc',
    'timezone_in',
    'source_lat',
    'source_lon',
    'planet',
    'longitude_deg',
    'latitude_deg',
    'distance_au',
    'speed_deg_per_day',
    'retrograde',
  ]));

  for (final date in dates) {
    for (final time in times) {
      final localDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Use given timezone only for labeling; engine expects UTC input
      final utcDateTime = localDateTime.toUtc();

      for (final loc in locations) {
        final positions = await engine.calculatePlanetaryPositions(
          dateTime: utcDateTime,
          latitude: loc.$1,
          longitude: loc.$2,
          precision: CalculationPrecision.ultra,
        );

        for (final entry in positions.positions.entries) {
          final p = entry.value;
          sink.writeln(_csv([
            utcDateTime.toIso8601String(),
            timezone,
            loc.$1.toStringAsFixed(6),
            loc.$2.toStringAsFixed(6),
            entry.key.name,
            p.longitude.toStringAsFixed(8),
            p.latitude.toStringAsFixed(8),
            p.distance.toStringAsFixed(8),
            p.speed.toStringAsFixed(8),
            p.isRetrograde ? 'true' : 'false',
          ]));
        }
      }
    }
  }

  await sink.flush();
  await sink.close();
  stdout.writeln('Wrote ${File(outPath).path}');
}

Map<String, String> _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a.startsWith('--')) {
      final key = a.substring(2);
      final value = (i + 1 < args.length && !args[i + 1].startsWith('--')) ? args[++i] : 'true';
      map[key] = value;
    }
  }
  return map;
}

List<DateTime> _parseDates(String? s) {
  if (s == null || s.trim().isEmpty) return [];
  return s.split(',').map((e) => DateTime.parse('${e.trim()}T00:00:00Z')).toList();
}

class _Hm {
  final int hour;
  final int minute;
  _Hm(this.hour, this.minute);
}

List<_Hm> _parseTimes(String? s) {
  if (s == null || s.trim().isEmpty) return [];
  return s.split(',').map((e) {
    final t = e.trim();
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = parts.length > 1 ? int.parse(parts[1]) : 0;
    return _Hm(h, m);
  }).toList();
}

List<(double, double)> _parseLocations(String? s) {
  if (s == null || s.trim().isEmpty) return [];
  // Format: "lat,lon;lat,lon;..."
  return s.split(';').map((pair) {
    final parts = pair.split(',');
    final lat = double.parse(parts[0].trim());
    final lon = double.parse(parts[1].trim());
    return (lat, lon);
  }).toList();
}

String _csv(List<String> cols) {
  return cols.map((c) => _escapeCsv(c)).join(',');
}

String _escapeCsv(String input) {
  // Simple CSV escaping
  final needsQuotes = input.contains(',') || input.contains('"') || input.contains('\n');
  var value = input.replaceAll('"', '""');
  if (needsQuotes) value = '"$value"';
  return value;
}
