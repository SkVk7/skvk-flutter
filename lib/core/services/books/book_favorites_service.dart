/// Book Favorites Service
///
/// Manages user favorite books with local persistence
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/logging/logging_helper.dart';

/// Book Favorites Service - Manages favorite books with persistence
class BookFavoritesService extends StateNotifier<Set<String>> {
  static const String _favoritesKey = 'book_favorites';

  BookFavoritesService() : super({}) {
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
      LoggingHelper.logError('Failed to load book favorites', source: 'BookFavoritesService', error: e);
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
      LoggingHelper.logError('Failed to save book favorites', source: 'BookFavoritesService', error: e);
    }
  }

  /// Check if book is favorite
  bool isFavorite(String bookId) {
    return state.contains(bookId);
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String bookId) async {
    final newState = Set<String>.from(state);
    if (newState.contains(bookId)) {
      newState.remove(bookId);
    } else {
      newState.add(bookId);
    }
    state = newState;
    await _saveFavorites();
  }

  /// Add to favorites
  Future<void> addFavorite(String bookId) async {
    if (!state.contains(bookId)) {
      final newState = Set<String>.from(state)..add(bookId);
      state = newState;
      await _saveFavorites();
    }
  }

  /// Remove from favorites
  Future<void> removeFavorite(String bookId) async {
    if (state.contains(bookId)) {
      final newState = Set<String>.from(state)..remove(bookId);
      state = newState;
      await _saveFavorites();
    }
  }

  /// Get all favorites
  Set<String> get favorites => state;

  /// Favorites stream
  Stream<Set<String>> get favoritesStream => stream;
}

/// Book favorites service provider
final bookFavoritesServiceProvider =
    StateNotifierProvider<BookFavoritesService, Set<String>>((ref) {
  return BookFavoritesService();
});

