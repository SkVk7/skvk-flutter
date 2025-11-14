/// Core error handling for the application
///
/// This file defines the failure types and error handling patterns
/// following Clean Architecture principles
library;

import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
    this.details,
  });
  final String message;
  final String? code;
  final dynamic details;

  @override
  List<Object?> get props => [message, code, details];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Calculation-related failures
class CalculationFailure extends Failure {
  const CalculationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Data not found failures
class DataNotFoundFailure extends Failure {
  const DataNotFoundFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Data incomplete failures
class DataIncompleteFailure extends Failure {
  const DataIncompleteFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });
}
