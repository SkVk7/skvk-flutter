/// Production Configuration
///
/// Production-ready configuration for the astrology application
/// Following Flutter best practices and performance optimization
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Production configuration class
class ProductionConfig {
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  /// App configuration
  static const String appName = 'SKVK Astrology';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  /// Performance settings
  static const bool enablePerformanceOverlay = false;
  static const bool enableSemanticsDebugger = false;
  static const bool enableRepaintRainbow = false;
  static const bool enableSlowAnimations = false;

  /// Logging configuration
  static bool get enableLogging => kDebugMode;
  static const bool enableCrashReporting = true;
  static const bool enableAnalytics = true;

  /// Cache configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB
  static const bool enableCacheCompression = true;

  /// Network configuration
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Animation configuration
  static const bool enableAnimations = true;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  /// Security configuration
  static const bool enableBiometricAuth = true;
  static const bool enableDataEncryption = true;
  static const bool enableSecureStorage = true;

  /// Feature flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enableCameraAccess = true;

  /// Astrology configuration
  static const bool enableSwissEphemeris = true;
  static const bool enableHighPrecisionCalculations = true;
  static const bool enableCaching = true;
  static const Duration astrologyCacheExpiration = Duration(hours: 12);

  /// UI configuration
  static const bool enableDarkMode = true;
  static const bool enableResponsiveDesign = true;
  static const bool enableAccessibility = true;
  static const bool enableRTLSupport = true;

  /// Development tools (only in debug mode)
  static bool get enableDevTools => kDebugMode;
  static bool get enableHotReload => kDebugMode;
  static bool get enableInspector => kDebugMode;

