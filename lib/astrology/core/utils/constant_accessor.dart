/// Centralized constant accessor to eliminate duplicate array access patterns
///
/// Provides type-safe access to astrological constants with built-in validation
library;

import '../enums/astrology_enums.dart';
import '../constants/astrology_constants.dart';
import 'validation_helpers.dart';

/// Generic constant accessor with validation
class ConstantAccessor {
  // Prevent instantiation
  ConstantAccessor._();

  /// Generic method to safely access array constants
  static T getFromArray<T>(List<T> array, int index, String type, int min, int max) {
    ValidationHelpers.validateRange(index, min, max, type);
    return array[index - 1]; // Convert 1-based to 0-based index
  }
}

/// Rashi constant accessor
class RashiAccessor {
  RashiAccessor._();

  static String getSanskritName(int number) =>
      ConstantAccessor.getFromArray(RashiConstants.sanskritNames, number, 'Rashi number', 1, 12);

  static String getEnglishName(int number) =>
      ConstantAccessor.getFromArray(RashiConstants.englishNames, number, 'Rashi number', 1, 12);

  static Element getElement(int number) => RashiConstants.getRashiElement(number);

  static Quality getQuality(int number) => RashiConstants.getRashiQuality(number);

  static Planet getLord(int number) => RashiConstants.getRashiLord(number);

  static String getSymbol(int number) =>
      ConstantAccessor.getFromArray(RashiConstants.symbols, number, 'Rashi number', 1, 12);

  static double getStartLongitude(int number) => (number - 1) * AstrologyConstants.degreesPerRashi;

  static double getEndLongitude(int number) => number * AstrologyConstants.degreesPerRashi;
}

/// Nakshatra constant accessor
class NakshatraAccessor {
  NakshatraAccessor._();

  static String getSanskritName(int number) => ConstantAccessor.getFromArray(
      NakshatraConstants.sanskritNames, number, 'Nakshatra number', 1, 27);

  static String getEnglishName(int number) => ConstantAccessor.getFromArray(
      NakshatraConstants.englishNames, number, 'Nakshatra number', 1, 27);

  static Planet getLord(int number) =>
      ConstantAccessor.getFromArray(NakshatraConstants.lords, number, 'Nakshatra number', 1, 27);

  static String getDeity(int number) =>
      ConstantAccessor.getFromArray(NakshatraConstants.deities, number, 'Nakshatra number', 1, 27);

  static String getSymbol(int number) =>
      ConstantAccessor.getFromArray(NakshatraConstants.symbols, number, 'Nakshatra number', 1, 27);

  static String getGender(int number) =>
      ConstantAccessor.getFromArray(NakshatraConstants.genders, number, 'Nakshatra number', 1, 27)
          .name;

  static String getGuna(int number) =>
      ConstantAccessor.getFromArray(NakshatraConstants.gunas, number, 'Nakshatra number', 1, 27)
          .name;

  static String getYoni(int number) =>
      ConstantAccessor.getFromArray(NakshatraConstants.yonis, number, 'Nakshatra number', 1, 27)
          .name;

  static String getNadi(int number) =>
      ConstantAccessor.getFromArray(NakshatraConstants.nadis, number, 'Nakshatra number', 1, 27)
          .name;

  static double getStartLongitude(int number) =>
      (number - 1) * AstrologyConstants.degreesPerNakshatra;

  static double getEndLongitude(int number) => number * AstrologyConstants.degreesPerNakshatra;
}

/// Pada constant accessor
class PadaAccessor {
  PadaAccessor._();

  static String getName(int number) {
    ValidationHelpers.validatePadaNumber(number);
    return number.toString(); // Just return the number, not "Pada 2"
  }

  static double getStartLongitude(int nakshatraNumber, int padaNumber) {
    ValidationHelpers.validateNakshatraNumber(nakshatraNumber);
    ValidationHelpers.validatePadaNumber(padaNumber);
    return (nakshatraNumber - 1) * AstrologyConstants.degreesPerNakshatra +
        (padaNumber - 1) * AstrologyConstants.degreesPerPada;
  }

  static double getEndLongitude(int nakshatraNumber, int padaNumber) {
    ValidationHelpers.validateNakshatraNumber(nakshatraNumber);
    ValidationHelpers.validatePadaNumber(padaNumber);
    return (nakshatraNumber - 1) * AstrologyConstants.degreesPerNakshatra +
        padaNumber * AstrologyConstants.degreesPerPada;
  }
}
