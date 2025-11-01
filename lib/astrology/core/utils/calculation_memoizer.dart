/// High-Performance Calculation Memoizer
///
/// This class provides intelligent memoization for astrological calculations
/// to eliminate redundant computations and maximize performance.
library;

import 'dart:async';
import 'dart:collection';
import '../entities/astrology_entities.dart';
import 'astrology_utils.dart';

/// High-performance memoization system for astrological calculations
class CalculationMemoizer {
  static CalculationMemoizer? _instance;

  // Multi-level cache system
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, int> _accessCounts = {};
  final Queue<String> _accessOrder = Queue<String>();

  // Configuration
  static const int _maxCacheSize = 1000;
  static const Duration _defaultTTL = Duration(hours: 24);
  static const Duration _shortTTL = Duration(hours: 1);
  static const Duration _longTTL = Duration(days: 30);

  // Cache statistics
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;

  // Private constructor for singleton
  CalculationMemoizer._();

  /// Get singleton instance
  static CalculationMemoizer get instance {
    _instance ??= CalculationMemoizer._();
    return _instance!;
  }

  // ============================================================================
  // MEMOIZATION METHODS
  // ============================================================================

  /// Memoize a calculation result with intelligent TTL
  Future<T> memoize<T>(
    String key,
    Future<T> Function() calculation, {
    Duration? ttl,
    bool isUserData = false,
    bool isPartnerData = false,
  }) async {
    // Determine TTL based on data type
    final effectiveTTL = ttl ?? _getEffectiveTTL(isUserData, isPartnerData);

    // Check if result is already cached and valid
    if (_isValidCache(key, effectiveTTL)) {
      _hitCount++;
      _updateAccessInfo(key);
      AstrologyUtils.logDebug('Memoization hit: $key');
      return _memoryCache[key] as T;
    }

    // Calculate new result
    _missCount++;
    AstrologyUtils.logDebug('Memoization miss: $key');

    try {
      final result = await calculation();
      _storeResult(key, result, effectiveTTL);
      return result;
    } catch (e) {
      AstrologyUtils.logError('Calculation failed for key $key: $e');
      rethrow;
    }
  }

  /// Memoize a synchronous calculation result
  T memoizeSync<T>(
    String key,
    T Function() calculation, {
    Duration? ttl,
    bool isUserData = false,
    bool isPartnerData = false,
  }) {
    // Determine TTL based on data type
    final effectiveTTL = ttl ?? _getEffectiveTTL(isUserData, isPartnerData);

    // Check if result is already cached and valid
    if (_isValidCache(key, effectiveTTL)) {
      _hitCount++;
      _updateAccessInfo(key);
      AstrologyUtils.logDebug('Memoization hit (sync): $key');
      return _memoryCache[key] as T;
    }

    // Calculate new result
    _missCount++;
    AstrologyUtils.logDebug('Memoization miss (sync): $key');

    try {
      final result = calculation();
      _storeResult(key, result, effectiveTTL);
      return result;
    } catch (e) {
      AstrologyUtils.logError('Sync calculation failed for key $key: $e');
      rethrow;
    }
  }

  /// Memoize with dependency tracking
  Future<T> memoizeWithDependencies<T>(
    String key,
    Future<T> Function() calculation, {
    required List<String> dependencies,
    Duration? ttl,
    bool isUserData = false,
    bool isPartnerData = false,
  }) async {
    // Check if any dependency has changed
    if (_hasDependencyChanged(key, dependencies)) {
      _invalidateKey(key);
    }

    return await memoize(
      key,
      calculation,
      ttl: ttl,
      isUserData: isUserData,
      isPartnerData: isPartnerData,
    );
  }

  /// Memoize with conditional invalidation
  Future<T> memoizeConditional<T>(
    String key,
    Future<T> Function() calculation, {
    required bool Function() shouldInvalidate,
    Duration? ttl,
    bool isUserData = false,
    bool isPartnerData = false,
  }) async {
    // Check if cache should be invalidated
    if (shouldInvalidate() && _memoryCache.containsKey(key)) {
      _invalidateKey(key);
    }

    return await memoize(
      key,
      calculation,
      ttl: ttl,
      isUserData: isUserData,
      isPartnerData: isPartnerData,
    );
  }

  // ============================================================================
  // SPECIALIZED MEMOIZATION METHODS
  // ============================================================================

  /// Memoize birth data calculations
  Future<FixedBirthData> memoizeBirthData(
    String key,
    Future<FixedBirthData> Function() calculation, {
    Duration? ttl,
  }) async {
    return await memoize(
      key,
      calculation,
      ttl: ttl ?? _longTTL, // Birth data rarely changes
      isUserData: true,
    );
  }

  /// Memoize compatibility calculations
  Future<CompatibilityResult> memoizeCompatibility(
    String key,
    Future<CompatibilityResult> Function() calculation, {
    Duration? ttl,
  }) async {
    return await memoize(
      key,
      calculation,
      ttl: ttl ?? _defaultTTL,
      isPartnerData: true,
    );
  }

