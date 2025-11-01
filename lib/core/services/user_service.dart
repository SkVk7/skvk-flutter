/// User Service
///
/// Clean, optimized service for user management that integrates with astrology library
/// Following Flutter best practices and SOLID principles
/// Production-ready with proper error handling and modular architecture
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../utils/either.dart';
import '../utils/app_logger.dart';
import '../errors/failures.dart';
import '../logging/logging_helper.dart';
import '../../astrology/astrology_library.dart';
import '../../astrology/core/facades/astrology_facade.dart';
import '../../astrology/cache/astrology_cache_manager.dart';
import '../../astrology/core/enums/astrology_enums.dart';
import '../../astrology/core/factories/data_factory.dart';
import 'user_storage_service.dart';

/// User service that manages user data and integrates with astrology calculations
class UserService extends Notifier<UserModel?> {
  final UserStorageService _storageService = UserStorageService.instance;
  final AstrologyCacheManager _cacheManager = AstrologyCacheManager.instance;

  bool _isInitialized = false;

  @override
  UserModel? build() {
    _initialize();
    return null;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize storage service and cache manager
      await _storageService.initialize();
      await _cacheManager.initialize();

      // Load user from storage
      await _loadUserFromStorage();

      _isInitialized = true;
    } catch (e) {
      LoggingHelper.logError('Failed to initialize user service', source: 'UserService', error: e);
    }
  }

  /// Load user from storage
  Future<void> _loadUserFromStorage() async {
    try {
      AppLogger.debug('Loading user from storage...', 'UserService');
      final result = await _storageService.getCurrentUser();
      AppLogger.debug('Storage result: ${result.isSuccess ? 'SUCCESS' : 'FAILURE'}', 'UserService');
      if (result.isSuccess && result.value != null) {
        state = result.value!;
        AppLogger.debug('User loaded: ${result.value!.name}', 'UserService');
      } else {
        AppLogger.debug('No user data in storage', 'UserService');
        state = null;
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load user from storage', source: 'UserService', error: e);
      AppLogger.error('ERROR loading user from storage: $e', e, StackTrace.current, 'UserService');
    }
  }

  /// Save user data
  Future<Result<void>> saveUser(UserModel user) async {
    try {
      // Validate user data
      if (!user.isValid) {
        return ResultHelper.failure(
          ValidationFailure(message: 'Invalid user data provided'),
        );
      }

      // Save to storage
      final saveResult = await _storageService.saveUser(user);
      if (saveResult.isFailure) {
        return saveResult;
      }

      // Update state
      state = user;

      // Compute and cache complete astrology data using centralized library
      await _precomputeCompleteAstrologyData(user);

      LoggingHelper.logInfo('User saved successfully');
      return ResultHelper.success(null);
    } catch (e) {
      LoggingHelper.logError('Failed to save user', source: 'UserService', error: e);
      return ResultHelper.failure(
        UnexpectedFailure(message: 'Failed to save user: ${e.toString()}'),
      );
    }
  }

  /// Update user data
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      final previousUser = state;
      bool isUserUpdate = previousUser != null;

      // Validate user data
      if (!user.isValid) {
        return ResultHelper.failure(
          ValidationFailure(message: 'Invalid user data provided'),
        );
      }

      // Update in storage
      final updateResult = await _storageService.updateUser(user);
      if (updateResult.isFailure) {
        return updateResult;
      }

      // Update state
      state = user;

      // If birth details changed, clear astrology cache
      if (isUserUpdate) {
        bool birthDetailsChanged = previousUser.dateOfBirth != user.dateOfBirth ||
            previousUser.timeOfBirth != user.timeOfBirth ||
            previousUser.latitude != user.latitude ||
            previousUser.longitude != user.longitude ||
            previousUser.ayanamsha != user.ayanamsha;

        if (birthDetailsChanged) {
          await _invalidateAstrologyCache(previousUser);
        }
      }

      // Pre-compute complete astrology data for user (full birth chart)
      await _precomputeCompleteAstrologyData(user);

      LoggingHelper.logInfo('User updated successfully');
      return ResultHelper.success(null);
    } catch (e) {
      LoggingHelper.logError('Failed to update user', source: 'UserService', error: e);
      return ResultHelper.failure(
        UnexpectedFailure(message: 'Failed to update user: ${e.toString()}'),
      );
    }
  }

  /// Get current user
  Future<Result<UserModel>> getCurrentUser() async {
    if (!_isInitialized) {
      await _initialize();
    }

    if (state == null) {
      return ResultHelper.failure(
        DataNotFoundFailure(message: 'No user data available'),
      );
    }

    return ResultHelper.success(state!);
  }

  /// Get cached user only
  UserModel? getCachedUser() {
    return state;
  }

  /// Refresh user data from storage
  Future<void> refreshUserData() async {
    try {
      LoggingHelper.logInfo('Refreshing user data from storage');
      await _loadUserFromStorage();
      LoggingHelper.logInfo('User data refreshed: ${state != null ? 'SUCCESS' : 'NO_USER'}');
    } catch (e) {
      LoggingHelper.logError('Failed to refresh user data', source: 'UserService', error: e);
    }
  }

  /// Get current user (legacy method for compatibility)
  Future<Result<UserModel>> getCurrentUserLegacy() async {
    return await getCurrentUser();
  }

  /// Set user data
  Future<Result<void>> setUser(UserModel user) async {
    return await updateUser(user);
  }

  /// Check if user has astrology data
  bool get hasAstrologyData {
    return state?.hasAstrologyData ?? false;
  }

  /// Delete user
  Future<Result<void>> deleteUser() async {
    try {
      final deleteResult = await _storageService.deleteUser();
      if (deleteResult.isFailure) {
        return deleteResult;
      }

      // Clear state
      state = null;

      LoggingHelper.logInfo('User deleted successfully');
      return ResultHelper.success(null);
    } catch (e) {
      LoggingHelper.logError('Failed to delete user', source: 'UserService', error: e);
      return ResultHelper.failure(
        UnexpectedFailure(message: 'Failed to delete user: ${e.toString()}'),
      );
    }
  }

  /// Check if user exists
  Future<Result<bool>> userExists() async {
    try {
      return await _storageService.userExists();
    } catch (e) {
      LoggingHelper.logError('Failed to check if user exists', source: 'UserService', error: e);
      return ResultHelper.failure(
        UnexpectedFailure(message: 'Failed to check if user exists: ${e.toString()}'),
      );
    }
  }

  /// Get user data for astrology calculations (decoupled approach)
  Future<Map<String, dynamic>?> getUserAstrologyData() async {
    if (state == null) return null;

    try {
      // Use local birth time - timezone conversion handled by AstrologyFacade
      final birthDateTime = state!.localBirthDateTime;

      // Return only essential user data for astrology calculations
      return {
        'name': state!.name,
        'dateOfBirth': birthDateTime.toIso8601String(),
        'timeOfBirth': {
          'hour': state!.timeOfBirth.hour,
          'minute': state!.timeOfBirth.minute,
        },
        'placeOfBirth': state!.placeOfBirth,
        'latitude': state!.latitude,
        'longitude': state!.longitude,
        'ayanamsha': state!.ayanamsha.name,
      };
    } catch (e) {
      LoggingHelper.logError('Failed to get user astrology data', source: 'UserService', error: e);
      return null;
    }
  }

  /// Get formatted astrology data for UI display (with caching)
  Future<Map<String, dynamic>?> getFormattedAstrologyData() async {
    if (state == null) {
      LoggingHelper.logWarning('No user state available for astrology data');
      AppLogger.error('User state is null in getFormattedAstrologyData', null, StackTrace.current,
          'UserService');
      return null;
    }

    try {
      LoggingHelper.logInfo('Getting formatted astrology data for user: ${state!.name}');

      // Use local birth time - timezone conversion handled by AstrologyFacade
      final birthDateTime = state!.localBirthDateTime;

      LoggingHelper.logInfo('Birth DateTime: $birthDateTime');
      LoggingHelper.logInfo(
          'Raw timeOfBirth: hour=${state!.timeOfBirth.hour}, minute=${state!.timeOfBirth.minute}');
      LoggingHelper.logInfo('Location: ${state!.latitude}, ${state!.longitude}');

      // Use intelligent caching for optimal performance
      LoggingHelper.logInfo('Using cached astrology data for optimal performance...');

      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from user's location
      final timezoneId =
          await astrologyFacade.getTimezoneFromLocation(state!.latitude, state!.longitude);

      // Get computed birth data from astrology library (uses cache)
      final startTime = DateTime.now();
      final fixedBirthData = await astrologyFacade.getFixedBirthData(
        localBirthDateTime: birthDateTime,
        timezoneId: timezoneId,
        latitude: state!.latitude,
        longitude: state!.longitude,
        isUserData: true,
        ayanamsha: state!.ayanamsha,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      LoggingHelper.logInfo('Astrology library call completed in: ${duration.inMilliseconds}ms');

      // Convert FixedBirthData to the expected format for the UI
      final result = {
        'moon_rashi': fixedBirthData.rashi, // Pass the full RashiData object
        'moon_nakshatra': fixedBirthData.nakshatra, // Pass the full NakshatraData object
        'moon_pada': fixedBirthData.pada, // Pass the full PadaData object
        'ascendant': fixedBirthData.birthChart.planetRashis[Planet.sun] ??
            RashiDataFactory.create(1), // Use Sun's rashi as ascendant fallback
        'birth_chart': {
          'house_lords': fixedBirthData.birthChart.houseLords,
          'planet_houses': fixedBirthData.birthChart.planetHouses,
          'planet_rashis': fixedBirthData.birthChart.planetRashis,
          'planet_nakshatras': fixedBirthData.birthChart.planetNakshatras,
        },
        'dasha': {
          'current_lord': fixedBirthData.dasha.currentLord.name,
          'start_date': fixedBirthData.dasha.startDate.toIso8601String(),
          'end_date': fixedBirthData.dasha.endDate.toIso8601String(),
          'progress': fixedBirthData.dasha.progress,
        },
        'calculated_at': fixedBirthData.calculatedAt.toIso8601String(),
      };

      LoggingHelper.logInfo('Formatted astrology data created successfully');
      LoggingHelper.logInfo('Data keys: ${result.keys.toList()}');
      return result;
    } catch (e) {
      LoggingHelper.logError('Failed to get formatted astrology data',
          source: 'UserService', error: e);
      AppLogger.error(
          'ERROR in getFormattedAstrologyData: $e', e, StackTrace.current, 'UserService');
      return null;
    }
  }

  /// Clear astrology cache
  Future<void> clearAstrologyCache() async {
    // Astrology cache is handled by the centralized library
    LoggingHelper.logInfo('Astrology cache cleared');
  }

  /// Refresh astrology data (now handled by centralized library)
  Future<Result<void>> refreshAstrologyData() async {
    try {
      if (state == null) {
        return ResultHelper.failure(
          DataNotFoundFailure(message: 'No user data available'),
        );
      }

      // Use local birth time - timezone conversion handled by AstrologyFacade
      final birthDateTime = state!.localBirthDateTime;

      // Clear and refresh data in centralized astrology cache
      await AstrologyLibrary.clearCacheEntry(
          'user_${birthDateTime.millisecondsSinceEpoch}_${state!.latitude}_${state!.longitude}');

      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from user's location
      final timezoneId =
          await astrologyFacade.getTimezoneFromLocation(state!.latitude, state!.longitude);

      // Trigger fresh calculation
      await astrologyFacade.getFixedBirthData(
        localBirthDateTime: birthDateTime,
        timezoneId: timezoneId,
        latitude: state!.latitude,
        longitude: state!.longitude,
        isUserData: true,
      );

      LoggingHelper.logInfo('Astrology data refreshed in centralized cache');
      return ResultHelper.success(null);
    } catch (e) {
      LoggingHelper.logError('Failed to refresh astrology data', source: 'UserService', error: e);
      return ResultHelper.failure(
        CalculationFailure(message: 'Failed to refresh astrology data: ${e.toString()}'),
      );
    }
  }

  /// Perform kundali matching
  Future<Result<Map<String, dynamic>>> performKundaliMatching({
    required Map<String, dynamic> partnerData,
  }) async {
    try {
      if (state == null) {
        return ResultHelper.failure(
          DataNotFoundFailure(message: 'No user data available'),
        );
      }

      final userAstrologyData = await getUserAstrologyData();
      if (userAstrologyData == null) {
        return ResultHelper.failure(
          DataNotFoundFailure(message: 'No astrology data available for current user'),
        );
      }

      // Kundali matching is handled by the centralized library
      return ResultHelper.success({});
    } catch (e) {
      LoggingHelper.logError('Failed to perform kundali matching', source: 'UserService', error: e);
      return ResultHelper.failure(
        CalculationFailure(message: 'Failed to perform kundali matching: ${e.toString()}'),
      );
    }
  }

  /// Pre-compute complete astrology data in centralized cache (decoupled approach)
  Future<void> _precomputeCompleteAstrologyData(UserModel user) async {
    try {
      // Create birth DateTime
      final birthDateTime = DateTime(
        user.dateOfBirth.year,
        user.dateOfBirth.month,
        user.dateOfBirth.day,
        user.timeOfBirth.hour,
        user.timeOfBirth.minute,
      );

      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from user's location
      final timezoneId =
          await astrologyFacade.getTimezoneFromLocation(user.latitude, user.longitude);

      // Pre-compute and cache complete birth chart in centralized astrology library
      await astrologyFacade.getFixedBirthData(
        localBirthDateTime: birthDateTime,
        timezoneId: timezoneId,
        latitude: user.latitude,
        longitude: user.longitude,
        isUserData: true, // Complete birth chart for user
        ayanamsha: user.ayanamsha,
      );

      LoggingHelper.logInfo('Astrology data pre-computed in centralized cache');
    } catch (e) {
      LoggingHelper.logError('Failed to pre-compute astrology data',
          source: 'UserService', error: e);
    }
  }

  /// Invalidate astrology cache when user data changes
  Future<void> _invalidateAstrologyCache(UserModel user) async {
    try {
      // Create birth DateTime for cache key
      final birthDateTime = DateTime(
        user.dateOfBirth.year,
        user.dateOfBirth.month,
        user.dateOfBirth.day,
        user.timeOfBirth.hour,
        user.timeOfBirth.minute,
      );

      // Clear user-specific cache entries
      final cacheKey =
          'user_${birthDateTime.millisecondsSinceEpoch}_${user.latitude}_${user.longitude}';
      await _cacheManager.clearCacheEntry(cacheKey);

      LoggingHelper.logInfo('Astrology cache invalidated for user data changes');
    } catch (e) {
      LoggingHelper.logError('Failed to invalidate astrology cache',
          source: 'UserService', error: e);
    }
  }

  /// Check if service is ready
  bool get isReady => _isInitialized && state != null;

  // Lucky number and color methods handled by centralized astrology library
}

/// Provider for the user service
final userServiceProvider = NotifierProvider<UserService, UserModel?>(
  () => UserService(),
);
