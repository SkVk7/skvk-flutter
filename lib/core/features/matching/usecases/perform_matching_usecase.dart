/// Perform Matching Use Case
///
/// Business logic for performing kundali matching
library;

import '../repositories/matching_repository.dart';
import '../../../utils/either.dart';
import '../../../errors/failures.dart';

/// Use case for performing kundali matching
class PerformMatchingUseCase {
  final MatchingRepository _matchingRepository;

  PerformMatchingUseCase({required MatchingRepository matchingRepository})
      : _matchingRepository = matchingRepository;

  /// Execute the matching use case with both persons' data
  Future<Result<MatchingResult>> call(
      PartnerData person1Data, PartnerData person2Data,
      {String? ayanamsha, String? houseSystem}) async {
    print(
        '🔍 DEBUG: PerformMatchingUseCase called with ${person1Data.name} and ${person2Data.name}');

    // Validate both persons' data
    if (!_isValidPartnerData(person1Data)) {
      print('🔍 DEBUG: Person 1 validation failed');
      return ResultHelper.failure(
        ValidationFailure(message: 'Invalid Person 1 data provided'),
      );
    }

    if (!_isValidPartnerData(person2Data)) {
      print('🔍 DEBUG: Person 2 validation failed');
      return ResultHelper.failure(
        ValidationFailure(message: 'Invalid Person 2 data provided'),
      );
    }

    print('🔍 DEBUG: Validation passed, calling repository');
    // Perform matching with both persons' data
    return await _matchingRepository.performMatching(person1Data, person2Data,
        ayanamsha: ayanamsha, houseSystem: houseSystem);
  }

  /// Validate partner data
  bool _isValidPartnerData(PartnerData partnerData) {
    return partnerData.name.trim().isNotEmpty &&
        partnerData.placeOfBirth.trim().isNotEmpty &&
        partnerData.dateOfBirth.isBefore(DateTime.now()) &&
        partnerData.latitude >= -90.0 &&
        partnerData.latitude <= 90.0 &&
        partnerData.longitude >= -180.0 &&
        partnerData.longitude <= 180.0;
  }
}
