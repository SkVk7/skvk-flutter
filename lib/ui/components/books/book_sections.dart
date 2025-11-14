/// Book Sections Components
///
/// Reusable section builders for books screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/services/books/book_favorites_service.dart';
import 'package:skvk_application/core/services/books/recently_viewed_books_service.dart';
import 'package:skvk_application/ui/components/books/book_horizontal_card.dart';
import 'package:skvk_application/ui/components/content/horizontal_section.dart';
import 'package:skvk_application/ui/components/content/horizontal_skeleton_section.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Recently Viewed Section Builder
class RecentlyViewedSection extends ConsumerWidget {
  const RecentlyViewedSection({
    required this.booksList,
    required this.getBookById,
    required this.onBookTap,
    required this.onNavigateToFilteredList,
    super.key,
  });

  final List<Map<String, dynamic>> booksList;
  final Map<String, dynamic>? Function(String) getBookById;
  final void Function(String bookId) onBookTap;
  final void Function(String title, List<Map<String, dynamic>> books)
      onNavigateToFilteredList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyViewed = ref.watch(recentlyViewedBooksServiceProvider);

    if (recentlyViewed.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final recentlyViewedBooks = recentlyViewed
        .map(getBookById)
        .whereType<Map<String, dynamic>>()
        .toList();

    if (recentlyViewedBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final bookCards = recentlyViewedBooks
        .take(5)
        .map(
          (book) => BookHorizontalCard(
            book: book,
            onTap: () => onBookTap(book['id'] as String),
          ),
        )
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Recently Viewed',
        icon: Icons.history,
        items: bookCards,
        totalCount: recentlyViewed.length,
        onSeeAll: recentlyViewed.length > 5
            ? () {
                final allRecentlyViewed = recentlyViewed
                    .map(getBookById)
                    .whereType<Map<String, dynamic>>()
                    .toList();
                onNavigateToFilteredList('Recently Viewed', allRecentlyViewed);
              }
            : null,
      ),
    );
  }
}

/// Favorites Section Builder
class FavoritesSection extends ConsumerWidget {
  const FavoritesSection({
    required this.booksList,
    required this.onBookTap,
    required this.onNavigateToFilteredList,
    super.key,
  });

  final List<Map<String, dynamic>> booksList;
  final void Function(String bookId) onBookTap;
  final void Function(String title, List<Map<String, dynamic>> books)
      onNavigateToFilteredList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(bookFavoritesServiceProvider);

    if (favorites.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final favoriteBooks = booksList
        .where((book) => favorites.contains(book['id']))
        .take(5)
        .toList();

    if (favoriteBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final bookCards = favoriteBooks
        .map(
          (book) => BookHorizontalCard(
            book: book,
            onTap: () => onBookTap(book['id'] as String),
          ),
        )
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Favorites',
        icon: Icons.favorite,
        items: bookCards,
        totalCount: favorites.length,
        onSeeAll: favorites.length > 5
            ? () {
                final allFavorites = booksList
                    .where((book) => favorites.contains(book['id']))
                    .toList();
                onNavigateToFilteredList('Favorites', allFavorites);
              }
            : null,
      ),
    );
  }
}

/// Most Read Section Builder
class MostReadSection extends ConsumerWidget {
  const MostReadSection({
    required this.booksList,
    required this.mostRead,
    required this.isLoading,
    required this.getBookById,
    required this.formatViewCount,
    required this.onBookTap,
    required this.onNavigateToFilteredList,
    super.key,
  });

  final List<Map<String, dynamic>> booksList;
  final List<Map<String, dynamic>> mostRead;
  final bool isLoading;
  final Map<String, dynamic>? Function(String) getBookById;
  final String Function(int) formatViewCount;
  final void Function(String bookId) onBookTap;
  final void Function(String title, List<Map<String, dynamic>> books)
      onNavigateToFilteredList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading || booksList.isEmpty) {
      return const HorizontalSkeletonSection(
        title: 'Most Read',
        icon: Icons.trending_up,
      );
    }

    if (mostRead.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final mostReadBooks = mostRead
        .map((item) {
          final bookId = item['id'] as String? ?? '';
          return getBookById(bookId);
        })
        .whereType<Map<String, dynamic>>()
        .take(5)
        .toList();

    if (mostReadBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final bookCards = mostReadBooks.asMap().entries.map((entry) {
      final book = entry.value;
      final bookId = book['id'] as String? ?? '';
      final viewCount = mostRead
              .firstWhere(
                (item) => item['id'] == bookId,
                orElse: () => {'count': 0},
              )['count'] as int? ??
          0;

      return Stack(
        children: [
          BookHorizontalCard(
            book: book,
            onTap: () => onBookTap(bookId),
          ),
          if (viewCount > 0)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: ResponsiveSystem.symmetric(
                  context,
                  horizontal: ResponsiveSystem.spacing(context, baseSpacing: 6),
                  vertical: ResponsiveSystem.spacing(context, baseSpacing: 2),
                ),
                decoration: BoxDecoration(
                  color: ThemeHelpers.getPrimaryColor(context),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                    bottomRight: Radius.circular(
                      ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                  ),
                ),
                child: Text(
                  formatViewCount(viewCount),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 10),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getAppBarTextColor(context),
                  ),
                ),
              ),
            ),
        ],
      );
    }).toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Most Read',
        icon: Icons.trending_up,
        items: bookCards,
        totalCount: mostRead.length,
        onSeeAll: mostRead.length > 5
            ? () {
                final allMostRead = mostRead
                    .map((item) {
                      final bookId = item['id'] as String? ?? '';
                      final viewCount = item['count'] as int? ?? 0;
                      final book = getBookById(bookId);
                      if (book != null) {
                        book['viewCount'] = viewCount;
                      }
                      return book;
                    })
                    .whereType<Map<String, dynamic>>()
                    .toList();
                onNavigateToFilteredList('Most Read', allMostRead);
              }
            : null,
      ),
    );
  }
}

/// Trending Section Builder
class TrendingSection extends ConsumerWidget {
  const TrendingSection({
    required this.booksList,
    required this.trending,
    required this.isLoading,
    required this.getBookById,
    required this.onBookTap,
    required this.onNavigateToFilteredList,
    super.key,
  });

  final List<Map<String, dynamic>> booksList;
  final List<Map<String, dynamic>> trending;
  final bool isLoading;
  final Map<String, dynamic>? Function(String) getBookById;
  final void Function(String bookId) onBookTap;
  final void Function(String title, List<Map<String, dynamic>> books)
      onNavigateToFilteredList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading || booksList.isEmpty) {
      return const HorizontalSkeletonSection(
        title: 'Trending Now',
        icon: Icons.local_fire_department,
      );
    }

    if (trending.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final trendingBooks = trending
        .map((item) {
          final bookId = item['id'] as String? ?? '';
          return getBookById(bookId);
        })
        .whereType<Map<String, dynamic>>()
        .take(5)
        .toList();

    if (trendingBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final bookCards = trendingBooks
        .map(
          (book) => BookHorizontalCard(
            book: book,
            onTap: () => onBookTap(book['id'] as String),
          ),
        )
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Trending Now',
        icon: Icons.local_fire_department,
        items: bookCards,
        totalCount: trending.length,
        onSeeAll: trending.length > 5
            ? () {
                final allTrending = trending
                    .map((item) {
                      final bookId = item['id'] as String? ?? '';
                      return getBookById(bookId);
                    })
                    .whereType<Map<String, dynamic>>()
                    .toList();
                onNavigateToFilteredList('Trending Now', allTrending);
              }
            : null,
      ),
    );
  }
}

