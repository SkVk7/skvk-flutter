/// Base Use Case
///
/// Provides base classes for use cases following Clean Architecture
library;

import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Base use case interface
/// All use cases should implement this interface
// ignore: one_member_abstracts
abstract class UseCase<TResult, Params> {
  /// Execute the use case
  Future<Result<TResult>> call(Params params);
}

/// Use case with no parameters
// ignore: one_member_abstracts
abstract class NoParamsUseCase<TResult> {
  /// Execute the use case
  Future<Result<TResult>> call();
}

/// Base use case implementation
abstract class BaseUseCase<TResult, Params>
    implements UseCase<TResult, Params> {
  @override
  Future<Result<TResult>> call(Params params) async {
    try {
      return await execute(params);
    } on Exception catch (e, stackTrace) {
      return ResultHelper.failure(
        UnexpectedFailure(
          message: e.toString(),
          details: {'stackTrace': stackTrace.toString()},
        ),
      );
    }
  }

  /// Execute the use case logic
  Future<Result<TResult>> execute(Params params);
}

/// Base use case with no parameters
abstract class BaseNoParamsUseCase<TResult>
    implements NoParamsUseCase<TResult> {
  @override
  Future<Result<TResult>> call() async {
    try {
      return await execute();
    } on Exception catch (e, stackTrace) {
      return ResultHelper.failure(
        UnexpectedFailure(
          message: e.toString(),
          details: {'stackTrace': stackTrace.toString()},
        ),
      );
    }
  }

  /// Execute the use case logic
  Future<Result<TResult>> execute();
}

/// Parameters for use cases that don't need any
class NoParams {
  const NoParams();
}
