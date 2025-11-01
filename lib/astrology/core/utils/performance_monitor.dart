/// Performance Monitor for Astrology Calculations
///
/// This class provides comprehensive performance monitoring and optimization
/// for astrological calculations to ensure maximum efficiency.
library;

import 'dart:async';
import 'dart:collection';
import 'astrology_utils.dart';

/// Performance monitoring and optimization system
class PerformanceMonitor {
  static PerformanceMonitor? _instance;

  // Performance metrics
  final Map<String, List<Duration>> _executionTimes = {};
  final Map<String, int> _executionCounts = {};
  final Map<String, DateTime> _lastExecution = {};
  final Queue<String> _recentOperations = Queue<String>();

  // Configuration
  static const int _maxRecentOperations = 100;
  static const Duration _slowOperationThreshold = Duration(milliseconds: 100);
  static const Duration _verySlowOperationThreshold = Duration(milliseconds: 500);

  // Statistics
  int _totalOperations = 0;
  Duration _totalExecutionTime = Duration.zero;

  // Private constructor for singleton
  PerformanceMonitor._();

  /// Get singleton instance
  static PerformanceMonitor get instance {
    _instance ??= PerformanceMonitor._();
    return _instance!;
  }

  // ============================================================================
  // PERFORMANCE MONITORING
  // ============================================================================

