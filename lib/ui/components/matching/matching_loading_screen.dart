/// Matching Loading Screen Component
///
/// Reusable loading screen for matching calculations
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Matching Loading Screen - Shows loading state during calculations
class MatchingLoadingScreen extends ConsumerWidget {
  const MatchingLoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationService = ref.watch(translationServiceProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeHelpers.getPrimaryColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 24),
          ),
          Text(
            translationService.translateContent(
              'calculating',
              fallback: 'Calculating Compatibility...',
            ),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.w600,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          Text(
            translationService.translateContent(
              'please_wait',
              fallback: 'Please wait while we calculate your compatibility',
            ),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
