/// Book Content List View Screen
///
/// Screen for displaying a filtered list of book content items
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart';
import 'package:skvk_application/core/services/books/book_favorites_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Book Content List View Screen - Shows filtered list of books
class BookContentListViewScreen extends ConsumerWidget {
  const BookContentListViewScreen({
    required this.title,
    required this.books,
    required this.onBookSelected,
    super.key,
  });
  final String title;
  final List<Map<String, dynamic>> books;
  final Function(String) onBookSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
    );
    final favorites = ref.watch(bookFavoritesServiceProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: ResponsiveSystem.symmetric(
                  context,
                  horizontal:
                      ResponsiveSystem.spacing(context, baseSpacing: 16),
                  vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.arrowLeft,
                        color: ThemeHelpers.getAppBarTextColor(context),
                        size: ResponsiveSystem.iconSize(context, baseSize: 24),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 22),
                          fontWeight: FontWeight.bold,
                          color: ThemeHelpers.getAppBarTextColor(context),
                        ),
                      ),
                    ),
                    Text(
                      '${books.length}',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 16),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Book List
              Expanded(
                child: books.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book,
                              size: ResponsiveSystem.iconSize(context,
                                  baseSize: 64,),
                              color:
                                  ThemeHelpers.getSecondaryTextColor(context),
                            ),
                            ResponsiveSystem.sizedBox(
                              context,
                              height: ResponsiveSystem.spacing(context,
                                  baseSpacing: 16,),
                            ),
                            Text(
                              'No books available',
                              style: TextStyle(
                                fontSize: ResponsiveSystem.fontSize(context,
                                    baseSize: 18,),
                                color:
                                    ThemeHelpers.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: ResponsiveSystem.symmetric(
                          context,
                          horizontal: ResponsiveSystem.spacing(context,
                              baseSpacing: 16,),
                          vertical:
                              ResponsiveSystem.spacing(context, baseSpacing: 8),
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          final bookId = book['id'] as String? ?? '';
                          final isFavorite = favorites.contains(bookId);
                          final availableLanguages = List<String>.from(
                              book['availableLanguages'] ?? [],);

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(
                              bottom: ResponsiveSystem.spacing(context,
                                  baseSpacing: 12,),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveSystem.spacing(context,
                                    baseSpacing: 16,),
                              ),
                            ),
                            color: ThemeHelpers.getSurfaceColor(context)
                                .withValues(alpha: 0.9),
                            child: ListTile(
                              leading: Icon(
                                Icons.menu_book,
                                color: ThemeHelpers.getPrimaryColor(context),
                                size: ResponsiveSystem.iconSize(context,
                                    baseSize: 32,),
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
                                    fontSize: ResponsiveSystem.fontSize(context,
                                        baseSize: 16,),
                                    fontWeight: FontWeight.bold,
                                    color: ThemeHelpers.getPrimaryTextColor(
                                        context,),
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Language: ${book['language'] ?? 'en'}',
                                    style: TextStyle(
                                      fontSize: ResponsiveSystem.fontSize(
                                          context,
                                          baseSize: 12,),
                                      color: ThemeHelpers.getSecondaryTextColor(
                                          context,),
                                    ),
                                  ),
                                  if (availableLanguages.length > 1)
                                    Text(
                                      'Available in ${availableLanguages.length} languages',
                                      style: TextStyle(
                                        fontSize: ResponsiveSystem.fontSize(
                                            context,
                                            baseSize: 11,),
                                        color:
                                            ThemeHelpers.getSecondaryTextColor(
                                                context,),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: isFavorite
                                          ? ThemeHelpers.getPrimaryColor(
                                              context,)
                                          : ThemeHelpers.getSecondaryTextColor(
                                              context,),
                                      size: ResponsiveSystem.iconSize(context,
                                          baseSize: 24,),
                                    ),
                                    onPressed: () {
                                      if (!context.mounted) return;
                                      ref
                                          .read(bookFavoritesServiceProvider
                                              .notifier,)
                                          .toggleFavorite(bookId);
                                    },
                                    tooltip: isFavorite
                                        ? 'Remove from favorites'
                                        : 'Add to favorites',
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: ThemeHelpers.getSecondaryTextColor(
                                        context,),
                                    size: ResponsiveSystem.iconSize(context,
                                        baseSize: 16,),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (!context.mounted) return;
                                onBookSelected(bookId);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
