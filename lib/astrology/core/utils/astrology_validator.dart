/// High-Precision Astrology Validator
///
/// This class provides comprehensive validation for all astrological calculations
/// to ensure maximum accuracy and prevent invalid inputs.
library;

import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';

/// Comprehensive validation system for astrological calculations
class AstrologyValidator {
  // Prevent instantiation
  AstrologyValidator._();

  // Validation constants
  static const double _minLatitude = -90.0;
  static const double _maxLatitude = 90.0;
  static const double _minLongitude = -180.0;
  static const double _maxLongitude = 180.0;
  static const double _minJulianDay = 1721425.5; // January 1, 1 CE
  static const double _maxJulianDay = 2469807.5; // January 1, 3000 CE

  // ============================================================================
  // INPUT VALIDATION METHODS
  // ============================================================================

  /// Validate birth date and time
  static ValidationResult validateBirthDateTime(DateTime birthDateTime) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if date is in the future
    if (birthDateTime.isAfter(DateTime.now())) {
      errors.add('Birth date cannot be in the future');
    }

    // Check if date is too far in the past
    final minDate = DateTime(1900, 1, 1);
    if (birthDateTime.isBefore(minDate)) {
      warnings.add('Birth date is very old (before 1900), accuracy may be reduced');
    }

    // Check if date is too far in the future
    final maxDate = DateTime(2100, 12, 31);
    if (birthDateTime.isAfter(maxDate)) {
      warnings.add('Birth date is very far in the future, accuracy may be reduced');
    }

    // Check for valid date components
    if (birthDateTime.year < 1 || birthDateTime.year > 3000) {
      errors.add('Invalid year: ${birthDateTime.year}');
    }

    if (birthDateTime.month < 1 || birthDateTime.month > 12) {
      errors.add('Invalid month: ${birthDateTime.month}');
    }

    if (birthDateTime.day < 1 || birthDateTime.day > 31) {
      errors.add('Invalid day: ${birthDateTime.day}');
    }

    if (birthDateTime.hour < 0 || birthDateTime.hour > 23) {
      errors.add('Invalid hour: ${birthDateTime.hour}');
    }

    if (birthDateTime.minute < 0 || birthDateTime.minute > 59) {
      errors.add('Invalid minute: ${birthDateTime.minute}');
    }

    if (birthDateTime.second < 0 || birthDateTime.second > 59) {
      errors.add('Invalid second: ${birthDateTime.second}');
    }

