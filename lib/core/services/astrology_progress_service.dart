/// Astrology Progress Service
///
/// Provides progress tracking and indicators for long-running astrology calculations
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_system.dart';

/// Progress tracking for astrology calculations
class AstrologyProgressService {
  static AstrologyProgressService? _instance;

  AstrologyProgressService._();

  static AstrologyProgressService get instance {
    _instance ??= AstrologyProgressService._();
    return _instance!;
  }

  final StreamController<AstrologyProgress> _progressController =
      StreamController<AstrologyProgress>.broadcast();

  Stream<AstrologyProgress> get progressStream => _progressController.stream;

  /// Start progress tracking for an operation
  void startProgress(String operationName) {
    _progressController.add(AstrologyProgress(
      operationName: operationName,
      progress: 0.0,
      message: 'Starting $operationName...',
      isComplete: false,
    ));
  }

  /// Update progress
  void updateProgress({
    required String operationName,
    required double progress,
    required String message,
  }) {
    _progressController.add(AstrologyProgress(
      operationName: operationName,
      progress: progress.clamp(0.0, 1.0),
      message: message,
      isComplete: progress >= 1.0,
    ));
  }

  /// Complete progress
  void completeProgress(String operationName) {
    _progressController.add(AstrologyProgress(
      operationName: operationName,
      progress: 1.0,
      message: 'Completed $operationName',
      isComplete: true,
    ));
  }

  /// Error progress
  void errorProgress(String operationName, String error) {
    _progressController.add(AstrologyProgress(
      operationName: operationName,
      progress: 0.0,
      message: 'Error: $error',
      isComplete: false,
      hasError: true,
    ));
  }

  void dispose() {
    _progressController.close();
  }
}

/// Progress data for astrology calculations
class AstrologyProgress {
  final String operationName;
  final double progress;
  final String message;
  final bool isComplete;
  final bool hasError;
  final DateTime timestamp;

  AstrologyProgress({
    required this.operationName,
    required this.progress,
    required this.message,
    required this.isComplete,
    this.hasError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'AstrologyProgress($operationName: ${(progress * 100).toInt()}% - $message)';
  }
}

/// Progress indicator widget for astrology calculations
class AstrologyProgressWidget extends ConsumerWidget {
  final String operationName;
  final double progress;
  final String message;
  final bool isIndeterminate;
  final bool hasError;
  final VoidCallback? onRetry;

  const AstrologyProgressWidget({
    super.key,
    required this.operationName,
    required this.progress,
    required this.message,
    this.isIndeterminate = false,
    this.hasError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.shade50
            : ThemeProperties.getPrimaryColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError
              ? Colors.red.shade200
              : ThemeProperties.getPrimaryColor(context).withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Operation name
          Text(
            operationName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Progress indicator
          if (hasError)
            const Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.red,
            )
          else if (isIndeterminate)
            const CircularProgressIndicator()
          else
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),

          const SizedBox(height: 12),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: hasError ? Colors.red.shade700 : Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),

          // Progress percentage
          if (!isIndeterminate && !hasError) ...[
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          // Retry button for errors
          if (hasError && onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Stream-based progress widget
class AstrologyProgressStreamWidget extends ConsumerWidget {
  final Stream<AstrologyProgress> progressStream;
  final VoidCallback? onRetry;

  const AstrologyProgressStreamWidget({
    super.key,
    required this.progressStream,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<AstrologyProgress>(
      stream: progressStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final progress = snapshot.data!;
        return AstrologyProgressWidget(
          operationName: progress.operationName,
          progress: progress.progress,
          message: progress.message,
          isIndeterminate: progress.progress == 0.0 && !progress.hasError,
          hasError: progress.hasError,
          onRetry: progress.hasError ? onRetry : null,
        );
      },
    );
  }
}

/// Progress overlay for full-screen operations
class AstrologyProgressOverlay extends ConsumerWidget {
  final Stream<AstrologyProgress> progressStream;
  final VoidCallback? onCancel;

  const AstrologyProgressOverlay({
    super.key,
    required this.progressStream,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.2 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AstrologyProgressStreamWidget(
                progressStream: progressStream,
                onRetry: onCancel,
              ),
              if (onCancel != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
