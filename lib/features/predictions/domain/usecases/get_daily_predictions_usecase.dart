/// Get Daily Predictions Use Case
///
/// Business logic for generating daily astrological predictions
/// Extracted from UI layer to domain layer following Clean Architecture
library;

import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';

/// Use case for getting daily predictions
class GetDailyPredictionsUseCase {
  GetDailyPredictionsUseCase();

  @Deprecated('Use API directly via AstrologyServiceBridge.getPredictions')
  Future<Result<Map<String, String>>> call({
    required Map<String, dynamic> birthData,
    required DateTime date,
  }) async {
    try {
      // TODO: Use API directly via AstrologyServiceBridge.getPredictions
      // This use case is deprecated - use API directly
      return ResultHelper.failure(
        CalculationFailure(message: 'Use API directly via AstrologyServiceBridge.getPredictions'),
      );
    } catch (e) {
      return ResultHelper.failure(
        CalculationFailure(message: 'Failed to generate daily predictions: $e'),
      );
    }
  }
}
