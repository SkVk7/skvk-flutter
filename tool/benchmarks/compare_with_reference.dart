// Comparator: Compare our positions CSV with a reference CSV (official engine)
// Usage:
//   dart run tool/benchmarks/compare_with_reference.dart \
//     --ours build/our_positions.csv --ref build/ref_positions.csv \
//     --out build/deviation_summary.json

import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final argMap = _parseArgs(args);
  final oursPath = argMap['ours'];
  final refPath = argMap['ref'];
  final outPath = argMap['out'] ?? 'build/deviation_summary.json';

  if (oursPath == null || refPath == null) {
    stderr.writeln('Provide --ours and --ref paths.');
    exitCode = 2;
    return;
  }

  final ours = await _readCsv(oursPath);
  final ref = await _readCsv(refPath);

  // Index by composite key for fast matching
  String key(Map<String, String> r) => [
        r['datetime_utc'],
        r['source_lat'],
        r['source_lon'],
        r['planet'],
      ].join('|');

  final refIndex = <String, Map<String, String>>{};
  for (final r in ref) {
    refIndex[key(r)] = r;
  }

  final deviations = <double>[];
  final perPlanet = <String, List<double>>{};
  int matched = 0;
  int missing = 0;

  for (final o in ours) {
    final k = key(o);
    final rr = refIndex[k];
    if (rr == null) {
      missing++;
      continue;
    }
    matched++;
    final lonO = double.parse(o['longitude_deg']!);
    final lonR = double.parse(rr['longitude_deg']!);
    final latO = double.parse(o['latitude_deg']!);
    final latR = double.parse(rr['latitude_deg']!);

    final dLon = _angleDeltaDeg(lonO, lonR).abs();
    final dLat = (latO - latR).abs();
    // Combine using max of lon/lat error to be conservative
    final combined = dLon > dLat ? dLon : dLat;

    deviations.add(combined);
    final planet = o['planet']!;
    (perPlanet[planet] ??= []).add(combined);
  }

  deviations.sort();
  double median(List<double> xs) => xs.isEmpty
      ? double.nan
      : (xs.length.isOdd
          ? xs[xs.length ~/ 2]
          : (xs[xs.length ~/ 2 - 1] + xs[xs.length ~/ 2]) / 2.0);

  double max(List<double> xs) => xs.isEmpty ? double.nan : xs.last;

  final summary = {
    'matched': matched,
    'missing': missing,
    'overall': {
      'median_deg': median(deviations),
      'max_deg': max(deviations),
      'median_arcmin': median(deviations) * 60.0,
      'max_arcmin': max(deviations) * 60.0,
    },
    'per_planet': {
      for (final e in perPlanet.entries)
        e.key: {
          'median_deg': median(e.value),
          'max_deg': max(e.value),
          'median_arcmin': median(e.value) * 60.0,
          'max_arcmin': max(e.value) * 60.0,
          'count': e.value.length,
        }
    }
  };

  await File(outPath).parent.create(recursive: true);
  await File(outPath).writeAsString(const JsonEncoder.withIndent('  ').convert(summary));
  stdout.writeln('Wrote summary: $outPath');
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

Future<List<Map<String, String>>> _readCsv(String path) async {
  final lines = const LineSplitter().convert(await File(path).readAsString());
  if (lines.isEmpty) return [];
  final headers = _splitCsvLine(lines.first);
  final rows = <Map<String, String>>[];
  for (var i = 1; i < lines.length; i++) {
    if (lines[i].trim().isEmpty) continue;
    final cols = _splitCsvLine(lines[i]);
    final map = <String, String>{};
    for (var j = 0; j < headers.length && j < cols.length; j++) {
      map[headers[j]] = cols[j];
    }
    rows.add(map);
  }
  return rows;
}

List<String> _splitCsvLine(String line) {
  final result = <String>[];
  final sb = StringBuffer();
  bool inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        sb.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (c == ',' && !inQuotes) {
      result.add(sb.toString());
      sb.clear();
    } else {
      sb.write(c);
    }
  }
  result.add(sb.toString());
  return result;
}

double _angleDeltaDeg(double a, double b) {
  // Smallest signed difference between angles (degrees)
  double d = (a - b) % 360.0;
  if (d > 180.0) d -= 360.0;
  if (d < -180.0) d += 360.0;
  return d;
}
