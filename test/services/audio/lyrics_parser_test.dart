/// Lyrics Parser Tests
///
/// Unit tests for LyricsParser
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:skvk_application/core/services/audio/lyrics_parser.dart';

void main() {
  group('LyricsParser', () {
    test('parseLrc should parse LRC format correctly', () {
      const lrcContent = '''
[00:12.00]Line 1
[00:15.50]Line 2
[01:23.45]Line 3
''';

      final lyrics = LyricsParser.parseLrc(lrcContent);

      expect(lyrics.length, 3);
      expect(lyrics[0].text, 'Line 1');
      expect(lyrics[0].timestamp, const Duration(seconds: 12));
      expect(lyrics[1].text, 'Line 2');
      expect(lyrics[1].timestamp, const Duration(milliseconds: 15500));
      expect(lyrics[2].text, 'Line 3');
      expect(lyrics[2].timestamp, const Duration(minutes: 1, seconds: 23, milliseconds: 450));
    });

    test('parseJson should parse JSON format correctly', () {
      final jsonList = [
        {'timestamp': 12000, 'text': 'Line 1'},
        {'timestamp': 15500, 'text': 'Line 2'},
        {'timestamp': 83450, 'text': 'Line 3'},
      ];

      final lyrics = LyricsParser.parseJson(jsonList);

      expect(lyrics.length, 3);
      expect(lyrics[0].text, 'Line 1');
      expect(lyrics[0].timestamp, const Duration(milliseconds: 12000));
      expect(lyrics[1].text, 'Line 2');
      expect(lyrics[1].timestamp, const Duration(milliseconds: 15500));
      expect(lyrics[2].text, 'Line 3');
      expect(lyrics[2].timestamp, const Duration(milliseconds: 83450));
    });

    test('parseLrc should handle empty content', () {
      final lyrics = LyricsParser.parseLrc('');
      expect(lyrics.isEmpty, true);
    });

    test('parseLrc should handle lines without timestamps', () {
      const lrcContent = '''
[00:12.00]Line 1
Plain text line
[00:15.50]Line 2
''';

      final lyrics = LyricsParser.parseLrc(lrcContent);
      expect(lyrics.length, 3);
    });
  });
}

