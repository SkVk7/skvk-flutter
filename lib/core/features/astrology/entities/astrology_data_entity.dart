/// Astrology data entity
///
/// This represents the core business object for astrology calculations
/// following Clean Architecture principles
library;

import 'package:equatable/equatable.dart';

/// Core astrology data entity
class AstrologyDataEntity extends Equatable {
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
  const MoonDataEntity({
    required this.rashi,
    required this.nakshatra,
    required this.pada,
    required this.longitude,
    required this.latitude,
  });
  final int rashi;
  final int nakshatra;
  final int pada;
  final double longitude;
  final double latitude;

  @override
  List<Object?> get props => [rashi, nakshatra, pada, longitude, latitude];
}

/// Ascendant data entity
class AscendantDataEntity extends Equatable {
  const AscendantDataEntity({
    required this.longitude,
    required this.rashi,
    required this.degree,
    required this.minute,
  });
  final double longitude;
  final int rashi;
  final double degree;
  final double minute;

  @override
  List<Object?> get props => [longitude, rashi, degree, minute];
}

/// Planet data entity
class PlanetDataEntity extends Equatable {
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
  final String name;
  final double longitude;
  final double latitude;
  final int rashi;
  final int nakshatra;
  final int pada;
  final int house;
  final bool isRetrograde;

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
  const DashaDataEntity({
    required this.currentDasha,
    required this.upcomingDashas,
    required this.nakshatra,
    required this.pada,
  });
  final CurrentDashaEntity currentDasha;
  final List<UpcomingDashaEntity> upcomingDashas;
  final int nakshatra;
  final int pada;

  @override
  List<Object?> get props => [currentDasha, upcomingDashas, nakshatra, pada];
}

/// Current dasha entity
class CurrentDashaEntity extends Equatable {
  const CurrentDashaEntity({
    required this.planet,
    required this.remainingYears,
    required this.startDate,
    required this.endDate,
  });
  final String planet;
  final double remainingYears;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [planet, remainingYears, startDate, endDate];
}

/// Upcoming dasha entity
class UpcomingDashaEntity extends Equatable {
  const UpcomingDashaEntity({
    required this.planet,
    required this.yearsFromNow,
    required this.startDate,
    required this.endDate,
  });
  final String planet;
  final double yearsFromNow;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [planet, yearsFromNow, startDate, endDate];
}

/// Fixed attributes entity
class FixedAttributesEntity extends Equatable {
  const FixedAttributesEntity({
    required this.luckyNumber,
    required this.luckyColor,
    required this.birthStone,
    required this.favorableDays,
    required this.favorableDirections,
  });
  final String luckyNumber;
  final String luckyColor;
  final String birthStone;
  final List<String> favorableDays;
  final List<String> favorableDirections;

  @override
  List<Object?> get props => [
        luckyNumber,
        luckyColor,
        birthStone,
        favorableDays,
        favorableDirections,
      ];
}
