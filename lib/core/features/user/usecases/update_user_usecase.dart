/// Update User Use Case
///
/// Use case for updating a user
library;

import '../../../base/base_usecase.dart';
import '../../../utils/either.dart';
import '../../../models/user/user_model.dart';
import '../../../interfaces/user_repository_interface.dart';

/// Parameters for UpdateUserUseCase
class UpdateUserParams {
  final UserModel user;

  const UpdateUserParams({required this.user});
}

/// Use case for updating a user
class UpdateUserUseCase extends BaseUseCase<void, UpdateUserParams> {
  final UserRepositoryInterface repository;

  UpdateUserUseCase(this.repository);

  @override
  Future<Result<void>> execute(UpdateUserParams params) async {
    return await repository.updateUser(params.user);
  }
}

