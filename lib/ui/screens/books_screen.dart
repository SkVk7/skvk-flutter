/// Books Screen
///
/// Screen for viewing devotional books in PDF format
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
// UI Utils - Use only these for consistency
import '../utils/theme_helpers.dart';
import '../utils/responsive_system.dart';
// Core imports
import '../../core/services/content/content_api_service.dart';
import '../../core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import '../../core/services/analytics/analytics_service.dart';
import '../../core/services/content/content_language_service.dart';
import '../../core/services/books/book_favorites_service.dart';
import '../../core/services/books/recently_viewed_books_service.dart';
import '../utils/screen_handlers.dart';
import '../../core/services/language/translation_service.dart';
import '../../core/logging/logging_helper.dart';
import '../../core/utils/validation/error_message_helper.dart';
// UI Components - Reusable components
import '../components/common/index.dart';
import '../components/content/book_reader_widget.dart';
import '../components/content/horizontal_section.dart';
import '../components/content/horizontal_skeleton_section.dart';
import 'book_content_list_view_screen.dart';

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
      // Load most read and trending in parallel
      final results = await Future.wait([
        AnalyticsService.instance.getMostVisitedBooks(limit: 10),
        AnalyticsService.instance.getTrending(limit: 10, type: 'book'),
      ]);
      
      if (mounted) {
        setState(() {
          _mostRead = results[0];
          _trending = results[1];
          _isLoadingAnalytics = false;
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load book analytics', source: 'BooksScreen', error: e);
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
    } catch (e) {
      return null;
    }
  }
  
  /// Extract category from ID (format: {category}-{content-id})
  String _extractCategoryFromId(String fullId) {
    final parts = fullId.split('-');
    if (parts.length < 2) {
      return 'Other';
    }
    // First part is category, capitalize it
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
      categories.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    return sortedCategories;
  }
  
  /// Navigate to filtered list screen
  void _navigateToFilteredBookList(String title, List<Map<String, dynamic>> books) {
    if (!mounted || books.isEmpty) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookContentListViewScreen(
          title: title,
          books: books,
          onBookSelected: (bookId) {
            // Navigate back and load the selected book
            Navigator.of(context).pop();
            // Load the book after a short delay to allow navigation to complete
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _loadBook(bookId);
              }
            });
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
      final booksList =
          await ContentApiService.instance.getBooksList(language: languageCode);

      if (mounted) {
        final books = List<Map<String, dynamic>>.from(booksList['books'] ?? []);
        LoggingHelper.logInfo(
          'Loaded ${books.length} books from Cloudflare R2 for language $languageCode',
          source: 'BooksScreen',
        );
        setState(() {
          _booksList = books;
          _filteredBooksList = books;
          _isLoading = false;
          // Clear error message if books are loaded successfully
          if (books.isNotEmpty) {
            _errorMessage = null;
            // Log book IDs for debugging
            final bookIds = books.map((b) => b['id']).join(', ');
            LoggingHelper.logInfo(
              'Available books: $bookIds',
              source: 'BooksScreen',
            );
          } else if (books.isEmpty) {
            // If books list is empty, show a helpful message
            _errorMessage = 'No books available at the moment. Please try again later.';
          }
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load books list',
          source: 'BooksScreen', error: e);
      if (mounted) {
        // Convert technical error to user-friendly message
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
    
    LoggingHelper.logInfo(
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
        // First try exact match
        selectedBook = _booksList.firstWhere(
          (b) => (b['id'] as String) == bookId,
        );
        LoggingHelper.logInfo(
          'Found book with exact match: ${selectedBook['id']}',
          source: 'BooksScreen',
        );
      } catch (e) {
        // If exact match fails, try normalized match
        try {
          selectedBook = _booksList.firstWhere(
            (b) => (b['id'] as String).toLowerCase().trim() == normalizedBookId,
          );
          LoggingHelper.logInfo(
            'Found book with normalized match: ${selectedBook['id']}',
            source: 'BooksScreen',
          );
        } catch (e2) {
          // If not found, log available IDs for debugging
          final availableIds = _booksList.map((b) => b['id'] as String).join(', ');
          LoggingHelper.logError(
            'Book not found: originalId=$bookId, normalizedId=$normalizedBookId. Available IDs: $availableIds',
            source: 'BooksScreen',
          );
          throw Exception('Book not found in list: $bookId (normalized: $normalizedBookId)');
        }
      }
      if (mounted) {
        setState(() {
          _selectedBook = selectedBook;
        });
      }

      // Get current language and available languages from book data
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
        }
        LoggingHelper.logInfo(
          'Book $normalizedBookId: Language $currentLanguageCode not available, using $languageToUse',
          source: 'BooksScreen',
        );
      }

      // CRITICAL PATH: Get book URL immediately (this is what user is waiting for)
      // Try with determined language, with fallback to English if needed
      String bookUrl = '';
      try {
        LoggingHelper.logInfo(
          'Fetching book URL: bookId=$normalizedBookId (original: $bookId), language=$languageToUse',
          source: 'BooksScreen',
        );
        bookUrl = await ContentApiService.instance
            .getBookUrl(normalizedBookId, language: languageToUse);
        LoggingHelper.logInfo(
          'Successfully got book URL: $bookUrl',
          source: 'BooksScreen',
        );
      } catch (e, stackTrace) {
        LoggingHelper.logError(
          'Failed to get book URL for $normalizedBookId (original: $bookId) in language $languageToUse: $e',
          source: 'BooksScreen',
          error: e,
          stackTrace: stackTrace,
        );
        // If requested language fails, try English as fallback
        if (languageToUse != 'en' && availableLanguages.contains('en')) {
          LoggingHelper.logInfo(
            'Book $normalizedBookId: Failed to load in $languageToUse, trying English',
            source: 'BooksScreen',
          );
          try {
            LoggingHelper.logInfo(
              'Trying English fallback for book: $normalizedBookId (original: $bookId)',
              source: 'BooksScreen',
            );
            bookUrl = await ContentApiService.instance
                .getBookUrl(normalizedBookId, language: 'en');
            languageToUse = 'en';
            LoggingHelper.logInfo(
              'Successfully got book URL in English: $bookUrl',
              source: 'BooksScreen',
            );
          } catch (e2, stackTrace2) {
            LoggingHelper.logError(
              'English fallback also failed for $normalizedBookId (original: $bookId): $e2',
              source: 'BooksScreen',
              error: e2,
              stackTrace: stackTrace2,
            );
            // If English also fails, try first available language
            if (availableLanguages.isNotEmpty && availableLanguages.first != 'en') {
              LoggingHelper.logInfo(
                'Book $normalizedBookId (original: $bookId): Failed to load in English, trying ${availableLanguages.first}',
                source: 'BooksScreen',
              );
              try {
                bookUrl = await ContentApiService.instance
                    .getBookUrl(normalizedBookId, language: availableLanguages.first);
                languageToUse = availableLanguages.first;
                LoggingHelper.logInfo(
                  'Successfully got book URL in ${availableLanguages.first}: $bookUrl',
                  source: 'BooksScreen',
                );
              } catch (e3, stackTrace3) {
                LoggingHelper.logError(
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
          }
        } else {
          rethrow; // Re-throw if no fallback available
        }
      }

      // Validate book URL
      if (bookUrl.isEmpty) {
        throw Exception('Invalid book URL. Please try again.');
      }

      LoggingHelper.logInfo(
          'Loading book: $normalizedBookId, language: $languageToUse (requested: $currentLanguageCode), URL: $bookUrl, available: $availableLanguages',
          source: 'BooksScreen');

      // Book URL is ready! Clear loading state and show book
      if (mounted) {
        setState(() {
          _bookUrl = bookUrl;
          _isLoadingBook = false;
        });
      }

      // Load available languages from R2 API (for dropdown filtering)
      // This should complete quickly to update the dropdown
      await _loadAvailableLanguages(normalizedBookId, languageToUse);

      // NON-BLOCKING: Track analytics (fire and forget)
      unawaited(_trackBookView(normalizedBookId));
      
      // Track recently viewed
      ref.read(recentlyViewedBooksServiceProvider.notifier).addBook(bookId);
    } catch (e) {
      LoggingHelper.logError('Failed to load book: $normalizedBookId',
          source: 'BooksScreen', error: e);
      LoggingHelper.logError('Error details: ${e.toString()}',
          source: 'BooksScreen');
      if (mounted) {
        // Convert technical error to user-friendly message
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(e);
        LoggingHelper.logError('User-friendly error: $userFriendlyMessage',
            source: 'BooksScreen');
        setState(() {
          _isLoadingBook = false;
          _errorMessage = 'Failed to load book: $userFriendlyMessage. Please check if the book is available in your selected language.';
          _selectedBook = null;
          _bookUrl = null;
        });
      }
    }
  }

  /// Load available languages from R2 API (for dropdown filtering)
  /// This fetches the actual available languages for the book from Cloudflare R2
  Future<void> _loadAvailableLanguages(
      String bookId, String currentLanguageCode) async {
    try {
      // Fetch available languages for this book from R2 API
      final languagesData =
          await ContentApiService.instance.getAvailableLanguages(
        contentId: bookId,
        contentType: 'books',
      );
      final availableLangs =
          List<String>.from(languagesData['languages'] ?? []);
      
      LoggingHelper.logInfo(
        'Book $bookId: Found ${availableLangs.length} available languages from R2: ${availableLangs.join(", ")}',
        source: 'BooksScreen',
      );
      
      // Update available languages in state (for language selector UI)
      // This will update the dropdown to show only available languages
      if (mounted) {
        setState(() {
          if (availableLangs.isNotEmpty) {
            _availableLanguages = availableLangs;
          } else {
            // If API returns empty, fallback to current language only
            _availableLanguages = [currentLanguageCode];
            LoggingHelper.logWarning(
              'Book $bookId: No languages returned from API, using current language only',
              source: 'BooksScreen',
            );
          }
        });
      }
      
      // If current language is not available, switch to first available or default
      if (availableLangs.isNotEmpty && !availableLangs.contains(currentLanguageCode)) {
        final defaultLang = availableLangs.contains('en')
            ? 'en'
            : availableLangs.first;
        LoggingHelper.logInfo(
          'Book $bookId: Current language $currentLanguageCode not available, switching to $defaultLang',
          source: 'BooksScreen',
        );
        final lang = ContentLanguage.fromCode(defaultLang);
        await ref
            .read(contentLanguageServiceProvider.notifier)
            .setContentLanguage(lang);
      }
    } catch (e) {
      LoggingHelper.logError('Failed to fetch available languages from R2',
          source: 'BooksScreen', error: e);
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
      await AnalyticsService.instance.trackBookView(bookId);
    } catch (e) {
      LoggingHelper.logError('Failed to track book view',
          source: 'BooksScreen', error: e);
      // Silently fail - analytics shouldn't block user experience
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final translationService = ref.watch(translationServiceProvider);
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
      isEvening: false,
      useSacredFire: false,
    );

    return Scaffold(
      body: Container(
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
                    onLanguageChanged: (value) {
                      LoggingHelper.logInfo('Language changed to: $value');
                    },
                  ),
                  // Theme Dropdown Widget
                  ThemeDropdown(
                    onThemeChanged: (value) {
                      LoggingHelper.logInfo('Theme changed to: $value');
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
                    translationService.translateHeader('devotional_books',
                        fallback: 'Devotional Books'),
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
                      horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
                      vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
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
                                  color: ThemeHelpers.getSecondaryTextColor(context),
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
                          horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
                          vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
                        ),
                      ),
                      style: TextStyle(
                        color: ThemeHelpers.getPrimaryTextColor(context),
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
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

              // Loading indicator when book is being loaded
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
                          height: ResponsiveSystem.spacing(context, baseSpacing: 16),
                        ),
                        Text(
                          'Loading book...',
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
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
                _buildRecentlyViewedSection(),

                // Favorites Section
                _buildFavoritesSection(),

                // Most Read Section (Analytics)
                _buildMostReadSection(),

                // Trending Section (Analytics)
                _buildTrendingSection(),

                // Category Sections (show skeleton if loading)
                if (_isLoading || _booksList.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildCategorySectionSkeleton(),
                  ),
                if (!_isLoading && _booksList.isNotEmpty)
                  ..._buildCategorySections(),

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

  /// Recently Viewed Section (Local Cache)
  Widget _buildRecentlyViewedSection() {
    final recentlyViewed = ref.watch(recentlyViewedBooksServiceProvider);
    
    if (recentlyViewed.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final recentlyViewedBooks = recentlyViewed
        .map((bookId) => _getBookById(bookId))
        .whereType<Map<String, dynamic>>()
        .toList();

    if (recentlyViewedBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final bookCards = recentlyViewedBooks
        .take(5)
        .map((book) => _buildHorizontalBookCard(book))
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Recently Viewed',
        icon: Icons.history,
        items: bookCards,
        totalCount: recentlyViewed.length,
        displayLimit: 5,
        onSeeAll: recentlyViewed.length > 5
            ? () {
                final allRecentlyViewed = recentlyViewed
                    .map((bookId) => _getBookById(bookId))
                    .whereType<Map<String, dynamic>>()
                    .toList();
                _navigateToFilteredBookList('Recently Viewed', allRecentlyViewed);
              }
            : null,
      ),
    );
  }

  /// Favorites Section (Local Cache)
  Widget _buildFavoritesSection() {
    final favorites = ref.watch(bookFavoritesServiceProvider);
    
    if (favorites.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final favoriteBooks = _booksList
        .where((book) => favorites.contains(book['id']))
        .take(5)
        .toList();

    if (favoriteBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final bookCards = favoriteBooks
        .map((book) => _buildHorizontalBookCard(book))
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Favorites',
        icon: Icons.favorite,
        items: bookCards,
        totalCount: favorites.length,
        displayLimit: 5,
        onSeeAll: favorites.length > 5
            ? () {
                final allFavorites = _booksList
                    .where((book) => favorites.contains(book['id']))
                    .toList();
                _navigateToFilteredBookList('Favorites', allFavorites);
              }
            : null,
      ),
    );
  }

  /// Most Read Section (Analytics - Server)
  Widget _buildMostReadSection() {
    // Show loading skeleton while loading analytics OR books list
    if (_isLoadingAnalytics || _isLoading) {
      return HorizontalSkeletonSection(
        title: 'Most Read',
        icon: Icons.trending_up,
      );
    }

    // Don't show if books list is empty (data not loaded yet)
    if (_booksList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (_mostRead.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final mostReadBooks = _mostRead
        .map((item) {
          final bookId = item['id'] as String? ?? '';
          return _getBookById(bookId);
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
      final viewCount = _mostRead.firstWhere(
        (item) => item['id'] == bookId,
        orElse: () => {'count': 0},
      )['count'] as int? ?? 0;
      
      return Stack(
        children: [
          _buildHorizontalBookCard(book),
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
                  _formatViewCount(viewCount),
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
        totalCount: _mostRead.length,
        displayLimit: 5,
        onSeeAll: _mostRead.length > 5
            ? () {
                final allMostRead = _mostRead
                    .map((item) {
                      final bookId = item['id'] as String? ?? '';
                      final viewCount = item['count'] as int? ?? 0;
                      final book = _getBookById(bookId);
                      if (book != null) {
                        book['viewCount'] = viewCount;
                      }
                      return book;
                    })
                    .whereType<Map<String, dynamic>>()
                    .toList();
                _navigateToFilteredBookList('Most Read', allMostRead);
              }
            : null,
      ),
    );
  }

  /// Trending Section (Analytics - Server)
  Widget _buildTrendingSection() {
    // Show loading skeleton while loading analytics OR books list
    if (_isLoadingAnalytics || _isLoading) {
      return HorizontalSkeletonSection(
        title: 'Trending Now',
        icon: Icons.local_fire_department,
      );
    }

    // Don't show if books list is empty (data not loaded yet)
    if (_booksList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (_trending.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final trendingBooks = _trending
        .map((item) {
          final bookId = item['id'] as String? ?? '';
          return _getBookById(bookId);
        })
        .whereType<Map<String, dynamic>>()
        .take(5)
        .toList();

    if (trendingBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final bookCards = trendingBooks
        .map((book) => _buildHorizontalBookCard(book))
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Trending Now',
        icon: Icons.local_fire_department,
        items: bookCards,
        totalCount: _trending.length,
        displayLimit: 5,
        onSeeAll: _trending.length > 5
            ? () {
                final allTrending = _trending
                    .map((item) {
                      final bookId = item['id'] as String? ?? '';
                      return _getBookById(bookId);
                    })
                    .whereType<Map<String, dynamic>>()
                    .toList();
                _navigateToFilteredBookList('Trending Now', allTrending);
              }
            : null,
      ),
    );
  }

  /// Build category sections
  List<Widget> _buildCategorySections() {
    final categories = _categorizeBooks();
    final widgets = <Widget>[];

    for (final entry in categories.entries) {
      final categoryName = entry.key;
      final books = entry.value;

      if (books.isEmpty) continue;

      final bookCards = books
          .take(5)
          .map((book) => _buildHorizontalBookCard(book))
          .toList();

      widgets.add(
        HorizontalSection(
          config: HorizontalSectionConfig(
            title: categoryName,
            icon: Icons.category,
            items: bookCards,
            totalCount: books.length,
            displayLimit: 5,
            onSeeAll: books.length > 5
                ? () => _navigateToFilteredBookList(categoryName, books)
                : null,
          ),
        ),
      );
    }

    return widgets;
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
            child: _buildBookCard(context, _booksList[index], false),
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
            child: _buildBookCard(context, _filteredBooksList[index], false),
          );
        },
        childCount: _filteredBooksList.length,
      ),
    );
  }


  /// Category Section Skeleton
  Widget _buildCategorySectionSkeleton() {
    return Column(
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
              Container(
                width: ResponsiveSystem.spacing(context, baseSpacing: 120),
                height: ResponsiveSystem.fontSize(context, baseSize: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: ThemeHelpers.getSecondaryTextColor(context)
                      .withValues(alpha: 0.2),
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
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                child: _buildHorizontalSkeletonCard(),
              );
            },
          ),
        ),
        ResponsiveSystem.sizedBox(
          context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 8),
        ),
      ],
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
                color: ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Horizontal Skeleton Card (for loading state)
  Widget _buildHorizontalSkeletonCard() {
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

  /// Format view count for display
  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// Horizontal Book Card (for sections)
  Widget _buildHorizontalBookCard(Map<String, dynamic> book) {
    final favorites = ref.watch(bookFavoritesServiceProvider);
    final bookId = book['id'] as String? ?? '';
    final title = book['title'] as String? ?? book['id'] as String? ?? '';
    final isFavorite = favorites.contains(bookId);

    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        _loadBook(bookId);
      },
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
                      if (!mounted) return;
                      ref.read(bookFavoritesServiceProvider.notifier).toggleFavorite(bookId);
                    },
                    child: Container(
                      padding: ResponsiveSystem.all(context, baseSpacing: 4),
                      decoration: BoxDecoration(
                        color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.7),
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

  Widget _buildBookCard(
      BuildContext context, Map<String, dynamic> book, bool isDark) {
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
                if (!mounted) return;
                ref.read(bookFavoritesServiceProvider.notifier).toggleFavorite(bookId);
              },
              tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            Icon(
          Icons.arrow_forward_ios,
          color: ThemeHelpers.getSecondaryTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 16),
            ),
          ],
        ),
        onTap: () {
          final bookId = book['id'] as String;
          LoggingHelper.logInfo(
            'User clicked book: id=$bookId, title=${book['title']}',
            source: 'BooksScreen',
          );
          // Pass the original book ID - normalization happens inside _loadBook
          _loadBook(bookId);
        },
      ),
    );
  }

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
                  borderRadius: ResponsiveSystem.circular(context, baseRadius: 24),
                  child: Container(
                    padding: ResponsiveSystem.all(context, baseSpacing: 10),
                    decoration: BoxDecoration(
                      color: ThemeHelpers.getSurfaceColor(context)
                          .withValues(alpha: 0.95),
                      borderRadius: ResponsiveSystem.circular(context, baseRadius: 24),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeHelpers.getShadowColor(context)
                              .withValues(alpha: 0.3),
                          blurRadius: ResponsiveSystem.spacing(context,
                              baseSpacing: 12),
                          offset: Offset(
                              0,
                              ResponsiveSystem.spacing(context,
                                  baseSpacing: 3)),
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
