/// Generate Horoscope Use Case
///
/// Business logic for generating horoscope
library;

import '../repositories/horoscope_repository.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';

/// Use case for generating horoscope
class GenerateHoroscopeUseCase {
  final HoroscopeRepository _horoscopeRepository;

  GenerateHoroscopeUseCase({required HoroscopeRepository horoscopeRepository})
      : _horoscopeRepository = horoscopeRepository;

  /// Execute the horoscope generation use case
  Future<Result<HoroscopeData>> call() async {
    // Check if user profile is complete
    final userDataResult = await _horoscopeRepository.getUserBirthData();
    if (userDataResult.isFailure || userDataResult.value == null) {
      return ResultHelper.failure(
        ValidationFailure(
            message:
                'User profile not complete. Please complete your profile first.'),
      );
    }

    // Generate horoscope
    return await _horoscopeRepository.generateHoroscope();
  }
}