  /// Memoize planetary positions calculations
  Future<PlanetaryPositions> memoizePlanetaryPositions(
    String key,
    Future<PlanetaryPositions> Function() calculation, {
    Duration? ttl,
  }) async {
    // RE-ENABLED CACHING FOR PRODUCTION PERFORMANCE
    return await memoize(
      key,
      calculation,
      ttl: ttl ?? _shortTTL, // Planetary positions change frequently (1 hour)
    );
  }

  /// Memoize nakshatra calculations
  Future<NakshatraData> memoizeNakshatra(
    String key,
    Future<NakshatraData> Function() calculation, {
    Duration? ttl,
  }) async {
    return await memoize(
      key,
      calculation,
      ttl: ttl ?? _defaultTTL,
    );
  }

  /// Memoize dasha calculations
  Future<DashaData> memoizeDasha(
    String key,
    Future<DashaData> Function() calculation, {
    Duration? ttl,
  }) async {
    return await memoize(
      key,
      calculation,
      ttl: ttl ?? _longTTL, // Dasha periods are long-term
    );
  }

  /// Memoize detailed matching calculations
  Future<DetailedMatchingResult> memoizeDetailedMatching(
    String key,
    Future<DetailedMatchingResult> Function() calculation, {
    Duration? ttl,
  }) async {
    return await memoize(
      key,
      calculation,
      ttl: ttl ?? _defaultTTL,
      isPartnerData: true,
    );
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Check if cache entry is valid
  bool _isValidCache(String key, Duration ttl) {
    if (!_memoryCache.containsKey(key)) {
      return false;
    }

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) {
      return false;
    }

    final age = DateTime.now().difference(timestamp);
    return age < ttl;
  }

  /// Store calculation result in cache
  void _storeResult(String key, dynamic result, Duration ttl) {
    // Intelligent memory pressure handling
    if (_memoryCache.length >= _maxCacheSize * 0.8) {
      // Evict 20% of cache when 80% full (proactive memory management)
      _evictLeastRecentlyUsed(evictionPercentage: 0.2);
    } else if (_memoryCache.length >= _maxCacheSize) {
      // Emergency eviction when cache is full
      _evictLeastRecentlyUsed(evictionPercentage: 0.3);
    }

    _memoryCache[key] = result;
    _cacheTimestamps[key] = DateTime.now();
    _updateAccessInfo(key);

    AstrologyUtils.logDebug(
        'Stored result in cache: $key (Cache size: ${_memoryCache.length}/$_maxCacheSize)');
  }

  /// Update access information for LRU eviction
  void _updateAccessInfo(String key) {
    _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;

    // Update access order for LRU
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// Evict least recently used entries with intelligent memory management
  void _evictLeastRecentlyUsed({double evictionPercentage = 0.1}) {
    if (_accessOrder.isEmpty) return;

    final entriesToEvict = (_accessOrder.length * evictionPercentage).ceil();
    final entriesEvicted = <String>[];

    for (int i = 0; i < entriesToEvict && _accessOrder.isNotEmpty; i++) {
      final keyToEvict = _accessOrder.removeFirst();
      _memoryCache.remove(keyToEvict);
      _cacheTimestamps.remove(keyToEvict);
      _accessCounts.remove(keyToEvict);
      entriesEvicted.add(keyToEvict);
      _evictionCount++;
    }

    AstrologyUtils.logDebug(
        'Evicted ${entriesEvicted.length} cache entries: ${entriesEvicted.join(', ')}');
  }

  /// Get effective TTL based on data type
  Duration _getEffectiveTTL(bool isUserData, bool isPartnerData) {
    if (isUserData) return _longTTL;
    if (isPartnerData) return _defaultTTL;
    return _shortTTL;
  }

  /// Check if dependencies have changed
  bool _hasDependencyChanged(String key, List<String> dependencies) {
    final keyTimestamp = _cacheTimestamps[key];
    if (keyTimestamp == null) return true;

    for (final dependency in dependencies) {
      final depTimestamp = _cacheTimestamps[dependency];
      if (depTimestamp != null && depTimestamp.isAfter(keyTimestamp)) {
        return true;
      }
    }

    return false;
  }

  /// Invalidate a specific cache key
  void _invalidateKey(String key) {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    _accessCounts.remove(key);
    _accessOrder.remove(key);

    AstrologyUtils.logDebug('Invalidated cache key: $key');
  }

  // ============================================================================
  // PUBLIC CACHE MANAGEMENT
  // ============================================================================

  /// Clear all cache entries
  void clearCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _accessCounts.clear();
    _accessOrder.clear();

    AstrologyUtils.logInfo('Calculation memoizer cache cleared');
  }

  /// Clear a specific cache entry
  void clearCacheEntry(String key) {
    _invalidateKey(key);
    AstrologyUtils.logInfo('Cleared cache entry: $key');
  }

