/// Base Use Case
///
/// Provides base classes for use cases following Clean Architecture
library;

import '../utils/either.dart';
import '../errors/failures.dart';

/// Base use case interface
/// All use cases should implement this interface
abstract class UseCase<Type, Params> {
  /// Execute the use case
  Future<Result<Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  /// Execute the use case
  Future<Result<Type>> call();
}

/// Base use case implementation
abstract class BaseUseCase<Type, Params> implements UseCase<Type, Params> {
  @override
  Future<Result<Type>> call(Params params) async {
    try {
      return await execute(params);
    } catch (e, stackTrace) {
      return ResultHelper.failure(
        UnexpectedFailure(
          message: e.toString(),
          details: {'stackTrace': stackTrace.toString()},
        ),
      );
    }
  }

  /// Execute the use case logic
  Future<Result<Type>> execute(Params params);
}

/// Base use case with no parameters
abstract class BaseNoParamsUseCase<Type> implements NoParamsUseCase<Type> {
  @override
  Future<Result<Type>> call() async {
    try {
      return await execute();
    } catch (e, stackTrace) {
      return ResultHelper.failure(
        UnexpectedFailure(
          message: e.toString(),
          details: {'stackTrace': stackTrace.toString()},
        ),
      );
    }
  }

  /// Execute the use case logic
  Future<Result<Type>> execute();
}

/// Parameters for use cases that don't need any
class NoParams {
  const NoParams();
}

