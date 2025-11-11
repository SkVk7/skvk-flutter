/// Horoscope Repository Implementation
///
/// Concrete implementation of horoscope repository
library;

import '../repositories/horoscope_repository.dart';
import '../../../utils/either.dart';
import '../../../errors/failures.dart';
import '../../../interfaces/user_repository_interface.dart';
import '../../../services/astrology/astrology_service_bridge.dart';
import '../../../utils/validation/error_message_helper.dart';

/// Horoscope repository implementation
class HoroscopeRepositoryImpl implements HoroscopeRepository {
  final UserRepositoryInterface _userRepository;

  HoroscopeRepositoryImpl({required UserRepositoryInterface userRepository})
      : _userRepository = userRepository;

  @override
  Future<Result<HoroscopeData>> generateHoroscope() async {
    try {
      // Get user birth data
      final userDataResult = await getUserBirthData();
      if (userDataResult.isFailure || userDataResult.value == null) {
        return ResultHelper.failure(
          ValidationFailure(
              message:
                  'User profile not complete. Please complete your profile first.'),
        );
      }

      final userData = userDataResult.value!;

      // Use local birth datetime (bridge will convert to UTC)
      final birthDateTime = userData['dateOfBirth'] is DateTime
          ? userData['dateOfBirth'] as DateTime
          : DateTime(
              userData['dateOfBirth'].year,
              userData['dateOfBirth'].month,
              userData['dateOfBirth'].day,
              userData['timeOfBirth'].hour,
              userData['timeOfBirth'].minute,
            );

      // Use AstrologyServiceBridge for timezone handling and API calls
      final bridge = AstrologyServiceBridge.instance;

      // Get timezone from user's location
      final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
          userData['latitude'], userData['longitude']);

      // Get birth data from API (handles timezone conversion automatically)
      final birthData = await bridge.getBirthData(
        localBirthDateTime: birthDateTime,
        timezoneId: timezoneId,
        latitude: userData['latitude'],
        longitude: userData['longitude'],
        ayanamsha: 'lahiri',
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
    } catch (e) {
      // Convert technical error to user-friendly message
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      return ResultHelper.failure(
        UnexpectedFailure(message: userFriendlyMessage),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getUserBirthData() async {
    final result = await _userRepository.getCachedAstrologyData();
    return ResultHelper.success(result);
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
      'White'
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
