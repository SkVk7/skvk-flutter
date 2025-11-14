/// Module Registry
///
/// Central registry for managing modular architecture
/// Allows for easy separation of features into separate packages
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';

/// Base interface for all modules
abstract class AppModule {
  /// Module name
  String get name;

  /// Module version
  String get version;

  /// Initialize the module
  Future<void> initialize();

  /// Dispose the module
  Future<void> dispose();

  /// Get module dependencies
  List<Type> get dependencies;

  /// Check if module is ready
  bool get isReady;
}

/// Module registry for managing all app modules
class ModuleRegistry {
  factory ModuleRegistry() => _instance;
  ModuleRegistry._internal();
  static final ModuleRegistry _instance = ModuleRegistry._internal();

  final Map<String, AppModule> _modules = {};
  final Map<String, bool> _initializationStatus = {};

  /// Register a module
  void registerModule(AppModule module) {
    _modules[module.name] = module;
    _initializationStatus[module.name] = false;

    if (kDebugMode) {
      LoggingHelper.logDebug(
        'Module registered: ${module.name} v${module.version}',
        source: 'ModuleRegistry',
      );
    }
  }

  /// Initialize a specific module
  Future<void> initializeModule(String moduleName) async {
    final module = _modules[moduleName];
    if (module == null) {
      throw Exception('Module $moduleName not found');
    }

    if (_initializationStatus[moduleName] ?? false) {
      return; // Already initialized
    }

    for (final dependency in module.dependencies) {
      final dependencyModule = _modules.values.firstWhere(
        (m) => m.runtimeType == dependency,
        orElse: () => throw Exception('Dependency $dependency not found'),
      );

      if (!_initializationStatus[dependencyModule.name]!) {
        await initializeModule(dependencyModule.name);
      }
    }

    await module.initialize();
    _initializationStatus[moduleName] = true;

    if (kDebugMode) {
      await LoggingHelper.logDebug(
        'Module initialized: $moduleName',
        source: 'ModuleRegistry',
      );
    }
  }

  /// Initialize all modules
  Future<void> initializeAll() async {
    final moduleNames = _modules.keys.toList();

    for (final moduleName in moduleNames) {
      if (!_initializationStatus[moduleName]!) {
        await initializeModule(moduleName);
      }
    }
  }

  /// Get a module by name
  T? getModule<T extends AppModule>(String name) {
    return _modules[name] as T?;
  }

  /// Get a module by type
  T? getModuleByType<T extends AppModule>() {
    return _modules.values.whereType<T>().firstOrNull;
  }

  /// Check if module is initialized
  bool isModuleInitialized(String moduleName) {
    return _initializationStatus[moduleName] ?? false;
  }

  /// Dispose all modules
  Future<void> disposeAll() async {
    for (final module in _modules.values) {
      await module.dispose();
    }
    _modules.clear();
    _initializationStatus.clear();
  }

  /// Get all registered modules
  List<AppModule> get allModules => _modules.values.toList();

  /// Get module initialization status
  Map<String, bool> get initializationStatus =>
      Map.unmodifiable(_initializationStatus);
}

/// Provider for module registry
final moduleRegistryProvider = Provider<ModuleRegistry>((ref) {
  return ModuleRegistry();
});

/// Core module - base functionality
class CoreModule implements AppModule {
  @override
  String get name => 'core';

  @override
  String get version => '1.0.0';

  @override
  List<Type> get dependencies => [];

  @override
  bool get isReady => _isInitialized;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// User module - user management functionality
class UserModule implements AppModule {
  @override
  String get name => 'user';

  @override
  String get version => '1.0.0';

  @override
  List<Type> get dependencies => [CoreModule];

  @override
  bool get isReady => _isInitialized;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// Astrology module - astrology calculations
class AstrologyModule implements AppModule {
  @override
  String get name => 'astrology';

  @override
  String get version => '1.0.0';

  @override
  List<Type> get dependencies => [CoreModule];

  @override
  bool get isReady => _isInitialized;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// Horoscope module - horoscope functionality
class HoroscopeModule implements AppModule {
  @override
  String get name => 'horoscope';

  @override
  String get version => '1.0.0';

  @override
  List<Type> get dependencies => [CoreModule, UserModule, AstrologyModule];

  @override
  bool get isReady => _isInitialized;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// Matching module - compatibility matching
class MatchingModule implements AppModule {
  @override
  String get name => 'matching';

  @override
  String get version => '1.0.0';

  @override
  List<Type> get dependencies => [CoreModule, UserModule, AstrologyModule];

  @override
  bool get isReady => _isInitialized;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// Calendar module - Hindu calendar functionality
class CalendarModule implements AppModule {
  @override
  String get name => 'calendar';

  @override
  String get version => '1.0.0';

  @override
  List<Type> get dependencies => [CoreModule, AstrologyModule];

  @override
  bool get isReady => _isInitialized;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// Predictions module - predictions functionality
class PredictionsModule implements AppModule {
  @override
  String get name => 'predictions';

  @override
  String get version => '1.0.0';

  @override
  List<Type> get dependencies => [CoreModule, UserModule, AstrologyModule];

  @override
  bool get isReady => _isInitialized;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}
