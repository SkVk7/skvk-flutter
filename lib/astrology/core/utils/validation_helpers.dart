/// Validation helper utilities for astrology calculations
///
/// Centralizes all validation logic to avoid code duplication
library;

/// Helper class for range validation
class ValidationHelpers {
  // Prevent instantiation
  ValidationHelpers._();

  /// Validate number is within range
  static void validateRange(int number, int min, int max, String type) {
    if (number < min || number > max) {
      throw ArgumentError('$type must be between $min and $max');
    }
  }

  /// Validate rashi number (1-12)
  static void validateRashiNumber(int rashiNumber) {
    validateRange(rashiNumber, 1, 12, 'Rashi number');
  }

  /// Validate nakshatra number (1-27)
  static void validateNakshatraNumber(int nakshatraNumber) {
    validateRange(nakshatraNumber, 1, 27, 'Nakshatra number');
  }

  /// Validate pada number (1-4)
  static void validatePadaNumber(int padaNumber) {
    validateRange(padaNumber, 1, 4, 'Pada number');
  }

  /// Validate house number (1-12)
  static void validateHouseNumber(int houseNumber) {
    validateRange(houseNumber, 1, 12, 'House number');
  }

  /// Validate planet enum
  static void validatePlanet(dynamic planet) {
    if (planet == null) {
      throw ArgumentError('Planet cannot be null');
    }
  }
}
