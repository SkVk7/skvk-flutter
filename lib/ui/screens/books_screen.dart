/// Books Screen
///
/// Screen for viewing devotional books in PDF format
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/analytics/analytics_service.dart';
import 'package:skvk_application/core/services/books/recently_viewed_books_service.dart';
import 'package:skvk_application/core/services/content/content_api_service.dart';
import 'package:skvk_application/core/services/content/content_language_service.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/core/utils/validation/error_message_helper.dart';
import 'package:skvk_application/ui/components/books/index.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/components/content/book_reader_widget.dart';
import 'package:skvk_application/ui/screens/book_content_list_view_screen.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Books screen
class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  List<Map<String, dynamic>> _booksList = [];
  Map<String, dynamic>? _selectedBook;
  bool _isLoading = false;
  bool _isLoadingBook = false;
  String? _errorMessage;
  String? _bookUrl; // Book URL for reader
  List<String> _availableLanguages =
      []; // Available languages for selected book

  // Analytics data
  List<Map<String, dynamic>> _mostRead = [];
  List<Map<String, dynamic>> _trending = [];
  bool _isLoadingAnalytics = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBooksList = [];

  @override
  void initState() {
    super.initState();
    _loadBooksList();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load analytics data (Most Read, Trending)
  Future<void> _loadAnalytics() async {
    if (_isLoadingAnalytics) return;

    setState(() {
      _isLoadingAnalytics = true;
    });

    try {
      final results = await Future.wait([
        AnalyticsService.instance().getMostVisitedBooks(),
        AnalyticsService.instance().getTrending(type: 'book'),
      ]);

      if (mounted) {
        setState(() {
          _mostRead = results[0];
          _trending = results[1];
          _isLoadingAnalytics = false;
        });
      }
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to load book analytics',
          source: 'BooksScreen', error: e,);
      if (mounted) {
        setState(() {
          _isLoadingAnalytics = false;
        });
      }
    }
  }

  /// Get book by ID from books list
  Map<String, dynamic>? _getBookById(String bookId) {
    try {
      return _booksList.firstWhere((book) => book['id'] == bookId);
    } on Exception {
      // No element found
      return null;
    }
  }

  /// Extract category from ID (format: {category}-{content-id})
  String _extractCategoryFromId(String fullId) {
    final parts = fullId.split('-');
    if (parts.length < 2) {
      return 'Other';
    }
    final category = parts[0];
    return category.isEmpty
        ? 'Other'
        : category[0].toUpperCase() + category.substring(1).toLowerCase();
  }

  /// Categorize books by parsing category from ID
  Map<String, List<Map<String, dynamic>>> _categorizeBooks() {
    final categories = <String, List<Map<String, dynamic>>>{};

    for (final book in _booksList) {
      final bookId = book['id'] as String? ?? '';
      final category = _extractCategoryFromId(bookId);

      if (!categories.containsKey(category)) {
        categories[category] = [];
      }
      categories[category]!.add(book);
    }

    // Sort categories alphabetically for consistent display
    final sortedCategories = Map.fromEntries(
      categories.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return sortedCategories;
  }

  /// Navigate to filtered list screen
  void _navigateToFilteredBookList(
      String title, List<Map<String, dynamic>> books,) {
    if (!mounted || books.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookContentListViewScreen(
          title: title,
          books: books,
          onBookSelected: (bookId) {
            Navigator.of(context).pop();
            unawaited(
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _loadBook(bookId);
                }
              }),
            );
          },
        ),
      ),
    );
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooksList = _booksList;
      } else {
        _filteredBooksList = _booksList.where((book) {
          final title = (book['title'] as String? ?? '').toLowerCase();
          final searchQuery = query.toLowerCase();
          return title.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _loadBooksList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final languageCode = ref
          .read(contentLanguageServiceProvider.notifier)
          .getCurrentLanguageCode();
      final booksList = await ContentApiService.instance()
          .getBooksList(language: languageCode);

      if (mounted) {
        final books = List<Map<String, dynamic>>.from(booksList['books'] ?? []);
        await LoggingHelper.logInfo(
          'Loaded ${books.length} books from Cloudflare R2 for language $languageCode',
          source: 'BooksScreen',
        );
        setState(() {
          _booksList = books;
          _filteredBooksList = books;
          _isLoading = false;
          if (books.isNotEmpty) {
            _errorMessage = null;
            // Log book IDs for debugging
            final bookIds = books.map((b) => b['id']).join(', ');
            unawaited(
              LoggingHelper.logInfo(
                'Available books: $bookIds',
                source: 'BooksScreen',
              ),
            );
          } else if (books.isEmpty) {
            _errorMessage =
                'No books available at the moment. Please try again later.';
          }
        });
      }
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to load books list',
        source: 'BooksScreen',
        error: e,
      );
      if (mounted) {
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(e);
        setState(() {
          _isLoading = false;
          _errorMessage = userFriendlyMessage;
        });
      }
    }
  }

  Future<void> _loadBook(String bookId) async {
    // Normalize book ID to match R2 format (lowercase, alphanumeric, hyphens only)
    final normalizedBookId = bookId.toLowerCase().trim();

    await LoggingHelper.logInfo(
      'Loading book: originalId=$bookId, normalizedId=$normalizedBookId',
      source: 'BooksScreen',
    );

    try {
      setState(() {
        _isLoadingBook = true;
        _errorMessage = null;
        _bookUrl = null;
        _selectedBook = null;
        _availableLanguages = [];
      });

      // Find selected book immediately for better UX
      // Try exact match first, then normalized match
      Map<String, dynamic>? selectedBook;
      try {
        selectedBook = _booksList.firstWhere(
          (b) => (b['id'] as String) == bookId,
        );
        await LoggingHelper.logInfo(
          'Found book with exact match: ${selectedBook['id']}',
          source: 'BooksScreen',
        );
      } on Exception {
        try {
          selectedBook = _booksList.firstWhere(
            (b) => (b['id'] as String).toLowerCase().trim() == normalizedBookId,
          );
          await LoggingHelper.logInfo(
            'Found book with normalized match: ${selectedBook['id']}',
            source: 'BooksScreen',
          );
        } on Exception {
          final availableIds =
              _booksList.map((b) => b['id'] as String).join(', ');
          await LoggingHelper.logError(
            'Book not found: originalId=$bookId, normalizedId=$normalizedBookId. Available IDs: $availableIds',
            source: 'BooksScreen',
          );
          throw Exception(
              'Book not found in list: $bookId (normalized: $normalizedBookId)',);
        } catch (e) {
          // Re-throw if it's not a StateError
          if (e is! StateError) rethrow;
          final availableIds =
              _booksList.map((b) => b['id'] as String).join(', ');
          await LoggingHelper.logError(
            'Book not found: originalId=$bookId, normalizedId=$normalizedBookId. Available IDs: $availableIds',
            source: 'BooksScreen',
          );
          throw Exception(
              'Book not found in list: $bookId (normalized: $normalizedBookId)',);
        }
      } catch (e) {
        // Re-throw if it's not a StateError
        if (e is! StateError) rethrow;
        final availableIds =
            _booksList.map((b) => b['id'] as String).join(', ');
        await LoggingHelper.logError(
          'Book not found: originalId=$bookId, normalizedId=$normalizedBookId. Available IDs: $availableIds',
          source: 'BooksScreen',
        );
        throw Exception(
            'Book not found in list: $bookId (normalized: $normalizedBookId)',);
      }
      if (mounted) {
        setState(() {
          _selectedBook = selectedBook;
        });
      }

      final languagePrefs = ref.read(contentLanguageServiceProvider);
      final currentLanguageCode = languagePrefs.selectedLanguage.code;
      final availableLanguages = List<String>.from(
        selectedBook['availableLanguages'] ?? [currentLanguageCode],
      );

      // Determine which language to use (prefer current, fallback to available)
      String languageToUse = currentLanguageCode;
      if (!availableLanguages.contains(currentLanguageCode)) {
        // Current language not available, try English first, then first available
        if (availableLanguages.contains('en')) {
          languageToUse = 'en';
        } else if (availableLanguages.isNotEmpty) {
          languageToUse = availableLanguages.first;
        } else {
          // Fallback to current language if no available languages
          languageToUse = currentLanguageCode;
        }
        await LoggingHelper.logInfo(
          'Book $normalizedBookId: Language $currentLanguageCode not available, using $languageToUse',
          source: 'BooksScreen',
        );
      }

      // CRITICAL PATH: Get book URL immediately (this is what user is waiting for)
      // Try with determined language, with fallback to English if needed
      String bookUrl = '';
      try {
        await LoggingHelper.logInfo(
          'Fetching book URL: bookId=$normalizedBookId (original: $bookId), language=$languageToUse',
          source: 'BooksScreen',
        );
        bookUrl = await ContentApiService.instance()
            .getBookUrl(normalizedBookId, language: languageToUse);
        await LoggingHelper.logInfo(
          'Successfully got book URL: $bookUrl',
          source: 'BooksScreen',
        );
      } on Exception catch (e, stackTrace) {
        await LoggingHelper.logError(
          'Failed to get book URL for $normalizedBookId (original: $bookId) in language $languageToUse: $e',
          source: 'BooksScreen',
          error: e,
          stackTrace: stackTrace,
        );
        if (languageToUse != 'en' && availableLanguages.contains('en')) {
          await LoggingHelper.logInfo(
            'Book $normalizedBookId: Failed to load in $languageToUse, trying English',
            source: 'BooksScreen',
          );
          try {
            await LoggingHelper.logInfo(
              'Trying English fallback for book: $normalizedBookId (original: $bookId)',
              source: 'BooksScreen',
            );
            bookUrl = await ContentApiService.instance()
                .getBookUrl(normalizedBookId, language: 'en');
            languageToUse = 'en';
            await LoggingHelper.logInfo(
              'Successfully got book URL in English: $bookUrl',
              source: 'BooksScreen',
            );
          } on Exception catch (e2, stackTrace2) {
            await LoggingHelper.logError(
              'English fallback also failed for $normalizedBookId (original: $bookId): $e2',
              source: 'BooksScreen',
              error: e2,
              stackTrace: stackTrace2,
            );
            if (availableLanguages.isNotEmpty) {
              final firstAvailableLang = availableLanguages.firstWhere(
                (lang) => lang != 'en',
                orElse: () => availableLanguages.first,
              );
              if (firstAvailableLang != 'en' &&
                  firstAvailableLang != languageToUse) {
                await LoggingHelper.logInfo(
                  'Book $normalizedBookId (original: $bookId): Failed to load in English, trying $firstAvailableLang',
                  source: 'BooksScreen',
                );
                try {
                  bookUrl = await ContentApiService.instance().getBookUrl(
                      normalizedBookId,
                      language: firstAvailableLang,);
                  languageToUse = firstAvailableLang;
                  await LoggingHelper.logInfo(
                    'Successfully got book URL in $firstAvailableLang: $bookUrl',
                    source: 'BooksScreen',
                  );
                } catch (e3, stackTrace3) {
                  await LoggingHelper.logError(
                    'All language fallbacks failed for $normalizedBookId (original: $bookId). Original error: $e, English error: $e2, First available error: $e3',
                    source: 'BooksScreen',
                    error: e3,
                    stackTrace: stackTrace3,
                  );
                  rethrow; // Re-throw original error if all fallbacks fail
                }
              } else {
                rethrow; // Re-throw original error if all fallbacks fail
              }
            } else {
              rethrow; // Re-throw original error if all fallbacks fail
            }
          }
        } else {
          rethrow; // Re-throw if no fallback available
        }
      }

      if (bookUrl.isEmpty) {
        throw Exception('Invalid book URL. Please try again.');
      }

      await LoggingHelper.logInfo(
        'Loading book: $normalizedBookId, language: $languageToUse (requested: $currentLanguageCode), URL: $bookUrl, available: $availableLanguages',
        source: 'BooksScreen',
      );

      // Book URL is ready! Clear loading state and show book
      if (mounted) {
        setState(() {
          _bookUrl = bookUrl;
          _isLoadingBook = false;
        });
      }

      await _loadAvailableLanguages(normalizedBookId, languageToUse);

      // NON-BLOCKING: Track analytics (fire and forget)
      unawaited(_trackBookView(normalizedBookId));

      // Track recently viewed
      unawaited(ref
          .read(recentlyViewedBooksServiceProvider.notifier)
          .addBook(bookId),);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to load book: $normalizedBookId',
        source: 'BooksScreen',
        error: e,
      );
      await LoggingHelper.logError(
        'Error details: ${e.toString()}',
        source: 'BooksScreen',
      );
      if (mounted) {
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(e);
        await LoggingHelper.logError(
          'User-friendly error: $userFriendlyMessage',
          source: 'BooksScreen',
        );
        setState(() {
          _isLoadingBook = false;
          _errorMessage =
              'Failed to load book: $userFriendlyMessage. Please check if the book is available in your selected language.';
          _selectedBook = null;
          _bookUrl = null;
        });
      }
    }
  }

  /// Load available languages from R2 API (for dropdown filtering)
  /// This fetches the actual available languages for the book from Cloudflare R2
  Future<void> _loadAvailableLanguages(
    String bookId,
    String currentLanguageCode,
  ) async {
    try {
      // Fetch available languages for this book from R2 API
      final languagesData =
          await ContentApiService.instance().getAvailableLanguages(
        contentId: bookId,
        contentType: 'books',
      );
      final availableLangs =
          List<String>.from(languagesData['languages'] ?? []);

      await LoggingHelper.logInfo(
        'Book $bookId: Found ${availableLangs.length} available languages from R2: ${availableLangs.join(", ")}',
        source: 'BooksScreen',
      );

      if (mounted) {
        setState(() {
          if (availableLangs.isNotEmpty) {
            _availableLanguages = availableLangs;
          } else {
            _availableLanguages = [currentLanguageCode];
          }
        });
        if (availableLangs.isEmpty) {
          unawaited(
            LoggingHelper.logWarning(
              'Book $bookId: No languages returned from API, using current language only',
              source: 'BooksScreen',
            ),
          );
        }
      }

      if (availableLangs.isNotEmpty &&
          !availableLangs.contains(currentLanguageCode)) {
        final defaultLang =
            availableLangs.contains('en') ? 'en' : availableLangs.first;
        await LoggingHelper.logInfo(
          'Book $bookId: Current language $currentLanguageCode not available, switching to $defaultLang',
          source: 'BooksScreen',
        );
        final lang = ContentLanguage.fromCode(defaultLang);
        await ref
            .read(contentLanguageServiceProvider.notifier)
            .setContentLanguage(lang);
      }
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to fetch available languages from R2',
        source: 'BooksScreen',
        error: e,
      );
      // Fallback: use current language only if API fails
      if (mounted) {
        setState(() {
          _availableLanguages = [currentLanguageCode];
        });
      }
    }
  }

  /// Track book view analytics (non-blocking, fire and forget)
  Future<void> _trackBookView(String bookId) async {
    try {
      await AnalyticsService.instance().trackBookView(bookId);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to track book view',
        source: 'BooksScreen',
        error: e,
      );
      // Silently fail - analytics shouldn't block user experience
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final translationService = ref.watch(translationServiceProvider);
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight:
                    ResponsiveSystem.spacing(context, baseSpacing: 120),
                floating: true,
                pinned: true,
                backgroundColor: ThemeHelpers.getTransparentColor(context),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    LucideIcons.arrowLeft,
                    color: ThemeHelpers.getAppBarTextColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  // Language Dropdown Widget
                  LanguageDropdown(
                    onLanguageChanged: (value) async {
                      await LoggingHelper.logInfo(
                          'Language changed to: $value',);
                    },
                  ),
                  // Theme Dropdown Widget
                  ThemeDropdown(
                    onThemeChanged: (value) async {
                      await LoggingHelper.logInfo('Theme changed to: $value');
                      ScreenHandlers.handleThemeChange(ref, value);
                    },
                  ),
                  // Profile Photo with Hover Effect
                  Padding(
                    padding: ResponsiveSystem.only(
                      context,
                      right: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    child: ProfilePhoto(
                      key: const ValueKey('profile_icon'),
                      onTap: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      tooltip: translationService.translateContent(
                        'my_profile',
                        fallback: 'My Profile',
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    translationService.translateHeader(
                      'devotional_books',
                      fallback: 'Devotional Books',
                    ),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 18),
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getAppBarTextColor(context),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: ThemeHelpers.getPrimaryGradient(context),
                    ),
                  ),
                ),
              ),

              // Search Bar (only show when not viewing a book)
              if (_selectedBook == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveSystem.symmetric(
                      context,
                      horizontal:
                          ResponsiveSystem.spacing(context, baseSpacing: 16),
                      vertical:
                          ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: ThemeHelpers.getSecondaryTextColor(
                                      context,),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterBooks('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: ThemeHelpers.getSurfaceColor(context)
                            .withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveSystem.spacing(context, baseSpacing: 12),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: ResponsiveSystem.symmetric(
                          context,
                          horizontal: ResponsiveSystem.spacing(context,
                              baseSpacing: 16,),
                          vertical: ResponsiveSystem.spacing(context,
                              baseSpacing: 12,),
                        ),
                      ),
                      style: TextStyle(
                        color: ThemeHelpers.getPrimaryTextColor(context),
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 16),
                      ),
                      onChanged: _filterBooks,
                    ),
                  ),
                ),

              // Book Reader (full screen when book is selected)
              if (_selectedBook != null && _bookUrl != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildBookReader(context, isDark),
                ),

              if (_selectedBook != null && _bookUrl == null && _isLoadingBook)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: ThemeHelpers.getPrimaryColor(context),
                        ),
                        ResponsiveSystem.sizedBox(
                          context,
                          height: ResponsiveSystem.spacing(context,
                              baseSpacing: 16,),
                        ),
                        Text(
                          'Loading book...',
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context,
                                baseSize: 16,),
                            color: ThemeHelpers.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Main Content (only show when no book is selected)
              if (_selectedBook == null) ...[
                // Recently Viewed Section
                RecentlyViewedSection(
                  booksList: _booksList,
                  getBookById: _getBookById,
                  onBookTap: _loadBook,
                  onNavigateToFilteredList: _navigateToFilteredBookList,
                ),

                // Favorites Section
                FavoritesSection(
                  booksList: _booksList,
                  onBookTap: _loadBook,
                  onNavigateToFilteredList: _navigateToFilteredBookList,
                ),

                // Most Read Section (Analytics)
                MostReadSection(
                  booksList: _booksList,
                  mostRead: _mostRead,
                  isLoading: _isLoadingAnalytics || _isLoading,
                  getBookById: _getBookById,
                  formatViewCount: _formatViewCount,
                  onBookTap: _loadBook,
                  onNavigateToFilteredList: _navigateToFilteredBookList,
                ),

                // Trending Section (Analytics)
                TrendingSection(
                  booksList: _booksList,
                  trending: _trending,
                  isLoading: _isLoadingAnalytics || _isLoading,
                  getBookById: _getBookById,
                  onBookTap: _loadBook,
                  onNavigateToFilteredList: _navigateToFilteredBookList,
                ),

                // Category Sections (show skeleton if loading)
                if (_isLoading || _booksList.isEmpty)
                  SliverToBoxAdapter(
                    child: BookCategorySectionsBuilder.buildSkeleton(context),
                  ),
                if (!_isLoading && _booksList.isNotEmpty)
                  ...BookCategorySectionsBuilder.buildSections(
                    categories: _categorizeBooks(),
                    onBookTap: _loadBook,
                    onNavigateToFilteredList: _navigateToFilteredBookList,
                  ),

                // All Books Section (or Search Results) - show skeleton if loading
                if (_isLoading)
                  SliverToBoxAdapter(
                    child: _buildAllBooksSectionSkeleton(),
                  )
                else if (_searchController.text.isNotEmpty)
                  _buildSearchResultsSection()
                else
                  _buildAllBooksSection(),

                // Error Message
                if (_errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: ResponsiveSystem.all(context, baseSpacing: 16),
                      child: ErrorDisplayWidget(
                        message: _errorMessage!,
                        onRetry: _loadBooksList,
                        icon: Icons.error_outline,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Format view count for display
  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// All Books Section
  Widget _buildAllBooksSection() {
    if (_booksList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: ResponsiveSystem.symmetric(
              context,
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            child: BookCard(
              book: _booksList[index],
              onTap: () => _loadBook(_booksList[index]['id'] as String),
            ),
          );
        },
        childCount: _booksList.length,
      ),
    );
  }

  /// Search Results Section
  Widget _buildSearchResultsSection() {
    if (_filteredBooksList.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: ResponsiveSystem.all(context, baseSpacing: 32),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: ResponsiveSystem.iconSize(context, baseSize: 64),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                Text(
                  'No books found',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    color: ThemeHelpers.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: ResponsiveSystem.symmetric(
              context,
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            child: BookCard(
              book: _filteredBooksList[index],
              onTap: () => _loadBook(_filteredBooksList[index]['id'] as String),
            ),
          );
        },
        childCount: _filteredBooksList.length,
      ),
    );
  }

  /// All Books Section Skeleton
  Widget _buildAllBooksSectionSkeleton() {
    return Padding(
      padding: ResponsiveSystem.symmetric(
        context,
        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
        vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
      ),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            child: Container(
              height: ResponsiveSystem.spacing(context, baseSpacing: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                color: ThemeHelpers.getSurfaceColor(context)
                    .withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Book Reader Widget
  Widget _buildBookReader(BuildContext context, bool isDark) {
    if (_bookUrl == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: ResponsiveSystemExtensions.screenHeight(context) * 0.85,
      child: Stack(
        children: [
          // Book Reader Widget
          BookReaderWidget(
            bookUrl: _bookUrl!,
            bookTitle: _selectedBook!['title'] ?? _selectedBook!['id'],
            availableLanguages: _availableLanguages,
            onContentLanguageChanged: (value) async {
              // Fetch book with new language on-demand
              if (_selectedBook != null) {
                final bookId = _selectedBook!['id'] as String;
                final normalizedBookId = bookId.toLowerCase().trim();
                await _loadBook(normalizedBookId);
              }
            },
          ),
          // Back button overlay (top-left corner - goes back to book list)
          // Positioned higher and with more spacing to avoid overlap with book content and navigation buttons
          Positioned(
            top: ResponsiveSystem.spacing(context, baseSpacing: 16),
            left: ResponsiveSystem.spacing(context, baseSpacing: 16),
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedBook = null;
                      _bookUrl = null;
                    });
                  },
                  borderRadius:
                      ResponsiveSystem.circular(context, baseRadius: 24),
                  child: Container(
                    padding: ResponsiveSystem.all(context, baseSpacing: 10),
                    decoration: BoxDecoration(
                      color: ThemeHelpers.getSurfaceColor(context)
                          .withValues(alpha: 0.95),
                      borderRadius:
                          ResponsiveSystem.circular(context, baseRadius: 24),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeHelpers.getShadowColor(context)
                              .withValues(alpha: 0.3),
                          blurRadius: ResponsiveSystem.spacing(
                            context,
                            baseSpacing: 12,
                          ),
                          offset: Offset(
                            0,
                            ResponsiveSystem.spacing(
                              context,
                              baseSpacing: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: ResponsiveSystem.iconSize(context, baseSize: 24),
                      color: ThemeHelpers.getPrimaryColor(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
