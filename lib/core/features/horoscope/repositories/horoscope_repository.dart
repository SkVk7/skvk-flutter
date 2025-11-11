/// Horoscope Repository Interface
///
/// Domain interface for horoscope operations
library;

import '../../../utils/either.dart';

/// Horoscope data entity
class HoroscopeData {
  final String nakshatram;
  final int pada;
  final String raasi;
  final String luckyNumber;
  final String luckyColor;
  final String currentDasha;
  final String upcomingDasha;
  final String generalPrediction;
  final String careerPrediction;
  final String healthPrediction;

  const HoroscopeData({
    required this.nakshatram,
    required this.pada,
    required this.raasi,
    required this.luckyNumber,
    required this.luckyColor,
    required this.currentDasha,
    required this.upcomingDasha,
    required this.generalPrediction,
    required this.careerPrediction,
    required this.healthPrediction,
  });
}

/// Horoscope repository interface
abstract class HoroscopeRepository {
  /// Generate horoscope data for user
  Future<Result<HoroscopeData>> generateHoroscope();

  /// Get user birth data for horoscope
  Future<Result<Map<String, dynamic>?>> getUserBirthData();
}
