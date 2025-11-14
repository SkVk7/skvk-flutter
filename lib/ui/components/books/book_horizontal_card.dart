/// Book Horizontal Card Component
///
/// Reusable horizontal book card for horizontal scrolling sections
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/services/books/book_favorites_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Book Horizontal Card - Horizontal card for section lists
class BookHorizontalCard extends ConsumerWidget {
  const BookHorizontalCard({
    required this.book,
    required this.onTap,
    super.key,
  });

  final Map<String, dynamic> book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(bookFavoritesServiceProvider);
    final bookId = book['id'] as String? ?? '';
    final title = book['title'] as String? ?? book['id'] as String? ?? '';
    final isFavorite = favorites.contains(bookId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveSystem.spacing(context, baseSpacing: 140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          color: ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.1),
              blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
              offset: Offset(
                0,
                ResponsiveSystem.spacing(context, baseSpacing: 2),
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Book Cover
            Stack(
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
                    color: ThemeHelpers.getPrimaryColor(context)
                        .withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    Icons.menu_book,
                    color: ThemeHelpers.getPrimaryColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 40),
                  ),
                ),
                // Favorite Star Button (top right corner)
                Positioned(
                  top: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  right: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(bookFavoritesServiceProvider.notifier)
                          .toggleFavorite(bookId);
                    },
                    child: Container(
                      padding: ResponsiveSystem.all(context, baseSpacing: 4),
                      decoration: BoxDecoration(
                        color: ThemeHelpers.getShadowColor(context)
                            .withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite
                            ? ThemeHelpers.getPrimaryColor(context)
                            : ThemeHelpers.getAppBarTextColor(context),
                        size: ResponsiveSystem.iconSize(context, baseSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Book Info
            Flexible(
              child: Padding(
                padding: ResponsiveSystem.all(context, baseSpacing: 8),
                child: Tooltip(
                  message: title,
                  preferBelow: false,
                  waitDuration: const Duration(milliseconds: 500),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                      fontWeight: FontWeight.w600,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

