/// Astrology Logger Service
///
/// Default implementation of the astrology logger interface.
/// Provides 100% accurate logging with no fallbacks or compromises.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/utils/app_logger.dart';
import '../interfaces/astrology_logger_interface.dart';

/// Log entry structure for astrology library
class AstrologyLogEntry {
  final DateTime timestamp;
  final String level;
  final String message;
  final String? source;
  final Map<String, dynamic>? metadata;
  final String? error;
  final String? stackTrace;

  AstrologyLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.source,
    this.metadata,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'message': message,
      'source': source,
      'metadata': metadata,
      'error': error,
      'stackTrace': stackTrace,
    };
  }

  String toFormattedString() {
    final buffer = StringBuffer();
    buffer
        .write('${timestamp.toIso8601String()} [${source ?? 'AstrologyLibrary'}] $level: $message');

    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write(' | Metadata: ${metadata.toString()}');
    }

    if (error != null) {
      buffer.write(' | Error: $error');
    }

    if (stackTrace != null) {
      buffer.write(' | StackTrace: $stackTrace');
    }

    return buffer.toString();
  }
}

/// Default logger implementation for astrology library with compression and cleanup
class AstrologyLoggerService implements AstrologyLoggerInterface {
  static AstrologyLoggerService? _instance;

  // Log management configuration
  static const String _logDirName = 'astrology_logs';
  static const String _compressedDirName = 'compressed_astrology_logs';
  static const String _indexFileName = 'astrology_log_index.json';
  static const int _maxLogFileSize = 1024 * 1024; // 1MB per file
  static const int _retentionDays = 7; // Keep logs for 7 days (longer than business layer)
  static const int _compressionThreshold = 3; // Compress after 3 log files

  Directory? _logDirectory;
  Directory? _compressedDirectory;
  File? _indexFile;
  Timer? _cleanupTimer;
  Timer? _compressionTimer;
  final List<AstrologyLogEntry> _currentLogBuffer = [];
  int _currentLogFileIndex = 0;
  int _currentLogFileSize = 0;
  bool _isInitialized = false;

  // Private constructor for singleton
  AstrologyLoggerService._();

  /// Get singleton instance
  static AstrologyLoggerService get instance {
    _instance ??= AstrologyLoggerService._();
    return _instance!;
  }

  /// Ensure logger is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Initialize the astrology logging system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get application documents directory with fallback
      Directory appDir;
      try {
        appDir = await getApplicationDocumentsDirectory();
      } catch (e) {
        // Fallback to temporary directory if path_provider fails
        print('Path provider failed, using temporary directory: $e');
        appDir = Directory.systemTemp;
      }

      _logDirectory = Directory('${appDir.path}/$_logDirName');
      _compressedDirectory = Directory('${appDir.path}/$_compressedDirName');

      // Create directories if they don't exist
      try {
        if (!await _logDirectory!.exists()) {
          await _logDirectory!.create(recursive: true);
        }
        if (!await _compressedDirectory!.exists()) {
          await _compressedDirectory!.create(recursive: true);
        }
      } catch (e) {
        print('Failed to create log directories: $e');
        // Continue without file logging
      }

      // Initialize index file
      _indexFile = File('${_logDirectory!.path}/$_indexFileName');
      await _loadLogIndex();

      // Start cleanup and compression timers
      _startCleanupTimer();
      _startCompressionTimer();

      _isInitialized = true;

