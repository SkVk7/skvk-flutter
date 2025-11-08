/// Books Screen
///
/// Screen for viewing devotional books in PDF format
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/content/content_api_service.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/content/content_language_service.dart';
import '../../../../core/services/language/translation_service.dart';
import '../../../../core/logging/logging_helper.dart';
import '../../../../core/utils/validation/error_message_helper.dart';
import '../../../../core/design_system/theme/theme_provider.dart';
import '../../../../shared/widgets/common/centralized_widgets.dart';
import '../widgets/book_reader_widget.dart';

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
  Map<String, String> _bookUrlsByLanguage =
      {}; // Cache book URLs by language for instant switching

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
        setState(() {
          _booksList = books;
          _isLoading = false;
          // Clear error message if books are loaded successfully
          if (books.isNotEmpty) {
            _errorMessage = null;
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
    try {
      setState(() {
        _isLoadingBook = true;
        _errorMessage = null;
        _bookUrl = null;
        _selectedBook = null;
        _availableLanguages = [];
      });

      // Find selected book immediately for better UX
      final selectedBook = _booksList.firstWhere((b) => b['id'] == bookId);
      if (mounted) {
        setState(() {
          _selectedBook = selectedBook;
        });
      }

      // Get current language
      final languagePrefs = ref.read(contentLanguageServiceProvider);
      final currentLanguageCode = languagePrefs.selectedLanguage.code;

      // CRITICAL PATH: Get book URL immediately (this is what user is waiting for)
      final bookUrl = await ContentApiService.instance
          .getBookUrl(bookId, language: currentLanguageCode);

      // Validate book URL
      if (bookUrl.isEmpty) {
        throw Exception('Invalid book URL. Please try again.');
      }

      LoggingHelper.logInfo(
          'Loading book: $bookId, language: $currentLanguageCode, URL: $bookUrl',
          source: 'BooksScreen');

      // Book URL is ready! Clear loading state and show book
      if (mounted) {
        setState(() {
          _bookUrl = bookUrl;
          _isLoadingBook = false;
        });
      }

      // NON-BLOCKING: Load languages and pre-fetch other language versions in background
      unawaited(_loadLanguagesAndPrefetchBooks(bookId, currentLanguageCode));

      // NON-BLOCKING: Track analytics (fire and forget)
      unawaited(_trackBookView(bookId));
    } catch (e) {
      LoggingHelper.logError('Failed to load book',
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
          _errorMessage = userFriendlyMessage;
        });
      }
    }
  }

  /// Load languages and pre-fetch other language versions in background (non-blocking)
  Future<void> _loadLanguagesAndPrefetchBooks(
      String bookId, String currentLanguageCode) async {
    try {
      // Fetch available languages for this book
      try {
        final languagesData =
            await ContentApiService.instance.getAvailableLanguages(
          contentId: bookId,
          contentType: 'books',
        );
        final availableLangs =
            List<String>.from(languagesData['languages'] ?? []);
        if (mounted) {
          setState(() {
            _availableLanguages = availableLangs;
          });
        }

        // If current language is not available, switch to first available or default
        if (availableLangs.isNotEmpty &&
            !availableLangs.contains(currentLanguageCode)) {
          final defaultLang = availableLangs.contains('en')
              ? 'en'
              : availableLangs.first;
          final lang = ContentLanguage.fromCode(defaultLang);
          await ref
              .read(contentLanguageServiceProvider.notifier)
              .setContentLanguage(lang);
        }

        // Pre-fetch URLs for all available languages in parallel (non-blocking)
        final bookUrlsByLanguage = <String, String>{};
        final fetchFutures = availableLangs.map((lang) async {
          try {
            final url = await ContentApiService.instance
                .getBookUrl(bookId, language: lang);
            bookUrlsByLanguage[lang] = url;
          } catch (e) {
            LoggingHelper.logError('Failed to pre-fetch book for language $lang',
                source: 'BooksScreen', error: e);
          }
        });

        // Wait for all language versions to be fetched (in background)
        await Future.wait(fetchFutures);

        // Update book URLs map for instant language switching
        if (mounted) {
          setState(() {
            _bookUrlsByLanguage = bookUrlsByLanguage;
          });
        }
      } catch (e) {
        LoggingHelper.logError('Failed to fetch available languages',
            source: 'BooksScreen', error: e);
        // Don't show error to user - this is background loading
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load languages/prefetch books',
          source: 'BooksScreen', error: e);
      // Don't show error to user - this is background loading
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

  Future<void> _onLanguageChanged() async {
    // Reload books list with new language
    await _loadBooksList();

    // If a book is selected, switch to new language instantly (if cached)
    if (_selectedBook != null && _bookUrlsByLanguage.isNotEmpty) {
      final languagePrefs = ref.read(contentLanguageServiceProvider);
      final newLanguageCode = languagePrefs.selectedLanguage.code;

      // Check if we have the new language cached
      if (_bookUrlsByLanguage.containsKey(newLanguageCode)) {
        // Instant switch - use cached URL
        setState(() {
          _bookUrl = _bookUrlsByLanguage[newLanguageCode];
        });
      } else {
        // Not cached - fetch it (should be fast since we pre-fetch)
        try {
          final bookId = _selectedBook!['id'];
          final newBookUrl = await ContentApiService.instance
              .getBookUrl(bookId, language: newLanguageCode);
          setState(() {
            _bookUrl = newBookUrl;
            _bookUrlsByLanguage[newLanguageCode] = newBookUrl;
          });
        } catch (e) {
          LoggingHelper.logError('Failed to switch language',
              source: 'BooksScreen', error: e);
          // Fallback: reload the book
          await _loadBook(_selectedBook!['id']);
        }
      }
    }
  }

  /// Handle theme change
  void _handleThemeChange(WidgetRef ref, String themeValue) {
    AppThemeMode themeMode;
    switch (themeValue) {
      case 'light':
        themeMode = AppThemeMode.light;
        break;
      case 'dark':
        themeMode = AppThemeMode.dark;
        break;
      case 'system':
        themeMode = AppThemeMode.system;
        break;
      default:
        themeMode = AppThemeMode.system;
    }

    ref.read(themeNotifierProvider.notifier).setThemeMode(themeMode);
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
                backgroundColor: ThemeProperties.getTransparentColor(context),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    LucideIcons.arrowLeft,
                    color: ThemeProperties.getAppBarTextColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  // Language Dropdown Widget
                  CentralizedLanguageDropdown(
                    onLanguageChanged: (value) {
                      LoggingHelper.logInfo('Language changed to: $value');
                    },
                  ),
                  // Theme Dropdown Widget
                  CentralizedThemeDropdown(
                    onThemeChanged: (value) {
                      LoggingHelper.logInfo('Theme changed to: $value');
                      _handleThemeChange(ref, value);
                    },
                  ),
                  // Profile Photo with Hover Effect
                  Padding(
                    padding: ResponsiveSystem.only(
                      context,
                      right: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    child: CentralizedProfilePhotoWithHover(
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
                      color: ThemeProperties.getAppBarTextColor(context),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: ThemeProperties.getPrimaryGradient(context),
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
                        CentralizedErrorMessage(
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
                              color: ThemeProperties.getPrimaryColor(context),
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
      color: ThemeProperties.getSurfaceColor(context),
      child: ListTile(
        leading: Icon(
          Icons.menu_book,
          color: ThemeProperties.getPrimaryColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 32),
        ),
        title: Text(
          book['title'] ?? book['id'],
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            fontWeight: FontWeight.bold,
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language: ${book['language'] ?? 'en'}',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
            ),
            if (availableLanguages.length > 1)
              Text(
                'Available in ${availableLanguages.length} languages',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 11),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: ThemeProperties.getSecondaryTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 16),
        ),
        onTap: () => _loadBook(book['id']),
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
              // Reload book with new language
              await _onLanguageChanged();
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
                      color: ThemeProperties.getSurfaceColor(context)
                          .withValues(alpha: 0.95),
                      borderRadius: ResponsiveSystem.circular(context, baseRadius: 24),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeProperties.getShadowColor(context)
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
                      color: ThemeProperties.getPrimaryColor(context),
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
