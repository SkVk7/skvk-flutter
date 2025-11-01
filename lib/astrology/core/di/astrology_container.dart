/// Astrology Dependency Injection Container
///
/// This container provides proper dependency injection for the astrology library,
/// replacing the singleton anti-pattern with clean, testable dependencies.
library;

import '../entities/astrology_entities.dart';
import '../interfaces/astrology_engine_interface.dart';
import '../interfaces/astrology_logger_interface.dart';
import '../services/swiss_ephemeris_service.dart';
import '../services/astrology_service.dart';
import '../services/astrology_logger_service.dart';
import '../../engines/astrology_engine.dart';
import '../utils/calculation_memoizer.dart';
import '../utils/astrology_utils.dart';
import '../utils/performance_monitor.dart';
import '../errors/astrology_error_handler.dart';

/// Dependency injection container for astrology library
///
/// This container provides proper dependency injection following SOLID principles
/// and eliminates the singleton anti-pattern for better testability and maintainability.
class AstrologyContainer {
  // Dependencies - properly injected, not singletons
  final AstrologyConfig _config;
  final SwissEphemerisServiceInterface _swissEphemerisService;
  final CalculationMemoizer _memoizer;
  final AstrologyEngineInterface _engine;
  final AstrologyServiceInterface _service;
  final PerformanceMonitor _performanceMonitor;
  final AstrologyErrorHandler _errorHandler;
  final AstrologyLoggerInterface _logger;

  bool _isInitialized = false;

  /// Constructor with proper dependency injection
  AstrologyContainer({
    required AstrologyConfig config,
    required SwissEphemerisServiceInterface swissEphemerisService,
    required CalculationMemoizer memoizer,
    required AstrologyEngineInterface engine,
    required AstrologyServiceInterface service,
    required PerformanceMonitor performanceMonitor,
    required AstrologyErrorHandler errorHandler,
    required AstrologyLoggerInterface logger,
  })  : _config = config,
        _swissEphemerisService = swissEphemerisService,
        _memoizer = memoizer,
        _engine = engine,
        _service = service,
        _performanceMonitor = performanceMonitor,
        _errorHandler = errorHandler,
        _logger = logger;

  /// Factory method for creating container with default dependencies
  static Future<AstrologyContainer> create({
    AstrologyConfig? config,
    AstrologyLoggerInterface? logger,
  }) async {
    final finalConfig = config ?? AstrologyConfig();
    final finalLogger = logger ?? AstrologyLoggerService.instance;

    // Create dependencies with proper injection
    final swissEphemerisService = SwissEphemerisService.instance;
    final memoizer = CalculationMemoizer.instance;
    final performanceMonitor = PerformanceMonitor.instance;
    final errorHandler = AstrologyErrorHandler.instance;

    // Create engine with dependencies
    final engine = AstrologyEngine();
    await engine.initialize(finalConfig);

    // Create service with dependencies
    final service = AstrologyService(
      engine: engine,
      swissEphemerisService: swissEphemerisService,
    );

    return AstrologyContainer(
      config: finalConfig,
      swissEphemerisService: swissEphemerisService,
      memoizer: memoizer,
      engine: engine,
      service: service,
      performanceMonitor: performanceMonitor,
      errorHandler: errorHandler,
      logger: finalLogger,
    );
  }

  /// Initialize the container (dependencies are already injected)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize logger if it's the default implementation
      if (_logger is AstrologyLoggerService) {
        await _logger.initialize();
      }

      // All dependencies are already properly injected in constructor
      // Just mark as initialized
      _isInitialized = true;
    } catch (e) {
      // If logger initialization fails, continue without logging
      print('Warning: Logger initialization failed: $e');
      _isInitialized = true;
    }
  }

  /// Get astrology service
  AstrologyServiceInterface get astrologyService {
    _ensureInitialized();
    return _service;
  }

  /// Get astrology engine
  AstrologyEngineInterface get astrologyEngine {
    _ensureInitialized();
    return _engine;
  }

  /// Get Swiss Ephemeris service
  SwissEphemerisServiceInterface get swissEphemerisService {
    _ensureInitialized();
    return _swissEphemerisService;
  }

  /// Get memoizer
  CalculationMemoizer get memoizer {
    _ensureInitialized();
    return _memoizer;
  }

  /// Get logger
  AstrologyLoggerInterface get logger {
    _ensureInitialized();
    return _logger;
  }

  /// Get configuration
  AstrologyConfig get config {
    _ensureInitialized();
    return _config;
  }

  /// Check if container is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose of resources with proper memory management
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      // Dispose of all dependencies in proper order
      await _engine.dispose();
      _memoizer.dispose();
      _performanceMonitor.dispose();
      _errorHandler.dispose();

      _isInitialized = false;
      AstrologyUtils.logInfo('AstrologyContainer disposed and memory cleaned up');
    } catch (e) {
      AstrologyUtils.logError('Error during AstrologyContainer disposal: $e');
      // Still mark as disposed even if cleanup failed
      _isInitialized = false;
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('AstrologyContainer not initialized. Call initialize() first.');
    }
  }
}

/// Factory for creating astrology container instances
class AstrologyContainerFactory {
  /// Create a new container instance
  static Future<AstrologyContainer> create() async {
    return await AstrologyContainer.create();
  }

  /// Create and initialize a container
  static Future<AstrologyContainer> createAndInitialize(AstrologyConfig config) async {
    final container = await create();
    await container.initialize();
    return container;
  }
}
