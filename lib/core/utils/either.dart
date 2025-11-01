/// Either type for functional error handling
///
/// This provides a functional approach to error handling
/// where operations can return either a success value or a failure
library;

import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Type alias for Either with Failure on the left and T on the right
typedef Result<T> = Either<Failure, T>;

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Check if the result is a success
  bool get isSuccess => isRight();

  /// Check if the result is a failure
  bool get isFailure => isLeft();

  /// Get the success value or null
  T? get value => fold((l) => null, (r) => r);

  /// Get the failure or null
  Failure? get failure => fold((l) => l, (r) => null);

  /// Transform the success value
  Result<R> map<R>(R Function(T) transform) {
    return fold(
      (failure) => Left(failure),
      (value) => Right(transform(value)),
    );
  }

  /// Transform the failure
  Result<T> mapFailure(Failure Function(Failure) transform) {
    return fold(
      (failure) => Left(transform(failure)),
      (value) => Right(value),
    );
  }

  /// Execute a function based on the result
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return this.fold(onFailure, onSuccess);
  }
}

/// Helper functions for creating Results
class ResultHelper {
  /// Create a success result
  static Result<T> success<T>(T value) => Right(value);

  /// Create a failure result
  static Result<T> failure<T>(Failure failure) => Left(failure);

  /// Create a failure result from a message
  static Result<T> failureFromMessage<T>(String message) =>
      Left(UnexpectedFailure(message: message));

  /// Create a result from a function that might throw
  static Result<T> tryCatch<T>(T Function() computation) {
    try {
      return Right(computation());
    } catch (e) {
      return Left(UnexpectedFailure(
        message: e.toString(),
        details: e,
      ));
    }
  }

  /// Create a result from an async function that might throw
  static Future<Result<T>> tryCatchAsync<T>(Future<T> Function() computation) async {
    try {
      final result = await computation();
      return Right(result);
    } catch (e) {
      return Left(UnexpectedFailure(
        message: e.toString(),
        details: e,
      ));
    }
  }

  /// Check if result is successful
  static bool isSuccess<T>(Result<T> result) {
    return result.isRight();
  }

  /// Check if result is failure
  static bool isFailure<T>(Result<T> result) {
    return result.isLeft();
  }

  /// Get value from successful result
  static T? getValue<T>(Result<T> result) {
    return result.fold(
      (failure) => null,
      (value) => value,
    );
  }

  /// Get failure from failed result
  static Failure? getFailure<T>(Result<T> result) {
    return result.fold(
      (failure) => failure,
      (value) => null,
    );
  }

  /// Transform successful result
  static Result<R> map<T, R>(
    Result<T> result,
    R Function(T) transform,
  ) {
    return result.map(transform);
  }

  /// Transform failed result
  static Result<T> mapFailure<T>(
    Result<T> result,
    Failure Function(Failure) transform,
  ) {
    return result.leftMap(transform);
  }

  /// Chain operations on successful result
  static Result<R> flatMap<T, R>(
    Result<T> result,
    Result<R> Function(T) transform,
  ) {
    return result.flatMap(transform);
  }

  /// Handle both success and failure cases
  static R fold<T, R>(
    Result<T> result,
    R Function(Failure) onFailure,
    R Function(T) onSuccess,
  ) {
    return result.fold(onFailure, onSuccess);
  }

  /// Get value or throw exception
  static T getOrThrow<T>(Result<T> result) {
    return result.fold(
      (failure) => throw Exception('Result is failure: $failure'),
      (value) => value,
    );
  }

  /// Get value or return default
  static T getOrElse<T>(Result<T> result, T defaultValue) {
    return result.fold(
      (failure) => defaultValue,
      (value) => value,
    );
  }
}
