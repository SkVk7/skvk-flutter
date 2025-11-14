/// Matching Repository Implementation
///
/// Concrete implementation of matching repository
/// Uses BaseRepository for consistent error handling
library;

import 'package:skvk_application/core/base/base_repository.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/core/features/matching/repositories/matching_repository.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/astrology/astrology_service_bridge.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Matching repository implementation
/// Extends BaseRepository for consistent error handling
class MatchingRepositoryImpl extends BaseRepository
    implements MatchingRepository {
  @override
  Future<Result<MatchingResult>> performMatching(
    PartnerData person1Data,
    PartnerData person2Data, {
    String? ayanamsha,
    String? houseSystem,
  }) async {
    await LoggingHelper.logDebug(
        'MatchingRepositoryImpl.performMatching called',
        source: 'MatchingRepository',);
    try {
      await LoggingHelper.logDebug('Using AstrologyServiceBridge for API calls',
          source: 'MatchingRepository',);

      // Use the local birth datetime (bridge will convert to UTC)
      final person1BirthDateTime = person1Data.dateOfBirth;
      final person2BirthDateTime = person2Data.dateOfBirth;

      // Use provided ayanamsha or default to Lahiri
      final selectedAyanamsha = ayanamsha ?? 'lahiri';

      // Use provided house system or default to Placidus
      final selectedHouseSystem = houseSystem ?? 'placidus';

      // Use AstrologyServiceBridge for timezone handling and API calls
      final bridge = AstrologyServiceBridge.instance();

      final person1TimezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
        person1Data.latitude,
        person1Data.longitude,
      );

      final person2TimezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
        person2Data.latitude,
        person2Data.longitude,
      );

      await LoggingHelper.logDebug('Calculating compatibility via API',
          source: 'MatchingRepository',);
      // The API internally handles birth chart fetching and caching
      final compatibilityResult = await bridge.calculateCompatibility(
        localPerson1BirthDateTime: person1BirthDateTime,
        person1TimezoneId: person1TimezoneId,
        person1Latitude: person1Data.latitude,
        person1Longitude: person1Data.longitude,
        localPerson2BirthDateTime: person2BirthDateTime,
        person2TimezoneId: person2TimezoneId,
        person2Latitude: person2Data.latitude,
        person2Longitude: person2Data.longitude,
        ayanamsha: selectedAyanamsha,
        houseSystem: selectedHouseSystem,
      );
      await LoggingHelper.logDebug('Compatibility calculation completed',
          source: 'MatchingRepository',);

      // Extract result from API response (using camelCase)
      final result = compatibilityResult;

      await LoggingHelper.logDebug('Creating matching result',
          source: 'MatchingRepository',);
      await LoggingHelper.logDebug('Result keys: ${result.keys.toList()}',
          source: 'MatchingRepository',);

      if (result.containsKey('error') || result.containsKey('message')) {
        final errorMessage =
            result['error'] ?? result['message'] ?? 'Unknown API error';
        await LoggingHelper.logWarning('API returned error: $errorMessage',
            source: 'MatchingRepository',);
        return ResultHelper.failure(
          UnexpectedFailure(message: 'API error: $errorMessage'),
        );
      }

      // Try camelCase first, then fall back to snake_case
      final kootaScoresKey = result.containsKey('kootaScores')
          ? 'kootaScores'
          : (result.containsKey('koota_scores') ? 'koota_scores' : null);
      final percentageKey = result.containsKey('percentage')
          ? 'percentage'
          : null; // percentage is same in both
      final totalScoreKey = result.containsKey('totalScore')
          ? 'totalScore'
          : (result.containsKey('total_score') ? 'total_score' : null);

      if (kootaScoresKey == null ||
          percentageKey == null ||
          totalScoreKey == null) {
        await LoggingHelper.logWarning('API response missing required fields',
            source: 'MatchingRepository',);
        await LoggingHelper.logDebug(
            'Has kootaScores: ${result.containsKey('kootaScores')}',
            source: 'MatchingRepository',);
        await LoggingHelper.logDebug(
            'Has koota_scores: ${result.containsKey('koota_scores')}',
            source: 'MatchingRepository',);
        await LoggingHelper.logDebug(
            'Has percentage: ${result.containsKey('percentage')}',
            source: 'MatchingRepository',);
        await LoggingHelper.logDebug(
            'Has totalScore: ${result.containsKey('totalScore')}',
            source: 'MatchingRepository',);
        await LoggingHelper.logDebug(
            'Has total_score: ${result.containsKey('total_score')}',
            source: 'MatchingRepository',);
        return ResultHelper.failure(
          ValidationFailure(
            message:
                'Invalid API response: missing required fields. Response keys: ${result.keys.toList()}',
          ),
        );
      }

      // Extract koota scores from API response (handle both camelCase and snake_case)
      // API returns kootaScores as Map<String, KootaScore> where KootaScore has 'score' field
      final kootaScoresMap = result[kootaScoresKey] as Map<String, dynamic>?;
      if (kootaScoresMap == null || kootaScoresMap.isEmpty) {
        await LoggingHelper.logWarning('API response has empty kootaScores',
            source: 'MatchingRepository',);
        return ResultHelper.failure(
          const ValidationFailure(
            message: 'Invalid API response: kootaScores is empty',
          ),
        );
      }

      final percentage = result[percentageKey] as double?;
      if (percentage == null) {
        await LoggingHelper.logWarning('API response missing percentage',
            source: 'MatchingRepository',);
        return ResultHelper.failure(
          const ValidationFailure(
            message: 'Invalid API response: missing percentage',
          ),
        );
      }

      final totalScore = result[totalScoreKey] as int?;
      if (totalScore == null) {
        await LoggingHelper.logWarning('API response missing totalScore',
            source: 'MatchingRepository',);
        return ResultHelper.failure(
          const ValidationFailure(
            message: 'Invalid API response: missing totalScore',
          ),
        );
      }

      final compatibility = result['compatibility'] as String? ?? 'Unknown';
      final recommendation =
          result['recommendation'] as String? ?? 'No recommendation available';

      // Extract individual koota scores from nested structure (validate each score)
      final kootaDetails = <String, String>{};
      for (final entry in kootaScoresMap.entries) {
        final kootaName = entry.key;
        final kootaScore = entry.value as Map<String, dynamic>?;
        if (kootaScore == null) {
          await LoggingHelper.logWarning('Koota $kootaName has null score data',
              source: 'MatchingRepository',);
          continue; // Skip invalid koota scores instead of defaulting to 0
        }
        final score = kootaScore['score'] as int?;
        if (score == null) {
          await LoggingHelper.logDebug('Koota $kootaName has null score value',
              source: 'MatchingRepository',);
          continue; // Skip invalid koota scores instead of defaulting to 0
        }
        kootaDetails[kootaName] = score.toString();
      }

      if (kootaDetails.isEmpty) {
        await LoggingHelper.logWarning(
            'No valid koota scores found in API response',
            source: 'MatchingRepository',);
        return ResultHelper.failure(
          const ValidationFailure(
            message: 'Invalid API response: no valid koota scores found',
          ),
        );
      }

      // Extract birth data for person1 (groom) and person2 (bride)
      final groomBirthDataKey = result.containsKey('groomBirthData')
          ? 'groomBirthData'
          : (result.containsKey('groom_birth_data')
              ? 'groom_birth_data'
              : null);
      final brideBirthDataKey = result.containsKey('brideBirthData')
          ? 'brideBirthData'
          : (result.containsKey('bride_birth_data')
              ? 'bride_birth_data'
              : null);

      // Extract nakshatra, rashi, and pada from birth data
      if (groomBirthDataKey != null) {
        final groomBirthData =
            result[groomBirthDataKey] as Map<String, dynamic>?;
        if (groomBirthData != null) {
          // Extract nakshatra (handle both camelCase and snake_case)
          final groomNakshatra =
              groomBirthData['nakshatra'] as Map<String, dynamic>?;
          if (groomNakshatra != null) {
            final nakshatraName = groomNakshatra['name'] as String?;
            if (nakshatraName != null) {
              kootaDetails['person1Nakshatram'] = nakshatraName;
            }
          }

          // Extract rashi (handle both camelCase and snake_case)
          final groomRashi = groomBirthData['rashi'] as Map<String, dynamic>?;
          if (groomRashi != null) {
            final rashiName = groomRashi['name'] as String?;
            if (rashiName != null) {
              kootaDetails['person1Raasi'] = rashiName;
            }
          }

          // Extract pada (handle both camelCase and snake_case)
          final groomPada = groomBirthData['pada'] as Map<String, dynamic>?;
          if (groomPada != null) {
            final padaName = groomPada['name'] as String?;
            if (padaName != null) {
              kootaDetails['person1Pada'] = padaName;
            } else {
              // Try to get pada number from nakshatra
              final padaNumber = groomNakshatra?['pada'] as int?;
              if (padaNumber != null) {
                kootaDetails['person1Pada'] = padaNumber.toString();
              }
            }
          }
        }
      }

      if (brideBirthDataKey != null) {
        final brideBirthData =
            result[brideBirthDataKey] as Map<String, dynamic>?;
        if (brideBirthData != null) {
          // Extract nakshatra (handle both camelCase and snake_case)
          final brideNakshatra =
              brideBirthData['nakshatra'] as Map<String, dynamic>?;
          if (brideNakshatra != null) {
            final nakshatraName = brideNakshatra['name'] as String?;
            if (nakshatraName != null) {
              kootaDetails['person2Nakshatram'] = nakshatraName;
            }
          }

          // Extract rashi (handle both camelCase and snake_case)
          final brideRashi = brideBirthData['rashi'] as Map<String, dynamic>?;
          if (brideRashi != null) {
            final rashiName = brideRashi['name'] as String?;
            if (rashiName != null) {
              kootaDetails['person2Raasi'] = rashiName;
            }
          }

          // Extract pada (handle both camelCase and snake_case)
          final bridePada = brideBirthData['pada'] as Map<String, dynamic>?;
          if (bridePada != null) {
            final padaName = bridePada['name'] as String?;
            if (padaName != null) {
              kootaDetails['person2Pada'] = padaName;
            } else {
              // Try to get pada number from nakshatra
              final padaNumber = brideNakshatra?['pada'] as int?;
              if (padaNumber != null) {
                kootaDetails['person2Pada'] = padaNumber.toString();
              }
            }
          }
        }
      }

      // Map koota names to display names (only include valid scores, no defaults)
      final displayKootaDetails = <String, String>{};

      // Map camelCase API keys to display names
      if (kootaDetails.containsKey('varna')) {
        displayKootaDetails['Varna'] = kootaDetails['varna']!;
      }
      if (kootaDetails.containsKey('vasya')) {
        displayKootaDetails['Vashya'] = kootaDetails['vasya']!;
      }
      if (kootaDetails.containsKey('tara')) {
        displayKootaDetails['Tara'] = kootaDetails['tara']!;
      }
      if (kootaDetails.containsKey('yoni')) {
        displayKootaDetails['Yoni'] = kootaDetails['yoni']!;
      }
      if (kootaDetails.containsKey('grahaMaitri')) {
        displayKootaDetails['Graha Maitri'] = kootaDetails['grahaMaitri']!;
      }
      if (kootaDetails.containsKey('gana')) {
        displayKootaDetails['Gana'] = kootaDetails['gana']!;
      }
      if (kootaDetails.containsKey('bhakoot')) {
        displayKootaDetails['Bhakoot'] = kootaDetails['bhakoot']!;
      }
      if (kootaDetails.containsKey('nadi')) {
        displayKootaDetails['Nadi'] = kootaDetails['nadi']!;
      }

      if (kootaDetails.containsKey('person1Nakshatram')) {
        displayKootaDetails['person1Nakshatram'] =
            kootaDetails['person1Nakshatram']!;
      }
      if (kootaDetails.containsKey('person1Raasi')) {
        displayKootaDetails['person1Raasi'] = kootaDetails['person1Raasi']!;
      }
      if (kootaDetails.containsKey('person1Pada')) {
        displayKootaDetails['person1Pada'] = kootaDetails['person1Pada']!;
      }
      if (kootaDetails.containsKey('person2Nakshatram')) {
        displayKootaDetails['person2Nakshatram'] =
            kootaDetails['person2Nakshatram']!;
      }
      if (kootaDetails.containsKey('person2Raasi')) {
        displayKootaDetails['person2Raasi'] = kootaDetails['person2Raasi']!;
      }
      if (kootaDetails.containsKey('person2Pada')) {
        displayKootaDetails['person2Pada'] = kootaDetails['person2Pada']!;
      }

      displayKootaDetails['totalPoints'] = totalScore.toString();

      final matchingResult = MatchingResult(
        compatibilityScore: percentage.clamp(0.0, 100.0),
        kootaDetails: displayKootaDetails,
        level: compatibility,
        recommendation: recommendation,
        totalScore: totalScore,
      );
      await LoggingHelper.logDebug(
          'Matching result created successfully with ${displayKootaDetails.length} koota scores',
          source: 'MatchingRepository',);

      return ResultHelper.success(matchingResult);
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Exception caught in repository: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'MatchingRepository',
      );
      return handleException<MatchingResult>(e, 'performMatching');
    }
  }
}
