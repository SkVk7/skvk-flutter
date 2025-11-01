/// Astrology Cache Manager for High-Performance Caching
///
/// This manager handles multi-layer caching for astrological calculations
/// to ensure optimal performance and data consistency.
library;

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/interfaces/astrology_engine_interface.dart';
import '../core/utils/astrology_utils.dart';

/// Cache retention policy for different types of data
enum CacheRetentionPolicy {
  /// Long-term cache for user data (365 days)
  longTerm,

  /// Short-term cache for partner data (30 days, max 25 entries)
  shortTerm,
}

/// Cache manager implementation
class AstrologyCacheManager implements AstrologyCacheInterface {
  static AstrologyCacheManager? _instance;
  SharedPreferences? _prefs;
  final Map<String, CacheEntry> _memoryCache = {};
  bool _isInitialized = false;

  // Cache configuration
  static const int _maxMemoryCacheSize = 100;
  static const int _maxPartnerCacheEntries = 25; // Limit partner cache to 25 entries
  static const Duration _userDataTTL = Duration(days: 365); // 1 year for user data
  static const Duration _partnerDataTTL = Duration(days: 30); // 30 days for partner data

  // Retention policy durations
  static const Duration _longTermTTL = Duration(days: 365); // 1 year for user data
  static const Duration _shortTermTTL = Duration(days: 30); // 30 days for partner data

  // Partner cache tracking for LRU eviction
  final List<String> _partnerCacheOrder = []; // LRU order (oldest first)

  // Private constructor for singleton
  AstrologyCacheManager._();

  /// Get singleton instance
  static AstrologyCacheManager get instance {
    _instance ??= AstrologyCacheManager._();
    return _instance!;
  }

  /// Initialize the cache manager
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;

