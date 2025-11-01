/// Matching Repository Implementation
///
/// Concrete implementation of matching repository
library;

import '../../domain/repositories/matching_repository.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../astrology/astrology_library.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../astrology/core/entities/astrology_entities.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';

/// Matching repository implementation
class MatchingRepositoryImpl implements MatchingRepository {
  @override
  Future<Result<MatchingResult>> performMatching(PartnerData person1Data, PartnerData person2Data,
      {AyanamshaType? ayanamsha}) async {
    print('🔍 DEBUG: MatchingRepositoryImpl.performMatching called');
    try {
      print('🔍 DEBUG: Initializing astrology library');
      // Initialize astrology library
      await AstrologyLibrary.initialize();
      print('🔍 DEBUG: Astrology library initialized');

      // Use the UTC birth datetime directly (timezone conversion already done in screen)
      final person1BirthDateTime = person1Data.dateOfBirth;
      final person2BirthDateTime = person2Data.dateOfBirth;

      // Use the same calculation method as user profile for consistency
      // Use provided ayanamsha or default to Lahiri
      final selectedAyanamsha = ayanamsha ?? AyanamshaType.lahiri;

      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from person1's location
      final person1TimezoneId = await astrologyFacade.getTimezoneFromLocation(
          person1Data.latitude, person1Data.longitude);

      // Get timezone from person2's location
      final person2TimezoneId = await astrologyFacade.getTimezoneFromLocation(
          person2Data.latitude, person2Data.longitude);

      print('🔍 DEBUG: Getting person1 fixed birth data with ayanamsha: $selectedAyanamsha');
      final person1FixedBirthData = await astrologyFacade.getFixedBirthData(
        localBirthDateTime: person1BirthDateTime,
        timezoneId: person1TimezoneId,
        latitude: person1Data.latitude,
        longitude: person1Data.longitude,
        isUserData: false,
        ayanamsha: selectedAyanamsha,
      );
      print('🔍 DEBUG: Person1 fixed birth data obtained');

      print('🔍 DEBUG: Getting person2 fixed birth data with ayanamsha: $selectedAyanamsha');
      final person2FixedBirthData = await astrologyFacade.getFixedBirthData(
        localBirthDateTime: person2BirthDateTime,
        timezoneId: person2TimezoneId,
        latitude: person2Data.latitude,
        longitude: person2Data.longitude,
        isUserData: false,
        ayanamsha: selectedAyanamsha,
      );
      print('🔍 DEBUG: Person2 fixed birth data obtained');

      // For compatibility matching, we only need nakshatra, rashi, and padam
      // The minimal data already contains these essential fields
      // We can perform basic compatibility matching using this lightweight data

      // Extract essential compatibility data from fixed birth data
      print('🔍 DEBUG: Extracting compatibility data');
      final person1Nakshatra = person1FixedBirthData.nakshatra;
      final person1Rashi = person1FixedBirthData.rashi;
      final person1Pada = person1FixedBirthData.pada.number;

      final person2Nakshatra = person2FixedBirthData.nakshatra;
      final person2Rashi = person2FixedBirthData.rashi;
      final person2Pada = person2FixedBirthData.pada.number;
      print('🔍 DEBUG: Compatibility data extracted');

      // Use astrology library for compatibility matching
      print('🔍 DEBUG: Performing compatibility matching using astrology library');
      final result = await _performCompatibilityMatching(
        person1Nakshatra: person1Nakshatra,
        person1Rashi: person1Rashi,
        person1Pada: person1Pada,
        person2Nakshatra: person2Nakshatra,
        person2Rashi: person2Rashi,
        person2Pada: person2Pada,
        person1BirthDateTime: person1BirthDateTime,
        person1Latitude: person1Data.latitude,
        person1Longitude: person1Data.longitude,
        person2BirthDateTime: person2BirthDateTime,
        person2Latitude: person2Data.latitude,
        person2Longitude: person2Data.longitude,
      );
      print('🔍 DEBUG: Compatibility matching completed');

      print('🔍 DEBUG: Creating matching result');
      print('🔍 DEBUG: Result keys: ${result.keys.toList()}');
      print('🔍 DEBUG: Varna score: ${result['varnaScore']}');
      print('🔍 DEBUG: Vashya score: ${result['vashyaScore']}');
      print('🔍 DEBUG: Tara score: ${result['taraScore']}');
      print('🔍 DEBUG: Yoni score: ${result['yoniScore']}');
      print('🔍 DEBUG: Graha Maitri score: ${result['grahaMaitriScore']}');
      print('🔍 DEBUG: Gana score: ${result['ganaScore']}');
      print('🔍 DEBUG: Bhakoot score: ${result['bhakootScore']}');
      print('🔍 DEBUG: Nadi score: ${result['nadiScore']}');
      print('🔍 DEBUG: Total points: ${result['totalPoints']}');

      final matchingResult = MatchingResult(
        compatibilityScore: (result['overallScore'] * 100).clamp(0, 100).toDouble(),
        kootaDetails: {
          'Varna': result['varnaScore']?.toString() ?? '1',
          'Vashya': result['vashyaScore']?.toString() ?? '2',
          'Tara': result['taraScore']?.toString() ?? '3',
          'Yoni': result['yoniScore']?.toString() ?? '4',
          'Graha Maitri': result['grahaMaitriScore']?.toString() ?? '5',
          'Gana': result['ganaScore']?.toString() ?? '6',
          'Bhakoot': result['bhakootScore']?.toString() ?? '7',
          'Nadi': result['nadiScore']?.toString() ?? '8',
          'totalPoints': (result['totalPoints'] ?? 0).toString(),
          // Add birth data for UI display (separate from scores)
          'person1Nakshatram': result['person1Nakshatram']?.toString() ?? 'Unknown',
          'person1Raasi': result['person1Raasi']?.toString() ?? 'Unknown',
          'person1Pada': result['person1Pada']?.toString() ?? 'Unknown',
          'person2Nakshatram': result['person2Nakshatram']?.toString() ?? 'Unknown',
          'person2Raasi': result['person2Raasi']?.toString() ?? 'Unknown',
          'person2Pada': result['person2Pada']?.toString() ?? 'Unknown',
        },
        level: result['level'],
        recommendation: result['recommendation'],
      );
      print('🔍 DEBUG: Matching result created, returning success');

      return ResultHelper.success(matchingResult);
    } catch (e) {
      print('🔍 DEBUG: Exception caught in repository: $e');
      return ResultHelper.failure(
        UnexpectedFailure(message: 'Matching calculation failed: $e'),
      );
    }
  }

