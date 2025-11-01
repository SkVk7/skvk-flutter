/// Get Daily Predictions Use Case
///
/// Business logic for generating daily astrological predictions
/// Extracted from UI layer to domain layer following Clean Architecture
library;

import '../../../../astrology/core/entities/astrology_entities.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';

/// Use case for getting daily predictions
class GetDailyPredictionsUseCase {
  final AstrologyFacade _astrologyFacade;

  GetDailyPredictionsUseCase({required AstrologyFacade astrologyFacade})
      : _astrologyFacade = astrologyFacade;

  /// Execute the daily predictions use case
  Future<Result<Map<String, String>>> call({
    required FixedBirthData birthData,
    required DateTime date,
  }) async {
    try {
      // Get timezone from user's location
      final timezoneId = await _astrologyFacade.getTimezoneFromLocation(
        birthData.latitude,
        birthData.longitude,
      );

      // Get current planetary positions for accurate predictions
      final currentPositions = await _astrologyFacade.calculatePlanetaryPositions(
        localDateTime: date,
        timezoneId: timezoneId,
        latitude: birthData.latitude,
        longitude: birthData.longitude,
        precision: CalculationPrecision.ultra,
      );

      // Generate predictions based on current positions
      final predictions = await _generatePredictionsFromPositions(
        birthData,
        currentPositions,
        date,
      );

      return ResultHelper.success(predictions);
    } catch (e) {
      return ResultHelper.failure(
        CalculationFailure(message: 'Failed to generate daily predictions: $e'),
      );
    }
  }

  /// Generate predictions from planetary positions
  Future<Map<String, String>> _generatePredictionsFromPositions(
    FixedBirthData birthData,
    PlanetaryPositions currentPositions,
    DateTime date,
  ) async {
    // Get nakshatra-based predictions
    final nakshatraPredictions = _getNakshatraBasedPredictions(
      birthData.nakshatra.number,
      birthData.nakshatra.name,
    );

    // Get rashi-based predictions
    final rashiPredictions = _getRashiBasedPredictions(
      birthData.rashi.number,
      birthData.rashi.name,
    );

    // Get dasha-based predictions
    final dashaPredictions = _getDashaBasedPredictions(
      birthData.dasha.currentLord,
    );

    // Get transit-based predictions
    final transitPredictions = _getTransitBasedPredictions(
      currentPositions,
      birthData,
    );

    // Combine all predictions
    return {
      'nakshatra': birthData.nakshatra.name,
      'rashi': birthData.rashi.name,
      'dasha':
          '${birthData.dasha.currentLord} (${birthData.dasha.remaining.inDays} days remaining)',
      'general_prediction': nakshatraPredictions['general'] ?? 'Positive day ahead',
      'love_prediction': rashiPredictions['love'] ?? 'Harmony in relationships',
      'career_prediction': dashaPredictions['career'] ?? 'Good opportunities',
      'health_prediction': transitPredictions['health'] ?? 'Maintain good health',
      'lucky_color': _getLuckyColor(birthData.nakshatra.number),
      'lucky_number': _getLuckyNumber(birthData.rashi.number),
      'lucky_time': _getLuckyTime(birthData.nakshatra.number),
    };
  }

  /// Get nakshatra-based predictions
  Map<String, String> _getNakshatraBasedPredictions(int nakshatraNumber, String nakshatraName) {
    final predictions = {
      1: {'general': 'New beginnings and fresh energy', 'love': 'Romantic opportunities'},
      2: {'general': 'Financial gains and stability', 'love': 'Deep emotional connections'},
      3: {'general': 'Communication and learning', 'love': 'Intellectual compatibility'},
      // Add more nakshatra predictions...
    };

    return predictions[nakshatraNumber] ??
        {
          'general': 'Positive energy from $nakshatraName',
          'love': 'Harmony in relationships',
        };
  }

