/// Book Card Component
///
/// Reusable vertical book card for list views
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/books/book_favorites_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Book Card - Vertical card design for book list
class BookCard extends ConsumerWidget {
  const BookCard({
    required this.book,
    required this.onTap,
    super.key,
  });

  final Map<String, dynamic> book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(bookFavoritesServiceProvider);
    final availableLanguages =
        List<String>.from(book['availableLanguages'] ?? []);
    final bookId = book['id'] as String? ?? '';
    final isFavorite = favorites.contains(bookId);

    return Card(
      margin: ResponsiveSystem.only(
        context,
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 12),
      ),
      elevation: ResponsiveSystem.elevation(context, baseElevation: 2),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      color: ThemeHelpers.getSurfaceColor(context),
      child: ListTile(
        leading: Icon(
          Icons.menu_book,
          color: ThemeHelpers.getPrimaryColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 32),
        ),
        title: Tooltip(
          message: book['title'] ?? book['id'],
          preferBelow: false,
          waitDuration: const Duration(milliseconds: 500),
          child: Text(
            book['title'] ?? book['id'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              fontWeight: FontWeight.bold,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language: ${book['language'] ?? 'en'}',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
            if (availableLanguages.length > 1)
              Text(
                'Available in ${availableLanguages.length} languages',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 11),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite
                    ? ThemeHelpers.getPrimaryColor(context)
                    : ThemeHelpers.getSecondaryTextColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 24),
              ),
              onPressed: () {
                ref
                    .read(bookFavoritesServiceProvider.notifier)
                    .toggleFavorite(bookId);
              },
              tooltip:
                  isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: ThemeHelpers.getSecondaryTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
            ),
          ],
        ),
        onTap: () async {
          final bookId = book['id'] as String;
          await LoggingHelper.logInfo(
            'User clicked book: id=$bookId, title=${book['title']}',
            source: 'BookCard',
          );
          onTap();
        },
      ),
    );
  }
}

