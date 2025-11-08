/// Analytics Service
///
/// Service for tracking user interactions and retrieving analytics data
/// from the Cloudflare Worker API.
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

/// Analytics Service
///
/// Provides methods to track user interactions and retrieve analytics data.
class AnalyticsService {
  static AnalyticsService? _instance;
  final String baseUrl;
  final http.Client _client;

  AnalyticsService._({
    required this.baseUrl,
    required http.Client client,
  }) : _client = client;

  /// Factory constructor
  factory AnalyticsService.create({
    String? baseUrl,
    http.Client? client,
  }) {
    // Get Workers URL from config (to be added to AppConfig)
    final workersUrl = baseUrl ?? AppConfig.current.workersBaseUrl;
    return AnalyticsService._(
      baseUrl: workersUrl,
      client: client ?? http.Client(),
    );
  }

  /// Get singleton instance
  static AnalyticsService get instance {
    _instance ??= AnalyticsService.create();
    return _instance!;
  }

  /// Track audio play event
  Future<void> trackAudioPlay(String contentId) async {
    await _trackEvent(
      event: 'play',
      contentType: 'audio',
      contentId: contentId,
    );
  }

  /// Track book view event
  Future<void> trackBookView(String contentId, {String? language}) async {
    await _trackEvent(
      event: 'view',
      contentType: 'book',
      contentId: contentId,
      language: language,
    );
  }

  /// Track lyrics view event
  Future<void> trackLyricsView(String contentId, {String? language}) async {
    await _trackEvent(
      event: 'view',
      contentType: 'lyrics',
      contentId: contentId,
      language: language,
    );
  }

  /// Track audio download event
  Future<void> trackAudioDownload(String contentId) async {
    await _trackEvent(
      event: 'download',
      contentType: 'audio',
      contentId: contentId,
    );
  }

  /// Internal method to track analytics events
  Future<void> _trackEvent({
    required String event,
    required String contentType,
    required String contentId,
    String? language,
  }) async {
    try {
      await _client
          .post(
        Uri.parse('$baseUrl/api/analytics/track'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'event': event,
          'contentType': contentType,
          'contentId': contentId,
          if (language != null) 'language': language,
        }),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Analytics tracking timeout');
        },
      );
    } catch (e) {
      // Silently fail - analytics shouldn't break the app
      developer.log('Analytics tracking failed: $e', name: 'AnalyticsService');
    }
  }

  /// Get most played audio
  ///
  /// Returns list of most played audio items sorted by play count
  Future<List<Map<String, dynamic>>> getMostPlayed({int limit = 10}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/analytics/most-played?limit=$limit'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['mostPlayed'] ?? []);
      } else {
        developer.log('Failed to get most played: ${response.statusCode}',
            name: 'AnalyticsService');
        return [];
      }
    } catch (e) {
      developer.log('Error getting most played: $e', name: 'AnalyticsService');
      return [];
    }
  }

  /// Get most visited books
  ///
  /// Returns list of most visited books sorted by view count
  Future<List<Map<String, dynamic>>> getMostVisitedBooks(
      {int limit = 10}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/analytics/most-visited-books?limit=$limit'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['mostVisited'] ?? []);
      } else {
        developer.log(
            'Failed to get most visited books: ${response.statusCode}',
            name: 'AnalyticsService');
        return [];
      }
    } catch (e) {
      developer.log('Error getting most visited books: $e',
          name: 'AnalyticsService');
      return [];
    }
  }

  /// Get trending content
  ///
  /// Returns list of trending content items from the last 7 days
  /// [type] can be 'audio', 'book', 'lyrics', or 'all' (default)
  Future<List<Map<String, dynamic>>> getTrending({
    int limit = 10,
    String? type,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/analytics/trending?limit=$limit');
      final finalUrl = type != null
          ? url.replace(
              queryParameters: {'limit': limit.toString(), 'type': type})
          : url;

      final response = await _client.get(
        finalUrl,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['trending'] ?? []);
      } else {
        developer.log('Failed to get trending: ${response.statusCode}',
            name: 'AnalyticsService');
        return [];
      }
    } catch (e) {
      developer.log('Error getting trending: $e', name: 'AnalyticsService');
      return [];
    }
  }

  /// Get content statistics
  ///
  /// Returns statistics for a specific content item
  Future<Map<String, dynamic>?> getContentStats(String contentId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/analytics/stats/$contentId'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        developer.log('Failed to get content stats: ${response.statusCode}',
            name: 'AnalyticsService');
        return null;
      }
    } catch (e) {
      developer.log('Error getting content stats: $e',
          name: 'AnalyticsService');
      return null;
    }
  }
}
