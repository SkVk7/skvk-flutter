/// Book Horizontal Skeleton Card Component
///
/// Loading skeleton for horizontal book cards
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Book Horizontal Skeleton Card - Loading skeleton for horizontal book cards
class BookHorizontalSkeletonCard extends StatelessWidget {
  const BookHorizontalSkeletonCard({super.key});

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
                  height: ResponsiveSystem.spacing(context, baseSpacing: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSystem.spacing(context, baseSpacing: 4),
                    ),
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
                  height: ResponsiveSystem.spacing(context, baseSpacing: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSystem.spacing(context, baseSpacing: 4),
                    ),
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

