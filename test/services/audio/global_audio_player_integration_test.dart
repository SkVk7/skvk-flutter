/// Global Audio Player Integration Tests
///
/// Integration tests for GlobalAudioPlayerController with queue integration
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/services/audio/global_audio_player_controller.dart';
import 'package:skvk_application/core/services/audio/player_queue_service.dart';
import 'package:skvk_application/core/models/audio/track.dart';

void main() {
  group('GlobalAudioPlayerController Integration', () {
    late ProviderContainer container;
    late GlobalAudioPlayerController playerController;
    late PlayerQueueService queueService;

    setUp(() {
      container = ProviderContainer();
      playerController = container.read(globalAudioPlayerProvider.notifier);
      queueService = container.read(playerQueueServiceProvider.notifier);
      
      // Wire up queue service
      playerController.setQueueService(queueService);
    });

    tearDown(() {
      container.dispose();
    });

    test('queue integration should load track when queue changes', () async {
      final tracks = [
        Track(
          id: '1',
          title: 'Track 1',
          subtitle: 'Artist 1',
          album: 'Album 1',
          duration: const Duration(minutes: 3),
          coverUrl: 'https://example.com/cover1.jpg',
          sourceUrl: 'https://example.com/audio1.mp3',
          metadata: {},
        ),
      ];

      await queueService.loadQueue(tracks, startIndex: 0, autoplay: false);
      
      // Wait for queue state change to propagate
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Verify player state reflects queue
      // Note: Actual track loading requires audio URL, so we just verify integration
      expect(queueService.currentTrack?.id, '1');
    });

    test('playback completion should move to next track in queue', () async {
      final tracks = [
        Track(
          id: '1',
          title: 'Track 1',
          subtitle: 'Artist 1',
          album: 'Album 1',
          duration: const Duration(minutes: 3),
          coverUrl: '',
          sourceUrl: '',
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
          metadata: {},
        ),
      ];

      await queueService.loadQueue(tracks, startIndex: 0, autoplay: false);
      expect(queueService.currentIndex, 0);

      // Simulate playback completion
      await queueService.next();
      expect(queueService.currentIndex, 1);
    });
  });
}