  /// Monitor execution time of an operation
  Future<T> monitorOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      _recordExecution(operationName, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordExecution(operationName, stopwatch.elapsed, isError: true);
      rethrow;
    }
  }

  /// Monitor synchronous operation
  T monitorSyncOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      _recordExecution(operationName, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordExecution(operationName, stopwatch.elapsed, isError: true);
      rethrow;
    }
  }

  /// Record execution time for an operation
  void _recordExecution(String operationName, Duration executionTime, {bool isError = false}) {
    // Update execution times
    _executionTimes.putIfAbsent(operationName, () => []);
    _executionTimes[operationName]!.add(executionTime);

    // Keep only last 50 executions for memory efficiency
    if (_executionTimes[operationName]!.length > 50) {
      _executionTimes[operationName]!.removeAt(0);
    }

    // Update execution counts
    _executionCounts[operationName] = (_executionCounts[operationName] ?? 0) + 1;
    _lastExecution[operationName] = DateTime.now();

    // Update recent operations
    _recentOperations.add(operationName);
    if (_recentOperations.length > _maxRecentOperations) {
      _recentOperations.removeFirst();
    }

    // Update global statistics
    _totalOperations++;
    _totalExecutionTime += executionTime;

    // Log slow operations
    if (executionTime > _verySlowOperationThreshold) {
      AstrologyUtils.logWarning(
          'Very slow operation: $operationName took ${executionTime.inMilliseconds}ms');
    } else if (executionTime > _slowOperationThreshold) {
      AstrologyUtils.logInfo(
          'Slow operation: $operationName took ${executionTime.inMilliseconds}ms');
    }

    // Log errors
    if (isError) {
      AstrologyUtils.logError(
          'Operation failed: $operationName after ${executionTime.inMilliseconds}ms');
    }
  }

  // ============================================================================
  // PERFORMANCE ANALYSIS
  // ============================================================================

  /// Get performance statistics for an operation
  Map<String, dynamic> getOperationStats(String operationName) {
    final times = _executionTimes[operationName];
    if (times == null || times.isEmpty) {
      return {
        'operation': operationName,
        'count': 0,
        'averageTime': 0.0,
        'minTime': 0.0,
        'maxTime': 0.0,
        'totalTime': 0.0,
        'lastExecution': null,
      };
    }

    final totalTime = times.fold<Duration>(Duration.zero, (sum, time) => sum + time);
    final averageTime = totalTime.inMicroseconds / times.length / 1000.0; // Convert to milliseconds
    final minTime = times.map((t) => t.inMilliseconds).reduce((a, b) => a < b ? a : b);
    final maxTime = times.map((t) => t.inMilliseconds).reduce((a, b) => a > b ? a : b);

    return {
      'operation': operationName,
      'count': times.length,
      'averageTime': averageTime,
      'minTime': minTime.toDouble(),
      'maxTime': maxTime.toDouble(),
      'totalTime': totalTime.inMilliseconds.toDouble(),
      'lastExecution': _lastExecution[operationName],
    };
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final operationStats = <String, Map<String, dynamic>>{};

    for (final operationName in _executionTimes.keys) {
      operationStats[operationName] = getOperationStats(operationName);
    }

    // Find slowest operations
    final slowestOperations = operationStats.entries.toList()
      ..sort((a, b) => b.value['averageTime'].compareTo(a.value['averageTime']));

    // Find most frequent operations
    final mostFrequentOperations = operationStats.entries.toList()
      ..sort((a, b) => b.value['count'].compareTo(a.value['count']));

    return {
      'totalOperations': _totalOperations,
      'totalExecutionTime': _totalExecutionTime.inMilliseconds,
      'averageOperationTime':
          _totalOperations > 0 ? _totalExecutionTime.inMilliseconds / _totalOperations : 0.0,
      'operationCount': operationStats.length,
      'slowestOperations': slowestOperations.take(5).map((e) => e.value).toList(),
      'mostFrequentOperations': mostFrequentOperations.take(5).map((e) => e.value).toList(),
      'recentOperations': _recentOperations.toList(),
    };
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    final summary = getPerformanceSummary();

    // Check for slow operations
    final slowestOps = summary['slowestOperations'] as List;
    for (final op in slowestOps) {
      final avgTime = op['averageTime'] as double;
      if (avgTime > 1000) {
        // More than 1 second
        recommendations
            .add('Consider optimizing ${op['operation']} (avg: ${avgTime.toStringAsFixed(1)}ms)');
      }
    }

    // Check for frequent operations
    final frequentOps = summary['mostFrequentOperations'] as List;
    for (final op in frequentOps) {
      final count = op['count'] as int;
      if (count > 100) {
        recommendations.add('Consider caching ${op['operation']} (called $count times)');
      }
    }

    // Check overall performance
    final avgTime = summary['averageOperationTime'] as double;
    if (avgTime > 500) {
      recommendations.add(
          'Overall performance is slow (avg: ${avgTime.toStringAsFixed(1)}ms). Consider optimization.');
    }

    return recommendations;
  }

  // ============================================================================
  // PERFORMANCE OPTIMIZATION
  // ============================================================================

  /// Optimize cache based on performance data
  Map<String, dynamic> getCacheOptimizationRecommendations() {
    final recommendations = <String, dynamic>{};
    final summary = getPerformanceSummary();

    // Analyze operation patterns
    final frequentOps = summary['mostFrequentOperations'] as List;
    final slowOps = summary['slowestOperations'] as List;

    // Recommend cache TTL adjustments
    final cacheRecommendations = <String>[];

    for (final op in frequentOps) {
      final operationName = op['operation'] as String;
      final count = op['count'] as int;

      if (count > 50) {
        if (operationName.contains('birth') || operationName.contains('fixed')) {
          cacheRecommendations.add('Increase cache TTL for $operationName (frequent fixed data)');
        } else if (operationName.contains('planetary') || operationName.contains('current')) {
          cacheRecommendations.add('Decrease cache TTL for $operationName (dynamic data)');
        }
      }
    }

    recommendations['cacheRecommendations'] = cacheRecommendations;
    recommendations['frequentOperations'] = frequentOps;
    recommendations['slowOperations'] = slowOps;

    return recommendations;
  }

  // ============================================================================
  // CLEANUP AND RESET
  // ============================================================================

  /// Clear all performance data
  void clearPerformanceData() {
    _executionTimes.clear();
    _executionCounts.clear();
    _lastExecution.clear();
    _recentOperations.clear();
    _totalOperations = 0;
    _totalExecutionTime = Duration.zero;

    AstrologyUtils.logInfo('Performance monitoring data cleared');
  }

  /// Reset performance data for a specific operation
  void resetOperationData(String operationName) {
    _executionTimes.remove(operationName);
    _executionCounts.remove(operationName);
    _lastExecution.remove(operationName);

    AstrologyUtils.logInfo('Performance data reset for operation: $operationName');
  }

  /// Dispose of all resources for proper memory management
  void dispose() {
    clearPerformanceData();
    AstrologyUtils.logInfo('PerformanceMonitor disposed and memory cleaned up');
  }
}
