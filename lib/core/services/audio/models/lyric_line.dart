/// Lyric Line Model
///
/// Represents a single lyric line with timestamp
library;

import 'package:flutter/foundation.dart';

/// Lyric line with timestamp
@immutable
class LyricLine {
  const LyricLine({
    required this.timestamp,
    required this.text,
  });
  final Duration timestamp;
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricLine &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          text == other.text;

  @override
  int get hashCode => timestamp.hashCode ^ text.hashCode;

  @override
  String toString() => 'LyricLine(timestamp: $timestamp, text: $text)';
}
