/// Core exceptions for the application
///
/// This file defines custom exceptions that can be thrown
/// and converted to failures in the presentation layer
library;

/// Base exception class
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.details,
  });
  final String message;
  final String? code;
  final dynamic details;

  @override
  String toString() => 'AppException: $message';
}

/// Server exception
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Calculation exception
class CalculationException extends AppException {
  const CalculationException({
    required super.message,
    super.code,
    super.details,
  });
}
