/// Generate Horoscope Use Case
///
/// Business logic for generating horoscope
library;

import 'package:skvk_application/core/base/base_usecase.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/core/features/horoscope/repositories/horoscope_repository.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Use case for generating horoscope
class GenerateHoroscopeUseCase extends BaseNoParamsUseCase<HoroscopeData> {
  GenerateHoroscopeUseCase({required HoroscopeRepository horoscopeRepository})
      : _horoscopeRepository = horoscopeRepository;
  final HoroscopeRepository _horoscopeRepository;

  @override
  Future<Result<HoroscopeData>> execute() async {
    await LoggingHelper.logDebug('GenerateHoroscopeUseCase.execute called',
        source: 'GenerateHoroscopeUseCase',);

    final userDataResult = await _horoscopeRepository.getUserBirthData();
    if (userDataResult.isFailure || userDataResult.value == null) {
      await LoggingHelper.logWarning('User profile not complete',
          source: 'GenerateHoroscopeUseCase',);
      return ResultHelper.failure(
        const ValidationFailure(
          message:
              'User profile not complete. Please complete your profile first.',
        ),
      );
    }

    await LoggingHelper.logDebug('User profile complete, generating horoscope',
        source: 'GenerateHoroscopeUseCase',);
    // Generate horoscope
    return _horoscopeRepository.generateHoroscope();
  }
}
