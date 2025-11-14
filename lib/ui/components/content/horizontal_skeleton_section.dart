/// Horizontal Skeleton Section Widget
///
/// Reusable skeleton loading widget for horizontal sections
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Horizontal Skeleton Section
///
/// Displays a skeleton loading state for horizontal sections
class HorizontalSkeletonSection extends StatelessWidget {
  const HorizontalSkeletonSection({
    required this.title,
    required this.icon,
    super.key,
    this.itemCount = 5,
  });
  final String title;
  final IconData icon;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: ResponsiveSystem.symmetric(
              context,
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 20),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: ThemeHelpers.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ResponsiveSystem.spacing(context, baseSpacing: 180),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: ResponsiveSystem.symmetric(
                context,
                horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                  child: _buildHorizontalSkeletonCard(context),
                );
              },
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSkeletonCard(BuildContext context) {
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
                  height: ResponsiveSystem.fontSize(context, baseSize: 12),
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