  /// Get rashi-based predictions
  Map<String, String> _getRashiBasedPredictions(int rashiNumber, String rashiName) {
    final predictions = {
      1: {'love': 'Passionate relationships', 'career': 'Leadership opportunities'},
      2: {'love': 'Stable partnerships', 'career': 'Financial growth'},
      3: {'love': 'Intellectual connections', 'career': 'Communication skills'},
      // Add more rashi predictions...
    };

    return predictions[rashiNumber] ??
        {
          'love': 'Harmony in relationships',
          'career': 'Good opportunities ahead',
        };
  }

  /// Get dasha-based predictions
  Map<String, String> _getDashaBasedPredictions(Planet currentLord) {
    final predictions = {
      Planet.sun: {'career': 'Leadership opportunities', 'health': 'Vitality and energy'},
      Planet.moon: {'career': 'Emotional intelligence', 'health': 'Mental well-being'},
      Planet.mars: {'career': 'Action and initiative', 'health': 'Physical strength'},
      // Add more dasha predictions...
    };

    return predictions[currentLord] ??
        {
          'career': 'Good opportunities ahead',
          'health': 'Maintain good health',
        };
  }

  /// Get transit-based predictions
  Map<String, String> _getTransitBasedPredictions(
    PlanetaryPositions currentPositions,
    FixedBirthData birthData,
  ) {
    // Analyze current planetary positions for predictions
    final healthPrediction = _analyzeHealthTransits(currentPositions);
    final careerPrediction = _analyzeCareerTransits(currentPositions);
    final lovePrediction = _analyzeLoveTransits(currentPositions);

    return {
      'health': healthPrediction,
      'career': careerPrediction,
      'love': lovePrediction,
    };
  }

  /// Analyze health transits
  String _analyzeHealthTransits(PlanetaryPositions positions) {
    // Analyze planetary positions for health predictions
    if (positions.positions[Planet.mars]?.isRetrograde == true) {
      return 'Focus on physical health and energy management';
    }
    return 'Maintain good health practices';
  }

  /// Analyze career transits
  String _analyzeCareerTransits(PlanetaryPositions positions) {
    // Analyze planetary positions for career predictions
    if (positions.positions[Planet.jupiter]?.speed != null &&
        positions.positions[Planet.jupiter]!.speed > 0) {
      return 'Good opportunities for growth and expansion';
    }
    return 'Steady progress in career';
  }

  /// Analyze love transits
  String _analyzeLoveTransits(PlanetaryPositions positions) {
    // Analyze planetary positions for love predictions
    if (positions.positions[Planet.venus]?.isRetrograde == true) {
      return 'Review and strengthen existing relationships';
    }
    return 'Harmony in relationships';
  }

  /// Get lucky color based on nakshatra
  String _getLuckyColor(int nakshatraNumber) {
    const colors = [
      'Red',
      'Orange',
      'Yellow',
      'Green',
      'Blue',
      'Indigo',
      'Violet',
      'Pink',
      'Gold',
      'Silver',
      'White',
      'Black',
      'Brown',
      'Purple',
      'Turquoise',
      'Coral',
      'Lavender',
      'Crimson',
      'Emerald',
      'Sapphire',
      'Ruby',
      'Amber',
      'Pearl',
      'Diamond',
      'Opal',
      'Topaz',
      'Garnet'
    ];
    return colors[(nakshatraNumber - 1) % colors.length];
  }

  /// Get lucky number based on rashi
  String _getLuckyNumber(int rashiNumber) {
    const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    return numbers[(rashiNumber - 1) % numbers.length].toString();
  }

  /// Get lucky time based on nakshatra
  String _getLuckyTime(int nakshatraNumber) {
    const times = [
      '6:00 AM - 8:00 AM',
      '8:00 AM - 10:00 AM',
      '10:00 AM - 12:00 PM',
      '12:00 PM - 2:00 PM',
      '2:00 PM - 4:00 PM',
      '4:00 PM - 6:00 PM',
      '6:00 PM - 8:00 PM',
      '8:00 PM - 10:00 PM',
      '10:00 PM - 12:00 AM',
      '12:00 AM - 2:00 AM',
      '2:00 AM - 4:00 AM',
      '4:00 AM - 6:00 AM'
    ];
    return times[(nakshatraNumber - 1) % times.length];
  }
}
