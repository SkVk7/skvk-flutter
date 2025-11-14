/// Check Profile Complete Use Case
///
/// Use case for checking if user profile is complete
library;

import 'package:skvk_application/core/base/base_usecase.dart';
import 'package:skvk_application/core/interfaces/user_repository_interface.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Use case for checking if profile is complete
class CheckProfileCompleteUseCase extends BaseNoParamsUseCase<bool> {
  CheckProfileCompleteUseCase(this.repository);
  final UserRepositoryInterface repository;

  @override
  Future<Result<bool>> execute() async {
    try {
      final isComplete = await repository.isProfileComplete();
      return ResultHelper.success(isComplete);
    } on Exception catch (e) {
      return ResultHelper.failureFromMessage(
          'Failed to check profile completion: $e',);
    }
  }
}
