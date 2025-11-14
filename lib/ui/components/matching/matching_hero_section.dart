/// Matching Hero Section Component
///
/// Reusable hero section for matching screen
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Matching Hero Section - Input screen hero
class MatchingHeroSection extends StatelessWidget {
  const MatchingHeroSection({
    required this.translationService,
    super.key,
  });
  final TranslationService translationService;

  @override
  Widget build(BuildContext context) {
    final primaryGradient = ThemeHelpers.getPrimaryGradient(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 30),
          ),
          bottomRight: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 30),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              ResponsiveSystem.spacing(context, baseSpacing: 60),
          bottom: ResponsiveSystem.spacing(context, baseSpacing: 20),
          left: ResponsiveSystem.spacing(context, baseSpacing: 20),
          right: ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.heart,
              size: ResponsiveSystem.iconSize(context, baseSize: 40),
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            // Main title
            Text(
              '💕 ${translationService.translateHeader('kundali_matching', fallback: 'Kundali Matching')}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            // Subtitle
            Text(
              'Find your perfect partner',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getPrimaryTextColor(context)
                    .withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Matching Results Hero Section - Results screen hero
class MatchingResultsHeroSection extends StatelessWidget {
  const MatchingResultsHeroSection({
    super.key,
    this.compatibilityScore,
  });
  final double? compatibilityScore;

  @override
  Widget build(BuildContext context) {
    final primaryGradient = ThemeHelpers.getPrimaryGradient(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 30),
          ),
          bottomRight: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 30),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: ResponsiveSystem.spacing(context, baseSpacing: 32),
          bottom: ResponsiveSystem.spacing(context, baseSpacing: 24),
          left: ResponsiveSystem.spacing(context, baseSpacing: 20),
          right: ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.star,
              size: ResponsiveSystem.iconSize(context, baseSize: 48),
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            Text(
              'Matching Results',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                color: ThemeHelpers.getPrimaryTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            Text(
              '${(compatibilityScore ?? 0).toStringAsFixed(0)}% Compatible',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                color: ThemeHelpers.getPrimaryTextColor(context)
                    .withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
