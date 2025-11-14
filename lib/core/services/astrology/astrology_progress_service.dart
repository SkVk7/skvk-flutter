/// Astrology Progress Service
///
/// Provides progress tracking and indicators for long-running astrology calculations
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/design_system/design_system.dart';

/// Progress tracking for astrology calculations
class AstrologyProgressService {
  AstrologyProgressService._();

  factory AstrologyProgressService.instance() {
    return _instance ??= AstrologyProgressService._();
  }
  static AstrologyProgressService? _instance;
  final StreamController<AstrologyProgress> _progressController =
      StreamController<AstrologyProgress>.broadcast();

  Stream<AstrologyProgress> get progressStream => _progressController.stream;

  /// Start progress tracking for an operation
  void startProgress(String operationName) {
    _progressController.add(
      AstrologyProgress(
        operationName: operationName,
        progress: 0,
        message: 'Starting $operationName...',
        isComplete: false,
      ),
    );
  }

  /// Update progress
  void updateProgress({
    required String operationName,
    required double progress,
    required String message,
  }) {
    _progressController.add(
      AstrologyProgress(
        operationName: operationName,
        progress: progress.clamp(0.0, 1.0),
        message: message,
        isComplete: progress >= 1.0,
      ),
    );
  }

  /// Complete progress
  void completeProgress(String operationName) {
    _progressController.add(
      AstrologyProgress(
        operationName: operationName,
        progress: 1,
        message: 'Completed $operationName',
        isComplete: true,
      ),
    );
  }

  /// Error progress
  void errorProgress(String operationName, String error) {
    _progressController.add(
      AstrologyProgress(
        operationName: operationName,
        progress: 0,
        message: 'Error: $error',
        isComplete: false,
        hasError: true,
      ),
    );
  }

  void dispose() {
    _progressController.close();
  }
}

/// Progress data for astrology calculations
class AstrologyProgress {
  AstrologyProgress({
    required this.operationName,
    required this.progress,
    required this.message,
    required this.isComplete,
    this.hasError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  final String operationName;
  final double progress;
  final String message;
  final bool isComplete;
  final bool hasError;
  final DateTime timestamp;

  @override
  String toString() {
    return 'AstrologyProgress($operationName: ${(progress * 100).toInt()}% - $message)';
  }
}

/// Progress indicator widget for astrology calculations
class AstrologyProgressWidget extends ConsumerWidget {
  const AstrologyProgressWidget({
    required this.operationName,
    required this.progress,
    required this.message,
    super.key,
    this.isIndeterminate = false,
    this.hasError = false,
    this.onRetry,
  });
  final String operationName;
  final double progress;
  final String message;
  final bool isIndeterminate;
  final bool hasError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: hasError
            ? ThemeHelpers.getErrorColor(context).withValues(alpha: 0.1)
            : ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.1),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: hasError
              ? ThemeHelpers.getErrorColor(context).withValues(alpha: 0.3)
              : ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.3),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Operation name
          Text(
            operationName,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              fontWeight: FontWeight.bold,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),

          ResponsiveSystem.sizedBox(context, height: 12),

          // Progress indicator
          if (hasError)
            Icon(
              Icons.error_outline,
              size: ResponsiveSystem.iconSize(context, baseSize: 32),
              color: ThemeHelpers.getErrorColor(context),
            )
          else if (isIndeterminate)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelpers.getPrimaryColor(context),
              ),
            )
          else
            LinearProgressIndicator(
              value: progress,
              backgroundColor: ThemeHelpers.getSecondaryTextColor(context)
                  .withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelpers.getPrimaryColor(context),
              ),
            ),

          ResponsiveSystem.sizedBox(context, height: 12),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: hasError
                  ? ThemeHelpers.getErrorColor(context)
                  : ThemeHelpers.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),

          // Progress percentage
          if (!isIndeterminate && !hasError) ...[
            ResponsiveSystem.sizedBox(context, height: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: ThemeHelpers.getSecondaryTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          // Retry button for errors
          if (hasError && onRetry != null) ...[
            ResponsiveSystem.sizedBox(context, height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelpers.getErrorColor(context),
                foregroundColor: Theme.of(context).colorScheme.onError,
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
  const AstrologyProgressStreamWidget({
    required this.progressStream,
    super.key,
    this.onRetry,
  });
  final Stream<AstrologyProgress> progressStream;
  final VoidCallback? onRetry;

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
  const AstrologyProgressOverlay({
    required this.progressStream,
    super.key,
    this.onCancel,
  });
  final Stream<AstrologyProgress> progressStream;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: ResponsiveSystem.all(context, baseSpacing: 32),
          padding: ResponsiveSystem.all(context, baseSpacing: 24),
          decoration: BoxDecoration(
            color: ThemeHelpers.getSurfaceColor(context),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
            boxShadow: [
              BoxShadow(
                color:
                    ThemeHelpers.getShadowColor(context).withValues(alpha: 0.2),
                blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 10),
                offset: Offset(
                  0,
                  ResponsiveSystem.spacing(context, baseSpacing: 5),
                ),
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
                ResponsiveSystem.sizedBox(context, height: 16),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeHelpers.getPrimaryColor(context),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
