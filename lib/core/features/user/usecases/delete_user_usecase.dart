/// Delete User Use Case
///
/// Use case for deleting the current user
library;

import 'package:skvk_application/core/base/base_usecase.dart';
import 'package:skvk_application/core/interfaces/user_repository_interface.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Use case for deleting the current user
class DeleteUserUseCase extends BaseNoParamsUseCase<void> {
  DeleteUserUseCase(this.repository);
  final UserRepositoryInterface repository;

  @override
  Future<Result<void>> execute() async {
    return repository.deleteUser();
  }
}
