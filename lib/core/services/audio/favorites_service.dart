/// Favorites Service
///
/// Manages user favorites with local persistence
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/logging/logging_helper.dart';

/// Favorites Service - Manages favorites with persistence
class FavoritesService extends StateNotifier<Set<String>> {
  static const String _favoritesKey = 'audio_favorites';

  FavoritesService() : super({}) {
    _loadFavorites();
  }

  /// Load favorites from storage
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson != null) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        state = decoded.map((id) => id as String).toSet();
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load favorites', source: 'FavoritesService', error: e);
      state = {};
    }
  }

  /// Save favorites to storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = jsonEncode(state.toList());
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      LoggingHelper.logError('Failed to save favorites', source: 'FavoritesService', error: e);
    }
  }

  /// Check if track is favorite
  bool isFavorite(String trackId) {
    return state.contains(trackId);
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String trackId) async {
    final newState = Set<String>.from(state);
    if (newState.contains(trackId)) {
      newState.remove(trackId);
    } else {
      newState.add(trackId);
    }
    state = newState;
    await _saveFavorites();
  }

  /// Add to favorites
  Future<void> addFavorite(String trackId) async {
    if (!state.contains(trackId)) {
      final newState = Set<String>.from(state)..add(trackId);
      state = newState;
      await _saveFavorites();
    }
  }

  /// Remove from favorites
  Future<void> removeFavorite(String trackId) async {
    if (state.contains(trackId)) {
      final newState = Set<String>.from(state)..remove(trackId);
      state = newState;
      await _saveFavorites();
    }
  }

  /// Get all favorites
  Set<String> get favorites => state;

  /// Favorites stream
  Stream<Set<String>> get favoritesStream => stream;
}

/// Favorites service provider
final favoritesServiceProvider =
    StateNotifierProvider<FavoritesService, Set<String>>((ref) {
  return FavoritesService();
});

