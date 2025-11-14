/// User Repository Implementation
///
/// Concrete implementation of user repository following Clean Architecture
/// Uses BaseRepository for consistent error handling
library;

import 'package:skvk_application/core/base/base_repository.dart';
import 'package:skvk_application/core/interfaces/user_repository_interface.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/services/user/user_service.dart';
import 'package:skvk_application/core/utils/either.dart';

/// User repository implementation
/// Extends BaseRepository for consistent error handling
class UserRepositoryImpl extends BaseRepository
    implements UserRepositoryInterface {
  UserRepositoryImpl({required UserService userService})
      : _userService = userService;
  final UserService _userService;

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      return await _userService.getCurrentUser();
    } on Exception catch (e) {
      return handleException(e, 'getCurrentUser');
    }
  }

  @override
  Future<Result<void>> saveUser(UserModel user) async {
    try {
      return await _userService.saveUser(user);
    } on Exception catch (e) {
      return handleException(e, 'saveUser');
    }
  }

  @override
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      return await _userService.updateUser(user);
    } on Exception catch (e) {
      return handleException(e, 'updateUser');
    }
  }

  @override
  Future<Result<void>> deleteUser() async {
    try {
      return await _userService.deleteUser();
    } on Exception catch (e) {
      return handleException(e, 'deleteUser');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedAstrologyData() async {
    try {
      return await _userService.getUserAstrologyData();
    } on Exception {
      return null;
    }
  }

  @override
  Future<bool> isProfileComplete() async {
    final result = await getCurrentUser();
    return result.isSuccess && result.value != null;
  }
}
