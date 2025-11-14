/// Base Repository
///
/// Provides base classes for repositories following Clean Architecture
library;

import 'package:skvk_application/core/errors/exceptions.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Base repository interface
/// All repositories should implement this interface
abstract class BaseRepository {
  /// Handle exceptions and convert to failures
  Result<T> handleException<T>(dynamic exception, [String? context]) {
    if (exception is AppException) {
      return _mapExceptionToFailure<T>(exception);
    }

    return ResultHelper.failure(
      UnexpectedFailure(
        message: exception.toString(),
        details: {
          'context': context,
          'exception': exception,
        },
      ),
    );
  }

  /// Handle async exceptions and convert to failures
  Future<Result<T>> handleExceptionAsync<T>(
    Future<T> Function() computation, {
    String? context,
  }) async {
    try {
      final result = await computation();
      return ResultHelper.success(result);
    } on Exception catch (e) {
      return handleException<T>(e, context);
    }
  }

  /// Map exception to failure
  Result<T> _mapExceptionToFailure<T>(AppException exception) {
    if (exception is ServerException) {
      return ResultHelper.failure(
        ServerFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        ),
      );
    }

    if (exception is NetworkException) {
      return ResultHelper.failure(
        NetworkFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        ),
      );
    }

    if (exception is CacheException) {
      return ResultHelper.failure(
        CacheFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        ),
      );
    }

    if (exception is ValidationException) {
      return ResultHelper.failure(
        ValidationFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        ),
      );
    }

    if (exception is AuthException) {
      return ResultHelper.failure(
        AuthFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        ),
      );
    }

    if (exception is CalculationException) {
      return ResultHelper.failure(
        CalculationFailure(
          message: exception.message,
          code: exception.code,
          details: exception.details,
        ),
      );
    }

    return ResultHelper.failure(
      UnexpectedFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      ),
    );
  }
}
