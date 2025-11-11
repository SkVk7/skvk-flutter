/// Error Display Widget Component
///
/// Reusable error message display with optional retry button
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import 'modern_button.dart';

/// ErrorDisplayWidget - Displays error message with optional retry button
@immutable
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

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
              message,
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

