/// Factory classes for creating astrological data objects
///
/// Centralizes object creation to eliminate duplicate construction logic
library;

import '../entities/astrology_entities.dart';
import '../utils/constant_accessor.dart';
import '../utils/astrology_utils.dart';

/// Factory for creating RashiData objects
class RashiDataFactory {
  RashiDataFactory._();

  /// Create RashiData from rashi number
  static RashiData create(int rashiNumber) {
    return RashiData(
      number: rashiNumber,
      name: RashiAccessor.getEnglishName(rashiNumber), // Ensure English-only output
      englishName: RashiAccessor.getEnglishName(rashiNumber),
      element: RashiAccessor.getElement(rashiNumber),
      quality: RashiAccessor.getQuality(rashiNumber),
      lord: RashiAccessor.getLord(rashiNumber),
      symbol: RashiAccessor.getSymbol(rashiNumber),
      startLongitude: RashiAccessor.getStartLongitude(rashiNumber),
      endLongitude: RashiAccessor.getEndLongitude(rashiNumber),
    );
  }

  /// Create RashiData from longitude
  static RashiData fromLongitude(double longitude) {
    final rashiNumber = AstrologyUtils.calculateRashiNumber(longitude);
    return create(rashiNumber);
  }
}

/// Factory for creating NakshatraData objects
class NakshatraDataFactory {
  NakshatraDataFactory._();

  /// Create NakshatraData from nakshatra number
  static NakshatraData create(int nakshatraNumber) {
    return NakshatraData(
      number: nakshatraNumber,
      name: NakshatraAccessor.getEnglishName(nakshatraNumber), // Ensure English-only output
      englishName: NakshatraAccessor.getEnglishName(nakshatraNumber),
      lord: NakshatraAccessor.getLord(nakshatraNumber),
      deity: NakshatraAccessor.getDeity(nakshatraNumber),
      symbol: NakshatraAccessor.getSymbol(nakshatraNumber),
      startLongitude: NakshatraAccessor.getStartLongitude(nakshatraNumber),
      endLongitude: NakshatraAccessor.getEndLongitude(nakshatraNumber),
      gender: NakshatraAccessor.getGender(nakshatraNumber),
      guna: NakshatraAccessor.getGuna(nakshatraNumber),
      yoni: NakshatraAccessor.getYoni(nakshatraNumber),
      nadi: NakshatraAccessor.getNadi(nakshatraNumber),
    );
  }

  /// Create NakshatraData from longitude
  static NakshatraData fromLongitude(double longitude) {
    final nakshatraNumber = AstrologyUtils.calculateNakshatraNumber(longitude);
    return create(nakshatraNumber);
  }
}

/// Factory for creating PadaData objects
class PadaDataFactory {
  PadaDataFactory._();

  /// Create PadaData from nakshatra number and pada number
  static PadaData create(int nakshatraNumber, int padaNumber) {
    return PadaData(
      number: padaNumber,
      name: PadaAccessor.getName(padaNumber),
      description: 'Pada $padaNumber',
      startLongitude: PadaAccessor.getStartLongitude(nakshatraNumber, padaNumber),
      endLongitude: PadaAccessor.getEndLongitude(nakshatraNumber, padaNumber),
    );
  }

  /// Create PadaData from longitude
  static PadaData fromLongitude(double longitude) {
    final nakshatraNumber = AstrologyUtils.calculateNakshatraNumber(longitude);
    final padaNumber = AstrologyUtils.calculatePadaNumber(longitude);
    return create(nakshatraNumber, padaNumber);
  }
}

/// Factory for creating complete astrological data from longitude
class AstrologicalDataFactory {
  AstrologicalDataFactory._();

  /// Create all astrological data (Rashi, Nakshatra, Pada) from longitude
  static ({
    RashiData rashi,
    NakshatraData nakshatra,
    PadaData pada,
  }) createFromLongitude(double longitude) {
    final nakshatraNumber = AstrologyUtils.calculateNakshatraNumber(longitude);
    final padaNumber = AstrologyUtils.calculatePadaNumber(longitude);

    return (
      rashi: RashiDataFactory.fromLongitude(longitude),
      nakshatra: NakshatraDataFactory.fromLongitude(longitude),
      pada: PadaDataFactory.create(nakshatraNumber, padaNumber),
    );
  }
}
