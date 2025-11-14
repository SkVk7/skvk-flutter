/// Audio Category Sections Component
///
/// Reusable category sections builder
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/components/audio/audio_horizontal_track_card.dart';
import 'package:skvk_application/ui/components/content/horizontal_section.dart';
import 'package:skvk_application/ui/components/content/horizontal_skeleton_section.dart';

/// Category Sections Builder - Builds category sections from categorized tracks
class CategorySectionsBuilder {
  /// Build category sections from categorized tracks
  static List<Widget> buildSections({
    required Map<String, List<Map<String, dynamic>>> categories,
    required void Function(String title, List<Map<String, dynamic>> tracks)
        onNavigateToFilteredList,
  }) {
    final widgets = <Widget>[];

    for (final entry in categories.entries) {
      final categoryName = entry.key;
      final tracks = entry.value;

      if (tracks.isEmpty) continue;

      final trackCards = tracks
          .take(5)
          .map((track) => AudioHorizontalTrackCard(music: track))
          .toList();

      widgets.add(
        HorizontalSection(
          config: HorizontalSectionConfig(
            title: categoryName,
            icon: Icons.category,
            items: trackCards,
            totalCount: tracks.length,
            onSeeAll: tracks.length > 5
                ? () => onNavigateToFilteredList(categoryName, tracks)
                : null,
          ),
        ),
      );
    }

    return widgets;
  }

  /// Build category section skeleton
  static Widget buildSkeleton(BuildContext context) {
    return const HorizontalSkeletonSection(
      title: 'Categories',
      icon: Icons.category,
    );
  }
}