  /// Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentConfig() {
    if (_isProduction) {
      return _getProductionConfig();
    } else {
      return _getDevelopmentConfig();
    }
  }

  /// Production environment configuration
  static Map<String, dynamic> _getProductionConfig() {
    return {
      'environment': 'production',
      'debugMode': false,
      'enableLogging': false,
      'enableCrashReporting': true,
      'enableAnalytics': true,
      'enablePerformanceOverlay': false,
      'enableSemanticsDebugger': false,
      'enableRepaintRainbow': false,
      'enableSlowAnimations': false,
      'enableDevTools': false,
      'enableHotReload': false,
      'enableInspector': false,
      'cacheExpiration': cacheExpiration.inMilliseconds,
      'maxCacheSize': maxCacheSize,
      'networkTimeout': networkTimeout.inMilliseconds,
      'maxRetryAttempts': maxRetryAttempts,
      'retryDelay': retryDelay.inMilliseconds,
      'enableAnimations': enableAnimations,
      'defaultAnimationDuration': defaultAnimationDuration.inMilliseconds,
      'fastAnimationDuration': fastAnimationDuration.inMilliseconds,
      'slowAnimationDuration': slowAnimationDuration.inMilliseconds,
      'enableBiometricAuth': enableBiometricAuth,
      'enableDataEncryption': enableDataEncryption,
      'enableSecureStorage': enableSecureStorage,
      'enableOfflineMode': enableOfflineMode,
      'enablePushNotifications': enablePushNotifications,
      'enableLocationServices': enableLocationServices,
      'enableCameraAccess': enableCameraAccess,
      'enableSwissEphemeris': enableSwissEphemeris,
      'enableHighPrecisionCalculations': enableHighPrecisionCalculations,
      'enableCaching': enableCaching,
      'astrologyCacheExpiration': astrologyCacheExpiration.inMilliseconds,
      'enableDarkMode': enableDarkMode,
      'enableResponsiveDesign': enableResponsiveDesign,
      'enableAccessibility': enableAccessibility,
      'enableRTLSupport': enableRTLSupport,
    };
  }

  /// Development environment configuration
  static Map<String, dynamic> _getDevelopmentConfig() {
    return {
      'environment': 'development',
      'debugMode': true,
      'enableLogging': true,
      'enableCrashReporting': false,
      'enableAnalytics': false,
      'enablePerformanceOverlay': false,
      'enableSemanticsDebugger': false,
      'enableRepaintRainbow': false,
      'enableSlowAnimations': false,
      'enableDevTools': true,
      'enableHotReload': true,
      'enableInspector': true,
      'cacheExpiration': const Duration(minutes: 30).inMilliseconds,
      'maxCacheSize': 50, // MB
      'networkTimeout': const Duration(seconds: 60).inMilliseconds,
      'maxRetryAttempts': 5,
      'retryDelay': const Duration(seconds: 1).inMilliseconds,
      'enableAnimations': enableAnimations,
      'defaultAnimationDuration': defaultAnimationDuration.inMilliseconds,
      'fastAnimationDuration': fastAnimationDuration.inMilliseconds,
      'slowAnimationDuration': slowAnimationDuration.inMilliseconds,
      'enableBiometricAuth': false,
      'enableDataEncryption': false,
      'enableSecureStorage': false,
      'enableOfflineMode': true,
      'enablePushNotifications': false,
      'enableLocationServices': true,
      'enableCameraAccess': true,
      'enableSwissEphemeris': enableSwissEphemeris,
      'enableHighPrecisionCalculations': enableHighPrecisionCalculations,
      'enableCaching': enableCaching,
      'astrologyCacheExpiration': const Duration(hours: 1).inMilliseconds,
      'enableDarkMode': enableDarkMode,
      'enableResponsiveDesign': enableResponsiveDesign,
      'enableAccessibility': enableAccessibility,
      'enableRTLSupport': enableRTLSupport,
    };
  }

  /// Check if running in production mode
  static bool get isProduction => _isProduction;

  /// Check if running in development mode
  static bool get isDevelopment => !_isProduction;

  /// Get app version string
  static String get versionString => '$appVersion ($appBuildNumber)';

  /// Get app identifier
  static String get appIdentifier => 'com.skvk.astrology';

  /// Get supported locales
  static List<Locale> get supportedLocales => [
        const Locale('en', 'US'),
        const Locale('hi', 'IN'),
        const Locale('ta', 'IN'),
        const Locale('te', 'IN'),
        const Locale('kn', 'IN'),
        const Locale('ml', 'IN'),
        const Locale('gu', 'IN'),
        const Locale('bn', 'IN'),
        const Locale('mr', 'IN'),
        const Locale('or', 'IN'),
        const Locale('pa', 'IN'),
      ];

  /// Get default locale
  static const Locale defaultLocale = Locale('en', 'US');

  /// Get theme configuration
  static Map<String, dynamic> getThemeConfig() {
    return {
      'primaryColor': 0xFF6B46C1,
      'secondaryColor': 0xFF9333EA,
      'accentColor': 0xFFEC4899,
      'backgroundColor': 0xFFF8FAFC,
      'surfaceColor': 0xFFFFFFFF,
      'errorColor': 0xFFEF4444,
      'warningColor': 0xFFF59E0B,
      'successColor': 0xFF10B981,
      'infoColor': 0xFF3B82F6,
      'textPrimaryColor': 0xFF1F2937,
      'textSecondaryColor': 0xFF6B7280,
      'textDisabledColor': 0xFF9CA3AF,
      'borderColor': 0xFFE5E7EB,
      'dividerColor': 0xFFF3F4F6,
      'shadowColor': 0xFF000000,
      'fontFamily': 'NotoSans',
      'fontSizeSmall': 12.0,
      'fontSizeMedium': 14.0,
      'fontSizeLarge': 16.0,
      'fontSizeXLarge': 18.0,
      'fontSizeXXLarge': 20.0,
      'fontSizeTitle': 24.0,
      'fontSizeHeadline': 28.0,
      'fontSizeDisplay': 32.0,
      'borderRadius': 8.0,
      'borderRadiusSmall': 4.0,
      'borderRadiusLarge': 12.0,
      'borderRadiusXLarge': 16.0,
      'elevation': 2.0,
      'elevationSmall': 1.0,
      'elevationLarge': 4.0,
      'elevationXLarge': 8.0,
    };
  }
}
