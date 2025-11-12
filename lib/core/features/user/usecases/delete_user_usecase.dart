/// Delete User Use Case
///
/// Use case for deleting the current user
library;

import '../../../base/base_usecase.dart';
import '../../../utils/either.dart';
import '../../../interfaces/user_repository_interface.dart';

/// Use case for deleting the current user
class DeleteUserUseCase extends BaseNoParamsUseCase<void> {
  final UserRepositoryInterface repository;

  DeleteUserUseCase(this.repository);

  @override
  Future<Result<void>> execute() async {
    return await repository.deleteUser();
  }
}

