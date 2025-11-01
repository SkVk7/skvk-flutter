/// Business Logger Adapter
///
/// Adapter for business logging with 100% accuracy requirements.
/// No fallback methods - only genuine Swiss Ephemeris precision.
library;

import '../interfaces/astrology_logger_interface.dart';

/// Business logger adapter with no compromises in accuracy
class BusinessLoggerAdapter implements AstrologyLoggerInterface {
  final AstrologyLoggerInterface _businessLogger;

  BusinessLoggerAdapter(this._businessLogger);

  @override
  Future<void> debug(String message, {String? source, Map<String, dynamic>? metadata}) async {
    try {
      await _businessLogger.debug(message, source: source, metadata: metadata);
    } catch (e) {
      // Use proper error handling instead of fallback
      throw Exception('Business logger failed: $e');
    }
  }

  @override
  Future<void> info(String message, {String? source, Map<String, dynamic>? metadata}) async {
    try {
      await _businessLogger.info(message, source: source, metadata: metadata);
    } catch (e) {
      // Use proper error handling instead of fallback
      throw Exception('Business logger failed: $e');
    }
  }

  @override
  Future<void> warning(String message,
      {String? source,
      Map<String, dynamic>? metadata,
      dynamic error,
      StackTrace? stackTrace}) async {
    try {
      await _businessLogger.warning(message, source: source, metadata: metadata);
    } catch (e) {
      // Use proper error handling instead of fallback
      throw Exception('Business logger failed: $e');
    }
  }

  @override
  Future<void> error(String message,
      {String? source,
      Map<String, dynamic>? metadata,
      dynamic error,
      StackTrace? stackTrace}) async {
    try {
      await _businessLogger.error(message,
          source: source, metadata: metadata, error: error, stackTrace: stackTrace);
    } catch (e) {
      // Use proper error handling instead of fallback
      throw Exception('Business logger failed: $e');
    }
  }

  @override
  Future<void> critical(String message,
      {String? source,
      Map<String, dynamic>? metadata,
      dynamic error,
      StackTrace? stackTrace}) async {
    try {
      await _businessLogger.critical(message,
          source: source, metadata: metadata, error: error, stackTrace: stackTrace);
    } catch (e) {
      // Use proper error handling instead of fallback
      throw Exception('Business logger failed: $e');
    }
  }

  @override
  Future<void> performance(String operation, Duration duration,
      {String? source, Map<String, dynamic>? additionalMetrics}) async {
    try {
      await _businessLogger.performance(operation, duration,
          source: source, additionalMetrics: additionalMetrics);
    } catch (e) {
      // Use proper error handling instead of fallback
      throw Exception('Business logger failed: $e');
    }
  }

  @override
  Future<T?> executeWithLogging<T>(
    Future<T> Function() function, {
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
    bool logSuccess = false,
  }) async {
    try {
      return await _businessLogger.executeWithLogging(function,
          source: source, operation: operation, metadata: metadata, logSuccess: logSuccess);
    } catch (e) {
      // Use proper error handling instead of fallback
      throw Exception('Business logger failed: $e');
    }
  }

  @override
  T? executeSyncWithLogging<T>(
    T Function() function, {
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
    bool logSuccess = false,
  }) {
    try {
      return _businessLogger.executeSyncWithLogging(function,
          source: source, operation: operation, metadata: metadata, logSuccess: logSuccess);
    } catch (e) {
      // Use proper error handling instead of fallback
      throw Exception('Business logger failed: $e');
    }
  }
}
