/// Core entities for astrological calculations
///
/// These entities represent the domain objects for astrological data
/// following Domain-Driven Design principles
library;

import '../enums/astrology_enums.dart';

/// Configuration for astrological calculations
class AstrologyConfig {
  final CalculationPrecision precision;
  final AyanamshaType ayanamsha;
  final HouseSystem houseSystem;
  final bool cacheEnabled;
  final bool swissEphemerisEnabled;
  final String timezone;

  const AstrologyConfig({
    this.precision = CalculationPrecision.ultra,
    this.ayanamsha = AyanamshaType.lahiri,
    this.houseSystem = HouseSystem.placidus,
    this.cacheEnabled = true,
    this.swissEphemerisEnabled = true,
    this.timezone = 'Asia/Kolkata',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AstrologyConfig &&
          runtimeType == other.runtimeType &&
          precision == other.precision &&
          ayanamsha == other.ayanamsha &&
          houseSystem == other.houseSystem &&
          cacheEnabled == other.cacheEnabled &&
          swissEphemerisEnabled == other.swissEphemerisEnabled &&
          timezone == other.timezone;

  @override
  int get hashCode =>
      precision.hashCode ^
      ayanamsha.hashCode ^
      houseSystem.hashCode ^
      cacheEnabled.hashCode ^
      swissEphemerisEnabled.hashCode ^
      timezone.hashCode;
}

/// Fixed birth data that doesn't change
class FixedBirthData {
  final DateTime birthDateTime;
  final double latitude;
  final double longitude;
  final RashiData rashi;
  final NakshatraData nakshatra;
  final PadaData pada;
  final DashaData dasha;
  final BirthChart birthChart;
  final DateTime calculatedAt;

  const FixedBirthData({
    required this.birthDateTime,
    required this.latitude,
    required this.longitude,
    required this.rashi,
    required this.nakshatra,
    required this.pada,
    required this.dasha,
    required this.birthChart,
    required this.calculatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedBirthData &&
          runtimeType == other.runtimeType &&
          birthDateTime == other.birthDateTime &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => birthDateTime.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}

/// Dynamic data that changes over time
class DynamicData {
  final DateTime targetDate;
  final double latitude;
  final double longitude;
  final PlanetaryPositions currentPlanets;
  final List<TransitData> transits;
  final List<FestivalData> festivals;
  final List<MuhurtaData> auspiciousTimes;
  final DateTime calculatedAt;

  const DynamicData({
    required this.targetDate,
    required this.latitude,
    required this.longitude,
    required this.currentPlanets,
    required this.transits,
    required this.festivals,
    required this.auspiciousTimes,
    required this.calculatedAt,
  });
}

/// Individual planetary position data
class PlanetaryPosition {
  final Planet planet;
  final double longitude;
  final double latitude;
  final double distance;
  final double speed;
  final bool isRetrograde;
  final double declination;
  final double rightAscension;

  const PlanetaryPosition({
    required this.planet,
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.speed,
    required this.isRetrograde,
    required this.declination,
    required this.rightAscension,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanetaryPosition &&
          runtimeType == other.runtimeType &&
          planet == other.planet &&
          longitude == other.longitude &&
          latitude == other.latitude &&
          distance == other.distance &&
          speed == other.speed &&
          isRetrograde == other.isRetrograde &&
          declination == other.declination &&
          rightAscension == other.rightAscension;

  @override
  int get hashCode =>
      planet.hashCode ^
      longitude.hashCode ^
      latitude.hashCode ^
      distance.hashCode ^
      speed.hashCode ^
      isRetrograde.hashCode ^
      declination.hashCode ^
      rightAscension.hashCode;
}

/// Planetary positions data
class PlanetaryPositions {
  final Map<Planet, PlanetPosition> positions;
  final DateTime calculatedAt;
  final double latitude;
  final double longitude;

  const PlanetaryPositions({
    required this.positions,
    required this.calculatedAt,
    required this.latitude,
    required this.longitude,
  });

  PlanetPosition? getPlanet(Planet planet) => positions[planet];

  List<PlanetPosition> get allPositions => positions.values.toList();
}

/// Individual planet position
class PlanetPosition {
  final Planet planet;
  final double longitude;
  final double latitude;
  final double distance;
  final double speed;
  final RashiData rashi;
  final NakshatraData nakshatra;
  final PadaData pada;
  final bool isRetrograde;
  final double declination;
  final double rightAscension;

  const PlanetPosition({
    required this.planet,
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.speed,
    required this.rashi,
    required this.nakshatra,
    required this.pada,
    required this.isRetrograde,
    required this.declination,
    required this.rightAscension,
  });
}

/// Rashi (Zodiac Sign) data
class RashiData {
  final int number; // 1-12
  final String name;
  final String englishName;
  final Element element;
  final Quality quality;
  final Planet lord;
  final String symbol;
  final double startLongitude;
  final double endLongitude;

  const RashiData({
    required this.number,
    required this.name,
    required this.englishName,
    required this.element,
    required this.quality,
    required this.lord,
    required this.symbol,
    required this.startLongitude,
    required this.endLongitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RashiData && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;
}

/// Nakshatra data
class NakshatraData {
  final int number; // 1-27
  final String name;
  final String englishName;
  final Planet lord;
  final String deity;
  final String symbol;
  final double startLongitude;
  final double endLongitude;
  final String gender;
  final String guna;
  final String yoni;
  final String nadi;

  const NakshatraData({
    required this.number,
    required this.name,
    required this.englishName,
    required this.lord,
    required this.deity,
    required this.symbol,
    required this.startLongitude,
    required this.endLongitude,
    required this.gender,
    required this.guna,
    required this.yoni,
    required this.nadi,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NakshatraData && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;
}

/// Pada data
class PadaData {
  final int number; // 1-4
  final String name;
  final String description;
  final double startLongitude;
  final double endLongitude;

  const PadaData({
    required this.number,
    required this.name,
    required this.description,
    required this.startLongitude,
    required this.endLongitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PadaData && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;
}

/// Dasha data
class DashaData {
  final Planet currentLord;
  final DateTime startDate;
  final DateTime endDate;
  final Duration remaining;
  final double progress; // 0.0 to 1.0
  final List<DashaPeriod> allPeriods;
  final DateTime calculatedAt;

  const DashaData({
    required this.currentLord,
    required this.startDate,
    required this.endDate,
    required this.remaining,
    required this.progress,
    required this.allPeriods,
    required this.calculatedAt,
  });
}

/// Dasha period
class DashaPeriod {
  final Planet lord;
  final DateTime startDate;
  final DateTime endDate;
  final Duration duration;
  final int years;
  final int months;
  final int days;

  const DashaPeriod({
    required this.lord,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.years,
    required this.months,
    required this.days,
  });
}

/// House position data
class HousePosition {
  final House house;
  final double longitude;
  final double latitude;
  final Planet? lord;
  final String description;
  final DateTime calculatedAt;

  const HousePosition({
    required this.house,
    required this.longitude,
    required this.latitude,
    this.lord,
    required this.description,
    required this.calculatedAt,
  });
}

/// House positions collection
class HousePositions {
  final Map<House, HousePosition> houses;
  final HouseSystem houseSystem;
  final DateTime calculatedAt;

  const HousePositions({
    required this.houses,
    required this.houseSystem,
    required this.calculatedAt,
  });
}

/// Birth chart data
class BirthChart {
  final Map<House, Planet?> houseLords;
  final Map<Planet, House> planetHouses;
  final Map<Planet, RashiData> planetRashis;
  final Map<Planet, NakshatraData> planetNakshatras;
  final DateTime calculatedAt;

  const BirthChart({
    required this.houseLords,
    required this.planetHouses,
    required this.planetRashis,
    required this.planetNakshatras,
    required this.calculatedAt,
  });
}

/// Transit data
class TransitData {
  final Planet planet;
  final RashiData currentRashi;
  final RashiData previousRashi;
  final DateTime entryDate;
  final DateTime exitDate;
  final bool isRetrograde;
  final String description;
  final String impact;

  const TransitData({
    required this.planet,
    required this.currentRashi,
    required this.previousRashi,
    required this.entryDate,
    required this.exitDate,
    required this.isRetrograde,
    required this.description,
    required this.impact,
  });
}

/// Regional calendar information
class RegionalCalendarInfo {
  final RegionalCalendar calendar;
  final String name;
  final String region;
  final String description;
  final List<CalendarCharacteristics> characteristics;
  final Map<String, dynamic> regionalVariations;
  final DateTime calculatedAt;

  const RegionalCalendarInfo({
    required this.calendar,
    required this.name,
    required this.region,
    required this.description,
    required this.characteristics,
    required this.regionalVariations,
    required this.calculatedAt,
  });

  @override
  String toString() => 'RegionalCalendarInfo(calendar: $calendar, region: $region)';
}

/// Festival data with regional support
class FestivalData {
  final String name;
  final String englishName;
  final DateTime date;
  final String description;
  final String significance;
  final bool isAuspicious;
  final String type;
  final RegionalCalendar regionalCalendar;
  final String regionalName;
  final Map<String, dynamic> regionalVariations;
  final DateTime calculatedAt;

  const FestivalData({
    required this.name,
    required this.englishName,
    required this.date,
    required this.description,
    required this.significance,
    required this.isAuspicious,
    required this.type,
    required this.regionalCalendar,
    required this.regionalName,
    required this.regionalVariations,
    required this.calculatedAt,
  });

  @override
  String toString() => 'FestivalData(name: $name, date: $date, region: $regionalCalendar)';
}

/// Muhurta (Auspicious time) data
class MuhurtaData {
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final String purpose;
  final bool isAuspicious;
  final double score; // 0.0 to 1.0

  const MuhurtaData({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.purpose,
    required this.isAuspicious,
    required this.score,
  });
}

/// Ashta Koota matching result
class AshtaKootaResult {
  final int totalScore; // 0-36
  final Map<String, int> kootaScores;
  final String compatibilityLevel;
  final String recommendation;
  final Map<String, String> insights;
  final DateTime calculatedAt;

  const AshtaKootaResult({
    required this.totalScore,
    required this.kootaScores,
    required this.compatibilityLevel,
    required this.recommendation,
    required this.insights,
    required this.calculatedAt,
  });
}

/// Compatibility result
class CompatibilityResult {
  final double overallScore; // 0.0 to 1.0
  final String level;
  final String recommendation;
  final List<String> strengths;
  final List<String> challenges;
  final DateTime calculatedAt;

  const CompatibilityResult({
    required this.overallScore,
    required this.level,
    required this.recommendation,
    required this.strengths,
    required this.challenges,
    required this.calculatedAt,
  });
}

/// Detailed matching result
class DetailedMatchingResult {
  final AshtaKootaResult ashtaKoota;
  final CompatibilityResult compatibility;
  final Map<String, dynamic> additionalAnalysis;
  final DateTime calculatedAt;

  const DetailedMatchingResult({
    required this.ashtaKoota,
    required this.compatibility,
    required this.additionalAnalysis,
    required this.calculatedAt,
  });
}
