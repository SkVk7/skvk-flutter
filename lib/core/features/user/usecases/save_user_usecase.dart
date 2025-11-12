/// Save User Use Case
///
/// Use case for saving a user
library;

import '../../../base/base_usecase.dart';
import '../../../utils/either.dart';
import '../../../models/user/user_model.dart';
import '../../../interfaces/user_repository_interface.dart';

/// Parameters for SaveUserUseCase
class SaveUserParams {
  final UserModel user;

  const SaveUserParams({required this.user});
}

/// Use case for saving a user
class SaveUserUseCase extends BaseUseCase<void, SaveUserParams> {
  final UserRepositoryInterface repository;

  SaveUserUseCase(this.repository);

  @override
  Future<Result<void>> execute(SaveUserParams params) async {
    return await repository.saveUser(params.user);
  }
}

