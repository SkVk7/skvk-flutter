/// Error Display Widget Component
///
/// Reusable error message display with optional retry button
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/ui/components/common/modern_button.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Error Widget - Displays error from Failure type
@immutable
class ErrorWidget extends StatelessWidget {
  const ErrorWidget({
    required this.failure,
    super.key,
    this.onRetry,
    this.icon,
    this.customMessage,
  });
  final Failure failure;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? customMessage;

  /// Get user-friendly error message
  String get _errorMessage {
    if (customMessage != null) return customMessage!;

    if (failure is NetworkFailure) {
      return 'Unable to connect. Please check your internet connection and try again.';
    }
    if (failure is ServerFailure) {
      return 'Server error occurred. Please try again later.';
    }
    if (failure is ValidationFailure) {
      return failure.message;
    }
    if (failure is CacheFailure) {
      return 'Data loading error. Please try again.';
    }

    return failure.message;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: ResponsiveSystem.iconSize(context, baseSize: 48),
              color: ThemeHelpers.getErrorColor(context),
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getErrorColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              ResponsiveSystem.sizedBox(context, height: 16),
              ModernButton(
                text: 'Retry',
                onPressed: onRetry,
                width: ResponsiveSystem.screenWidth(context) * 0.5,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error Display Widget - Legacy support for string messages
@immutable
class ErrorDisplayWidget extends StatelessWidget {
  const ErrorDisplayWidget({
    required this.message,
    super.key,
    this.onRetry,
    this.icon,
  });
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      failure: UnexpectedFailure(message: message),
      onRetry: onRetry,
      icon: icon,
    );
  }
}
