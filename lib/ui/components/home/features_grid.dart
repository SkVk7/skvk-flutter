/// Features Grid Component
///
/// Reusable features grid that adapts to screen size and zoom
library;

import 'package:flutter/material.dart';
import '../../utils/responsive_system.dart';
import '../cards/feature_card.dart';
import '../../../core/services/language/translation_service.dart';

/// Feature Grid Item
/// 
/// Immutable data class for feature grid items
@immutable
class FeatureGridItem {
  final String titleKey;
  final String fallbackTitle;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureGridItem({
    required this.titleKey,
    required this.fallbackTitle,
    required this.icon,
    required this.onTap,
  });
}

/// Features Grid - Responsive grid that adapts to screen size and zoom
class FeaturesGrid extends StatelessWidget {
  final TranslationService translationService;
  final List<FeatureGridItem> items;
  final int? crossAxisCount;
  final double? baseAspectRatio;

  const FeaturesGrid({
    super.key,
    required this.translationService,
    required this.items,
    this.crossAxisCount,
    this.baseAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive grid columns based on screen size
    final int gridCrossAxisCount = crossAxisCount ??
        ResponsiveSystem.responsive(
          context,
          mobile: 2,
          tablet: 3,
          desktop: 4,
          largeDesktop: 4,
        );

    // Get text scale factor to adjust aspect ratio for zoom
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

    // Base aspect ratios - taller cards to accommodate text and zoom
    final double gridBaseAspectRatio = baseAspectRatio ??
        ResponsiveSystem.responsive(
          context,
          mobile: 1.0, // Taller cards to accommodate zoomed text
          tablet: 1.1,
          desktop: 1.2,
          largeDesktop: 1.3,
        );

    // Adjust aspect ratio based on zoom level - make cards taller when zoomed in
    // Lower aspect ratio = taller cards (more vertical space)
    final double adjustedAspectRatio = textScaleFactor > 1.0
        ? gridBaseAspectRatio / (1 + (textScaleFactor - 1.0) * 0.5) // More aggressive adjustment for zoom
        : gridBaseAspectRatio;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Responsive crossAxisCount based on screen size
      crossAxisCount: gridCrossAxisCount,
      crossAxisSpacing: ResponsiveSystem.spacing(context, baseSpacing: 12),
      mainAxisSpacing: ResponsiveSystem.spacing(context, baseSpacing: 12),
      // Adjusted aspect ratio that accounts for zoom level
      childAspectRatio: adjustedAspectRatio,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return FeatureCard(
          key: ValueKey('feature_${item.titleKey}_$index'),
          title: translationService.translateHeader(
            item.titleKey,
            fallback: item.fallbackTitle,
          ),
          icon: item.icon,
          onTap: item.onTap,
        );
      }).toList(),
    );
  }
}

