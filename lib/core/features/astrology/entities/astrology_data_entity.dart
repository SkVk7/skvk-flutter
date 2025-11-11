/// Astrology data entity
///
/// This represents the core business object for astrology calculations
/// following Clean Architecture principles
library;

import 'package:equatable/equatable.dart';

/// Core astrology data entity
class AstrologyDataEntity extends Equatable {
  final String userId;
  final DateTime birthDateTime;
  final double latitude;
  final double longitude;
  final String placeOfBirth;
  final MoonDataEntity moonData;
  final AscendantDataEntity ascendantData;
  final Map<String, PlanetDataEntity> planetaryPositions;
  final DashaDataEntity dashaData;
  final FixedAttributesEntity fixedAttributes;
  final DateTime computedAt;
  final String calculationMethod;
  final String accuracy;

  const AstrologyDataEntity({
    required this.userId,
    required this.birthDateTime,
    required this.latitude,
    required this.longitude,
    required this.placeOfBirth,
    required this.moonData,
    required this.ascendantData,
    required this.planetaryPositions,
    required this.dashaData,
    required this.fixedAttributes,
    required this.computedAt,
    required this.calculationMethod,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [
        userId,
        birthDateTime,
        latitude,
        longitude,
        placeOfBirth,
        moonData,
        ascendantData,
        planetaryPositions,
        dashaData,
        fixedAttributes,
        computedAt,
        calculationMethod,
        accuracy,
      ];
}

/// Moon data entity
class MoonDataEntity extends Equatable {
  final int rashi;
  final int nakshatra;
  final int pada;
  final double longitude;
  final double latitude;

  const MoonDataEntity({
    required this.rashi,
    required this.nakshatra,
    required this.pada,
    required this.longitude,
    required this.latitude,
  });

  @override
  List<Object?> get props => [rashi, nakshatra, pada, longitude, latitude];
}

/// Ascendant data entity
class AscendantDataEntity extends Equatable {
  final double longitude;
  final int rashi;
  final double degree;
  final double minute;

  const AscendantDataEntity({
    required this.longitude,
    required this.rashi,
    required this.degree,
    required this.minute,
  });

  @override
  List<Object?> get props => [longitude, rashi, degree, minute];
}

/// Planet data entity
class PlanetDataEntity extends Equatable {
  final String name;
  final double longitude;
  final double latitude;
  final int rashi;
  final int nakshatra;
  final int pada;
  final int house;
  final bool isRetrograde;

  const PlanetDataEntity({
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.rashi,
    required this.nakshatra,
    required this.pada,
    required this.house,
    required this.isRetrograde,
  });

  @override
  List<Object?> get props => [
        name,
        longitude,
        latitude,
        rashi,
        nakshatra,
        pada,
        house,
        isRetrograde,
      ];
}

/// Dasha data entity
class DashaDataEntity extends Equatable {
  final CurrentDashaEntity currentDasha;
  final List<UpcomingDashaEntity> upcomingDashas;
  final int nakshatra;
  final int pada;

  const DashaDataEntity({
    required this.currentDasha,
    required this.upcomingDashas,
    required this.nakshatra,
    required this.pada,
  });

  @override
  List<Object?> get props => [currentDasha, upcomingDashas, nakshatra, pada];
}

/// Current dasha entity
class CurrentDashaEntity extends Equatable {
  final String planet;
  final double remainingYears;
  final DateTime startDate;
  final DateTime endDate;

  const CurrentDashaEntity({
    required this.planet,
    required this.remainingYears,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [planet, remainingYears, startDate, endDate];
}

/// Upcoming dasha entity
class UpcomingDashaEntity extends Equatable {
  final String planet;
  final double yearsFromNow;
  final DateTime startDate;
  final DateTime endDate;

  const UpcomingDashaEntity({
    required this.planet,
    required this.yearsFromNow,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [planet, yearsFromNow, startDate, endDate];
}

/// Fixed attributes entity
class FixedAttributesEntity extends Equatable {
  final String luckyNumber;
  final String luckyColor;
  final String birthStone;
  final List<String> favorableDays;
  final List<String> favorableDirections;

  const FixedAttributesEntity({
    required this.luckyNumber,
    required this.luckyColor,
    required this.birthStone,
    required this.favorableDays,
    required this.favorableDirections,
  });

  @override
  List<Object?> get props => [
        luckyNumber,
        luckyColor,
        birthStone,
        favorableDays,
        favorableDirections,
      ];
}
