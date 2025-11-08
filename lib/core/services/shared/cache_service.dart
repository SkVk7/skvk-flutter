/// Cache Service
///
/// Smart in-memory cache with LRU eviction and threshold limits.
/// Supports different cache pools for different data types.
library;

/// Cache entry with access tracking for LRU
class _CacheEntry {
  final dynamic data;
  final DateTime expiryTime;
  final DateTime lastAccessed;
  final String cacheType;

  _CacheEntry(this.data, this.expiryTime, this.lastAccessed, this.cacheType);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// Cache type constants
class CacheType {
  static const String userBirthData =
      'user_birth_data'; // Full birth chart - cached for years
  static const String minimalBirthData =
      'minimal_birth_data'; // For compatibility - 30 days, limited entries
  static const String compatibility =
      'compatibility'; // Compatibility results - 30 days, limited entries
  static const String predictions = 'predictions'; // Time-based predictions
  static const String calendar = 'calendar'; // Calendar data
}

/// Cache Service
///
/// Provides smart caching with:
/// - LRU (Least Recently Used) eviction
/// - Threshold limits for compatibility matching
/// - Different TTLs for different data types
/// - Priority-based caching (user data > compatibility > predictions)
class CacheService {
  static CacheService? _instance;
  final Map<String, _CacheEntry> _cache = {};

  // Cache thresholds
  static const int maxMinimalBirthDataEntries =
      20; // Max cached groom/bride combinations
  static const int maxCompatibilityEntries =
      30; // Max cached compatibility results
  static const int maxPredictionEntries = 50; // Max cached predictions

  CacheService._();

  /// Get singleton instance
  static CacheService get instance {
    _instance ??= CacheService._();
    return _instance!;
  }

  /// Get cached data (updates last accessed time)
  Map<String, dynamic>? get(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      if (entry != null) {
        _cache.remove(key);
      }
      return null;
    }

    // Update last accessed time (LRU)
    _cache[key] = _CacheEntry(
      entry.data,
      entry.expiryTime,
      DateTime.now(),
      entry.cacheType,
    );

    return entry.data as Map<String, dynamic>?;
  }

  /// Set cached data with smart management
  void set(
    String key,
    Map<String, dynamic> data, {
    required Duration duration,
    String cacheType = CacheType.predictions,
  }) {
    // Remove expired entries first
    _clearExpiredEntries();

    // Check threshold limits for specific cache types
    if (cacheType == CacheType.minimalBirthData) {
      _enforceThreshold(
        cacheType,
        maxMinimalBirthDataEntries,
        key,
        data,
        duration,
      );
      return;
    } else if (cacheType == CacheType.compatibility) {
      _enforceThreshold(
        cacheType,
        maxCompatibilityEntries,
        key,
        data,
        duration,
      );
      return;
    } else if (cacheType == CacheType.predictions) {
      _enforceThreshold(
        cacheType,
        maxPredictionEntries,
        key,
        data,
        duration,
      );
      return;
    }

    // For user birth data and calendar - no threshold, cache indefinitely until expiry
    final expiryTime = DateTime.now().add(duration);
    _cache[key] = _CacheEntry(data, expiryTime, DateTime.now(), cacheType);
  }

  /// Enforce threshold limits using LRU eviction
  void _enforceThreshold(
    String cacheType,
    int maxEntries,
    String newKey,
    Map<String, dynamic> newData,
    Duration duration,
  ) {
    // Get all entries of this cache type
    final entriesOfType = _cache.entries
        .where((entry) => entry.value.cacheType == cacheType)
        .toList();

    // If under threshold, just add the new entry
    if (entriesOfType.length < maxEntries) {
      final expiryTime = DateTime.now().add(duration);
      _cache[newKey] = _CacheEntry(
        newData,
        expiryTime,
        DateTime.now(),
        cacheType,
      );
      return;
    }

    // At threshold - use LRU eviction
    // Sort by last accessed time (oldest first)
    entriesOfType
        .sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

    // Remove the oldest (least recently used) entry
    final oldestKey = entriesOfType.first.key;
    _cache.remove(oldestKey);

    // Add new entry
    final expiryTime = DateTime.now().add(duration);
    _cache[newKey] = _CacheEntry(
      newData,
      expiryTime,
      DateTime.now(),
      cacheType,
    );
  }

  /// Clear expired entries
  void clearExpired() {
    _clearExpiredEntries();
  }

  void _clearExpiredEntries() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Clear cache by type
  void clearByType(String cacheType) {
    _cache.removeWhere((key, entry) => entry.cacheType == cacheType);
  }

  /// Remove specific key from cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Get cache size
  int get size => _cache.length;

  /// Get cache size by type
  int getSizeByType(String cacheType) {
    return _cache.values.where((entry) => entry.cacheType == cacheType).length;
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'totalSize': size,
      'userBirthData': getSizeByType(CacheType.userBirthData),
      'minimalBirthData': getSizeByType(CacheType.minimalBirthData),
      'compatibility': getSizeByType(CacheType.compatibility),
      'predictions': getSizeByType(CacheType.predictions),
      'calendar': getSizeByType(CacheType.calendar),
    };
  }
}
