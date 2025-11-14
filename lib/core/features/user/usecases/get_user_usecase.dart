/// Get User Use Case
///
/// Use case for retrieving the current user
library;

import 'package:skvk_application/core/base/base_usecase.dart';
import 'package:skvk_application/core/interfaces/user_repository_interface.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Parameters for GetUserUseCase (none needed)
class GetUserParams {
  const GetUserParams();
}

/// Use case for getting the current user
class GetUserUseCase extends BaseUseCase<UserModel?, GetUserParams> {
  GetUserUseCase(this.repository);
  final UserRepositoryInterface repository;

  @override
  Future<Result<UserModel?>> execute(GetUserParams params) async {
    return repository.getCurrentUser();
  }
}

/// Simplified use case without parameters
class GetUserUseCaseSimple extends BaseNoParamsUseCase<UserModel?> {
  GetUserUseCaseSimple(this.repository);
  final UserRepositoryInterface repository;

  @override
  Future<Result<UserModel?>> execute() async {
    return repository.getCurrentUser();
  }
}
