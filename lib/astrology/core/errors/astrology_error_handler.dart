/// Comprehensive Error Handler for Astrology Library
///
/// This class provides robust error handling, recovery mechanisms,
/// and detailed error reporting for all astrological calculations.
library;

import 'dart:async';
import 'dart:developer' as developer;
import '../utils/astrology_utils.dart';

/// Comprehensive error handling system for astrology calculations
class AstrologyErrorHandler {
  static AstrologyErrorHandler? _instance;

  // Error tracking
  final List<AstrologyError> _errorHistory = [];
  final Map<String, int> _errorCounts = {};
  final Map<String, DateTime> _lastErrorTime = {};

  // Configuration
  static const int _maxErrorHistory = 1000;

  // Private constructor for singleton
  AstrologyErrorHandler._();

  /// Get singleton instance
  static AstrologyErrorHandler get instance {
    _instance ??= AstrologyErrorHandler._();
    return _instance!;
  }

  // ============================================================================
  // ERROR HANDLING METHODS
  // ============================================================================

  /// Handle and log an error with context
  Future<T> handleError<T>(
    String operation,
    Future<T> Function() operationFunction, {
    String? context,
    Map<String, dynamic>? additionalData,
    bool retryOnFailure = false,
    int maxRetries = 3,
  }) async {
    try {
      return await operationFunction();
    } catch (e, stackTrace) {
      final error = AstrologyError(
        type: _classifyError(e),
        message: e.toString(),
        operation: operation,
        context: context,
        timestamp: DateTime.now(),
        stackTrace: stackTrace.toString(),
        additionalData: additionalData ?? {},
      );

      _recordError(error);
      _logError(error);

      if (retryOnFailure && maxRetries > 0) {
        AstrologyUtils.logInfo('Retrying operation: $operation ($maxRetries retries left)');
        await Future.delayed(const Duration(milliseconds: 100));
        return await handleError(
          operation,
          operationFunction,
          context: context,
          additionalData: additionalData,
          retryOnFailure: retryOnFailure,
          maxRetries: maxRetries - 1,
        );
      }

      throw _createUserFriendlyError(error);
    }
  }