      AstrologyUtils.logInfo('Astrology Cache Manager initialized');
    } catch (e) {
      AstrologyUtils.logError('Failed to initialize cache manager: $e');
      rethrow;
    }
  }

  @override
  Future<T?> getCachedData<T>(String key) async {
    await _ensureInitialized();

    try {
      // Check memory cache first
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && !memoryEntry.isExpired) {
        AstrologyUtils.logDebug('Cache hit (memory): $key');
        return memoryEntry.data as T?;
      }

      // Check persistent cache
      final persistentData = _prefs!.getString('astro_cache_$key');
      if (persistentData != null) {
        final entry = CacheEntry.fromJson(json.decode(persistentData));
        if (!entry.isExpired) {
          // Load back into memory cache
          _memoryCache[key] = entry;
          AstrologyUtils.logDebug('Cache hit (persistent): $key');
          return entry.data as T?;
        } else {
          // Remove expired entry
          await _prefs!.remove('astro_cache_$key');
        }
      }

      AstrologyUtils.logDebug('Cache miss: $key');
      return null;
    } catch (e) {
      AstrologyUtils.logError('Error getting cached data for key $key: $e');
      return null;
    }
  }

  @override
  Future<void> setCachedData<T>(String key, T data,
      {Duration? ttl, bool isUserData = false, CacheRetentionPolicy? retentionPolicy}) async {
    await _ensureInitialized();

    try {
      // Determine TTL based on retention policy or data type
      Duration ttlToUse;
      if (retentionPolicy != null) {
        ttlToUse = retentionPolicy == CacheRetentionPolicy.longTerm ? _longTermTTL : _shortTermTTL;
      } else {
        ttlToUse = ttl ?? (isUserData ? _userDataTTL : _partnerDataTTL);
      }

      final entry = CacheEntry(
        data: data,
        timestamp: DateTime.now(),
        ttl: ttlToUse,
        isUserData: isUserData,
      );

      // Store in memory cache
      _memoryCache[key] = entry;

      // Handle partner cache limit (non-user data with short-term retention)
      if (retentionPolicy == CacheRetentionPolicy.shortTerm ||
          (!isUserData && retentionPolicy == null)) {
        _managePartnerCache(key);
      }

      // Store in persistent cache if data is serializable
      if (_isSerializable(data)) {
        await _prefs!.setString('astro_cache_$key', json.encode(entry.toJson()));
      }

      // Clean up memory cache if it's too large
      _cleanupMemoryCache();

      AstrologyUtils.logDebug('Data cached: $key (${isUserData ? 'user' : 'partner'})');
    } catch (e) {
      AstrologyUtils.logError('Error setting cached data for key $key: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _ensureInitialized();

    try {
      // Clear memory cache
      _memoryCache.clear();

      // Clear persistent cache
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('astro_cache_')) {
          await _prefs!.remove(key);
        }
      }

      AstrologyUtils.logInfo('All caches cleared');
    } catch (e) {
      AstrologyUtils.logError('Error clearing cache: $e');
    }
  }

  @override
  Future<void> clearCacheEntry(String key) async {
    await _ensureInitialized();

    try {
      // Remove from memory cache
      _memoryCache.remove(key);

      // Remove from persistent cache
      await _prefs!.remove('astro_cache_$key');

      AstrologyUtils.logDebug('Cache entry cleared: $key');
    } catch (e) {
      AstrologyUtils.logError('Error clearing cache entry $key: $e');
    }
  }

  @override
  Future<bool> hasCachedData(String key) async {
    await _ensureInitialized();

    try {
      // Check memory cache
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && !memoryEntry.isExpired) {
        return true;
      }

      // Check persistent cache
      final persistentData = _prefs!.getString('astro_cache_$key');
      if (persistentData != null) {
        final entry = CacheEntry.fromJson(json.decode(persistentData));
        if (!entry.isExpired) {
          return true;
        } else {
          // Remove expired entry
          await _prefs!.remove('astro_cache_$key');
        }
      }

      return false;
    } catch (e) {
      AstrologyUtils.logError('Error checking cache for key $key: $e');
      return false;
    }
  }

  // Private helper methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  bool _isSerializable(dynamic data) {
    try {
      json.encode(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _cleanupMemoryCache() {
    if (_memoryCache.length > _maxMemoryCacheSize) {
      // Remove oldest entries
      final entries = _memoryCache.entries.toList();
      entries.sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      final toRemove = entries.take(_memoryCache.length - _maxMemoryCacheSize);
      for (final entry in toRemove) {
        _memoryCache.remove(entry.key);
      }

      AstrologyUtils.logDebug('Memory cache cleaned up');
    }
  }

  /// Manage partner cache with LRU eviction (max 25 entries)
  void _managePartnerCache(String key) {
    // Remove key from order if it exists (move to end)
    _partnerCacheOrder.remove(key);

    // Add key to end (most recently used)
    _partnerCacheOrder.add(key);

    // Remove oldest entries if limit exceeded
    while (_partnerCacheOrder.length > _maxPartnerCacheEntries) {
      final oldestKey = _partnerCacheOrder.removeAt(0);
      _memoryCache.remove(oldestKey);

      // Also remove from persistent cache
      _prefs?.remove('astro_cache_$oldestKey');

      AstrologyUtils.logDebug('Removed oldest partner cache entry: $oldestKey');
    }
  }

  /// Clear all partner cache entries
  @override
  Future<void> clearPartnerCache() async {
    await _ensureInitialized();

    try {
      // Clear partner entries from memory cache
      final partnerKeys = _memoryCache.keys.where((key) => key.startsWith('partner_')).toList();
      for (final key in partnerKeys) {
        _memoryCache.remove(key);
      }

      // Clear partner entries from persistent cache
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('astro_cache_partner_')) {
          await _prefs!.remove(key);
        }
      }

      // Clear partner cache order
      _partnerCacheOrder.clear();

      AstrologyUtils.logInfo('Partner cache cleared');
    } catch (e) {
      AstrologyUtils.logError('Error clearing partner cache: $e');
    }
  }

  /// Get partner cache statistics
  @override
  Map<String, dynamic> getPartnerCacheStats() {
    final partnerEntries = _memoryCache.keys.where((key) => key.startsWith('partner_')).length;

    return {
      'partnerEntries': partnerEntries,
      'maxPartnerEntries': _maxPartnerCacheEntries,
      'remainingSlots': _maxPartnerCacheEntries - partnerEntries,
      'partnerCacheOrder': _partnerCacheOrder.length,
    };
  }

  /// Get cache statistics
  @override
  Map<String, dynamic> getCacheStats() {
    final memoryEntries = _memoryCache.length;
    final expiredEntries = _memoryCache.values.where((entry) => entry.isExpired).length;

    return {
      'memoryEntries': memoryEntries,
      'expiredEntries': expiredEntries,
      'activeEntries': memoryEntries - expiredEntries,
      'maxMemoryCacheSize': _maxMemoryCacheSize,
    };
  }

  /// Clear expired entries
  Future<void> clearExpiredEntries() async {
    await _ensureInitialized();

    try {
      // Clear expired memory cache entries
      final expiredKeys = _memoryCache.entries
          .where((entry) => entry.value.isExpired)
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredKeys) {
        _memoryCache.remove(key);
      }

      // Clear expired persistent cache entries
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('astro_cache_')) {
          final data = _prefs!.getString(key);
          if (data != null) {
            try {
              final entry = CacheEntry.fromJson(json.decode(data));
              if (entry.isExpired) {
                await _prefs!.remove(key);
              }
            } catch (e) {
              // Remove corrupted entries
              await _prefs!.remove(key);
            }
          }
        }
      }

      AstrologyUtils.logInfo('Expired cache entries cleared');
    } catch (e) {
      AstrologyUtils.logError('Error clearing expired entries: $e');
    }
  }
}

/// Cache entry class
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;
  final bool isUserData;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
    this.isUserData = false,
  });

  bool get isExpired {
    return DateTime.now().difference(timestamp) > ttl;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'ttl': ttl.inMilliseconds,
      'isUserData': isUserData,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      ttl: Duration(milliseconds: json['ttl']),
      isUserData: json['isUserData'] ?? false,
    );
  }
}
