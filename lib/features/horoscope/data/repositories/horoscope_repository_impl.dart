/// Horoscope Repository Implementation
///
/// Concrete implementation of horoscope repository
library;

import '../../domain/repositories/horoscope_repository.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/interfaces/user_repository_interface.dart';
import '../../../../astrology/astrology_library.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';

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
              message: 'User profile not complete. Please complete your profile first.'),
        );
      }

      final userData = userDataResult.value!;

      // Initialize astrology library
      await AstrologyLibrary.initialize();

      // Use stored UTC birth time (converted once and stored)
      final birthDateTime = userData['utcBirthDateTime'] ??
          DateTime(
            userData['dateOfBirth'].year,
            userData['dateOfBirth'].month,
            userData['dateOfBirth'].day,
            userData['timeOfBirth'].hour,
            userData['timeOfBirth'].minute,
          );

      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from user's location
      final timezoneId = await astrologyFacade.getTimezoneFromLocation(
          userData['latitude'], userData['longitude']);

      // Get fixed birth data from AstrologyFacade
      final birthData = await astrologyFacade.getFixedBirthData(
        localBirthDateTime: birthDateTime,
        timezoneId: timezoneId,
        latitude: userData['latitude'],
        longitude: userData['longitude'],
        isUserData: true,
        ayanamsha: AyanamshaType.lahiri,
      );

      // Extract horoscope data
      final horoscopeData = HoroscopeData(
        nakshatram: birthData.nakshatra.name,
        pada: birthData.pada.number,
        raasi: birthData.rashi.name,
        luckyNumber: _getLuckyNumber(birthData.nakshatra.number),
        luckyColor: _getLuckyColor(birthData.nakshatra.number),
        currentDasha: _getCurrentDasha(birthData),
        upcomingDasha: _getUpcomingDasha(birthData),
        generalPrediction:
            _getGeneralPrediction(birthData.nakshatra.number, birthData.rashi.number),
        careerPrediction: _getCareerPrediction(birthData.nakshatra.number, birthData.rashi.number),
        healthPrediction: _getHealthPrediction(birthData.nakshatra.number, birthData.rashi.number),
      );

      return ResultHelper.success(horoscopeData);
    } catch (e) {
      return ResultHelper.failure(
        UnexpectedFailure(message: 'Horoscope generation failed: $e'),
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

  String _getCurrentDasha(dynamic birthData) {
    // Implementation for current dasha
    return 'Current Dasha: ${birthData.dasha?.currentDasha ?? 'Unknown'}';
  }

  String _getUpcomingDasha(dynamic birthData) {
    // Implementation for upcoming dasha
    return 'Upcoming Dasha: ${birthData.dasha?.upcomingDasha ?? 'Unknown'}';
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
