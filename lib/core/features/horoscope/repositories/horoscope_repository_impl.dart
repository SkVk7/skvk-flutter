/// Horoscope Repository Implementation
///
/// Concrete implementation of horoscope repository
/// Uses BaseRepository for consistent error handling
library;

import 'package:skvk_application/core/base/base_repository.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/core/features/horoscope/repositories/horoscope_repository.dart';
import 'package:skvk_application/core/interfaces/user_repository_interface.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/astrology/astrology_service_bridge.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Horoscope repository implementation
/// Extends BaseRepository for consistent error handling
class HoroscopeRepositoryImpl extends BaseRepository
    implements HoroscopeRepository {
  HoroscopeRepositoryImpl({required UserRepositoryInterface userRepository})
      : _userRepository = userRepository;
  final UserRepositoryInterface _userRepository;

  @override
  Future<Result<HoroscopeData>> generateHoroscope() async {
    try {
      final userDataResult = await getUserBirthData();
      if (userDataResult.isFailure || userDataResult.value == null) {
        return ResultHelper.failure(
          const ValidationFailure(
            message:
                'User profile not complete. Please complete your profile first.',
          ),
        );
      }

      final userData = userDataResult.value!;

      // Use local birth datetime (bridge will convert to UTC)
      final dateOfBirth = userData['dateOfBirth'] as dynamic;
      final timeOfBirth = userData['timeOfBirth'] as dynamic;
      final birthDateTime = dateOfBirth is DateTime
          ? dateOfBirth
          : DateTime(
              (dateOfBirth as DateTime).year,
              dateOfBirth.month,
              dateOfBirth.day,
              (timeOfBirth as Map<String, dynamic>)['hour'] as int,
              timeOfBirth['minute'] as int,
            );

      // Use AstrologyServiceBridge for timezone handling and API calls
      final bridge = AstrologyServiceBridge.instance();

      final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
        userData['latitude'],
        userData['longitude'],
      );

      final birthData = await bridge.getBirthData(
        localBirthDateTime: birthDateTime,
        timezoneId: timezoneId,
        latitude: userData['latitude'],
        longitude: userData['longitude'],
      );

      // Extract horoscope data from API response
      final nakshatraMap = birthData['nakshatra'] as Map<String, dynamic>?;
      final rashiMap = birthData['rashi'] as Map<String, dynamic>?;
      final padaMap = birthData['pada'] as Map<String, dynamic>?;
      final dashaMap = birthData['dasha'] as Map<String, dynamic>?;

      final nakshatraNumber = nakshatraMap?['number'] as int? ?? 1;
      final rashiNumber = rashiMap?['number'] as int? ?? 1;

      final horoscopeData = HoroscopeData(
        nakshatram: nakshatraMap?['name'] as String? ?? 'Unknown',
        pada: padaMap?['number'] as int? ?? 1,
        raasi: rashiMap?['name'] as String? ?? 'Unknown',
        luckyNumber: _getLuckyNumber(nakshatraNumber),
        luckyColor: _getLuckyColor(nakshatraNumber),
        currentDasha: _getCurrentDasha(dashaMap),
        upcomingDasha: _getUpcomingDasha(dashaMap),
        generalPrediction: _getGeneralPrediction(nakshatraNumber, rashiNumber),
        careerPrediction: _getCareerPrediction(nakshatraNumber, rashiNumber),
        healthPrediction: _getHealthPrediction(nakshatraNumber, rashiNumber),
      );

      return ResultHelper.success(horoscopeData);
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Exception caught in horoscope repository: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'HoroscopeRepository',
      );
      return handleException<HoroscopeData>(e, 'generateHoroscope');
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getUserBirthData() async {
    try {
      final result = await _userRepository.getCachedAstrologyData();
      return ResultHelper.success(result);
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Exception getting user birth data: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'HoroscopeRepository',
      );
      return handleException<Map<String, dynamic>?>(e, 'getUserBirthData');
    }
  }

  // Helper methods for predictions
  String _getLuckyNumber(int nakshatraNumber) {
    // Implementation for lucky number calculation
    return (nakshatraNumber % 9 + 1).toString();
  }

  String _getLuckyColor(int nakshatraNumber) {
    // Implementation for lucky color calculation
    final colors = [
      'Red',
      'Orange',
      'Yellow',
      'Green',
      'Blue',
      'Indigo',
      'Violet',
      'Pink',
      'White',
    ];
    return colors[nakshatraNumber % colors.length];
  }

  String _getCurrentDasha(Map<String, dynamic>? dashaMap) {
    if (dashaMap == null) return 'Unknown';
    final currentLord = dashaMap['currentLord'] as String? ?? 'Unknown';
    return 'Current Dasha: $currentLord';
  }

  String _getUpcomingDasha(Map<String, dynamic>? dashaMap) {
    if (dashaMap == null) return 'Unknown';
    final upcomingDashas = dashaMap['upcomingDashas'] as List?;
    if (upcomingDashas == null || upcomingDashas.isEmpty) return 'Unknown';
    final firstUpcoming = upcomingDashas.first as Map<String, dynamic>?;
    final lord = firstUpcoming?['lord'] as String? ?? 'Unknown';
    return 'Upcoming Dasha: $lord';
  }

  String _getGeneralPrediction(int nakshatraNumber, int rashiNumber) {
    // Implementation for general prediction
    return 'General prediction based on nakshatra $nakshatraNumber and rashi $rashiNumber';
  }

  String _getCareerPrediction(int nakshatraNumber, int rashiNumber) {
    // Implementation for career prediction
    return 'Career prediction based on nakshatra $nakshatraNumber and rashi $rashiNumber';
  }

  String _getHealthPrediction(int nakshatraNumber, int rashiNumber) {
    // Implementation for health prediction
    return 'Health prediction based on nakshatra $nakshatraNumber and rashi $rashiNumber';
  }
}
