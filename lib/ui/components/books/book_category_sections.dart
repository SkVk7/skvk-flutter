/// Book Category Sections Component
///
/// Reusable category sections builder
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/components/books/book_horizontal_card.dart';
import 'package:skvk_application/ui/components/content/horizontal_section.dart';
import 'package:skvk_application/ui/components/content/horizontal_skeleton_section.dart';

/// Category Sections Builder - Builds category sections from categorized books
class BookCategorySectionsBuilder {
  /// Build category sections from categorized books
  static List<Widget> buildSections({
    required Map<String, List<Map<String, dynamic>>> categories,
    required void Function(String bookId) onBookTap,
    required void Function(String title, List<Map<String, dynamic>> books)
        onNavigateToFilteredList,
  }) {
    final widgets = <Widget>[];

    for (final entry in categories.entries) {
      final categoryName = entry.key;
      final books = entry.value;

      if (books.isEmpty) continue;

      final bookCards = books
          .take(5)
          .map(
            (book) => BookHorizontalCard(
              book: book,
              onTap: () => onBookTap(book['id'] as String),
            ),
          )
          .toList();

      widgets.add(
        HorizontalSection(
          config: HorizontalSectionConfig(
            title: categoryName,
            icon: Icons.category,
            items: bookCards,
            totalCount: books.length,
            onSeeAll: books.length > 5
                ? () => onNavigateToFilteredList(categoryName, books)
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

