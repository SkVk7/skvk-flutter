/// Audio Horizontal Skeleton Card Component
///
/// Loading skeleton for horizontal track cards
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Audio Horizontal Skeleton Card - Loading state for horizontal track cards
class AudioHorizontalSkeletonCard extends StatelessWidget {
  const AudioHorizontalSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveSystem.spacing(context, baseSpacing: 140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveSystem.spacing(context, baseSpacing: 12),
        ),
        color: ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: ResponsiveSystem.spacing(context, baseSpacing: 140),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                topRight: Radius.circular(
                  ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
              ),
              color: ThemeHelpers.getSecondaryTextColor(context)
                  .withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: ResponsiveSystem.all(context, baseSpacing: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: ResponsiveSystem.fontSize(context, baseSize: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: ThemeHelpers.getSecondaryTextColor(context)
                        .withValues(alpha: 0.1),
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                ),
                Container(
                  width: ResponsiveSystem.spacing(context, baseSpacing: 80),
                  height: ResponsiveSystem.fontSize(context, baseSize: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: ThemeHelpers.getSecondaryTextColor(context)
                        .withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
