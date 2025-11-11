/// Playlist Service Tests
///
/// Unit tests for PlaylistService
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/services/audio/playlist_service.dart';
import 'package:skvk_application/core/services/audio/models/playlist.dart';
import 'package:skvk_application/core/services/audio/models/track.dart';

void main() {
  group('PlaylistService', () {
    late ProviderContainer container;
    late PlaylistService playlistService;

    setUp(() {
      container = ProviderContainer();
      playlistService = container.read(playlistServiceProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('createPlaylist should create a new playlist', () async {
      final playlist = await playlistService.createPlaylist(
        'Test Playlist',
        description: 'Test description',
      );

      expect(playlist.name, 'Test Playlist');
      expect(playlist.description, 'Test description');
      expect(playlist.trackCount, 0);
    });

    test('deletePlaylist should remove playlist', () async {
      final playlist = await playlistService.createPlaylist('Test Playlist');
      final playlists = container.read(playlistServiceProvider);
      expect(playlists.length, 1);

      await playlistService.deletePlaylist(playlist.id);
      final updatedPlaylists = container.read(playlistServiceProvider);
      expect(updatedPlaylists.length, 0);
    });

    test('renamePlaylist should update playlist name', () async {
      final playlist = await playlistService.createPlaylist('Test Playlist');
      await playlistService.renamePlaylist(playlist.id, 'Renamed Playlist');

      final playlists = container.read(playlistServiceProvider);
      final updatedPlaylist = playlists.firstWhere((p) => p.id == playlist.id);
      expect(updatedPlaylist.name, 'Renamed Playlist');
    });
  });
}

