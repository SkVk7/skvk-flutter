/// Logging Helper
///
/// Provides convenient methods for logging throughout the application.
/// Automatically handles try-catch blocks and provides structured logging.
library;

import 'package:skvk_application/core/logging/app_logger.dart';

/// Helper class for easy logging integration
class LoggingHelper {
  static final AppLogger _logger = AppLogger();

  /// Log an error with automatic stack trace capture
  static Future<void> logError(
    String message, {
    String? source,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    final errorMetadata = <String, dynamic>{
      if (metadata != null) ...metadata,
      if (error != null) 'error': error.toString(),
    };

    await _logger.error(
      message,
      source: source,
      metadata: errorMetadata,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  /// Log a warning with context
  static Future<void> logWarning(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.warning(
      message,
      source: source,
      metadata: metadata,
      stackTrace: StackTrace.current,
    );
  }

  /// Log an info message
  static Future<void> logInfo(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.info(
      message,
      source: source,
      metadata: metadata,
    );
  }

  /// Log a debug message
  static Future<void> logDebug(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) async {
    await _logger.debug(
      message,
      source: source,
      metadata: metadata,
    );
  }

  /// Log a critical error
  static Future<void> logCritical(
    String message, {
    String? source,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    final errorMetadata = <String, dynamic>{
      if (metadata != null) ...metadata,
      if (error != null) 'error': error.toString(),
    };

    await _logger.critical(
      message,
      source: source,
      metadata: errorMetadata,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  /// Execute a function with automatic error logging
  static Future<T?> executeWithLogging<T>(
    Future<T> Function() function, {
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
    bool logSuccess = false,
  }) async {
    try {
      final result = await function();

      if (logSuccess) {
        await logInfo(
          'Operation completed successfully: $operation',
          source: source,
          metadata: metadata,
        );
      }

      return result;
    } on Exception catch (e, stackTrace) {
      await logError(
        'Operation failed: $operation',
        source: source,
        error: e,
        stackTrace: stackTrace,
        metadata: metadata,
      );
      return null;
    }
  }

  /// Execute a synchronous function with automatic error logging
  static T? executeSyncWithLogging<T>(
    T Function() function, {
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
    bool logSuccess = false,
  }) {
    try {
      final result = function();

      if (logSuccess) {
        logInfo(
          'Operation completed successfully: $operation',
          source: source,
          metadata: metadata,
        );
      }

      return result;
    } on Exception catch (e, stackTrace) {
      logError(
        'Operation failed: $operation',
        source: source,
        error: e,
        stackTrace: stackTrace,
        metadata: metadata,
      );
      return null;
    }
  }

  /// Log performance metrics
  static Future<void> logPerformance(
    String operation,
    Duration duration, {
    String? source,
    Map<String, dynamic>? additionalMetrics,
  }) async {
    final metrics = <String, dynamic>{
      'duration_ms': duration.inMilliseconds,
      'duration_seconds': duration.inSeconds,
      if (additionalMetrics != null) ...additionalMetrics,
    };

    await _logger.info(
      'Performance: $operation',
      source: source,
      metadata: metrics,
    );
  }

  /// Log user actions for analytics
  static Future<void> logUserAction(
    String action, {
    String? source,
    Map<String, dynamic>? context,
  }) async {
    await _logger.info(
      'User Action: $action',
      source: source,
      metadata: context,
    );
  }

  /// Log API calls
  static Future<void> logApiCall(
    String endpoint,
    String method, {
    String? source,
    int? statusCode,
    Duration? duration,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) async {
    final metadata = <String, dynamic>{
      'endpoint': endpoint,
      'method': method,
      if (statusCode != null) 'status_code': statusCode,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
      if (requestData != null) 'request_data': requestData,
      if (responseData != null) 'response_data': responseData,
    };

    final level = statusCode != null && statusCode >= 400
        ? LogLevel.error
        : LogLevel.info;

    await _logger.log(
      level,
      'API Call: $method $endpoint',
      source: source,
      metadata: metadata,
    );
  }

  /// Get logger instance for advanced usage
  static AppLogger get logger => _logger;
}
