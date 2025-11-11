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
import '../utils/screen_handlers.dart';
import '../../core/services/language/translation_service.dart';
import '../../core/logging/logging_helper.dart';
import '../../core/utils/validation/error_message_helper.dart';
// UI Components - Reusable components
import '../components/common/index.dart';
import '../components/content/book_reader_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBooksList();
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

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveSystem.all(context, baseSpacing: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Books List
                      if (_booksList.isNotEmpty && _selectedBook == null)
                        ..._booksList.map(
                            (book) => _buildBookCard(context, book, isDark)),

                      // Book Reader
                      if (_selectedBook != null && _bookUrl != null) ...[
                        _buildBookReader(context, isDark),
                      ],

                      // Error Message
                      if (_errorMessage != null)
                        ErrorDisplayWidget(
                          message: _errorMessage!,
                          onRetry: _loadBooksList,
                          icon: Icons.error_outline,
                        ),

                      // Loading Indicator
                      if (_isLoading || _isLoadingBook)
                        Center(
                          child: Padding(
                            padding:
                                ResponsiveSystem.all(context, baseSpacing: 24),
                            child: CircularProgressIndicator(
                              color: ThemeHelpers.getPrimaryColor(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(
      BuildContext context, Map<String, dynamic> book, bool isDark) {
    final availableLanguages =
        List<String>.from(book['availableLanguages'] ?? []);

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
        title: Text(
          book['title'] ?? book['id'],
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            fontWeight: FontWeight.bold,
            color: ThemeHelpers.getPrimaryTextColor(context),
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
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: ThemeHelpers.getSecondaryTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 16),
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
