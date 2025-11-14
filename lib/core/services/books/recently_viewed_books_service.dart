/// Recently Viewed Books Service
///
/// Tracks recently viewed books with local persistence
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';

/// Recently Viewed Books Service - Tracks recently viewed books with persistence
class RecentlyViewedBooksService extends StateNotifier<List<String>> {
  // Keep last 50 books

  RecentlyViewedBooksService() : super([]) {
    _loadRecentlyViewed();
  }
  static const String _recentlyViewedKey = 'books_recently_viewed';
  static const int _maxRecentBooks = 50;

  /// Load recently viewed from storage
  Future<void> _loadRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentlyViewedJson = prefs.getString(_recentlyViewedKey);

      if (recentlyViewedJson != null) {
        final List<dynamic> decoded = jsonDecode(recentlyViewedJson);
        state = decoded.map((id) => id as String).toList();
      }
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to load recently viewed books',
          source: 'RecentlyViewedBooksService', error: e,);
      state = [];
    }
  }

  /// Save recently viewed to storage
  Future<void> _saveRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentlyViewedJson = jsonEncode(state);
      await prefs.setString(_recentlyViewedKey, recentlyViewedJson);
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to save recently viewed books',
          source: 'RecentlyViewedBooksService', error: e,);
    }
  }

  /// Add book to recently viewed
  Future<void> addBook(String bookId) async {
    final newState = List<String>.from(state);

    // ignore: cascade_invocations
    newState
      ..remove(bookId)
      ..insert(0, bookId);

    // Keep only max books
    if (newState.length > _maxRecentBooks) {
      newState.removeRange(_maxRecentBooks, newState.length);
    }

    state = newState;
    await _saveRecentlyViewed();
  }

  /// Get recently viewed books
  List<String> get recentlyViewed => state;

  /// Clear recently viewed
  Future<void> clear() async {
    state = [];
    await _saveRecentlyViewed();
  }

  /// Recently viewed stream
  Stream<List<String>> get recentlyViewedStream => stream;
}

/// Recently viewed books service provider
final recentlyViewedBooksServiceProvider =
    StateNotifierProvider<RecentlyViewedBooksService, List<String>>((ref) {
  return RecentlyViewedBooksService();
});
