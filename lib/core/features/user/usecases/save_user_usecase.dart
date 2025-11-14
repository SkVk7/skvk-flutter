/// Save User Use Case
///
/// Use case for saving a user
library;

import 'package:skvk_application/core/base/base_usecase.dart';
import 'package:skvk_application/core/interfaces/user_repository_interface.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Parameters for SaveUserUseCase
class SaveUserParams {
  const SaveUserParams({required this.user});
  final UserModel user;
}

/// Use case for saving a user
class SaveUserUseCase extends BaseUseCase<void, SaveUserParams> {
  SaveUserUseCase(this.repository);
  final UserRepositoryInterface repository;

  @override
  Future<Result<void>> execute(SaveUserParams params) async {
    return repository.saveUser(params.user);
  }
}
