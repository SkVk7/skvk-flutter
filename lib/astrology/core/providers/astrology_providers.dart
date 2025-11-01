/// Astrology Providers
///
/// Riverpod providers for astrology services, replacing manual singletons
/// with proper dependency injection and state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';
import '../interfaces/astrology_engine_interface.dart';
import '../interfaces/astrology_logger_interface.dart';
import '../services/swiss_ephemeris_service.dart';
import '../services/astrology_service.dart';
import '../services/astrology_logger_service.dart';
import '../utils/calculation_memoizer.dart';
import '../utils/performance_monitor.dart';
import '../errors/astrology_error_handler.dart';
import '../../engines/astrology_engine.dart';
import '../facades/astrology_facade.dart';
import '../../../features/astrology/services/astrology_business_service.dart';

/// Provider for Swiss Ephemeris Service
final swissEphemerisServiceProvider = Provider<SwissEphemerisServiceInterface>((ref) {
  return SwissEphemerisService.instance;
});

/// Provider for Astrology Logger Service
final astrologyLoggerServiceProvider = Provider<AstrologyLoggerInterface>((ref) {
  return AstrologyLoggerService.instance;
});

/// Provider for Calculation Memoizer
final calculationMemoizerProvider = Provider<CalculationMemoizer>((ref) {
  return CalculationMemoizer.instance;
});

/// Provider for Performance Monitor
final performanceMonitorProvider = Provider<PerformanceMonitor>((ref) {
  return PerformanceMonitor.instance;
});

/// Provider for Astrology Error Handler
final astrologyErrorHandlerProvider = Provider<AstrologyErrorHandler>((ref) {
  return AstrologyErrorHandler.instance;
});

/// Provider for Astrology Engine
final astrologyEngineProvider = Provider<AstrologyEngineInterface>((ref) {
  // Initialize engine (dependencies are handled internally)
  final engine = AstrologyEngine();
  engine.initialize(AstrologyConfig());
  return engine;
});

/// Provider for Astrology Service
final astrologyServiceProvider = Provider<AstrologyServiceInterface>((ref) {
  final engine = ref.watch(astrologyEngineProvider);
  final swissEphemerisService = ref.watch(swissEphemerisServiceProvider);

  return AstrologyService(
    engine: engine,
    swissEphemerisService: swissEphemerisService,
  );
});

/// Provider for Astrology Facade
final astrologyFacadeProvider = Provider<AstrologyFacade>((ref) {
  return AstrologyFacade.instance;
});

/// Provider for Astrology Business Service
final astrologyBusinessServiceProvider = Provider<AstrologyBusinessService>((ref) {
  final facade = ref.watch(astrologyFacadeProvider);
  final logger = ref.watch(astrologyLoggerServiceProvider);
  return AstrologyBusinessService.create(
    astrologyFacade: facade,
    logger: logger,
  );
});

/// Provider for Astrology Config
final astrologyConfigProvider = Provider<AstrologyConfig>((ref) {
  return AstrologyConfig();
});

/// Provider for getting fixed birth data
final getFixedBirthDataProvider = FutureProvider.family<
    FixedBirthData,
    ({
      DateTime birthDateTime,
      double latitude,
      double longitude,
      bool isUserData,
      AyanamshaType ayanamsha,
      CalculationPrecision precision,
    })>((ref, params) async {
  final astrologyService = ref.watch(astrologyServiceProvider);

  return await astrologyService.getFixedBirthData(
    birthDateTime: params.birthDateTime,
    latitude: params.latitude,
    longitude: params.longitude,
    isUserData: params.isUserData,
    ayanamsha: params.ayanamsha,
    precision: params.precision,
  );
});

/// Provider for getting minimal birth data
final getMinimalBirthDataProvider = FutureProvider.family<
    Map<String, dynamic>,
    ({
      DateTime birthDateTime,
      double latitude,
      double longitude,
      AyanamshaType ayanamsha,
      CalculationPrecision precision,
    })>((ref, params) async {
  final astrologyService = ref.watch(astrologyServiceProvider);

  return await astrologyService.getMinimalBirthData(
    birthDateTime: params.birthDateTime,
    latitude: params.latitude,
    longitude: params.longitude,
    ayanamsha: params.ayanamsha,
    precision: params.precision,
  );
});

/// Provider for calculating compatibility
final calculateCompatibilityProvider = FutureProvider.family<
    CompatibilityResult,
    ({
      FixedBirthData person1,
      FixedBirthData person2,
      CalculationPrecision precision,
    })>((ref, params) async {
  final astrologyService = ref.watch(astrologyServiceProvider);

  return await astrologyService.calculateCompatibility(
    person1: params.person1,
    person2: params.person2,
    precision: params.precision,
  );
});

/// Provider for getting current dasha
final getCurrentDashaProvider = FutureProvider.family<
    DashaData,
    ({
      FixedBirthData birthData,
      DateTime? currentDateTime,
      CalculationPrecision precision,
    })>((ref, params) async {
  final astrologyService = ref.watch(astrologyServiceProvider);

  return await astrologyService.getCurrentDasha(
    birthData: params.birthData,
    currentDateTime: params.currentDateTime,
    precision: params.precision,
  );
});

/// Provider for calculating planetary positions
final calculatePlanetaryPositionsProvider = FutureProvider.family<
    PlanetaryPositions,
    ({
      DateTime dateTime,
      double latitude,
      double longitude,
      AyanamshaType ayanamsha,
      CalculationPrecision precision,
    })>((ref, params) async {
  final astrologyService = ref.watch(astrologyServiceProvider);

  return await astrologyService.calculatePlanetaryPositions(
    dateTime: params.dateTime,
    latitude: params.latitude,
    longitude: params.longitude,
    ayanamsha: params.ayanamsha,
    precision: params.precision,
  );
});
