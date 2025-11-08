/// Validation utilities for the Vedic Astrology Pro application
library;

/// Validates email format
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

/// Validates phone number format (Indian format)
bool isValidPhoneNumber(String phone) {
  return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
}

/// Validates date of birth (must be in the past)
bool isValidDateOfBirth(DateTime dateOfBirth) {
  return dateOfBirth.isBefore(DateTime.now());
}

/// Validates latitude value
bool isValidLatitude(double latitude) {
  return latitude >= -90.0 && latitude <= 90.0;
}

/// Validates longitude value
bool isValidLongitude(double longitude) {
  return longitude >= -180.0 && longitude <= 180.0;
}

/// Validates name (should not be empty and contain only letters and spaces)
bool isValidName(String name) {
  return name.trim().isNotEmpty &&
      RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim());
}

/// Validates place name (should not be empty)
bool isValidPlaceName(String place) {
  return place.trim().isNotEmpty;
}

/// Validates time of birth (should be valid time)
bool isValidTimeOfBirth(int hour, int minute) {
  return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
}

/// Validates nakshatra number (1-27)
bool isValidNakshatra(int nakshatra) {
  return nakshatra >= 1 && nakshatra <= 27;
}

/// Validates rashi number (1-12)
bool isValidRashi(int rashi) {
  return rashi >= 1 && rashi <= 12;
}

/// Validates pada number (1-4)
bool isValidPada(int pada) {
  return pada >= 1 && pada <= 4;
}
