/// Content API Service
///
/// HTTP client service for content API calls (audio, lyrics, books).
/// Connects to Cloudflare Workers for R2 content access.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/shared/cache_service.dart';
import '../../../core/logging/logging_helper.dart';
// Conditional import for HttpClient (mobile only)
import 'content_api_service_stub.dart'
    if (dart.library.io) 'content_api_service_mobile.dart';

/// Common utility for handling gzip decompression from HTTP responses
/// 
/// Handles both web (browser auto-decompression) and mobile (manual decompression) cases
/// Works for both lyrics and books
class ContentDecompressionHelper {
  /// Extract and decompress content from HTTP response
  /// 
  /// Handles:
  /// - Browser auto-decompression (web)
  /// - Manual decompression fallback (if browser didn't decompress)
  /// - Direct usage if not compressed
  /// 
  /// Returns the decompressed string content
  static String extractContent(http.Response response, {String source = 'ContentApiService'}) {
    // Check if response body is empty
    if (response.bodyBytes.isEmpty) {
      throw Exception('Response body is empty');
    }

    // Check if browser didn't decompress (shouldn't happen, but just in case)
    // Gzip files start with magic bytes 0x1f 0x8b
    final bodyBytes = response.bodyBytes;
    final isStillCompressed = bodyBytes.length >= 2 &&
        bodyBytes[0] == 0x1f &&
        bodyBytes[1] == 0x8b;

    if (isStillCompressed) {
      LoggingHelper.logWarning(
        'Response is still compressed - browser did not auto-decompress. Manual decompression needed.',
        source: source,
      );
      // Fallback: Manually decompress if browser didn't do it
      try {
        final decompressedBytes = GZipDecoder().decodeBytes(bodyBytes);
        final content = utf8.decode(decompressedBytes);
        LoggingHelper.logInfo(
          'Manually decompressed gzip content (${bodyBytes.length} bytes -> ${decompressedBytes.length} bytes)',
          source: source,
        );
        return content;
      } catch (e) {
        LoggingHelper.logError(
          'Failed to manually decompress gzip content',
          source: source,
          error: e,
        );
        throw Exception('Failed to decompress gzip content: $e');
      }
    } else {
      // Browser automatically decompressed gzip, just use response.body
      return response.body;
    }
  }
}

/// Content API Service
///
/// Provides methods to call content API endpoints.
/// All methods return Map<String, dynamic> (raw JSON).
class ContentApiService {
  static ContentApiService? _instance;
  final String baseUrl;
  final http.Client _httpClient; // For web platform
  final CacheService _cache;

  ContentApiService._({
    required this.baseUrl,
    required http.Client httpClient,
    required CacheService cache,
  })  : _httpClient = httpClient,
        _cache = cache;

  /// Factory constructor
  factory ContentApiService.create({
    String? baseUrl,
    http.Client? client,
    CacheService? cache,
  }) {
    // Get Workers URL from config
    final workersUrl = baseUrl ?? AppConfig.current.workersBaseUrl;
    return ContentApiService._(
      baseUrl: workersUrl,
      httpClient: client ?? http.Client(),
      cache: cache ?? CacheService.instance,
    );
  }

  /// Get singleton instance
  static ContentApiService get instance {
    _instance ??= ContentApiService.create();
    return _instance!;
  }

  /// Get list of all music files
  Future<Map<String, dynamic>> getMusicList() async {
    try {
      const cacheKey = 'music_list';

      // Check cache (cache for 10 days)
      final cachedData = _cache.get(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/music'),
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

        // Cache for 10 days
        _cache.set(
          cacheKey,
          data,
          duration: const Duration(days: 10),
        );

        return data;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting music list: $e');
      rethrow;
    }
  }

  /// Get music file URL (direct URL from Worker)
  Future<String> getMusicUrl(String musicId) async {
    try {
      // The Worker now directly serves the file, so the URL is the endpoint itself
      return '$baseUrl/api/music/$musicId';
    } catch (e) {
      debugPrint('Error getting music URL: $e');
      rethrow;
    }
  }

  /// Get lyrics for a music file
  Future<String> getLyrics(String musicId,
      {String? language, bool forceRefresh = false}) async {
    try {
      final lang = language ?? 'en';
      const cacheKeyPrefix = 'lyrics_';
      final cacheKey = '$cacheKeyPrefix${musicId}_$lang';

      // Check cache only if not forcing refresh
      if (!forceRefresh) {
        final cachedData = _cache.get(cacheKey);
        if (cachedData != null) {
          // Cache stores as map, extract lyrics string
          return cachedData['lyrics'] as String;
        }
      }

      String lyrics;

      if (kIsWeb) {
        // Web: Browser's fetch API automatically decompresses gzip responses
        // Just use response.body - it's already decompressed by the browser
        // This is much faster than manual decompression (native C code)
        final response = await _httpClient.get(
          Uri.parse('$baseUrl/api/lyrics/$musicId?lang=$lang'),
          headers: {
            'Accept': 'text/plain',
            'Accept-Encoding': 'gzip, deflate',
          },
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('API request timeout');
          },
        );

        if (response.statusCode != 200) {
          throw Exception(
              'API error: ${response.statusCode} - ${response.body}');
        }

        // Use common decompression helper (same as books)
        lyrics = ContentDecompressionHelper.extractContent(
          response,
          source: 'ContentApiService',
        );
      } else {
        // Mobile: Use HttpClient with automatic decompression
        lyrics =
            await _getLyricsMobile('$baseUrl/api/lyrics/$musicId?lang=$lang');
      }

      // Cache for 10 days (store as string in cache)
      _cache.set(
        cacheKey,
        {'lyrics': lyrics},
        duration: const Duration(days: 10),
      );

      return lyrics;
    } catch (e) {
      debugPrint('Error getting lyrics: $e');
      rethrow;
    }
  }

  /// Mobile implementation using HttpClient (automatic gzip decompression)
  Future<String> _getLyricsMobile(String url) {
    return getLyricsMobile(url);
  }

  /// Get list of all books
  Future<Map<String, dynamic>> getBooksList({String? language}) async {
    try {
      final lang = language ?? 'en';
      final cacheKey = 'books_list_$lang';

      // Check cache (cache for 10 days)
      final cachedData = _cache.get(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/books?lang=$lang'),
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

        // Cache for 10 days
        _cache.set(
          cacheKey,
          data,
          duration: const Duration(days: 10),
        );

        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Books not found. Please check your connection and try again.');
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception('Invalid request. Please try again later.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}. Please try again later.');
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting books list: $e');
      rethrow;
    }
  }

  /// Get book file URL (direct URL from Worker)
  Future<String> getBookUrl(String bookId, {String? language}) async {
    try {
      final lang = language ?? 'en';
      // The Worker now directly serves the file, so the URL is the endpoint itself
      return '$baseUrl/api/books/$bookId?lang=$lang';
    } catch (e) {
      debugPrint('Error getting book URL: $e');
      rethrow;
    }
  }

  /// Get available languages for a content item
  Future<Map<String, dynamic>> getAvailableLanguages({
    required String contentId,
    required String contentType, // 'books' or 'lyrics'
  }) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
            '$baseUrl/api/languages?contentId=$contentId&type=$contentType'),
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
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting available languages: $e');
      rethrow;
    }
  }
}
