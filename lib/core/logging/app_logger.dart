/// App Logger
///
/// Comprehensive logging system for the application with compression and auto-cleanup.
/// Stores logs locally, compresses them, and automatically cleans up old logs.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Log levels for different types of messages
enum LogLevel {
  debug('DEBUG', 0),
  info('INFO', 1),
  warning('WARNING', 2),
  error('ERROR', 3),
  critical('CRITICAL', 4);

  const LogLevel(this.name, this.level);
  final String name;
  final int level;
}

/// Log entry structure
class LogEntry {
  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.stackTrace,
    this.metadata,
    this.source,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (level) => level.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      source: json['source'] as String?,
    );
  }
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? stackTrace;
  final Map<String, dynamic>? metadata;
  final String? source;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'levelValue': level.level,
      'message': message,
      'stackTrace': stackTrace,
      'metadata': metadata,
      'source': source,
    };
  }

  String toFormattedString() {
    final buffer = StringBuffer()
      ..write('[${timestamp.toIso8601String()}] ')
      ..write('[${level.name}] ');
    if (source != null) buffer.write('[$source] ');
    buffer.write(message);

    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write(' | Metadata: ${json.encode(metadata)}');
    }

    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }

    return buffer.toString();
  }
}

/// Compressed log file manager
class CompressedLogFile {
  CompressedLogFile({
    required this.fileName,
    required this.created,
    required this.originalSize,
    required this.compressedSize,
    required this.entries,
  });
  final String fileName;
  final DateTime created;
  final int originalSize;
  final int compressedSize;
  final List<LogEntry> entries;

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'created': created.toIso8601String(),
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'entryCount': entries.length,
    };
  }

  double get compressionRatio =>
      originalSize > 0 ? compressedSize / originalSize : 0.0;
  int get spaceSaved => originalSize - compressedSize;
}

/// Main application logger with compression and auto-cleanup
class AppLogger {
  factory AppLogger() => _instance;
  AppLogger._internal();
  static final AppLogger _instance = AppLogger._internal();

  static const String _logDirName = 'app_logs';
  static const String _compressedDirName = 'compressed_logs';
  static const String _indexFileName = 'log_index.json';
  static const int _maxLogFileSize = 1024 * 1024; // 1MB per file
  static const int _retentionDays = 2; // Keep logs for 2 days
  static const int _compressionThreshold = 5; // Compress after 5 log files

  Directory? _logDirectory;
  Directory? _compressedDirectory;
  File? _indexFile;
  Timer? _cleanupTimer;
  Timer? _compressionTimer;
  final List<LogEntry> _currentLogBuffer = [];
  int _currentLogFileIndex = 0;
  int _currentLogFileSize = 0;
  bool _isInitialized = false;

  /// Initialize the logging system
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _logDirectory = Directory('${appDir.path}/$_logDirName');
      _compressedDirectory = Directory('${appDir.path}/$_compressedDirName');

      if (!_logDirectory!.existsSync()) {
        _logDirectory!.createSync(recursive: true);
      }
      if (!_compressedDirectory!.existsSync()) {
        _compressedDirectory!.createSync(recursive: true);
      }

      _indexFile = File('${_logDirectory!.path}/$_indexFileName');
      await _loadLogIndex();

      // Mark as initialized
      _isInitialized = true;

      // Start cleanup and compression timers
      _startCleanupTimer();
      _startCompressionTimer();

      // Flush any buffered logs that accumulated during initialization
      if (_currentLogBuffer.isNotEmpty) {
        await _flushLogBuffer();
      }