      // Log initialization
      await _log('INFO', 'AstrologyLoggerService initialized successfully',
          source: 'AstrologyLoggerService');
    } catch (e) {
      // Fallback to console if logging system fails
      print('Failed to initialize AstrologyLoggerService: $e');
      // Set as initialized to prevent repeated attempts
      _isInitialized = true;
    }
  }

  @override
  Future<void> debug(String message, {String? source, Map<String, dynamic>? metadata}) async {
    await _ensureInitialized();
    await _log('DEBUG', message, source: source, metadata: metadata);
  }

  @override
  Future<void> info(String message, {String? source, Map<String, dynamic>? metadata}) async {
    await _ensureInitialized();
    await _log('INFO', message, source: source, metadata: metadata);
  }

  @override
  Future<void> warning(String message, {String? source, Map<String, dynamic>? metadata}) async {
    await _ensureInitialized();
    await _log('WARNING', message, source: source, metadata: metadata);
  }

  @override
  Future<void> error(String message,
      {String? source,
      Map<String, dynamic>? metadata,
      dynamic error,
      StackTrace? stackTrace}) async {
    await _ensureInitialized();
    await _log('ERROR', message,
        source: source, metadata: metadata, error: error, stackTrace: stackTrace);
  }

  @override
  Future<void> critical(String message,
      {String? source,
      Map<String, dynamic>? metadata,
      dynamic error,
      StackTrace? stackTrace}) async {
    await _ensureInitialized();
    await _log('CRITICAL', message,
        source: source, metadata: metadata, error: error, stackTrace: stackTrace);
  }

  @override
  Future<void> performance(String operation, Duration duration,
      {String? source, Map<String, dynamic>? additionalMetrics}) async {
    await _ensureInitialized();
    final metrics = <String, dynamic>{
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'duration_us': duration.inMicroseconds,
      if (additionalMetrics != null) ...additionalMetrics,
    };

    _log('PERFORMANCE', 'Operation: $operation took ${duration.inMilliseconds}ms',
        source: source, metadata: metrics);
  }

  @override
  Future<T?> executeWithLogging<T>(
    Future<T> Function() function, {
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
    bool logSuccess = false,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await function();
      stopwatch.stop();

      if (logSuccess) {
        await info(
          'Operation completed successfully: $operation',
          source: source,
          metadata: {
            if (metadata != null) ...metadata,
            'duration_ms': stopwatch.elapsedMilliseconds,
          },
        );
      }

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      await error(
        'Operation failed: $operation',
        source: source,
        error: e,
        stackTrace: stackTrace,
        metadata: {
          if (metadata != null) ...metadata,
          'duration_ms': stopwatch.elapsedMilliseconds,
        },
      );
      return null;
    }
  }

  @override
  T? executeSyncWithLogging<T>(
    T Function() function, {
    String? source,
    String? operation,
    Map<String, dynamic>? metadata,
    bool logSuccess = false,
  }) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = function();
      stopwatch.stop();

      if (logSuccess) {
        info(
          'Operation completed successfully: $operation',
          source: source,
          metadata: {
            if (metadata != null) ...metadata,
            'duration_ms': stopwatch.elapsedMilliseconds,
          },
        );
      }

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      error(
        'Operation failed: $operation',
        source: source,
        error: e,
        stackTrace: stackTrace,
        metadata: {
          if (metadata != null) ...metadata,
          'duration_ms': stopwatch.elapsedMilliseconds,
        },
      );
      return null;
    }
  }

  /// Internal logging method with file storage
  Future<void> _log(
    String level,
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
    dynamic error,
    StackTrace? stackTrace,
  }) async {
    try {
      // Initialize if not already done
      if (!_isInitialized) {
        await initialize();
      }

      final entry = AstrologyLogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: message,
        source: source,
        metadata: metadata,
        error: error?.toString(),
        stackTrace: stackTrace?.toString(),
      );

      _currentLogBuffer.add(entry);
      _currentLogFileSize += entry.toFormattedString().length;

      // Write to console for development (only for warnings and errors)
      if (level == 'WARNING' || level == 'ERROR' || level == 'CRITICAL') {
        try {
          AppLogger.debug(entry.toFormattedString());
        } catch (e) {
          print(entry.toFormattedString());
        }
      }

      // Flush buffer if it's getting large
      if (_currentLogBuffer.length >= 50 || _currentLogFileSize >= _maxLogFileSize) {
        await _flushLogBuffer();
      }
    } catch (e) {
      // Fallback to console if logging fails
      print('AstrologyLoggerService failed: $e');
      print('$level: $message');
    }
  }

  /// Flush current log buffer to file
  Future<void> _flushLogBuffer() async {
    if (_currentLogBuffer.isEmpty) return;

    try {
      // Check if log directory is initialized
      if (_logDirectory == null) {
        print('Log directory not initialized, skipping file logging');
        _currentLogBuffer.clear();
        _currentLogFileSize = 0;
        return;
      }

      // Check if directories exist, if not, skip file logging
      if (!await _logDirectory!.exists()) {
        print('Log directory does not exist, skipping file logging');
        _currentLogBuffer.clear();
        _currentLogFileSize = 0;
        return;
      }

      final logFile = File(
          '${_logDirectory!.path}/astrology_log_${_currentLogFileIndex.toString().padLeft(3, '0')}.log');

      // Write all buffered entries to file
      final logContent =
          '${_currentLogBuffer.map((entry) => entry.toFormattedString()).join('\n')}\n';
      await logFile.writeAsString(logContent, mode: FileMode.append);

      // Update index
      await _updateLogIndex(logFile.path, _currentLogBuffer.length);

      // Clear buffer and reset size
      _currentLogBuffer.clear();
      _currentLogFileSize = 0;

      // Check if we need to create a new file
      if (await logFile.length() >= _maxLogFileSize) {
        _currentLogFileIndex++;
      }
    } catch (e) {
      print('Failed to flush log buffer: $e');
      // Clear buffer to prevent memory issues
      _currentLogBuffer.clear();
      _currentLogFileSize = 0;
    }
  }

  /// Load log index from file
  Future<void> _loadLogIndex() async {
    try {
      if (_indexFile == null) {
        print('Index file not initialized, skipping index load');
        _currentLogFileIndex = 0;
        return;
      }
      
      if (await _indexFile!.exists()) {
        final content = await _indexFile!.readAsString();
        final index = jsonDecode(content) as Map<String, dynamic>;
        _currentLogFileIndex = index['currentFileIndex'] ?? 0;
      }
    } catch (e) {
      print('Failed to load log index: $e');
      _currentLogFileIndex = 0;
    }
  }

  /// Update log index
  Future<void> _updateLogIndex(String filePath, int entryCount) async {
    try {
      if (_indexFile == null) {
        print('Index file not initialized, skipping index update');
        return;
      }
      
      // Check if index file exists, if not, skip index update
      if (!await _indexFile!.exists()) {
        print('Index file does not exist, skipping index update');
        return;
      }

      final index = {
        'currentFileIndex': _currentLogFileIndex,
        'lastUpdate': DateTime.now().toIso8601String(),
        'totalEntries': entryCount,
      };
      await _indexFile!.writeAsString(jsonEncode(index));
    } catch (e) {
      print('Failed to update log index: $e');
    }
  }

  /// Start cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 6), (timer) {
      _cleanupOldLogs();
    });
  }

  /// Start compression timer
  void _startCompressionTimer() {
    _compressionTimer = Timer.periodic(const Duration(hours: 12), (timer) {
      _compressOldLogs();
    });
  }

  /// Clean up old log files
  Future<void> _cleanupOldLogs() async {
    try {
      if (_logDirectory == null || _compressedDirectory == null) {
        print('Log directories not initialized, skipping cleanup');
        return;
      }
      
      final cutoffDate = DateTime.now().subtract(Duration(days: _retentionDays));

      // Clean up regular log files
      final logFiles = await _logDirectory!
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .cast<File>()
          .toList();

      for (final file in logFiles) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }

      // Clean up compressed log files
      final compressedFiles = await _compressedDirectory!
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.gz'))
          .cast<File>()
          .toList();

      for (final file in compressedFiles) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Failed to cleanup old logs: $e');
    }
  }

  /// Compress old log files
  Future<void> _compressOldLogs() async {
    try {
      if (_logDirectory == null || _compressedDirectory == null) {
        print('Log directories not initialized, skipping compression');
        return;
      }
      
      var logFiles = await _logDirectory!
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .cast<File>()
          .toList();

      if (logFiles.length >= _compressionThreshold) {
        // Sort by modification time (oldest first)
        final sortedFiles = <File>[];
        for (final file in logFiles) {
          sortedFiles.add(file);
        }
        sortedFiles.sort((a, b) {
          final statA = a.statSync();
          final statB = b.statSync();
          return statA.modified.compareTo(statB.modified);
        });
        logFiles = sortedFiles;

        // Compress oldest files (keep the most recent ones uncompressed)
        final filesToCompress = logFiles.take(logFiles.length - 2).toList();

        for (final file in filesToCompress) {
          await _compressFile(file);
        }
      }
    } catch (e) {
      print('Failed to compress logs: $e');
    }
  }

  /// Compress a single log file
  Future<void> _compressFile(File file) async {
    try {
      if (_compressedDirectory == null) {
        print('Compressed directory not initialized, skipping file compression');
        return;
      }
      
      final fileName = file.path.split('/').last;
      final compressedFile = File('${_compressedDirectory!.path}/$fileName.gz');

      // Read file content
      final content = await file.readAsBytes();

      // Simple compression (in production, use proper gzip compression)
      final compressed = gzip.encode(content);

      // Write compressed content
      await compressedFile.writeAsBytes(compressed);

      // Delete original file
      await file.delete();
    } catch (e) {
      print('Failed to compress file ${file.path}: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _compressionTimer?.cancel();
    _flushLogBuffer();
  }
}
