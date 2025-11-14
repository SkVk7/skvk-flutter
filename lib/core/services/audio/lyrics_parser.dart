/// Lyrics Parser
///
/// Parses LRC format and JSON format lyrics into LyricLine objects
library;

import 'dart:async';
import 'dart:convert';

import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/audio/models/lyric_line.dart';

/// Lyrics Parser - Parses LRC and JSON formats
class LyricsParser {
  /// Parse LRC format lyrics
  ///
  /// LRC format example:
  /// [00:12.00]Line 1
  /// [00:15.50]Line 2
  /// [01:23.45]Line 3
  static List<LyricLine> parseLrc(String lrcContent) {
    final lines = <LyricLine>[];

    if (lrcContent.isEmpty) {
      return lines;
    }

    final lrcLines = lrcContent.split('\n');
    int lineNumber = 0;

    for (final line in lrcLines) {
      lineNumber++;
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Match [mm:ss.ff] or [mm:ss:ff] format
      final regex = RegExp(r'\[(\d{2}):(\d{2})[\.:](\d{2,3})\]');
      final matches = regex.allMatches(trimmedLine);

      if (matches.isNotEmpty) {
        final lastMatch = matches.last;
        final text = trimmedLine.substring(lastMatch.end).trim();

        if (text.isNotEmpty) {
          try {
            final minutes = int.parse(lastMatch.group(1)!);
            final seconds = int.parse(lastMatch.group(2)!);
            final millisecondsStr = lastMatch.group(3)!;
            final milliseconds =
                int.parse(millisecondsStr.padRight(3, '0').substring(0, 3));

            final timestamp = Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            );

            lines.add(LyricLine(timestamp: timestamp, text: text));
          } on Exception catch (e) {
            unawaited(
              LoggingHelper.logError(
                'Failed to parse timestamp on line $lineNumber: $trimmedLine',
                source: 'LyricsParser',
                error: e,
              ),
            );
            // Fallback: add line without timestamp at the end
            if (lines.isNotEmpty) {
              final lastTimestamp = lines.last.timestamp;
              lines.add(
                LyricLine(
                  timestamp: lastTimestamp + const Duration(seconds: 1),
                  text: trimmedLine,
                ),
              );
            } else {
              lines.add(
                LyricLine(
                  timestamp: Duration(seconds: lineNumber),
                  text: trimmedLine,
                ),
              );
            }
          }
        }
      } else {
        // No timestamp found - add as plain text with sequential timestamp
        if (lines.isNotEmpty) {
          final lastTimestamp = lines.last.timestamp;
          lines.add(
            LyricLine(
              timestamp: lastTimestamp + const Duration(seconds: 1),
              text: trimmedLine,
            ),
          );
        } else {
          lines.add(
            LyricLine(
              timestamp: Duration(seconds: lineNumber),
              text: trimmedLine,
            ),
          );
        }
      }
    }

    // Sort by timestamp
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    unawaited(
      LoggingHelper.logInfo(
        'Parsed ${lines.length} lyric lines from ${lrcLines.length} input lines',
        source: 'LyricsParser',
      ),
    );

    return lines;
  }

  /// Parse JSON format lyrics
  ///
  /// JSON format example:
  /// [
  ///   {"timestamp": 12000, "text": "Line 1"},
  ///   {"timestamp": 15500, "text": "Line 2"},
  ///   {"timestamp": 83450, "text": "Line 3"}
  /// ]
  static List<LyricLine> parseJson(List<dynamic> jsonList) {
    final lines = <LyricLine>[];

    for (final item in jsonList) {
      try {
        final map = item as Map<String, dynamic>;
        final timestampMs = map['timestamp'] as int? ?? 0;
        final text = map['text'] as String? ?? '';

        if (text.isNotEmpty) {
          lines.add(
            LyricLine(
              timestamp: Duration(milliseconds: timestampMs),
              text: text,
            ),
          );
        }
      } on Exception catch (e) {
        unawaited(
          LoggingHelper.logError(
            'Failed to parse JSON lyric item: $item',
            source: 'LyricsParser',
            error: e,
          ),
        );
      }
    }

    // Sort by timestamp
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    unawaited(
      LoggingHelper.logInfo(
        'Parsed ${lines.length} lyric lines from JSON',
        source: 'LyricsParser',
      ),
    );

    return lines;
  }

  /// Parse JSON string format lyrics
  static List<LyricLine> parseJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return parseJson(decoded);
    } on Exception catch (e) {
      unawaited(
        LoggingHelper.logError(
          'Failed to parse JSON string: $jsonString',
          source: 'LyricsParser',
          error: e,
        ),
      );
      return [];
    }
  }
}