      // Log initialization
      await _log(
        LogLevel.info,
        'AppLogger initialized successfully',
        source: 'AppLogger',
      );
    } on Exception catch (e) {
      // Fallback to console if logging system fails
      developer.log('Failed to initialize AppLogger: $e', name: 'AppLogger');
    }
  }

  /// Log a message with specified level
  Future<void> log(
    LogLevel level,
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) async {
    try {
      await _log(
        level,
        message,
        source: source,
        metadata: metadata,
        stackTrace: stackTrace,
      );
    } on Exception catch (e) {
      // Fallback to console if logging fails
      developer.log('Logging failed: $e', name: 'AppLogger');
    }
  }

  /// Internal logging method
  Future<void> _log(
    LogLevel level,
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      source: source,
      metadata: metadata,
      stackTrace: stackTrace?.toString(),
    );

    _currentLogBuffer.add(entry);
    _currentLogFileSize += entry.toFormattedString().length;

    // Write to console for development (only for warnings and errors)
    if (level.level >= LogLevel.warning.level) {
      // Using print as last resort for critical logging
      developer.log(entry.toFormattedString(), name: 'AppLogger');
    }

    // Flush buffer if it's getting large
    if (_currentLogBuffer.length >= 50 ||
        _currentLogFileSize >= _maxLogFileSize) {
      await _flushLogBuffer();
    }
  }

  /// Flush current log buffer to file
  Future<void> _flushLogBuffer() async {
    if (_currentLogBuffer.isEmpty) return;

    // Don't flush if not initialized - logs will be buffered until initialization completes
    if (!_isInitialized || _logDirectory == null) {
      return;
    }

    try {
      final logFile = File(
        '${_logDirectory!.path}/log_${_currentLogFileIndex.toString().padLeft(3, '0')}.json',
      );

      final jsonEntries =
          _currentLogBuffer.map((entry) => entry.toJson()).toList();
      final jsonString = json.encode(jsonEntries);

      // Write to file
      await logFile.writeAsString(jsonString);

      await _updateLogIndex(
        logFile.path,
        _currentLogBuffer.length,
        jsonString.length,
      );

      // Reset buffer
      _currentLogBuffer.clear();
      _currentLogFileSize = 0;
      _currentLogFileIndex++;

      await _checkCompressionNeeded();
    } on Exception catch (e) {
      // Using print as last resort for critical logging
      developer.log('Failed to flush log buffer: $e', name: 'AppLogger');
    }
  }

  /// Update log index
  Future<void> _updateLogIndex(
    String filePath,
    int entryCount,
    int fileSize,
  ) async {
    if (!_isInitialized || _indexFile == null) return;

    try {
      final index = await _getLogIndex();
      index[filePath] = {
        'created': DateTime.now().toIso8601String(),
        'entryCount': entryCount,
        'fileSize': fileSize,
        'compressed': false,
      };
      await _indexFile!.writeAsString(json.encode(index));
    } on Exception catch (e) {
      developer.log('Failed to update log index: $e', name: 'AppLogger');
    }
  }

  /// Get current log index
  Future<Map<String, dynamic>> _getLogIndex() async {
    if (!_isInitialized || _indexFile == null) return {};

    try {
      if (_indexFile!.existsSync()) {
        final content = _indexFile!.readAsStringSync();
        return Map<String, dynamic>.from(json.decode(content));
      }
    } on Exception catch (e) {
      developer.log('Failed to read log index: $e', name: 'AppLogger');
    }
    return {};
  }

  /// Load log index on initialization
  Future<void> _loadLogIndex() async {
    try {
      final index = await _getLogIndex();
      _currentLogFileIndex = index.length;
    } on Exception {
      _currentLogFileIndex = 0;
    }
  }

  /// Check if compression is needed
  Future<void> _checkCompressionNeeded() async {
    try {
      final index = await _getLogIndex();
      final uncompressedFiles = index.entries
          .where((entry) =>
              !((entry.value as Map<String, dynamic>)['compressed'] as bool? ??
                  false),)
          .length;

      if (uncompressedFiles >= _compressionThreshold) {
        await _compressOldLogs();
      }
    } on Exception catch (e) {
      developer.log('Failed to check compression needed: $e',
          name: 'AppLogger',);
    }
  }

  /// Compress old log files
  Future<void> _compressOldLogs() async {
    if (!_isInitialized || _compressedDirectory == null || _indexFile == null) {
      return;
    }

    try {
      final index = await _getLogIndex();
      final filesToCompress = index.entries
          .where((entry) =>
              !((entry.value as Map<String, dynamic>)['compressed'] as bool? ??
                  false),)
          .take(_compressionThreshold)
          .toList();

      for (final fileEntry in filesToCompress) {
        final filePath = fileEntry.key;
        final fileInfo = fileEntry.value as Map<String, dynamic>;

        final logFile = File(filePath);
        if (logFile.existsSync()) {
          // Read and parse log entries
          final content = logFile.readAsStringSync();
          final entries = (json.decode(content) as List)
              .map((json) => LogEntry.fromJson(json as Map<String, dynamic>))
              .toList();

          final compressedFileName =
              'compressed_${DateTime.now().millisecondsSinceEpoch}.json';
          final compressedFile =
              File('${_compressedDirectory!.path}/$compressedFileName');

          // Simple compression: remove redundant data and format efficiently
          final compressedEntries = entries
              .map(
                (entry) => {
                  't': entry.timestamp.millisecondsSinceEpoch,
                  'l': entry.level.level,
                  'm': entry.message,
                  if (entry.source != null) 's': entry.source,
                  if (entry.metadata != null && entry.metadata!.isNotEmpty)
                    'd': entry.metadata,
                  if (entry.stackTrace != null) 'st': entry.stackTrace,
                },
              )
              .toList();

          final compressedContent = json.encode(compressedEntries);
          await compressedFile.writeAsString(compressedContent);

          final originalSize = fileInfo['fileSize'] as int;
          final compressedSize = compressedContent.length;
          index[filePath] = {
            ...fileInfo,
            'compressed': true,
            'compressedFile': compressedFile.path,
            'originalSize': originalSize,
            'compressedSize': compressedSize,
            'compressionRatio': compressedSize / originalSize,
          };

          await logFile.delete();
        }
      }

      await _indexFile!.writeAsString(json.encode(index));
      await log(
        LogLevel.info,
        'Compressed ${filesToCompress.length} log files',
        source: 'AppLogger',
      );
    } on Exception catch (e) {
      developer.log('Failed to compress logs: $e', name: 'AppLogger');
    }
  }

  /// Start cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(hours: 6), (timer) {
      _cleanupOldLogs();
    });
  }

  /// Start compression timer
  void _startCompressionTimer() {
    _compressionTimer?.cancel();
    _compressionTimer = Timer.periodic(const Duration(hours: 12), (timer) {
      _checkCompressionNeeded();
    });
  }

  /// Clean up old log files
  Future<void> _cleanupOldLogs() async {
    if (!_isInitialized || _indexFile == null) return;

    try {
      final cutoffDate =
          DateTime.now().subtract(const Duration(days: _retentionDays));
      final index = await _getLogIndex();
      final filesToDelete = <String>[];

      for (final entry in index.entries) {
        final entryValue = entry.value as Map<String, dynamic>;
        final created = DateTime.parse(entryValue['created'] as String);
        if (created.isBefore(cutoffDate)) {
          filesToDelete.add(entry.key);

          if (entryValue['compressedFile'] != null) {
            final compressedFile = File(entryValue['compressedFile'] as String);
            if (compressedFile.existsSync()) {
              compressedFile.deleteSync();
            }
          }
        }
      }

      for (final filePath in filesToDelete) {
        final file = File(filePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
        index.remove(filePath);
      }

      if (filesToDelete.isNotEmpty) {
        await _indexFile!.writeAsString(json.encode(index));
        await log(
          LogLevel.info,
          'Cleaned up ${filesToDelete.length} old log files',
          source: 'AppLogger',
        );
      }
    } on Exception catch (e) {
      developer.log('Failed to cleanup old logs: $e', name: 'AppLogger');
    }
  }

  /// Get log statistics
  Future<Map<String, dynamic>> getLogStatistics() async {
    try {
      final index = await _getLogIndex();
      int totalFiles = 0;
      int totalEntries = 0;
      int totalSize = 0;
      int compressedFiles = 0;
      int compressedSize = 0;
      int originalSize = 0;

      for (final entry in index.values) {
        final entryMap = entry as Map<String, dynamic>;
        totalFiles++;
        totalEntries += entryMap['entryCount'] as int;
        totalSize += entryMap['fileSize'] as int;

        if (entryMap['compressed'] == true) {
          compressedFiles++;
          compressedSize += entryMap['compressedSize'] as int;
          originalSize += entryMap['originalSize'] as int;
        }
      }

      return {
        'totalFiles': totalFiles,
        'totalEntries': totalEntries,
        'totalSize': totalSize,
        'compressedFiles': compressedFiles,
        'compressedSize': compressedSize,
        'originalSize': originalSize,
        'spaceSaved': originalSize - compressedSize,
        'compressionRatio':
            originalSize > 0 ? compressedSize / originalSize : 0.0,
        'currentBufferSize': _currentLogBuffer.length,
        'currentFileSize': _currentLogFileSize,
      };
    } on Exception catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get recent log entries for debugging
  Future<List<LogEntry>> getRecentLogs({
    int count = 100,
    LogLevel? minLevel,
  }) async {
    try {
      final allEntries = <LogEntry>[];
      final index = await _getLogIndex();

      // Read from current buffer
      for (final entry in _currentLogBuffer) {
        if (minLevel == null || entry.level.level >= minLevel.level) {
          allEntries.add(entry);
        }
      }

      // Read from files
      for (final entry in index.entries) {
        final filePath = entry.key;
        final fileInfo = entry.value as Map<String, dynamic>;

        if (fileInfo['compressed'] == true) {
          // Read compressed file
          final compressedFile = File(fileInfo['compressedFile'] as String);
          if (compressedFile.existsSync()) {
            final content = compressedFile.readAsStringSync();
            final compressedEntries = json.decode(content) as List<dynamic>;

            for (final compressedEntry in compressedEntries) {
              final entryMap = compressedEntry as Map<String, dynamic>;
              final entry = LogEntry(
                timestamp: DateTime.fromMillisecondsSinceEpoch(
                  entryMap['t'] as int,
                ),
                level: LogLevel.values[entryMap['l'] as int],
                message: entryMap['m'] as String,
                source: entryMap['s'] as String?,
                metadata: entryMap['d'] as Map<String, dynamic>?,
                stackTrace: entryMap['st'] as String?,
              );

              if (minLevel == null || entry.level.level >= minLevel.level) {
                allEntries.add(entry);
              }
            }
          }
        } else {
          // Read regular file
          final file = File(filePath);
          if (file.existsSync()) {
            final content = file.readAsStringSync();
            final entries = (json.decode(content) as List)
                .map((json) => LogEntry.fromJson(json as Map<String, dynamic>))
                .where(
                  (entry) =>
                      minLevel == null || entry.level.level >= minLevel.level,
                )
                .toList();
            allEntries.addAll(entries);
          }
        }
      }

      // Sort by timestamp and return recent entries
      allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allEntries.take(count).toList();
    } on Exception catch (e) {
      developer.log('Failed to get recent logs: $e', name: 'AppLogger');
      return [];
    }
  }

  /// Force flush all pending logs
  Future<void> flush() async {
    await _flushLogBuffer();
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _compressionTimer?.cancel();
    _flushLogBuffer();
  }

  // Convenience methods for different log levels
  Future<void> debug(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      log(LogLevel.debug, message, source: source, metadata: metadata);

  Future<void> info(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      log(LogLevel.info, message, source: source, metadata: metadata);

  Future<void> warning(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.warning,
        message,
        source: source,
        metadata: metadata,
        stackTrace: stackTrace,
      );

  Future<void> error(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.error,
        message,
        source: source,
        metadata: metadata,
        stackTrace: stackTrace,
      );

  Future<void> critical(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.critical,
        message,
        source: source,
        metadata: metadata,
        stackTrace: stackTrace,
      );
}
