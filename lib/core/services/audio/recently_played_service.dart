/// Recently Played Service
///
/// Tracks recently played tracks with local persistence
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';

/// Recently Played Service - Tracks recently played with persistence
class RecentlyPlayedService extends StateNotifier<List<String>> {
  // Keep last 50 tracks

  RecentlyPlayedService() : super([]) {
    _loadRecentlyPlayed();
  }
  static const String _recentlyPlayedKey = 'audio_recently_played';
  static const int _maxRecentTracks = 50;

  /// Load recently played from storage
  Future<void> _loadRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentlyPlayedJson = prefs.getString(_recentlyPlayedKey);

      if (recentlyPlayedJson != null) {
        final List<dynamic> decoded = jsonDecode(recentlyPlayedJson);
        state = decoded.map((id) => id as String).toList();
      }
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to load recently played',
          source: 'RecentlyPlayedService', error: e,);
      state = [];
    }
  }

  /// Save recently played to storage
  Future<void> _saveRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentlyPlayedJson = jsonEncode(state);
      await prefs.setString(_recentlyPlayedKey, recentlyPlayedJson);
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to save recently played',
          source: 'RecentlyPlayedService', error: e,);
    }
  }

  /// Add track to recently played
  Future<void> addTrack(String trackId) async {
    final newState = List<String>.from(state)
      ..remove(trackId)
      ..insert(0, trackId);

    // Keep only max tracks
    if (newState.length > _maxRecentTracks) {
      newState.removeRange(_maxRecentTracks, newState.length);
    }

    state = newState;
    await _saveRecentlyPlayed();
  }

  /// Get recently played tracks
  List<String> get recentlyPlayed => state;

  /// Clear recently played
  Future<void> clear() async {
    state = [];
    await _saveRecentlyPlayed();
  }

  /// Recently played stream
  Stream<List<String>> get recentlyPlayedStream => stream;
}

/// Recently played service provider
final recentlyPlayedServiceProvider =
    StateNotifierProvider<RecentlyPlayedService, List<String>>((ref) {
  return RecentlyPlayedService();
});
