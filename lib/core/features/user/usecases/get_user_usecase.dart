/// Get User Use Case
///
/// Use case for retrieving the current user
library;

import '../../../base/base_usecase.dart';
import '../../../utils/either.dart';
import '../../../models/user/user_model.dart';
import '../../../interfaces/user_repository_interface.dart';

/// Parameters for GetUserUseCase (none needed)
class GetUserParams {
  const GetUserParams();
}

/// Use case for getting the current user
class GetUserUseCase extends BaseUseCase<UserModel?, GetUserParams> {
  final UserRepositoryInterface repository;

  GetUserUseCase(this.repository);

  @override
  Future<Result<UserModel?>> execute(GetUserParams params) async {
    return await repository.getCurrentUser();
  }
}

/// Simplified use case without parameters
class GetUserUseCaseSimple extends BaseNoParamsUseCase<UserModel?> {
  final UserRepositoryInterface repository;

  GetUserUseCaseSimple(this.repository);

  @override
  Future<Result<UserModel?>> execute() async {
    return await repository.getCurrentUser();
  }
}

