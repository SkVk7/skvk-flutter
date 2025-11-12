/// Generate Horoscope Use Case
///
/// Business logic for generating horoscope
library;

import '../repositories/horoscope_repository.dart';
import '../../../utils/either.dart';
import '../../../errors/failures.dart';
import '../../../base/base_usecase.dart';
import '../../../logging/logging_helper.dart';

/// Use case for generating horoscope
class GenerateHoroscopeUseCase extends BaseNoParamsUseCase<HoroscopeData> {
  final HoroscopeRepository _horoscopeRepository;

  GenerateHoroscopeUseCase({required HoroscopeRepository horoscopeRepository})
      : _horoscopeRepository = horoscopeRepository;

  @override
  Future<Result<HoroscopeData>> execute() async {
    LoggingHelper.logDebug('GenerateHoroscopeUseCase.execute called', source: 'GenerateHoroscopeUseCase');
    
    // Check if user profile is complete
    final userDataResult = await _horoscopeRepository.getUserBirthData();
    if (userDataResult.isFailure || userDataResult.value == null) {
      LoggingHelper.logWarning('User profile not complete', source: 'GenerateHoroscopeUseCase');
      return ResultHelper.failure(
        ValidationFailure(
            message:
                'User profile not complete. Please complete your profile first.'),
      );
    }

    LoggingHelper.logDebug('User profile complete, generating horoscope', source: 'GenerateHoroscopeUseCase');
    // Generate horoscope
    return await _horoscopeRepository.generateHoroscope();
  }

  /// Legacy call method for backward compatibility
  @override
  Future<Result<HoroscopeData>> call() async {
    return await execute();
  }
}
