/// Matching Repository Implementation
///
/// Concrete implementation of matching repository
library;

import '../../domain/repositories/matching_repository.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/astrology/astrology_service_bridge.dart';
import '../../../../core/utils/validation/error_message_helper.dart';

/// Matching repository implementation
class MatchingRepositoryImpl implements MatchingRepository {
  @override
  Future<Result<MatchingResult>> performMatching(
      PartnerData person1Data, PartnerData person2Data,
      {String? ayanamsha, String? houseSystem}) async {
    print('🔍 DEBUG: MatchingRepositoryImpl.performMatching called');
    try {
      print('🔍 DEBUG: Using AstrologyServiceBridge for API calls');

      // Use the local birth datetime (bridge will convert to UTC)
      final person1BirthDateTime = person1Data.dateOfBirth;
      final person2BirthDateTime = person2Data.dateOfBirth;

      // Use provided ayanamsha or default to Lahiri
      final selectedAyanamsha = ayanamsha ?? 'lahiri';

      // Use provided house system or default to Placidus
      final selectedHouseSystem = houseSystem ?? 'placidus';

      // Use AstrologyServiceBridge for timezone handling and API calls
      final bridge = AstrologyServiceBridge.instance;

      // Get timezone from person1's location
      final person1TimezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
          person1Data.latitude, person1Data.longitude);

      // Get timezone from person2's location
      final person2TimezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
          person2Data.latitude, person2Data.longitude);

      print('🔍 DEBUG: Calculating compatibility via API');
      // Calculate compatibility using bridge (handles timezone conversion automatically)
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
      print('🔍 DEBUG: Compatibility calculation completed');

      // Extract result from API response (using camelCase)
      final result = compatibilityResult;

      print('🔍 DEBUG: Creating matching result');
      print('🔍 DEBUG: Result keys: ${result.keys.toList()}');
      print('🔍 DEBUG: Full result: $result');

      // Check if API returned an error response
      if (result.containsKey('error') || result.containsKey('message')) {
        final errorMessage =
            result['error'] ?? result['message'] ?? 'Unknown API error';
        print('🔍 DEBUG: API returned error: $errorMessage');
        return ResultHelper.failure(
          UnexpectedFailure(message: 'API error: $errorMessage'),
        );
      }

      // Handle both camelCase and snake_case for backward compatibility
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

      // Validate API response has required fields (check both naming conventions)
      if (kootaScoresKey == null ||
          percentageKey == null ||
          totalScoreKey == null) {
        print('🔍 DEBUG: API response missing required fields');
        print(
            '🔍 DEBUG: Has kootaScores: ${result.containsKey('kootaScores')}');
        print(
            '🔍 DEBUG: Has koota_scores: ${result.containsKey('koota_scores')}');
        print('🔍 DEBUG: Has percentage: ${result.containsKey('percentage')}');
        print('🔍 DEBUG: Has totalScore: ${result.containsKey('totalScore')}');
        print(
            '🔍 DEBUG: Has total_score: ${result.containsKey('total_score')}');
        return ResultHelper.failure(
          ValidationFailure(
              message:
                  'Invalid API response: missing required fields. Response keys: ${result.keys.toList()}'),
        );
      }

      // Extract koota scores from API response (handle both camelCase and snake_case)
      // API returns kootaScores as Map<String, KootaScore> where KootaScore has 'score' field
      final kootaScoresMap = result[kootaScoresKey] as Map<String, dynamic>?;
      if (kootaScoresMap == null || kootaScoresMap.isEmpty) {
        print('🔍 DEBUG: API response has empty kootaScores');
        return ResultHelper.failure(
          ValidationFailure(
              message: 'Invalid API response: kootaScores is empty'),
        );
      }

      final percentage = result[percentageKey] as double?;
      if (percentage == null) {
        print('🔍 DEBUG: API response missing percentage');
        return ResultHelper.failure(
          ValidationFailure(
              message: 'Invalid API response: missing percentage'),
        );
      }

      final totalScore = result[totalScoreKey] as int?;
      if (totalScore == null) {
        print('🔍 DEBUG: API response missing totalScore');
        return ResultHelper.failure(
          ValidationFailure(
              message: 'Invalid API response: missing totalScore'),
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
          print('🔍 DEBUG: Koota $kootaName has null score data');
          continue; // Skip invalid koota scores instead of defaulting to 0
        }
        final score = kootaScore['score'] as int?;
        if (score == null) {
          print('🔍 DEBUG: Koota $kootaName has null score value');
          continue; // Skip invalid koota scores instead of defaulting to 0
        }
        kootaDetails[kootaName] = score.toString();
      }

      // Validate that we have at least some koota scores
      if (kootaDetails.isEmpty) {
        print('🔍 DEBUG: No valid koota scores found in API response');
        return ResultHelper.failure(
          ValidationFailure(
              message: 'Invalid API response: no valid koota scores found'),
        );
      }

      // Extract birth data for person1 (groom) and person2 (bride)
      // Handle both camelCase and snake_case
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

      // Add birth data fields
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

      // Add total points
      displayKootaDetails['totalPoints'] = totalScore.toString();

      final matchingResult = MatchingResult(
        compatibilityScore: percentage.clamp(0.0, 100.0),
        kootaDetails: displayKootaDetails,
        level: compatibility,
        recommendation: recommendation,
      );
      print(
          '🔍 DEBUG: Matching result created successfully with ${displayKootaDetails.length} koota scores');

      return ResultHelper.success(matchingResult);
    } catch (e) {
      print('🔍 DEBUG: Exception caught in repository: $e');
      // Convert technical error to user-friendly message
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      return ResultHelper.failure(
        UnexpectedFailure(message: userFriendlyMessage),
      );
    }
  }
}
