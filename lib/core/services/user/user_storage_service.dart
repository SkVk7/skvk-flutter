/// User Storage Service
///
/// Clean, optimized service for user data storage using centralized astrology cache
/// Following Flutter best practices and SOLID principles
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/services/shared/cache_service.dart';
import 'package:skvk_application/core/utils/either.dart';

/// User storage service that integrates with centralized astrology cache
class UserStorageService {
  /// Get singleton instance
  factory UserStorageService.instance() {
    return _instance ??= UserStorageService._();
  }

  // Private constructor for singleton
  UserStorageService._();
  static UserStorageService? _instance;
  SharedPreferences? _prefs;
  final CacheService _cacheService = CacheService.instance();

  // Storage keys
  static const String _userDataKey = 'user_profile_data';
  static const String _userCacheKey = 'user_cache';

  /// Initialize the service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await LoggingHelper.logInfo('User Storage Service initialized');
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to initialize user storage service',
        source: 'UserStorageService',
        error: e,
      );
      rethrow;
    }
  }

  /// Save user data to local storage and cache
  Future<Result<void>> saveUser(UserModel user) async {
    try {
      await _ensureInitialized();

      if (!user.isValid) {
        return ResultHelper.failure(
          const ValidationFailure(message: 'Invalid user data provided'),
        );
      }

      final userJson = json.encode(user.toJson());
      await _prefs!.setString(_userDataKey, userJson);

      // Cache user data (user data with 1 year TTL)
      _cacheService.set(
        _userCacheKey,
        user.toJson(),
        duration: const Duration(days: 365),
      );

      await LoggingHelper.logInfo('User data saved successfully');
      return ResultHelper.success(null);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to save user data',
        source: 'UserStorageService',
        error: e,
      );
      return ResultHelper.failure(
        UnexpectedFailure(message: 'Failed to save user data: ${e.toString()}'),
      );
    }
  }

  /// Get current user data
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      await _ensureInitialized();

      final cachedData = _cacheService.get(_userCacheKey);
      if (cachedData != null) {
        final user = UserModel.fromJson(cachedData);
        await LoggingHelper.logDebug('User data retrieved from cache');
        return ResultHelper.success(user);
      }

      // Fallback to SharedPreferences
      final userData = _prefs!.getString(_userDataKey);
      if (userData != null) {
        final userMap = json.decode(userData);
        final user = UserModel.fromJson(userMap);

        // Cache it for future use
        _cacheService.set(
          _userCacheKey,
          userMap as Map<String, dynamic>,
          duration: const Duration(days: 365),
        );

        await LoggingHelper.logDebug(
            'User data retrieved from storage and cached',);
        return ResultHelper.success(user);
      }

      await LoggingHelper.logDebug('No user data found');
      return ResultHelper.success(null);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to get current user',
        source: 'UserStorageService',
        error: e,
      );
      return ResultHelper.failure(
        UnexpectedFailure(
          message: 'Failed to get current user: ${e.toString()}',
        ),
      );
    }
  }

  /// Update user data
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      await _ensureInitialized();

      if (!user.isValid) {
        return ResultHelper.failure(
          const ValidationFailure(message: 'Invalid user data provided'),
        );
      }

      final updatedUser = user.copyWith(
        updatedAt: DateTime.now(),
      );

      final userJson = json.encode(updatedUser.toJson());
      await _prefs!.setString(_userDataKey, userJson);

      _cacheService.set(
        _userCacheKey,
        updatedUser.toJson(),
        duration: const Duration(days: 365),
      );

      await LoggingHelper.logInfo('User data updated successfully');
      return ResultHelper.success(null);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to update user data',
        source: 'UserStorageService',
        error: e,
      );
      return ResultHelper.failure(
        UnexpectedFailure(
          message: 'Failed to update user data: ${e.toString()}',
        ),
      );
    }
  }

  /// Check if user exists
  Future<Result<bool>> userExists() async {
    try {
      await _ensureInitialized();

      final userData = _prefs!.getString(_userDataKey);
      return ResultHelper.success(userData != null);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to check if user exists',
        source: 'UserStorageService',
        error: e,
      );
      return ResultHelper.failure(
        UnexpectedFailure(
          message: 'Failed to check if user exists: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete user data
  Future<Result<void>> deleteUser() async {
    try {
      await _ensureInitialized();

      await _prefs!.remove(_userDataKey);

      _cacheService.remove(_userCacheKey);

      await LoggingHelper.logInfo('User data deleted successfully');
      return ResultHelper.success(null);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to delete user data',
        source: 'UserStorageService',
        error: e,
      );
      return ResultHelper.failure(
        UnexpectedFailure(
          message: 'Failed to delete user data: ${e.toString()}',
        ),
      );
    }
  }

  /// Clear all user data and cache
  Future<Result<void>> clearAllUserData() async {
    try {
      await _ensureInitialized();

      await _prefs!.remove(_userDataKey);

      _cacheService.remove(_userCacheKey);

      await LoggingHelper.logInfo('All user data cleared successfully');
      return ResultHelper.success(null);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to clear user data',
        source: 'UserStorageService',
        error: e,
      );
      return ResultHelper.failure(
        UnexpectedFailure(
          message: 'Failed to clear user data: ${e.toString()}',
        ),
      );
    }
  }

  /// Get user data for astrology calculations (decoupled approach)
  Future<Result<Map<String, dynamic>?>> getUserAstrologyData() async {
    try {
      final userResult = await getCurrentUser();
      if (userResult.isFailure || userResult.value == null) {
        return ResultHelper.success(null);
      }

      final user = userResult.value!;

      final astrologyData = {
        'name': user.name,
        'dateOfBirth': user.dateOfBirth.toIso8601String(),
        'timeOfBirth': {
          'hour': user.timeOfBirth.hour,
          'minute': user.timeOfBirth.minute,
        },
        'placeOfBirth': user.placeOfBirth,
        'latitude': user.latitude,
        'longitude': user.longitude,
        'ayanamsha': user.ayanamsha,
      };

      return ResultHelper.success(astrologyData);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to get user astrology data',
        source: 'UserStorageService',
        error: e,
      );
      return ResultHelper.failure(
        UnexpectedFailure(
          message: 'Failed to get user astrology data: ${e.toString()}',
        ),
      );
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      await _ensureInitialized();

      // Cache stats not available in simple cache service
      final cacheStats = <String, dynamic>{};
      final hasUserData = await userExists();

      return {
        'hasUserData': hasUserData.isSuccess ? hasUserData.value : false,
        'cacheStats': cacheStats,
        'storageType': 'SharedPreferences + AstrologyCache',
      };
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to get storage stats',
        source: 'UserStorageService',
        error: e,
      );
      return {
        'error': e.toString(),
      };
    }
  }

  // Private helper methods

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
}
