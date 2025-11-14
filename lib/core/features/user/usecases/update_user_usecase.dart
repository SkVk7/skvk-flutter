/// Update User Use Case
///
/// Use case for updating a user
library;

import 'package:skvk_application/core/base/base_usecase.dart';
import 'package:skvk_application/core/interfaces/user_repository_interface.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Parameters for UpdateUserUseCase
class UpdateUserParams {
  const UpdateUserParams({required this.user});
  final UserModel user;
}

/// Use case for updating a user
class UpdateUserUseCase extends BaseUseCase<void, UpdateUserParams> {
  UpdateUserUseCase(this.repository);
  final UserRepositoryInterface repository;

  @override
  Future<Result<void>> execute(UpdateUserParams params) async {
    return repository.updateUser(params.user);
  }
}