  /// Handle synchronous error
  T handleSyncError<T>(
    String operation,
    T Function() operationFunction, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      return operationFunction();
    } catch (e, stackTrace) {
      final error = AstrologyError(
        type: _classifyError(e),
        message: e.toString(),
        operation: operation,
        context: context,
        timestamp: DateTime.now(),
        stackTrace: stackTrace.toString(),
        additionalData: additionalData ?? {},
      );

      _recordError(error);
      _logError(error);

      throw _createUserFriendlyError(error);
    }
  }

  /// Classify error type
  AstrologyErrorType _classifyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return AstrologyErrorType.validation;
    } else if (errorString.contains('calculation') || errorString.contains('compute')) {
      return AstrologyErrorType.calculation;
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return AstrologyErrorType.network;
    } else if (errorString.contains('cache') || errorString.contains('memory')) {
      return AstrologyErrorType.cache;
    } else if (errorString.contains('timeout')) {
      return AstrologyErrorType.timeout;
    } else if (errorString.contains('permission') || errorString.contains('access')) {
      return AstrologyErrorType.permission;
    } else if (errorString.contains('format') || errorString.contains('parse')) {
      return AstrologyErrorType.format;
    } else {
      return AstrologyErrorType.unknown;
    }
  }

  /// Record error for analysis
  void _recordError(AstrologyError error) {
    // Add to history
    _errorHistory.add(error);
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }

    // Update error counts
    final errorKey = '${error.operation}:${error.type}';
    _errorCounts[errorKey] = (_errorCounts[errorKey] ?? 0) + 1;
    _lastErrorTime[errorKey] = error.timestamp;
  }

  /// Log error with appropriate level
  void _logError(AstrologyError error) {
    final logMessage = 'Error in ${error.operation}: ${error.message}';

    switch (error.type) {
      case AstrologyErrorType.validation:
        AstrologyUtils.logWarning(logMessage);
        break;
      case AstrologyErrorType.calculation:
        AstrologyUtils.logError(logMessage);
        break;
      case AstrologyErrorType.network:
        AstrologyUtils.logError(logMessage);
        break;
      case AstrologyErrorType.cache:
        AstrologyUtils.logWarning(logMessage);
        break;
      case AstrologyErrorType.timeout:
        AstrologyUtils.logError(logMessage);
        break;
      case AstrologyErrorType.permission:
        AstrologyUtils.logError(logMessage);
        break;
      case AstrologyErrorType.format:
        AstrologyUtils.logWarning(logMessage);
        break;
      case AstrologyErrorType.unknown:
        AstrologyUtils.logError(logMessage);
        break;
    }

    // Log to developer console for debugging
    developer.log(
      logMessage,
      name: 'AstrologyError',
      error: error,
      stackTrace: StackTrace.fromString(error.stackTrace),
    );
  }

  /// Create user-friendly error message
  Exception _createUserFriendlyError(AstrologyError error) {
    String userMessage;

    switch (error.type) {
      case AstrologyErrorType.validation:
        userMessage = 'Invalid input provided. Please check your data and try again.';
        break;
      case AstrologyErrorType.calculation:
        userMessage =
            'Calculation failed. Please try again or contact support if the issue persists.';
        break;
      case AstrologyErrorType.network:
        userMessage = 'Network error occurred. Please check your connection and try again.';
        break;
      case AstrologyErrorType.cache:
        userMessage = 'Temporary data issue. Please try again.';
        break;
      case AstrologyErrorType.timeout:
        userMessage = 'Operation timed out. Please try again.';
        break;
      case AstrologyErrorType.permission:
        userMessage = 'Access denied. Please check your permissions.';
        break;
      case AstrologyErrorType.format:
        userMessage = 'Data format error. Please check your input format.';
        break;
      case AstrologyErrorType.unknown:
        userMessage = 'An unexpected error occurred. Please try again.';
        break;
    }

    return AstrologyException(userMessage, error);
  }

  // ============================================================================
  // ERROR ANALYSIS AND REPORTING
  // ============================================================================

  /// Get error statistics
  Map<String, dynamic> getErrorStatistics() {
    final totalErrors = _errorHistory.length;
    final errorTypes = <AstrologyErrorType, int>{};
    final operationErrors = <String, int>{};

    for (final error in _errorHistory) {
      errorTypes[error.type] = (errorTypes[error.type] ?? 0) + 1;
      operationErrors[error.operation] = (operationErrors[error.operation] ?? 0) + 1;
    }

    return {
      'totalErrors': totalErrors,
      'errorTypes': errorTypes.map((k, v) => MapEntry(k.name, v)),
      'operationErrors': operationErrors,
      'recentErrors': _errorHistory.take(10).map((e) => e.toMap()).toList(),
      'errorRate': _calculateErrorRate(),
    };
  }

  /// Calculate error rate (errors per hour)
  double _calculateErrorRate() {
    if (_errorHistory.isEmpty) return 0.0;

    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    final recentErrors = _errorHistory.where((e) => e.timestamp.isAfter(oneHourAgo)).length;
    return recentErrors.toDouble();
  }

  /// Get error trends
  Map<String, dynamic> getErrorTrends() {
    final trends = <String, dynamic>{};

    // Analyze error frequency by hour
    final hourlyErrors = <int, int>{};
    for (final error in _errorHistory) {
      final hour = error.timestamp.hour;
      hourlyErrors[hour] = (hourlyErrors[hour] ?? 0) + 1;
    }

    trends['hourlyDistribution'] = hourlyErrors;

    // Find most problematic operations
    final operationCounts = <String, int>{};
    for (final error in _errorHistory) {
      operationCounts[error.operation] = (operationCounts[error.operation] ?? 0) + 1;
    }

    final sortedOperations = operationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    trends['mostProblematicOperations'] = sortedOperations
        .take(5)
        .map((e) => {
              'operation': e.key,
              'errorCount': e.value,
            })
        .toList();

    return trends;
  }

  /// Get error recovery recommendations
  List<String> getErrorRecoveryRecommendations() {
    final recommendations = <String>[];
    final stats = getErrorStatistics();

    // Check for high error rates
    final errorRate = stats['errorRate'] as double;
    if (errorRate > 10) {
      recommendations.add(
          'High error rate detected (${errorRate.toStringAsFixed(1)} errors/hour). Consider system maintenance.');
    }

    // Check for specific error patterns
    final errorTypes = stats['errorTypes'] as Map<String, int>;
    for (final entry in errorTypes.entries) {
      final count = entry.value;
      if (count > 50) {
        switch (entry.key) {
          case 'validation':
            recommendations
                .add('High validation error count ($count). Consider improving input validation.');
            break;
          case 'calculation':
            recommendations.add(
                'High calculation error count ($count). Consider reviewing calculation logic.');
            break;
          case 'cache':
            recommendations
                .add('High cache error count ($count). Consider optimizing cache strategy.');
            break;
          case 'network':
            recommendations
                .add('High network error count ($count). Consider improving network handling.');
            break;
        }
      }
    }

    return recommendations;
  }

  /// Clear error data for proper memory management
  void clearErrorData() {
    _errorHistory.clear();
    _errorCounts.clear();
    _lastErrorTime.clear();
    AstrologyUtils.logInfo('Error handler data cleared');
  }

  /// Dispose of all resources for proper memory management
  void dispose() {
    clearErrorData();
    AstrologyUtils.logInfo('AstrologyErrorHandler disposed and memory cleaned up');
  }

  // ============================================================================
  // ERROR RECOVERY
  // ============================================================================

  /// Attempt to recover from error
  Future<T?> attemptRecovery<T>(
    String operation,
    Future<T> Function() operationFunction,
    AstrologyError error,
  ) async {
    try {
      switch (error.type) {
        case AstrologyErrorType.cache:
          // Clear cache and retry
          AstrologyUtils.logInfo('Attempting cache recovery for $operation');
          // Note: Cache clearing would be implemented here
          return await operationFunction();

        case AstrologyErrorType.network:
          // Wait and retry
          AstrologyUtils.logInfo('Attempting network recovery for $operation');
          await Future.delayed(const Duration(seconds: 2));
          return await operationFunction();

        case AstrologyErrorType.timeout:
          // Retry with longer timeout
          AstrologyUtils.logInfo('Attempting timeout recovery for $operation');
          return await operationFunction();

        default:
          return null; // No recovery available
      }
    } catch (e) {
      AstrologyUtils.logError('Recovery failed for $operation: $e');
      return null;
    }
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  /// Clear error history
  void clearErrorHistory() {
    _errorHistory.clear();
    _errorCounts.clear();
    _lastErrorTime.clear();

    AstrologyUtils.logInfo('Error history cleared');
  }

  /// Clear errors for specific operation
  void clearOperationErrors(String operation) {
    _errorHistory.removeWhere((e) => e.operation == operation);
    _errorCounts.removeWhere((key, value) => key.startsWith('$operation:'));
    _lastErrorTime.removeWhere((key, value) => key.startsWith('$operation:'));

    AstrologyUtils.logInfo('Error history cleared for operation: $operation');
  }
}