  /// Clear cache entries by pattern
  void clearCacheByPattern(String pattern) {
    final keysToRemove = _memoryCache.keys.where((key) => key.contains(pattern)).toList();

    for (final key in keysToRemove) {
      _invalidateKey(key);
    }

    AstrologyUtils.logInfo('Cleared cache entries matching pattern: $pattern');
  }

  /// Clear expired cache entries
  void clearExpiredEntries() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      // Check if entry is expired (using default TTL as reference)
      final age = now.difference(timestamp);
      if (age > _defaultTTL) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _invalidateKey(key);
    }

    AstrologyUtils.logInfo('Cleared ${keysToRemove.length} expired cache entries');
  }

  /// Preload cache with common calculations
  Future<void> preloadCache({
    required List<Map<String, dynamic>> preloadData,
    required Future<dynamic> Function(Map<String, dynamic>) calculationFunction,
  }) async {
    AstrologyUtils.logInfo('Preloading cache with ${preloadData.length} entries');

    final futures = preloadData.map((data) async {
      final key = data['key'] as String;
      final result = await calculationFunction(data);
      _storeResult(key, result, _defaultTTL);
    }).toList();

    await Future.wait(futures);

    AstrologyUtils.logInfo('Cache preloading completed');
  }

  // ============================================================================
  // STATISTICS AND MONITORING
  // ============================================================================

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final totalRequests = _hitCount + _missCount;
    final hitRate = totalRequests > 0 ? (_hitCount / totalRequests) * 100 : 0.0;

    return {
      'cacheSize': _memoryCache.length,
      'maxCacheSize': _maxCacheSize,
      'hitCount': _hitCount,
      'missCount': _missCount,
      'hitRate': hitRate,
      'evictionCount': _evictionCount,
      'mostAccessedKeys': _getMostAccessedKeys(10),
      'oldestEntry': _getOldestEntry(),
      'newestEntry': _getNewestEntry(),
    };
  }

  /// Get most accessed cache keys
  List<Map<String, dynamic>> _getMostAccessedKeys(int limit) {
    final sortedKeys = _accessCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedKeys
        .take(limit)
        .map((entry) => {
              'key': entry.key,
              'accessCount': entry.value,
              'timestamp': _cacheTimestamps[entry.key],
            })
        .toList();
  }

  /// Get oldest cache entry
  Map<String, dynamic>? _getOldestEntry() {
    if (_cacheTimestamps.isEmpty) return null;

    final oldestEntry =
        _cacheTimestamps.entries.reduce((a, b) => a.value.isBefore(b.value) ? a : b);

    return {
      'key': oldestEntry.key,
      'timestamp': oldestEntry.value,
      'age': DateTime.now().difference(oldestEntry.value),
    };
  }

  /// Get newest cache entry
  Map<String, dynamic>? _getNewestEntry() {
    if (_cacheTimestamps.isEmpty) return null;

    final newestEntry = _cacheTimestamps.entries.reduce((a, b) => a.value.isAfter(b.value) ? a : b);

    return {
      'key': newestEntry.key,
      'timestamp': newestEntry.value,
      'age': DateTime.now().difference(newestEntry.value),
    };
  }

  /// Get cache health metrics
  Map<String, dynamic> getCacheHealth() {
    final stats = getCacheStats();
    final hitRate = stats['hitRate'] as double;

    String healthStatus;
    if (hitRate >= 80) {
      healthStatus = 'Excellent';
    } else if (hitRate >= 60) {
      healthStatus = 'Good';
    } else if (hitRate >= 40) {
      healthStatus = 'Fair';
    } else {
      healthStatus = 'Poor';
    }

    return {
      'healthStatus': healthStatus,
      'hitRate': hitRate,
      'cacheUtilization': (_memoryCache.length / _maxCacheSize) * 100,
      'recommendations': _getHealthRecommendations(hitRate),
    };
  }

  /// Get health recommendations
  List<String> _getHealthRecommendations(double hitRate) {
    final recommendations = <String>[];

    if (hitRate < 40) {
      recommendations.add('Consider increasing cache size or TTL');
      recommendations.add('Review cache key generation strategy');
    }

    if (_memoryCache.length >= _maxCacheSize * 0.9) {
      recommendations.add('Cache is nearly full, consider increasing max size');
    }

    if (_evictionCount > _hitCount) {
      recommendations.add('High eviction rate, consider optimizing cache strategy');
    }

    return recommendations;
  }

  /// Reset statistics
  void resetStats() {
    _hitCount = 0;
    _missCount = 0;
    _evictionCount = 0;

    AstrologyUtils.logInfo('Cache statistics reset');
  }

  /// Dispose of all resources for proper memory management
  void dispose() {
    clearCache();
    resetStats();
    AstrologyUtils.logInfo('CalculationMemoizer disposed and memory cleaned up');
  }
}
