/// Matching Repository Interface
///
/// Domain interface for matching operations
library;

import 'package:flutter/material.dart';
import '../../../../core/utils/either.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';

/// Matching result data
class MatchingResult {
  final double compatibilityScore;
  final Map<String, String> kootaDetails;
  final String level;
  final String recommendation;

  const MatchingResult({
    required this.compatibilityScore,
    required this.kootaDetails,
    required this.level,
    required this.recommendation,
  });
}

/// Partner data for matching
class PartnerData {
  final String name;
  final DateTime dateOfBirth;
  final TimeOfDay timeOfBirth;
  final String placeOfBirth;
  final double latitude;
  final double longitude;

  const PartnerData({
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.latitude,
    required this.longitude,
  });
}

/// Matching repository interface
abstract class MatchingRepository {
  /// Perform compatibility matching with both persons' data
  Future<Result<MatchingResult>> performMatching(PartnerData person1Data, PartnerData person2Data,
      {AyanamshaType? ayanamsha});
}
