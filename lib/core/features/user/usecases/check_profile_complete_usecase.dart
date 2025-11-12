/// Check Profile Complete Use Case
///
/// Use case for checking if user profile is complete
library;

import '../../../base/base_usecase.dart';
import '../../../utils/either.dart';
import '../../../interfaces/user_repository_interface.dart';

/// Use case for checking if profile is complete
class CheckProfileCompleteUseCase extends BaseNoParamsUseCase<bool> {
  final UserRepositoryInterface repository;

  CheckProfileCompleteUseCase(this.repository);

  @override
  Future<Result<bool>> execute() async {
    try {
      final isComplete = await repository.isProfileComplete();
      return ResultHelper.success(isComplete);
    } catch (e) {
      return ResultHelper.failureFromMessage('Failed to check profile completion: $e');
    }
  }
}