/// Astrology error types
enum AstrologyErrorType {
  validation,
  calculation,
  network,
  cache,
  timeout,
  permission,
  format,
  unknown,
}

/// Detailed error information
class AstrologyError {
  final AstrologyErrorType type;
  final String message;
  final String operation;
  final String? context;
  final DateTime timestamp;
  final String stackTrace;
  final Map<String, dynamic> additionalData;

  const AstrologyError({
    required this.type,
    required this.message,
    required this.operation,
    this.context,
    required this.timestamp,
    required this.stackTrace,
    required this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'message': message,
      'operation': operation,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace,
      'additionalData': additionalData,
    };
  }

  @override
  String toString() {
    return 'AstrologyError(type: ${type.name}, operation: $operation, message: $message)';
  }
}

/// User-friendly astrology exception
class AstrologyException implements Exception {
  final String message;
  final AstrologyError? originalError;

  const AstrologyException(this.message, [this.originalError]);

  @override
  String toString() => 'AstrologyException: $message';
}

/// Enhanced error recovery system
class ErrorRecoverySystem {
  static const int _maxRetryAttempts = 3;
  static const Duration _baseRetryDelay = Duration(milliseconds: 100);

  /// Attempt to recover from an error with exponential backoff
  static Future<T> recoverWithRetry<T>(
    Future<T> Function() operation,
    String operationName, {
    int maxAttempts = _maxRetryAttempts,
    Duration baseDelay = _baseRetryDelay,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts < maxAttempts) {
          final delay = Duration(
            milliseconds: baseDelay.inMilliseconds * (1 << (attempts - 1)),
          );

          AstrologyUtils.logWarning(
            'Operation $operationName failed (attempt $attempts/$maxAttempts), retrying in ${delay.inMilliseconds}ms: $e',
          );

          await Future.delayed(delay);
        }
      }
    }

    AstrologyUtils.logError(
      'Operation $operationName failed after $maxAttempts attempts: $lastException',
    );

    throw lastException!;
  }

  /// Validate and correct input data
  static Map<String, dynamic> validateAndCorrectInput(
    Map<String, dynamic> input,
    Map<String, dynamic> validationRules,
  ) {
    final correctedInput = Map<String, dynamic>.from(input);

    for (final entry in validationRules.entries) {
      final key = entry.key;
      final rules = entry.value as Map<String, dynamic>;

      if (correctedInput.containsKey(key)) {
        final value = correctedInput[key];
        final correctedValue = _applyValidationRules(value, rules);
        correctedInput[key] = correctedValue;
      }
    }

    return correctedInput;
  }

  /// Apply validation rules to a value
  static dynamic _applyValidationRules(dynamic value, Map<String, dynamic> rules) {
    // Type validation
    if (rules.containsKey('type')) {
      final expectedType = rules['type'] as String;
      value = _convertToType(value, expectedType);
    }

    // Range validation
    if (rules.containsKey('min') && rules.containsKey('max')) {
      final min = rules['min'] as num;
      final max = rules['max'] as num;
      if (value is num) {
        value = value.clamp(min, max);
      }
    }

    // Default value
    if (value == null && rules.containsKey('default')) {
      value = rules['default'];
    }

    return value;
  }

  /// Convert value to specified type
  static dynamic _convertToType(dynamic value, String type) {
    switch (type) {
      case 'int':
        return value is int ? value : int.tryParse(value.toString()) ?? 0;
      case 'double':
        return value is double ? value : double.tryParse(value.toString()) ?? 0.0;
      case 'string':
        return value.toString();
      case 'bool':
        return value is bool ? value : value.toString().toLowerCase() == 'true';
      default:
        return value;
    }
  }
}
