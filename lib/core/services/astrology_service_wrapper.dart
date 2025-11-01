/// Application Layer Astrology Service Wrapper
///
/// This service handles timezone conversion at the application layer
/// and provides a clean interface for the UI layer.
library;

import 'centralized_timezone_service.dart';
import '../services/astrology_progress_service.dart';
import '../../astrology/core/facades/astrology_facade.dart';
import '../../astrology/core/enums/astrology_enums.dart';
import '../../astrology/core/entities/astrology_entities.dart';
import '../models/user_model.dart';

/// Application layer wrapper for astrology calculations
/// Handles timezone conversion and provides user-friendly interface
class AstrologyServiceWrapper {
  static AstrologyServiceWrapper? _instance;

  AstrologyServiceWrapper._();

  static AstrologyServiceWrapper get instance {
    _instance ??= AstrologyServiceWrapper._();
    return _instance!;
  }

  /// Get birth data with automatic timezone conversion
  /// User provides local birth time, we convert to UTC internally
  Future<FixedBirthData> getBirthData({
    required DateTime localBirthTime, // User's local birth time
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    bool isUserData = false,
  }) async {
    // Use AstrologyFacade for timezone handling
    final astrologyFacade = AstrologyFacade.instance;

    // Get timezone from location
    final timezoneId = await astrologyFacade.getTimezoneFromLocation(latitude, longitude);

    // Call AstrologyFacade with local time (handles timezone conversion)
    return await astrologyFacade.getFixedBirthData(
      localBirthDateTime: localBirthTime,
      timezoneId: timezoneId,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
      isUserData: isUserData,
    );
  }

  /// Get birth data from UserModel (uses stored UTC time)
  /// This is the RECOMMENDED method - uses pre-calculated UTC time
  Future<FixedBirthData> getBirthDataFromUser({
    required UserModel user,
    bool isUserData = false,
    bool showProgress = true,
  }) async {
    try {
      if (showProgress) {
        AstrologyProgressService.instance.startProgress('Birth Data Calculation');
      }

      // Use local birth time - timezone conversion handled by AstrologyFacade
      final localBirthTime = user.localBirthDateTime;

      if (showProgress) {
        AstrologyProgressService.instance.updateProgress(
          operationName: 'Birth Data Calculation',
          progress: 0.3,
          message: 'Using stored UTC time for calculations...',
        );
      }

      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from user's location
      final timezoneId =
          await astrologyFacade.getTimezoneFromLocation(user.latitude, user.longitude);

      // Call AstrologyFacade with local time (handles timezone conversion)
      final result = await astrologyFacade.getFixedBirthData(
        localBirthDateTime: localBirthTime,
        timezoneId: timezoneId,
        latitude: user.latitude,
        longitude: user.longitude,
        ayanamsha: user.ayanamsha,
        isUserData: isUserData,
      );

      if (showProgress) {
        AstrologyProgressService.instance.completeProgress('Birth Data Calculation');
      }

      return result;
    } catch (e) {
      if (showProgress) {
        AstrologyProgressService.instance.errorProgress(
          'Birth Data Calculation',
          e.toString(),
        );
      }
      rethrow;
    }
  }

  /// Get birth data with enhanced timezone conversion
  Future<FixedBirthData> getBirthDataEnhanced({
    required DateTime localBirthTime, // User's local birth time
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    bool isUserData = false,
  }) async {
    // Use AstrologyFacade for timezone handling
    final astrologyFacade = AstrologyFacade.instance;

    // Get timezone from location
    final timezoneId = await astrologyFacade.getTimezoneFromLocation(latitude, longitude);

    // Call AstrologyFacade with local time (handles timezone conversion)
    return await astrologyFacade.getFixedBirthData(
      localBirthDateTime: localBirthTime,
      timezoneId: timezoneId,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
      isUserData: isUserData,
    );
  }

  /// Get minimal birth data for kundali matching
  Future<Map<String, dynamic>> getMinimalBirthData({
    required DateTime localBirthTime, // User's local birth time
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
  }) async {
    // Use AstrologyFacade for timezone handling
    final astrologyFacade = AstrologyFacade.instance;

    // Get timezone from location
    final timezoneId = await astrologyFacade.getTimezoneFromLocation(latitude, longitude);

    // Call AstrologyFacade with local time (handles timezone conversion)
    return await astrologyFacade.getMinimalBirthData(
      localBirthDateTime: localBirthTime,
      timezoneId: timezoneId,
      latitude: latitude,
      longitude: longitude,
      ayanamsha: ayanamsha,
    );
  }

  /// Format birth time for display (preserves user's original input)
  String formatBirthTimeForDisplay(DateTime localBirthTime, double longitude, double latitude) {
    // Format the local time for display (no conversion needed)
    return '${localBirthTime.hour.toString().padLeft(2, '0')}:${localBirthTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get timezone information for display
  String getTimezoneInfo(double longitude, double latitude) {
    return CentralizedTimezoneService.instance.getTimezoneName(longitude, latitude);
  }
}
