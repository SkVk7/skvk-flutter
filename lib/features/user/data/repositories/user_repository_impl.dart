/// User Repository Implementation
///
/// Concrete implementation of user repository following Clean Architecture
library;

import '../../../../core/interfaces/user_repository_interface.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/services/user_service.dart';

/// User repository implementation
class UserRepositoryImpl implements UserRepositoryInterface {
  final UserService _userService;

  UserRepositoryImpl({required UserService userService}) : _userService = userService;

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    return await _userService.getCurrentUser();
  }

  @override
  Future<Result<void>> saveUser(UserModel user) async {
    return await _userService.saveUser(user);
  }

  @override
  Future<Result<void>> updateUser(UserModel user) async {
    return await _userService.updateUser(user);
  }

  @override
  Future<Result<void>> deleteUser() async {
    return await _userService.deleteUser();
  }

  @override
  Future<Map<String, dynamic>?> getCachedAstrologyData() async {
    return await _userService.getUserAstrologyData();
  }

  @override
  Future<bool> isProfileComplete() async {
    final result = await _userService.getCurrentUser();
    return result.isSuccess && result.value != null;
  }
}
