/// Error Boundary Widget
///
/// Catches and handles errors in the widget tree
/// Provides a fallback UI when errors occur
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/logging/app_logger.dart';

/// Error boundary widget that catches errors in the widget tree
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    required this.child,
    this.fallback,
    this.onError,
    this.showErrorDetails = false,
    super.key,
  });

  /// Child widget to wrap
  final Widget child;

  /// Fallback widget to show when an error occurs
  final Widget? fallback;

  /// Error handler callback
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Whether to show error details in debug mode
  final bool showErrorDetails;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  // Error handling method - kept for future use with ErrorWidget.builder
  // ignore: unused_element
  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
      _hasError = true;
    });

    // Log the error
    AppLogger().error(
      'Error caught by ErrorBoundary: $error',
      source: 'ErrorBoundary',
      stackTrace: stackTrace,
      metadata: {'error': error.toString()},
    );

    // Call error handler if provided
    widget.onError?.call(error, stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      if (widget.fallback != null) {
        return widget.fallback!;
      }

      return _ErrorWidget(
        error: _error,
        stackTrace: _stackTrace,
        showErrorDetails: widget.showErrorDetails,
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
            _hasError = false;
          });
        },
      );
    }

    return widget.child;
  }
}

/// Error widget to display when an error occurs
class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({
    required this.error,
    required this.stackTrace,
    required this.showErrorDetails,
    required this.onRetry,
  });
  final Object? error;
  final StackTrace? stackTrace;
  final bool showErrorDetails;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We encountered an unexpected error. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
              if (showErrorDetails && kDebugMode && error != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Error Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    error.toString(),
                    style: const TextStyle(fontSize: 10),
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

/// Global error handler for Flutter errors
class GlobalErrorHandler {
  static void initialize() {
    FlutterError.onError = (details) {
      AppLogger().error(
        'Flutter Error: ${details.exception}',
        source: 'FlutterError',
        stackTrace: details.stack,
        metadata: {'exception': details.exception.toString()},
      );

      // In production, report to crash reporting service
      if (kReleaseMode) {
        // TODO: Report to crash reporting service (e.g., Sentry, Firebase Crashlytics)
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger().error(
        'Platform Error: $error',
        source: 'PlatformDispatcher',
        stackTrace: stack,
        metadata: {'error': error.toString()},
      );

      // In production, report to crash reporting service
      if (kReleaseMode) {
        // TODO: Report to crash reporting service
      }

      return true;
    };
  }
}

/// Error boundary provider for Riverpod
final errorBoundaryProvider = Provider<ErrorBoundary>((ref) {
  return ErrorBoundary(
    child: const SizedBox.shrink(),
    onError: (error, stackTrace) {
      AppLogger().error(
        'Riverpod Error: $error',
        source: 'RiverpodError',
        stackTrace: stackTrace,
        metadata: {'error': error.toString()},
      );
    },
  );
});
