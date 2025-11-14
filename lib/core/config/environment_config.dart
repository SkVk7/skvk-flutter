/// Environment Configuration
///
/// Centralized environment configuration management
/// Supports multiple environments: dev, staging, production
library;

import 'package:flutter/foundation.dart';
import 'package:skvk_application/core/config/app_config.dart';

/// Environment configuration manager
class EnvironmentConfig {
  /// Current environment
  static Environment get currentEnvironment {
    const env = String.fromEnvironment('ENV');
    if (env.isNotEmpty) {
      switch (env.toLowerCase()) {
        case 'dev':
        case 'development':
          return Environment.dev;
        case 'sit':
          return Environment.sit;
        case 'uat':
          return Environment.uat;
        case 'uat2':
          return Environment.uat2;
        case 'prod':
        case 'production':
          return Environment.prod;
        default:
          break;
      }
    }

    // Fallback to build mode
    if (kReleaseMode) {
      return Environment.prod;
    } else {
      return Environment.dev;
    }
  }

  /// Get current app configuration
  static AppConfig get current => AppConfig.forEnvironment(currentEnvironment);

  /// Check if running in production
  static bool get isProduction => currentEnvironment == Environment.prod;

  /// Check if running in development
  static bool get isDevelopment => currentEnvironment == Environment.dev;

  /// Check if running in testing environment
  static bool get isTesting => [
        Environment.sit,
        Environment.uat,
        Environment.uat2,
      ].contains(currentEnvironment);

  /// Get environment name
  static String get environmentName => currentEnvironment.name.toUpperCase();

  /// Get API base URL for current environment
  static String get apiBaseUrl => current.apiBaseUrl;

  /// Get workers base URL for current environment
  static String get workersBaseUrl => current.workersBaseUrl;

  /// Get API key for current environment
  static String get apiKey => current.apiKey;

  /// Get API headers for current environment
  static Map<String, String> get apiHeaders => current.apiHeaders;

  /// Check if logging is enabled
  static bool get enableLogging => current.enableLogging;

  /// Check if crash reporting is enabled
  static bool get enableCrashReporting => current.enableCrashReporting;

  /// Check if analytics is enabled
  static bool get enableAnalytics => current.enableAnalytics;

  /// Get app name for current environment
  static String get appName => current.appName;

  /// Get app version for current environment
  static String get version => current.version;

  /// Get timeout configuration
  static Map<String, int> get timeoutConfig => current.timeoutConfig;

  /// Get connect timeout in milliseconds
  static int get connectTimeout => current.connectTimeout;

  /// Get receive timeout in milliseconds
  static int get receiveTimeout => current.receiveTimeout;
}
