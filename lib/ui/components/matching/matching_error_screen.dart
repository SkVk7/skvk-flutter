/// Matching Error Screen Component
///
/// Reusable error screen for matching failures
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../common/index.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/services/language/translation_service.dart';

/// Matching Error Screen - Shows error state with retry option
class MatchingErrorScreen extends ConsumerWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const MatchingErrorScreen({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationService = ref.watch(translationServiceProvider);
    
    return Center(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveSystem.iconSize(context, baseSize: 64),
              color: ThemeHelpers.getErrorColor(context),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
            Text(
              translationService.translateContent('error_loading_matching',
                  fallback: 'Unable to Load Matching Results'),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Text(
              errorMessage ??
                  translationService.translateContent('unknown_error',
                      fallback: 'An unknown error occurred'),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onGoBack != null) ...[
                  ModernButton(
                    text: translationService.translateContent('go_back',
                        fallback: 'Go Back'),
                    icon: LucideIcons.arrowLeft,
                    onPressed: onGoBack!,
                    width: ResponsiveSystem.screenWidth(context) * 0.35,
                  ),
                  ResponsiveSystem.sizedBox(context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                ],
                if (onRetry != null)
                  ModernButton(
                    text: translationService.translateContent('retry',
                        fallback: 'Retry'),
                    icon: LucideIcons.refreshCw,
                    onPressed: onRetry!,
                    width: ResponsiveSystem.screenWidth(context) * 0.35,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

