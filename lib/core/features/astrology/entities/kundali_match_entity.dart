/// Kundali match entity
///
/// This represents the core business object for kundali matching results
/// following Clean Architecture principles
library;

import 'package:equatable/equatable.dart';

/// Kundali match result entity
class KundaliMatchEntity extends Equatable {
  final String userId;
  final String partnerId;
  final int totalScore;
  final Map<String, int> kootaScores;
  final String compatibilityLevel;
  final String recommendation;
  final MatchDetailsEntity matchDetails;
  final DateTime calculatedAt;
  final String calculationMethod;

  const KundaliMatchEntity({
    required this.userId,
    required this.partnerId,
    required this.totalScore,
    required this.kootaScores,
    required this.compatibilityLevel,
    required this.recommendation,
    required this.matchDetails,
    required this.calculatedAt,
    required this.calculationMethod,
  });

  @override
  List<Object?> get props => [
        userId,
        partnerId,
        totalScore,
        kootaScores,
        compatibilityLevel,
        recommendation,
        matchDetails,
        calculatedAt,
        calculationMethod,
      ];
}

/// Match details entity
class MatchDetailsEntity extends Equatable {
  final PersonAstrologyDataEntity currentUser;
  final PersonAstrologyDataEntity partner;

  const MatchDetailsEntity({
    required this.currentUser,
    required this.partner,
  });

  @override
  List<Object?> get props => [currentUser, partner];
}

/// Person astrology data entity for matching
class PersonAstrologyDataEntity extends Equatable {
  final int moonNakshatra;
  final int moonPada;
  final int moonRashi;
  final String nakshatraName;
  final String rashiName;

  const PersonAstrologyDataEntity({
    required this.moonNakshatra,
    required this.moonPada,
    required this.moonRashi,
    required this.nakshatraName,
    required this.rashiName,
  });

  @override
  List<Object?> get props => [
        moonNakshatra,
        moonPada,
        moonRashi,
        nakshatraName,
        rashiName,
      ];
}
