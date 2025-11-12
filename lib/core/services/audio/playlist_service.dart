/// Playlist Service
///
/// Manages playlists with local persistence
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/playlist.dart';
import '../../models/audio/track.dart';
import '../../../core/logging/logging_helper.dart';
import '../../../core/services/analytics/analytics_service.dart';
import '../../../core/services/content/content_api_service.dart';

/// Playlist Service - Manages playlists with persistence
class PlaylistService extends StateNotifier<List<Playlist>> {
  static const String _playlistsKey = 'audio_playlists';

  Completer<void> _mutex = Completer<void>()..complete();

  PlaylistService() : super([]) {
    _loadPlaylists();
  }

  /// Acquire mutex for thread-safe operations
  Future<void> _acquireMutex() async {
    await _mutex.future;
    _mutex = Completer<void>();
  }

  /// Release mutex
  void _releaseMutex() {
    if (!_mutex.isCompleted) {
      _mutex.complete();
    }
  }

  /// Load playlists from storage
  Future<void> _loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString(_playlistsKey);
      
      if (playlistsJson != null) {
        final List<dynamic> decoded = jsonDecode(playlistsJson);
        final playlists = decoded
            .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
            .toList();
        state = playlists;
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load playlists', source: 'PlaylistService', error: e);
      state = [];
    }
  }

  /// Save playlists to storage
  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = jsonEncode(state.map((p) => p.toJson()).toList());
      await prefs.setString(_playlistsKey, playlistsJson);
    } catch (e) {
      LoggingHelper.logError('Failed to save playlists', source: 'PlaylistService', error: e);
    }
  }

  /// Playlists stream
  Stream<List<Playlist>> get playlistsStream => stream;

  /// Create playlist
  Future<Playlist> createPlaylist(
    String name, {
    String? description,
    List<Track> initialTracks = const [],
  }) async {
    await _acquireMutex();
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      final playlist = Playlist(
        id: id,
        name: name,
        description: description,
        trackIds: initialTracks.map((t) => t.id).toList(),
        createdAt: now,
        updatedAt: now,
      );

      state = [...state, playlist];
      await _savePlaylists();
      
      // Track analytics (non-blocking)
      Future.microtask(() {
        AnalyticsService.instance.trackPlaylistCreate(playlist.id).catchError((e) {
          LoggingHelper.logError('Failed to track playlist create', source: 'PlaylistService', error: e);
        });
      });
      
      return playlist;
    } finally {
      _releaseMutex();
    }
  }

  /// Rename playlist
  Future<void> renamePlaylist(String id, String newName) async {
    await _acquireMutex();
    try {
      final index = state.indexWhere((p) => p.id == id);
      if (index < 0) return;

      final updated = state[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );

      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
      await _savePlaylists();
    } finally {
      _releaseMutex();
    }
  }

  /// Delete playlist
  Future<void> deletePlaylist(String id) async {
    await _acquireMutex();
    try {
      state = state.where((p) => p.id != id).toList();
      await _savePlaylists();
    } finally {
      _releaseMutex();
    }
  }

  /// Add track to playlist
  Future<void> addToPlaylist(String playlistId, Track track) async {
    await _acquireMutex();
    try {
      final index = state.indexWhere((p) => p.id == playlistId);
      if (index < 0) return;

      final playlist = state[index];
      if (playlist.trackIds.contains(track.id)) return; // Already exists

      final updated = playlist.copyWith(
        trackIds: [...playlist.trackIds, track.id],
        updatedAt: DateTime.now(),
      );

      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
      await _savePlaylists();
    } finally {
      _releaseMutex();
    }
  }

  /// Remove track from playlist
  Future<void> removeFromPlaylist(String playlistId, String trackId) async {
    await _acquireMutex();
    try {
      final index = state.indexWhere((p) => p.id == playlistId);
      if (index < 0) return;

      final playlist = state[index];
      final updatedTrackIds = playlist.trackIds.where((id) => id != trackId).toList();

      final updated = playlist.copyWith(
        trackIds: updatedTrackIds,
        updatedAt: DateTime.now(),
      );

      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
      await _savePlaylists();
    } finally {
      _releaseMutex();
    }
  }

  /// Reorder playlist tracks
  Future<void> reorderPlaylist(
    String playlistId,
    int fromIndex,
    int toIndex,
  ) async {
    await _acquireMutex();
    try {
      final index = state.indexWhere((p) => p.id == playlistId);
      if (index < 0) return;

      final playlist = state[index];
      final trackIds = List<String>.from(playlist.trackIds);
      
      if (fromIndex < 0 || fromIndex >= trackIds.length ||
          toIndex < 0 || toIndex >= trackIds.length) {
        return;
      }

      final trackId = trackIds.removeAt(fromIndex);
      trackIds.insert(toIndex, trackId);

      final updated = playlist.copyWith(
        trackIds: trackIds,
        updatedAt: DateTime.now(),
      );

      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
      await _savePlaylists();
    } finally {
      _releaseMutex();
    }
  }

  /// Get playlist by ID
  Playlist? getPlaylist(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get tracks for a playlist
  /// Loads tracks from the API based on track IDs in the playlist
  Future<List<Track>> getTracksForPlaylist(String playlistId) async {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return [];

    if (playlist.trackIds.isEmpty) return [];

    try {
      // Load music list from API (uses cache)
      final musicList = await ContentApiService.instance.getMusicList();
      final allMusic = (musicList['music'] as List<dynamic>?)
              ?.map((music) => music as Map<String, dynamic>)
              .toList() ??
          [];

      // Create a map of track ID to music data for quick lookup
      final musicMap = <String, Map<String, dynamic>>{};
      for (final music in allMusic) {
        final id = music['id'] as String?;
        if (id != null) {
          musicMap[id] = music;
        }
      }

      // Get tracks in playlist order
      final tracks = <Track>[];
      for (final trackId in playlist.trackIds) {
        final music = musicMap[trackId];
        if (music != null) {
          tracks.add(Track.fromMusicMap(music));
        }
      }

      return tracks;
    } catch (e) {
      LoggingHelper.logError(
        'Failed to load tracks for playlist $playlistId',
        source: 'PlaylistService',
        error: e,
      );
      return [];
    }
  }

  /// Export playlist as JSON
  Future<String> exportPlaylist(String id) async {
    final playlist = getPlaylist(id);
    if (playlist == null) throw Exception('Playlist not found');
    return jsonEncode(playlist.toJson());
  }

  /// Import playlist from JSON
  Future<Playlist> importPlaylist(String jsonString) async {
    await _acquireMutex();
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final playlist = Playlist.fromJson(json);
      
      // Check if playlist with same ID exists
      final existingIndex = state.indexWhere((p) => p.id == playlist.id);
      if (existingIndex >= 0) {
        // Update existing
        state = [
          ...state.sublist(0, existingIndex),
          playlist.copyWith(updatedAt: DateTime.now()),
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        // Add new
        state = [...state, playlist];
      }
      
      await _savePlaylists();
      return playlist;
    } finally {
      _releaseMutex();
    }
  }
}

/// Playlist Service Provider
final playlistServiceProvider =
    StateNotifierProvider<PlaylistService, List<Playlist>>(
  (ref) => PlaylistService(),
);