    // Check for valid date (e.g., February 30th)
    try {
      DateTime(birthDateTime.year, birthDateTime.month, birthDateTime.day);
    } catch (e) {
      errors.add('Invalid date: ${birthDateTime.day}/${birthDateTime.month}/${birthDateTime.year}');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate calendar date and time (allows future dates for calendar viewing)
  static ValidationResult validateCalendarDateTime(DateTime dateTime) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if date is too far in the past
    final minDate = DateTime(1900, 1, 1);
    if (dateTime.isBefore(minDate)) {
      warnings.add('Date is very old (before 1900), accuracy may be reduced');
    }

    // Check if date is too far in the future
    final maxDate = DateTime(2100, 12, 31);
    if (dateTime.isAfter(maxDate)) {
      warnings.add('Date is very far in the future, accuracy may be reduced');
    }

    // Check for valid date components
    if (dateTime.year < 1 || dateTime.year > 3000) {
      errors.add('Invalid year: ${dateTime.year}');
    }

    if (dateTime.month < 1 || dateTime.month > 12) {
      errors.add('Invalid month: ${dateTime.month}');
    }

    if (dateTime.day < 1 || dateTime.day > 31) {
      errors.add('Invalid day: ${dateTime.day}');
    }

    if (dateTime.hour < 0 || dateTime.hour > 23) {
      errors.add('Invalid hour: ${dateTime.hour}');
    }

    if (dateTime.minute < 0 || dateTime.minute > 59) {
      errors.add('Invalid minute: ${dateTime.minute}');
    }

    if (dateTime.second < 0 || dateTime.second > 59) {
      errors.add('Invalid second: ${dateTime.second}');
    }

    // Check for valid date (e.g., February 30th)
    try {
      DateTime(dateTime.year, dateTime.month, dateTime.day);
    } catch (e) {
      errors.add('Invalid date: ${dateTime.day}/${dateTime.month}/${dateTime.year}');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate geographical coordinates
  static ValidationResult validateCoordinates(double latitude, double longitude) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate latitude
    if (latitude < _minLatitude || latitude > _maxLatitude) {
      errors.add('Invalid latitude: $latitude. Must be between $_minLatitude and $_maxLatitude');
    }

    // Validate longitude
    if (longitude < _minLongitude || longitude > _maxLongitude) {
      errors
          .add('Invalid longitude: $longitude. Must be between $_minLongitude and $_maxLongitude');
    }

    // Check for extreme coordinates
    if (latitude.abs() > 85) {
      warnings.add('Extreme latitude: $latitude. Calculations may be less accurate near poles');
    }

    if (longitude.abs() > 170) {
      warnings
          .add('Extreme longitude: $longitude. Calculations may be less accurate near date line');
    }

    // Check for common coordinate errors
    if (latitude == 0.0 && longitude == 0.0) {
      warnings.add('Coordinates (0,0) detected. Please verify this is correct');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate ayanamsha type
  static ValidationResult validateAyanamsha(AyanamshaType ayanamsha) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if ayanamsha is supported
    if (!AyanamshaType.values.contains(ayanamsha)) {
      errors.add('Unsupported ayanamsha type: $ayanamsha');
    }

    // Add warnings for less common ayanamsha types
    if (ayanamsha == AyanamshaType.ayanamshaZero) {
      warnings.add('Zero ayanamsha may not be suitable for Vedic astrology calculations');
    }

    if (ayanamsha == AyanamshaType.ayanamshaUser) {
      warnings.add('User-defined ayanamsha requires custom values to be set');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate calculation precision
  static ValidationResult validatePrecision(CalculationPrecision precision) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if precision is supported
    if (!CalculationPrecision.values.contains(precision)) {
      errors.add('Unsupported precision level: $precision');
    }

    // Add warnings for extreme precision levels
    if (precision == CalculationPrecision.ultra) {
      warnings.add('Ultra precision may significantly impact performance');
    }

    if (precision == CalculationPrecision.ultra) {
      warnings.add('Low precision may reduce calculation accuracy');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate house system
  static ValidationResult validateHouseSystem(HouseSystem houseSystem) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if house system is supported
    if (!HouseSystem.values.contains(houseSystem)) {
      errors.add('Unsupported house system: $houseSystem');
    }

    // Add warnings for less common house systems
    if (houseSystem == HouseSystem.whole) {
      warnings.add('Whole sign houses may not be suitable for all calculations');
    }

    if (houseSystem == HouseSystem.topocentric) {
      warnings.add('Topocentric houses require precise location data');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate nakshatra number
  static ValidationResult validateNakshatraNumber(int nakshatraNumber) {
    final errors = <String>[];
    final warnings = <String>[];

    if (nakshatraNumber < 1 || nakshatraNumber > 27) {
      errors.add('Invalid nakshatra number: $nakshatraNumber. Must be between 1 and 27');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate rashi number
  static ValidationResult validateRashiNumber(int rashiNumber) {
    final errors = <String>[];
    final warnings = <String>[];

    if (rashiNumber < 1 || rashiNumber > 12) {
      errors.add('Invalid rashi number: $rashiNumber. Must be between 1 and 12');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate pada number
  static ValidationResult validatePadaNumber(int padaNumber) {
    final errors = <String>[];
    final warnings = <String>[];

    if (padaNumber < 1 || padaNumber > 4) {
      errors.add('Invalid pada number: $padaNumber. Must be between 1 and 4');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate planet enum
  static ValidationResult validatePlanet(Planet planet) {
    final errors = <String>[];
    final warnings = <String>[];

    if (!Planet.values.contains(planet)) {
      errors.add('Unsupported planet: $planet');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ============================================================================
  // COMPREHENSIVE VALIDATION METHODS
  // ============================================================================

  /// Validate complete birth data input
  static ValidationResult validateBirthDataInput({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
    HouseSystem houseSystem = HouseSystem.placidus,
  }) {
    final allErrors = <String>[];
    final allWarnings = <String>[];

    // Validate birth date and time
    final dateValidation = validateBirthDateTime(birthDateTime);
    allErrors.addAll(dateValidation.errors);
    allWarnings.addAll(dateValidation.warnings);

    // Validate coordinates
    final coordValidation = validateCoordinates(latitude, longitude);
    allErrors.addAll(coordValidation.errors);
    allWarnings.addAll(coordValidation.warnings);

    // Validate ayanamsha
    final ayanamshaValidation = validateAyanamsha(ayanamsha);
    allErrors.addAll(ayanamshaValidation.errors);
    allWarnings.addAll(ayanamshaValidation.warnings);

    // Validate precision
    final precisionValidation = validatePrecision(precision);
    allErrors.addAll(precisionValidation.errors);
    allWarnings.addAll(precisionValidation.warnings);

    // Validate house system
    final houseValidation = validateHouseSystem(houseSystem);
    allErrors.addAll(houseValidation.errors);
    allWarnings.addAll(houseValidation.warnings);

    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }

  /// Validate calendar data input (allows future dates for calendar viewing)
  static ValidationResult validateCalendarDataInput({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    AyanamshaType ayanamsha = AyanamshaType.lahiri,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) {
    final allErrors = <String>[];
    final allWarnings = <String>[];

    // Validate calendar date and time (allows future dates)
    final dateValidation = validateCalendarDateTime(dateTime);
    allErrors.addAll(dateValidation.errors);
    allWarnings.addAll(dateValidation.warnings);

    // Validate coordinates
    final coordValidation = validateCoordinates(latitude, longitude);
    allErrors.addAll(coordValidation.errors);
    allWarnings.addAll(coordValidation.warnings);

    // Validate ayanamsha
    final ayanamshaValidation = validateAyanamsha(ayanamsha);
    allErrors.addAll(ayanamshaValidation.errors);
    allWarnings.addAll(ayanamshaValidation.warnings);

    // Validate precision
    final precisionValidation = validatePrecision(precision);
    allErrors.addAll(precisionValidation.errors);
    allWarnings.addAll(precisionValidation.warnings);

    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }

  /// Validate compatibility calculation input
  static ValidationResult validateCompatibilityInput({
    required FixedBirthData person1,
    required FixedBirthData person2,
    CalculationPrecision precision = CalculationPrecision.ultra,
  }) {
    final allErrors = <String>[];
    final allWarnings = <String>[];

    // Validate person1 birth data
    final person1Validation = validateBirthDataInput(
      birthDateTime: person1.birthDateTime,
      latitude: person1.latitude,
      longitude: person1.longitude,
      ayanamsha: AyanamshaType.lahiri, // Default ayanamsha
      precision: precision,
    );
    allErrors.addAll(person1Validation.errors.map((e) => 'Person 1: $e'));
    allWarnings.addAll(person1Validation.warnings.map((w) => 'Person 1: $w'));

    // Validate person2 birth data
    final person2Validation = validateBirthDataInput(
      birthDateTime: person2.birthDateTime,
      latitude: person2.latitude,
      longitude: person2.longitude,
      ayanamsha: AyanamshaType.lahiri, // Default ayanamsha
      precision: precision,
    );
    allErrors.addAll(person2Validation.errors.map((e) => 'Person 2: $e'));
    allWarnings.addAll(person2Validation.warnings.map((w) => 'Person 2: $w'));

    // Check for same person
    if (person1.birthDateTime == person2.birthDateTime &&
        person1.latitude == person2.latitude &&
        person1.longitude == person2.longitude) {
      allWarnings.add('Both persons have identical birth data');
    }

    // Check for extreme age differences
    final ageDifference = person1.birthDateTime.difference(person2.birthDateTime).abs();
    if (ageDifference.inDays > 365 * 100) {
      // More than 100 years
      allWarnings.add('Extreme age difference detected (${ageDifference.inDays ~/ 365} years)');
    }

    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }

  // ============================================================================
  // CALCULATION VALIDATION METHODS
  // ============================================================================

  /// Validate Julian Day calculation
  static ValidationResult validateJulianDay(double julianDay) {
    final errors = <String>[];
    final warnings = <String>[];

    if (julianDay < _minJulianDay || julianDay > _maxJulianDay) {
      errors.add('Julian Day out of valid range: $julianDay');
    }

    if (julianDay.isNaN || julianDay.isInfinite) {
      errors.add('Invalid Julian Day value: $julianDay');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate longitude values
  static ValidationResult validateLongitude(double longitude) {
    final errors = <String>[];
    final warnings = <String>[];

    if (longitude.isNaN || longitude.isInfinite) {
      errors.add('Invalid longitude value: $longitude');
    }

    // Normalize longitude to 0-360 range
    final normalizedLongitude = longitude % 360.0;
    if (normalizedLongitude < 0) {
      warnings.add('Negative longitude detected: $longitude');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate calculation result consistency
  static ValidationResult validateCalculationConsistency({
    required NakshatraData nakshatra,
    required RashiData rashi,
    required PadaData pada,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate nakshatra number
    final nakshatraValidation = validateNakshatraNumber(nakshatra.number);
    errors.addAll(nakshatraValidation.errors);
    warnings.addAll(nakshatraValidation.warnings);

    // Validate rashi number
    final rashiValidation = validateRashiNumber(rashi.number);
    errors.addAll(rashiValidation.errors);
    warnings.addAll(rashiValidation.warnings);

    // Validate pada number
    final padaValidation = validatePadaNumber(pada.number);
    errors.addAll(padaValidation.errors);
    warnings.addAll(padaValidation.warnings);

    // Check consistency between nakshatra and pada
    if (pada.number < 1 || pada.number > 4) {
      errors.add('Invalid pada number for nakshatra ${nakshatra.name}: ${pada.number}');
    }

    // Note: Ayanamsha validation removed since entities don't have ayanamsha property

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // ============================================================================
  // ERROR HANDLING AND RECOVERY
  // ============================================================================

  /// Get validation error message
  static String getValidationErrorMessage(ValidationResult result) {
    if (result.isValid) return '';

    final buffer = StringBuffer();
    buffer.writeln('Validation failed:');

    for (final error in result.errors) {
      buffer.writeln('  ❌ $error');
    }

    if (result.warnings.isNotEmpty) {
      buffer.writeln('\nWarnings:');
      for (final warning in result.warnings) {
        buffer.writeln('  ⚠️ $warning');
      }
    }

    return buffer.toString();
  }

  /// Get validation summary
  static String getValidationSummary(ValidationResult result) {
    if (result.isValid) {
      return '✅ Validation passed';
    }

    return '❌ Validation failed: ${result.errors.length} errors, ${result.warnings.length} warnings';
  }

  /// Check if validation result has critical errors
  static bool hasCriticalErrors(ValidationResult result) {
    return result.errors.any((error) =>
        error.toLowerCase().contains('invalid') ||
        error.toLowerCase().contains('unsupported') ||
        error.toLowerCase().contains('out of range'));
  }

  /// Get recommended fixes for validation errors
  static List<String> getRecommendedFixes(ValidationResult result) {
    final fixes = <String>[];

    for (final error in result.errors) {
      if (error.contains('latitude')) {
        fixes.add('Ensure latitude is between -90 and 90 degrees');
      } else if (error.contains('longitude')) {
        fixes.add('Ensure longitude is between -180 and 180 degrees');
      } else if (error.contains('birth date')) {
        fixes.add('Ensure birth date is valid and not in the future');
      } else if (error.contains('nakshatra number')) {
        fixes.add('Ensure nakshatra number is between 1 and 27');
      } else if (error.contains('rashi number')) {
        fixes.add('Ensure rashi number is between 1 and 12');
      } else if (error.contains('pada number')) {
        fixes.add('Ensure pada number is between 1 and 4');
      }
    }

    return fixes;
  }
}

/// Validation result container
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
  }
}
