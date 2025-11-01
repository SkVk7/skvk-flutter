/// Centralized Logging System
///
/// Provides a unified logging interface for the application
library;

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging system for the application
class AppLogger {
  static const String _tag = 'SKVK_APP';

  /// Log debug messages (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 800, // Debug level
      );
    }
  }

  /// Log info messages
  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 700, // Info level
    );
  }

  /// Log warning messages
  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
    );
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log performance metrics
  static void performance(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: '${tag ?? _tag}_PERF',
        level: 600, // Performance level
      );
    }
  }
}