  /// Use astrology library for compatibility matching
  Future<Map<String, dynamic>> _performCompatibilityMatching({
    required NakshatraData person1Nakshatra,
    required RashiData person1Rashi,
    required int person1Pada,
    required NakshatraData person2Nakshatra,
    required RashiData person2Rashi,
    required int person2Pada,
    required DateTime person1BirthDateTime,
    required double person1Latitude,
    required double person1Longitude,
    required DateTime person2BirthDateTime,
    required double person2Latitude,
    required double person2Longitude,
  }) async {
    try {
      // Create FixedBirthData objects for both persons using actual birth data
      final person1BirthData = FixedBirthData(
        birthDateTime: person1BirthDateTime,
        latitude: person1Latitude,
        longitude: person1Longitude,
        rashi: person1Rashi,
        nakshatra: person1Nakshatra,
        pada: PadaData(
          number: person1Pada,
          name: 'Pada $person1Pada',
          description: 'Pada $person1Pada',
          startLongitude: 0.0,
          endLongitude: 0.0,
        ),
        dasha: DashaData(
          currentLord: Planet.sun,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
          remaining: const Duration(days: 365),
          progress: 0.0,
          allPeriods: [],
          calculatedAt: DateTime.now(),
        ),
        birthChart: BirthChart(
          houseLords: {},
          planetHouses: {},
          planetRashis: {},
          planetNakshatras: {},
          calculatedAt: DateTime.now(),
        ),
        calculatedAt: DateTime.now(),
      );

      final person2BirthData = FixedBirthData(
        birthDateTime: person2BirthDateTime,
        latitude: person2Latitude,
        longitude: person2Longitude,
        rashi: person2Rashi,
        nakshatra: person2Nakshatra,
        pada: PadaData(
          number: person2Pada,
          name: 'Pada $person2Pada',
          description: 'Pada $person2Pada',
          startLongitude: 0.0,
          endLongitude: 0.0,
        ),
        dasha: DashaData(
          currentLord: Planet.sun,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
          remaining: const Duration(days: 365),
          progress: 0.0,
          allPeriods: [],
          calculatedAt: DateTime.now(),
        ),
        birthChart: BirthChart(
          houseLords: {},
          planetHouses: {},
          planetRashis: {},
          planetNakshatras: {},
          calculatedAt: DateTime.now(),
        ),
        calculatedAt: DateTime.now(),
      );

      // Use the new getDetailedMatching method that provides complete detailed scores
      // This method accepts UTC datetime and internally calls getMinimalBirthData
      // then performs complete kundali matching with all 8 kootas
      final detailedMatchingResult = await AstrologyLibrary.getDetailedMatching(
        person1: person1BirthData,
        person2: person2BirthData,
      );

      // Extract the complete detailed matching data
      final ashtaKoota = detailedMatchingResult.ashtaKoota;
      final compatibility = detailedMatchingResult.compatibility;

      // Debug: Log the actual koota scores
      print('🔍 DEBUG: AshtaKoota totalScore: ${ashtaKoota.totalScore}');
      print('🔍 DEBUG: AshtaKoota kootaScores: ${ashtaKoota.kootaScores}');
      print('🔍 DEBUG: Compatibility overallScore: ${compatibility.overallScore}');

      // Debug: Log the birth data being used
      print(
          '🔍 DEBUG: Person1 birth data: ${person1BirthData.birthDateTime}, ${person1BirthData.latitude}, ${person1BirthData.longitude}');
      print(
          '🔍 DEBUG: Person2 birth data: ${person2BirthData.birthDateTime}, ${person2BirthData.latitude}, ${person2BirthData.longitude}');

      // Return complete detailed scores with individual koota breakdown
      return {
        // Overall compatibility
        'overallScore': compatibility.overallScore,
        'level': compatibility.level,
        'recommendation': compatibility.recommendation,
        'totalPoints': ashtaKoota.totalScore,

        // Individual koota scores (0-36 total)
        'varnaScore': ashtaKoota.kootaScores['Varna'] ?? 0,
        'vashyaScore': ashtaKoota.kootaScores['Vashya'] ?? 0,
        'taraScore': ashtaKoota.kootaScores['Tara'] ?? 0,
        'yoniScore': ashtaKoota.kootaScores['Yoni'] ?? 0,
        'grahaMaitriScore': ashtaKoota.kootaScores['Graha Maitri'] ?? 0,
        'ganaScore': ashtaKoota.kootaScores['Gana'] ?? 0,
        'bhakootScore': ashtaKoota.kootaScores['Bhakoot'] ?? 0,
        'nadiScore': ashtaKoota.kootaScores['Nadi'] ?? 0,

        // Compatibility verdict
        'compatibilityLevel': ashtaKoota.compatibilityLevel,
        'compatibilityRecommendation': ashtaKoota.recommendation,
        'insights': ashtaKoota.insights,

        // Birth details (using English names)
        'person1Nakshatram': person1Nakshatra.englishName,
        'person1Raasi': person1Rashi.englishName,
        'person1Pada': person1Pada.toString(),
        'person2Nakshatram': person2Nakshatra.englishName,
        'person2Raasi': person2Rashi.englishName,
        'person2Pada': person2Pada.toString(),
      };
    } catch (e) {
      print('🔍 DEBUG: Error in astrology library detailed matching calculation: $e');
      return {
        'overallScore': 0.5,
        'level': 'Moderate',
        'recommendation': 'Compatibility calculation failed',
        'varnaScore': 0,
        'vashyaScore': 0,
        'taraScore': 0,
        'yoniScore': 0,
        'grahaMaitriScore': 0,
        'ganaScore': 0,
        'bhakootScore': 0,
        'nadiScore': 0,
        // Include actual nakshatram and raasi data even in error case (using English names)
        'person1Nakshatram': person1Nakshatra.englishName,
        'person1Raasi': person1Rashi.englishName,
        'person1Pada': person1Pada.toString(),
        'person2Nakshatram': person2Nakshatra.englishName,
        'person2Raasi': person2Rashi.englishName,
        'person2Pada': person2Pada.toString(),
      };
    }
  }
}
