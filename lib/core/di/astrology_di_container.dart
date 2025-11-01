/// Astrology Dependency Injection Container
///
/// This container manages all dependencies for the astrology system,
/// following the Dependency Injection pattern and ensuring proper
/// initialization order and lifecycle management.
///
/// Design Pattern: Dependency Injection Container
/// Responsibilities:
/// - Manage service dependencies
/// - Handle initialization order
/// - Provide singleton instances
/// - Support testing with mock dependencies
library;

import 'dart:async';
import '../../astrology/core/facades/astrology_facade.dart';
import '../../astrology/core/interfaces/astrology_engine_interface.dart';
import '../../astrology/core/interfaces/astrology_logger_interface.dart';
import '../../astrology/engines/astrology_engine.dart';
import '../../astrology/core/services/astrology_logger_service.dart';
import '../../features/astrology/services/astrology_business_service.dart';
import '../../astrology/core/entities/astrology_entities.dart';

/// Dependency injection container for astrology services
class AstrologyDIContainer {
  static AstrologyDIContainer? _instance;

  // Core services
  AstrologyEngineInterface? _astrologyEngine;
  AstrologyLoggerInterface? _logger;
  AstrologyFacade? _astrologyFacade;
  AstrologyBusinessService? _businessService;

  // Initialization state
  bool _isInitialized = false;
  final List<String> _initializationSteps = [];

  AstrologyDIContainer._();

  /// Get singleton instance
  static AstrologyDIContainer get instance {
    _instance ??= AstrologyDIContainer._();
    return _instance!;
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize all astrology services
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      await _initializeLogger();
      await _initializeAstrologyEngine();
      await _initializeAstrologyFacade();
      await _initializeBusinessService();

      _isInitialized = true;

      await _logger?.info(
        'Astrology DI Container initialized successfully',
        source: 'AstrologyDIContainer',
        metadata: {
          'steps': _initializationSteps,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      await _logger?.error(
        'Failed to initialize Astrology DI Container: $e',
        source: 'AstrologyDIContainer',
      );
      rethrow;
    }
  }

  /// Initialize logger service
  Future<void> _initializeLogger() async {
    _logger = AstrologyLoggerService.instance;
    _initializationSteps.add('Logger initialized');
  }

  /// Initialize astrology engine
  Future<void> _initializeAstrologyEngine() async {
    if (_logger == null) {
      throw StateError('Logger must be initialized before AstrologyEngine');
    }

    _astrologyEngine = AstrologyEngine();
    await _astrologyEngine!.initialize(AstrologyConfig());
    _initializationSteps.add('AstrologyEngine initialized');
  }

  /// Initialize astrology facade
  Future<void> _initializeAstrologyFacade() async {
    if (_astrologyEngine == null || _logger == null) {
      throw StateError('AstrologyEngine and Logger must be initialized before AstrologyFacade');
    }

    await AstrologyFacade.initialize(
      astrologyEngine: _astrologyEngine!,
      logger: _logger!,
    );
    _astrologyFacade = AstrologyFacade.instance;
    _initializationSteps.add('AstrologyFacade initialized');
  }

  /// Initialize business service
  Future<void> _initializeBusinessService() async {
    if (_astrologyFacade == null || _logger == null) {
      throw StateError('AstrologyFacade and Logger must be initialized before BusinessService');
    }

    await AstrologyBusinessService.initialize(
      astrologyFacade: _astrologyFacade!,
      logger: _logger!,
    );
    _businessService = AstrologyBusinessService.instance;
    _initializationSteps.add('BusinessService initialized');
  }

  // ============================================================================
  // SERVICE ACCESS
  // ============================================================================

  /// Get astrology engine
  AstrologyEngineInterface get astrologyEngine {
    if (_astrologyEngine == null) {
      throw StateError('AstrologyEngine not initialized. Call initialize() first.');
    }
    return _astrologyEngine!;
  }

  /// Get logger service
  AstrologyLoggerInterface get logger {
    if (_logger == null) {
      throw StateError('Logger not initialized. Call initialize() first.');
    }
    return _logger!;
  }

  /// Get astrology facade
  AstrologyFacade get astrologyFacade {
    if (_astrologyFacade == null) {
      throw StateError('AstrologyFacade not initialized. Call initialize() first.');
    }
    return _astrologyFacade!;
  }

  /// Get business service
  AstrologyBusinessService get businessService {
    if (_businessService == null) {
      throw StateError('BusinessService not initialized. Call initialize() first.');
    }
    return _businessService!;
  }

  // ============================================================================
  // TESTING SUPPORT
  // ============================================================================

  /// Set mock dependencies for testing
  void setMockDependencies({
    AstrologyEngineInterface? mockAstrologyEngine,
    AstrologyLoggerInterface? mockLogger,
    AstrologyFacade? mockAstrologyFacade,
    AstrologyBusinessService? mockBusinessService,
  }) {
    if (mockAstrologyEngine != null) {
      _astrologyEngine = mockAstrologyEngine;
    }
    if (mockLogger != null) {
      _logger = mockLogger;
    }
    if (mockAstrologyFacade != null) {
      _astrologyFacade = mockAstrologyFacade;
    }
    if (mockBusinessService != null) {
      _businessService = mockBusinessService;
    }

    _isInitialized = true;
  }

  /// Reset container for testing
  void reset() {
    _astrologyEngine = null;
    _logger = null;
    _astrologyFacade = null;
    _businessService = null;
    _isInitialized = false;
    _initializationSteps.clear();
  }

  // ============================================================================
  // STATUS AND HEALTH
  // ============================================================================

  /// Check if container is initialized
  bool get isInitialized => _isInitialized;

  /// Get initialization steps
  List<String> get initializationSteps => List.unmodifiable(_initializationSteps);

  /// Get container health status
  Map<String, dynamic> getHealthStatus() {
    return {
      'isInitialized': _isInitialized,
      'astrologyEngine': _astrologyEngine != null,
      'logger': _logger != null,
      'astrologyFacade': _astrologyFacade != null,
      'businessService': _businessService != null,
      'initializationSteps': _initializationSteps,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Validate all dependencies
  Future<bool> validateDependencies() async {
    try {
      // Check if all services are available
      final healthStatus = getHealthStatus();
      final allServicesAvailable = healthStatus['astrologyEngine'] == true &&
          healthStatus['logger'] == true &&
          healthStatus['astrologyFacade'] == true &&
          healthStatus['businessService'] == true;

      if (!allServicesAvailable) {
        await _logger?.warning(
          'Some dependencies are not available',
          source: 'AstrologyDIContainer',
          metadata: {'healthStatus': healthStatus},
        );
        return false;
      }

      await _logger?.info(
        'All dependencies validated successfully',
        source: 'AstrologyDIContainer',
      );
      return true;
    } catch (e) {
      await _logger?.error(
        'Dependency validation failed: $e',
        source: 'AstrologyDIContainer',
      );
      return false;
    }
  }
}
