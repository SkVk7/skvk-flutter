/// Perform Matching Use Case
///
/// Business logic for performing kundali matching
library;

import '../repositories/matching_repository.dart';
import '../../../utils/either.dart';
import '../../../errors/failures.dart';
import '../../../base/base_usecase.dart';
import '../../../logging/logging_helper.dart';

/// Parameters for PerformMatchingUseCase
class PerformMatchingParams {
  final PartnerData person1Data;
  final PartnerData person2Data;
  final String? ayanamsha;
  final String? houseSystem;

  const PerformMatchingParams({
    required this.person1Data,
    required this.person2Data,
    this.ayanamsha,
    this.houseSystem,
  });
}

/// Use case for performing kundali matching
class PerformMatchingUseCase extends BaseUseCase<MatchingResult, PerformMatchingParams> {
  final MatchingRepository _matchingRepository;

  PerformMatchingUseCase({required MatchingRepository matchingRepository})
      : _matchingRepository = matchingRepository;

  @override
  Future<Result<MatchingResult>> execute(PerformMatchingParams params) async {
    LoggingHelper.logDebug(
        'PerformMatchingUseCase called with ${params.person1Data.name} and ${params.person2Data.name}',
        source: 'PerformMatchingUseCase');

    // Validate both persons' data
    if (!_isValidPartnerData(params.person1Data)) {
      LoggingHelper.logWarning('Person 1 validation failed', source: 'PerformMatchingUseCase');
      return ResultHelper.failure(
        ValidationFailure(message: 'Invalid Person 1 data provided'),
      );
    }

    if (!_isValidPartnerData(params.person2Data)) {
      LoggingHelper.logWarning('Person 2 validation failed', source: 'PerformMatchingUseCase');
      return ResultHelper.failure(
        ValidationFailure(message: 'Invalid Person 2 data provided'),
      );
    }

    LoggingHelper.logDebug('Validation passed, calling repository', source: 'PerformMatchingUseCase');
    // Perform matching with both persons' data
    return await _matchingRepository.performMatching(
      params.person1Data,
      params.person2Data,
      ayanamsha: params.ayanamsha,
      houseSystem: params.houseSystem,
    );
  }

  /// Legacy call method for backward compatibility
  /// Note: This doesn't override BaseUseCase.call, it's a convenience method
  Future<Result<MatchingResult>> performMatching(
      PartnerData person1Data, PartnerData person2Data,
      {String? ayanamsha, String? houseSystem}) async {
    return await execute(PerformMatchingParams(
      person1Data: person1Data,
      person2Data: person2Data,
      ayanamsha: ayanamsha,
      houseSystem: houseSystem,
    ));
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
