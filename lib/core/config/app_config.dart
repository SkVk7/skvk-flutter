/// Application configuration management for different environments
/// Supports DEV, SIT, UAT, UAT2, and PROD environments
library;

import 'package:flutter/foundation.dart';

/// Environment types for the application
enum Environment {
  dev,
  sit,
  uat,
  uat2,
  prod,
}

/// Main application configuration class
class AppConfig {
  final Environment environment;
  final String appName;
  final String version;
  final bool enableLogging;
  final bool enableCrashReporting;
  final bool enableAnalytics;
  final String apiBaseUrl;
  final String workersBaseUrl; // Cloudflare Workers URL for content API
  final String apiKey;
  final int connectTimeout;
  final int receiveTimeout;

  const AppConfig._({
    required this.environment,
    required this.appName,
    required this.version,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.apiBaseUrl,
    required this.workersBaseUrl,
    required this.apiKey,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  /// Development environment configuration
  static const AppConfig dev = AppConfig._(
    environment: Environment.dev,
    appName: 'SKVK Astrology DEV',
    version: '1.0.0-dev',
    enableLogging: true,
    enableCrashReporting: false,
    enableAnalytics: false,
    apiBaseUrl: 'http://localhost:8080',
    workersBaseUrl:
        'https://skvk-media-content-worker.shabarinathkvikask.workers.dev',
    apiKey: 'dev-api-key-12345',
    connectTimeout: 30000,
    receiveTimeout: 30000,
  );

  /// SIT (System Integration Testing) environment configuration
  static const AppConfig sit = AppConfig._(
    environment: Environment.sit,
    appName: 'SKVK Astrology SIT',
    version: '1.0.0-sit',
    enableLogging: true,
    enableCrashReporting: true,
    enableAnalytics: false,
    apiBaseUrl: 'https://sit-api.astrology.com',
    workersBaseUrl:
        'https://skvk-media-content-worker.shabarinathkvikask.workers.dev',
    apiKey: 'sit-api-key-67890',
    connectTimeout: 30000,
    receiveTimeout: 30000,
  );

  /// UAT (User Acceptance Testing) environment configuration
  static const AppConfig uat = AppConfig._(
    environment: Environment.uat,
    appName: 'SKVK Astrology UAT',
    version: '1.0.0-uat',
    enableLogging: true,
    enableCrashReporting: true,
    enableAnalytics: true,
    apiBaseUrl: 'https://uat-api.astrology.com',
    workersBaseUrl:
        'https://skvk-media-content-worker.shabarinathkvikask.workers.dev',
    apiKey: 'uat-api-key-abcdef',
    connectTimeout: 30000,
    receiveTimeout: 30000,
  );

  /// UAT2 (Secondary UAT) environment configuration
  static const AppConfig uat2 = AppConfig._(
    environment: Environment.uat2,
    appName: 'SKVK Astrology UAT2',
    version: '1.0.0-uat2',
    enableLogging: true,
    enableCrashReporting: true,
    enableAnalytics: true,
    apiBaseUrl: 'https://uat2-api.astrology.com',
    workersBaseUrl:
        'https://skvk-media-content-worker.shabarinathkvikask.workers.dev',
    apiKey: 'uat2-api-key-ghijkl',
    connectTimeout: 30000,
    receiveTimeout: 30000,
  );

  /// Production environment configuration
  static const AppConfig prod = AppConfig._(
    environment: Environment.prod,
    appName: 'SKVK Astrology',
    version: '1.0.0',
    enableLogging: false,
    enableCrashReporting: true,
    enableAnalytics: true,
    apiBaseUrl: 'https://api.astrology.com',
    workersBaseUrl:
        'https://skvk-media-content-worker.shabarinathkvikask.workers.dev',
    apiKey: 'prod-api-key-mnopqr',
    connectTimeout: 15000,
    receiveTimeout: 15000,
  );

  /// Get configuration based on current environment
  static AppConfig get current {
    if (kReleaseMode) {
      // In release mode, determine environment from build flavor or default to prod
      return prod;
    } else {
      // In debug mode, use development configuration
      return dev;
    }
  }

  /// Get configuration for specific environment
  static AppConfig forEnvironment(Environment environment) {
    switch (environment) {
      case Environment.dev:
        return dev;
      case Environment.sit:
        return sit;
      case Environment.uat:
        return uat;
      case Environment.uat2:
        return uat2;
      case Environment.prod:
        return prod;
    }
  }

  /// Check if current environment is production
  bool get isProduction => environment == Environment.prod;

  /// Check if current environment is development
  bool get isDevelopment => environment == Environment.dev;

  /// Check if current environment is testing (SIT/UAT/UAT2)
  bool get isTesting => [
        Environment.sit,
        Environment.uat,
        Environment.uat2,
      ].contains(environment);

  /// Get environment-specific API headers
  Map<String, String> get apiHeaders => {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
        'X-Environment': environment.name.toUpperCase(),
        'X-App-Version': version,
      };

  /// Get environment-specific timeout configuration
  Map<String, int> get timeoutConfig => {
        'connectTimeout': connectTimeout,
        'receiveTimeout': receiveTimeout,
      };

  @override
  String toString() {
    return 'AppConfig('
        'environment: ${environment.name}, '
        'appName: $appName, '
        'version: $version, '
        'apiBaseUrl: $apiBaseUrl, '
        'isProduction: $isProduction)';
  }
}

/// Horoscope-specific configuration
class HoroscopeConfig {
  final CalculationPrecision defaultPrecision;
  final bool enableAdvancedCalculations;
  final bool enableCaching;
  final int cacheDurationMinutes;
  final bool enableDetailedAspects;
  final bool enablePerturbationCorrections;

  const HoroscopeConfig({
    this.defaultPrecision = CalculationPrecision.standard,
    this.enableAdvancedCalculations = false,
    this.enableCaching = true,
    this.cacheDurationMinutes = 60,
    this.enableDetailedAspects = true,
    this.enablePerturbationCorrections = false,
  });

  /// Development configuration with all features enabled
  static const HoroscopeConfig development = HoroscopeConfig(
    defaultPrecision: CalculationPrecision.scientific,
    enableAdvancedCalculations: true,
    enableCaching: false,
    cacheDurationMinutes: 0,
    enableDetailedAspects: true,
    enablePerturbationCorrections: true,
  );

  /// Production configuration optimized for performance
  static const HoroscopeConfig production = HoroscopeConfig(
    defaultPrecision: CalculationPrecision.standard,
    enableAdvancedCalculations: false,
    enableCaching: true,
    cacheDurationMinutes: 120,
    enableDetailedAspects: true,
    enablePerturbationCorrections: false,
  );

  /// Get configuration based on app environment
  static HoroscopeConfig forEnvironment(Environment environment) {
    switch (environment) {
      case Environment.dev:
        return development;
      case Environment.sit:
      case Environment.uat:
      case Environment.uat2:
        return production; // Use production settings for testing
      case Environment.prod:
        return production;
    }
  }
}

/// Calculation precision levels for horoscope calculations
enum CalculationPrecision {
  standard, // Standard astrological precision
  high, // High precision for research
  scientific // Maximum scientific precision
}

/// Global configuration instance
final AppConfig appConfig = AppConfig.current;
final HoroscopeConfig horoscopeConfig =
    HoroscopeConfig.forEnvironment(appConfig.environment);
