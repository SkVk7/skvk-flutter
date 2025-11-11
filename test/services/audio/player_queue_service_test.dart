/// Player Queue Service Tests
///
/// Unit tests for PlayerQueueService
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/services/audio/player_queue_service.dart';
import 'package:skvk_application/core/services/audio/models/track.dart';
import 'package:skvk_application/core/services/audio/models/queue_state.dart';
import 'package:skvk_application/core/services/audio/global_audio_player_controller.dart';

void main() {
  group('PlayerQueueService', () {
    late ProviderContainer container;
    late PlayerQueueService queueService;

    setUp(() {
      container = ProviderContainer();
      queueService = container.read(playerQueueServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('loadQueue should set queue and current index', () async {
      final tracks = [
        Track(
          id: '1',
          title: 'Track 1',
          subtitle: 'Artist 1',
          album: 'Album 1',
          duration: const Duration(minutes: 3),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
        Track(
          id: '2',
          title: 'Track 2',
          subtitle: 'Artist 2',
          album: 'Album 2',
          duration: const Duration(minutes: 4),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
      ];

      await queueService.loadQueue(tracks, startIndex: 0);

      expect(queueService.queue.length, 2);
      expect(queueService.currentIndex, 0);
      expect(queueService.currentTrack?.id, '1');
    });

    test('appendTracks should add tracks to queue', () async {
      final initialTracks = [
        Track(
          id: '1',
          title: 'Track 1',
          subtitle: 'Artist 1',
          album: 'Album 1',
          duration: const Duration(minutes: 3),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
      ];

      await queueService.loadQueue(initialTracks);

      final newTracks = [
        Track(
          id: '2',
          title: 'Track 2',
          subtitle: 'Artist 2',
          album: 'Album 2',
          duration: const Duration(minutes: 4),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
      ];

      await queueService.appendTracks(newTracks);

      expect(queueService.queue.length, 2);
    });

    test('toggleShuffle should enable/disable shuffle', () async {
      final tracks = [
        Track(
          id: '1',
          title: 'Track 1',
          subtitle: 'Artist 1',
          album: 'Album 1',
          duration: const Duration(minutes: 3),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
        Track(
          id: '2',
          title: 'Track 2',
          subtitle: 'Artist 2',
          album: 'Album 2',
          duration: const Duration(minutes: 4),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
      ];

      await queueService.loadQueue(tracks);
      expect(queueService.shuffleEnabled, false);

      await queueService.toggleShuffle();
      expect(queueService.shuffleEnabled, true);

      await queueService.toggleShuffle();
      expect(queueService.shuffleEnabled, false);
    });

    test('setRepeatMode should update repeat mode', () async {
      await queueService.setRepeatMode(RepeatMode.all);
      expect(queueService.repeatMode, RepeatMode.all);

      await queueService.setRepeatMode(RepeatMode.one);
      expect(queueService.repeatMode, RepeatMode.one);

      await queueService.setRepeatMode(RepeatMode.none);
      expect(queueService.repeatMode, RepeatMode.none);
    });

    test('next should move to next track', () async {
      final tracks = [
        Track(
          id: '1',
          title: 'Track 1',
          subtitle: 'Artist 1',
          album: 'Album 1',
          duration: const Duration(minutes: 3),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
        Track(
          id: '2',
          title: 'Track 2',
          subtitle: 'Artist 2',
          album: 'Album 2',
          duration: const Duration(minutes: 4),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
      ];

      await queueService.loadQueue(tracks, startIndex: 0);
      expect(queueService.currentIndex, 0);

      await queueService.next();
      expect(queueService.currentIndex, 1);
    });

    test('previous should move to previous track', () async {
      final tracks = [
        Track(
          id: '1',
          title: 'Track 1',
          subtitle: 'Artist 1',
          album: 'Album 1',
          duration: const Duration(minutes: 3),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
        Track(
          id: '2',
          title: 'Track 2',
          subtitle: 'Artist 2',
          album: 'Album 2',
          duration: const Duration(minutes: 4),
          coverUrl: '',
          sourceUrl: '',
          isDownloaded: false,
          localPath: null,
          metadata: {},
        ),
      ];

      await queueService.loadQueue(tracks, startIndex: 1);
      expect(queueService.currentIndex, 1);

      await queueService.previous();
      expect(queueService.currentIndex, 0);
    });
  });
}

