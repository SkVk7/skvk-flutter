/// Astrology Logger Interface
///
/// This interface provides a decoupled logging mechanism for the astrology library.
/// It allows the business layer to inject its own logging implementation
/// while maintaining complete decoupling.
library;

/// Log levels for astrology library
enum AstrologyLogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Interface for astrology library logging
abstract class AstrologyLoggerInterface {
  /// Log a debug message
  Future<void> debug(String message, {String? source, Map<String, dynamic>? metadata});

  /// Log an info message
  Future<void> info(String message, {String? source, Map<String, dynamic>? metadata});

  /// Log a warning message
  Future<void> warning(String message, {String? source, Map<String, dynamic>? metadata});

  /// Log an error message
  Future<void> error(String message,
      {String? source, Map<String, dynamic>? metadata, dynamic error, StackTrace? stackTrace});

  /// Log a critical message
  Future<void> critical(String message,
      {String? source, Map<String, dynamic>? metadata, dynamic error, StackTrace? stackTrace});

  /// Log performance metrics
  Future<void> performance(String operation, Duration duration,
      {String? source, Map<String, dynamic>? additionalMetrics});

  /// Execute a function with automatic error logging
  Future<T?> executeWithLogging<T>(
    Future<T> Function() function, {
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
    bool logSuccess = false,
  });

  /// Execute a synchronous function with automatic error logging
  T? executeSyncWithLogging<T>(
    T Function() function, {
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
    bool logSuccess = false,
  });
}
