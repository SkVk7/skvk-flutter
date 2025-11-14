/// Horizontal Section Widget
///
/// Reusable widget for displaying horizontal scrolling sections
/// with title, icon, and "See All" button
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Configuration for a horizontal section
class HorizontalSectionConfig {
  const HorizontalSectionConfig({
    required this.title,
    required this.icon,
    required this.items,
    this.totalCount = 0,
    this.displayLimit = 5,
    this.onSeeAll,
    this.showSeeAll = true,
  });
  final String title;
  final IconData icon;
  final List<Widget> items;
  final int totalCount;
  final int displayLimit;
  final VoidCallback? onSeeAll;
  final bool showSeeAll;
}

/// Horizontal Section Widget
///
/// Displays a horizontal scrolling list with a title, icon, and optional "See All" button
class HorizontalSection extends StatelessWidget {
  const HorizontalSection({
    required this.config,
    super.key,
  });
  final HorizontalSectionConfig config;

  @override
  Widget build(BuildContext context) {
    if (config.items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final displayItems = config.items.take(config.displayLimit).toList();

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      config.icon,
                      color: ThemeHelpers.getPrimaryColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    Text(
                      config.title,
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 20),
                        fontWeight: FontWeight.bold,
                        color: ThemeHelpers.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                if (config.showSeeAll &&
                    config.totalCount > config.displayLimit &&
                    config.onSeeAll != null)
                  TextButton(
                    onPressed: config.onSeeAll,
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getPrimaryColor(context),
                      ),
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
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                  child: displayItems[index],
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
}
