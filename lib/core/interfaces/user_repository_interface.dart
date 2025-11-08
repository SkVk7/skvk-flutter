/// User Repository Interface
///
/// Abstract interface for user data operations following Clean Architecture
library;

import '../models/user/user_model.dart';
import '../utils/either.dart';

/// Abstract user repository interface
abstract class UserRepositoryInterface {
  /// Get current user
  Future<Result<UserModel?>> getCurrentUser();

  /// Save user data
  Future<Result<void>> saveUser(UserModel user);

  /// Update user data
  Future<Result<void>> updateUser(UserModel user);

  /// Delete user data
  Future<Result<void>> deleteUser();

  /// Get cached astrology data
  Future<Map<String, dynamic>?> getCachedAstrologyData();

  /// Check if user profile is complete
  Future<bool> isProfileComplete();
}
