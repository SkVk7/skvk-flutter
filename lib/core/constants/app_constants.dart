/// Application Constants
///
/// This file contains all the constants used throughout the application
/// for better maintainability and consistency
library;

class AppConstants {
  // App Information
  static const String appName = 'Vedic Astrology Pro';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your Personal Guide to Life\'s Journey';

  // API Configuration
  static const String baseUrl = 'https://api.vedicastrology.com';
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Cache Configuration
  static const int maxCacheSize = 10000;
  static const int cacheExpirationHours = 24;
  static const int cacheCleanupIntervalMinutes = 30;

  // Performance Configuration
  static const int maxConcurrentCalculations = 4;
  static const int calculationTimeoutSeconds = 10;

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

  // Hindu Calendar Configuration
  static const int maxYearsToShow = 100;
  static const int defaultYearRange = 10;

  // Validation Configuration
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const double minLatitude = -90.0;
  static const double maxLatitude = 90.0;
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;

  // User-Friendly Error Messages
  static const String networkErrorMessage =
      'Unable to connect. Please check your internet connection and try again.';
  static const String calculationErrorMessage =
      'Something went wrong with the calculation. Please try again.';
  static const String validationErrorMessage =
      'Please double-check your information and try again.';
  static const String unknownErrorMessage =
      'Oops! Something unexpected happened. Please try again.';

  // User-Friendly Success Messages
  static const String calculationSuccessMessage = 'Your horoscope is ready!';
  static const String dataSavedMessage = 'Your information has been saved.';
  static const String profileUpdatedMessage =
      'Your profile has been updated successfully.';

  // Hindu Traditional Colors
  static const int primarySaffron = 0xFFFF6B35;
  static const int primaryRed = 0xFFD32F2F;
  static const int primaryGold = 0xFFFFD700;
  static const int primaryMaroon = 0xFF8B0000;
  static const int primaryOrange = 0xFFFF8C00;

  // Hindu Traditional Fonts
  static const String primaryFontFamily = 'NotoSansDevanagari';
  static const String secondaryFontFamily = 'NotoSans';
  static const String englishFontFamily = 'Poppins';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String cacheKey = 'calculation_cache';
  static const String themeKey = 'app_theme';

  // Feature Flags
  static const bool enableSwissEphemeris = true;
  static const bool enableAdvancedCalculations = true;
  static const bool enableCaching = true;
  static const bool enableAnalytics = false; // Set to true for production
  static const bool enableCrashReporting = false; // Set to true for production
}
