/// User Repository Implementation
///
/// Concrete implementation of user repository following Clean Architecture
/// Uses BaseRepository for consistent error handling
library;

import '../../../interfaces/user_repository_interface.dart';
import '../../../models/user/user_model.dart';
import '../../../utils/either.dart';
import '../../../services/user/user_service.dart';
import '../../../base/base_repository.dart';

/// User repository implementation
/// Extends BaseRepository for consistent error handling
class UserRepositoryImpl extends BaseRepository implements UserRepositoryInterface {
  final UserService _userService;

  UserRepositoryImpl({required UserService userService})
      : _userService = userService;

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      return await _userService.getCurrentUser();
    } catch (e) {
      return handleException(e, 'getCurrentUser');
    }
  }

  @override
  Future<Result<void>> saveUser(UserModel user) async {
    try {
      return await _userService.saveUser(user);
    } catch (e) {
      return handleException(e, 'saveUser');
    }
  }

  @override
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      return await _userService.updateUser(user);
    } catch (e) {
      return handleException(e, 'updateUser');
    }
  }

  @override
  Future<Result<void>> deleteUser() async {
    try {
      return await _userService.deleteUser();
    } catch (e) {
      return handleException(e, 'deleteUser');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedAstrologyData() async {
    try {
      return await _userService.getUserAstrologyData();
    } catch (e) {
      // Return null on error for cached data
      return null;
    }
  }

  @override
  Future<bool> isProfileComplete() async {
    final result = await getCurrentUser();
    return result.isSuccess && result.value != null;
  }
}
