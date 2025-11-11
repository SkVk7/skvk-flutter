/// Book Reader Widget
///
/// E-book reader widget that displays book content as pages
/// Similar to Amazon Kindle or Google Play Books with physical book-like appearance
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/design_system/design_system.dart';
import '../../../core/logging/logging_helper.dart';
import '../../../core/utils/validation/error_message_helper.dart';
import 'content_language_dropdown.dart';
import '../../../core/services/content/content_api_service.dart';
import '../../../core/services/content/content_api_service_stub.dart'
    if (dart.library.io) '../../../core/services/content/content_api_service_mobile.dart';

/// Book page model
class BookPage {
  final int pageNumber;
  final String content;
  final String? title;

  BookPage({
    required this.pageNumber,
    required this.content,
    this.title,
  });
}

/// Book data model
class BookData {
  final String title;
  final String author;
  final int totalPages;
  final List<BookPage> pages;
  final String language;

  BookData({
    required this.title,
    required this.author,
    required this.totalPages,
    required this.pages,
    required this.language,
  });

  factory BookData.fromJson(Map<String, dynamic> json) {
    // Production-ready: Handle both 'pages' and 'chapters' formats for backward compatibility
    List<Map<String, dynamic>> pagesData;
    
    if (json.containsKey('pages') && json['pages'] != null) {
      // Modern format: pages array
      final pages = json['pages'];
      if (pages is! List) {
        LoggingHelper.logError(
          'Book JSON "pages" field is not a List. Type: ${pages.runtimeType}',
          source: 'BookData',
        );
        throw Exception('Invalid book format: "pages" must be a List');
      }
      // Validate and cast pages to List<Map<String, dynamic>>
      pagesData = [];
      for (final page in pages) {
        if (page is Map<String, dynamic>) {
          pagesData.add(page);
        } else {
          LoggingHelper.logError(
            'Page entry is not a Map. Type: ${page.runtimeType}',
            source: 'BookData',
          );
          // Skip invalid pages but continue processing
        }
      }
      LoggingHelper.logInfo(
        'Using modern "pages" format with ${pagesData.length} pages',
        source: 'BookData',
      );
    } else if (json.containsKey('chapters') && json['chapters'] != null) {
      // Legacy format: chapters array - convert to pages
      final chapters = json['chapters'];
      if (chapters is! List) {
        LoggingHelper.logError(
          'Book JSON "chapters" field is not a List. Type: ${chapters.runtimeType}',
          source: 'BookData',
        );
        throw Exception('Invalid book format: "chapters" must be a List');
      }
      
      LoggingHelper.logInfo(
        'Converting legacy "chapters" format to "pages" format (${chapters.length} chapters)',
        source: 'BookData',
      );
      
      // Convert chapters to pages
      pagesData = [];
      int pageNumber = 1;
      for (final chapter in chapters) {
        if (chapter is! Map<String, dynamic>) {
          LoggingHelper.logError(
            'Chapter entry is not a Map. Type: ${chapter.runtimeType}',
            source: 'BookData',
          );
          continue; // Skip invalid chapters
        }
        
        final chapterContent = chapter['content'] as String? ?? '';
        if (chapterContent.isNotEmpty) {
          pagesData.add({
            'pageNumber': pageNumber,
            'content': chapterContent,
            'title': chapter['title'] as String?,
          });
          pageNumber++;
        }
      }
      
      LoggingHelper.logInfo(
        'Converted ${chapters.length} chapters to ${pagesData.length} pages',
        source: 'BookData',
      );
    } else {
      // Neither format found
      LoggingHelper.logError(
        'Book JSON missing both "pages" and "chapters" fields. Available keys: ${json.keys.join(", ")}',
        source: 'BookData',
      );
      throw Exception('Invalid book format: missing "pages" or "chapters" field');
    }
    
    // Process pages data into BookPage objects
    final pages = pagesData
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final page = entry.value;
          
          // Handle pageNumber - use index + 1 if not provided
          final pageNumber = page['pageNumber'] as int? ?? (index + 1);
          final content = page['content'] as String? ?? '';
          final pageTitle = page['title'] as String?;
          
          // Log if pageNumber is missing (shouldn't happen after conversion)
          if (page['pageNumber'] == null && json.containsKey('pages')) {
            LoggingHelper.logWarning(
              'Page at index $index missing pageNumber, using index+1: $pageNumber',
              source: 'BookData',
            );
          }
          
          if (content.isEmpty) {
            LoggingHelper.logWarning(
              'Page at index $index has empty content',
              source: 'BookData',
            );
          }
          
          return BookPage(
            pageNumber: pageNumber,
            content: content,
            title: pageNumber == 1 && pageTitle == null 
                ? json['title'] as String? 
                : pageTitle,
          );
        })
        .toList();

    return BookData(
      title: json['title'] as String? ?? 'Untitled',
      author: json['author'] as String? ?? 'Unknown Author',
      totalPages: json['totalPages'] as int? ?? pages.length,
      pages: pages,
      language: json['language'] as String? ?? 'en',
    );
  }
}

/// Book Reader Widget
///
/// Displays book content as paginated pages with physical book-like appearance
class BookReaderWidget extends ConsumerStatefulWidget {
  final String bookUrl;
  final String? bookTitle;
  final List<String>?
      availableLanguages; // Available languages for content language dropdown
  final Function(String)?
      onContentLanguageChanged; // Callback when content language changes

  const BookReaderWidget({
    super.key,
    required this.bookUrl,
    this.bookTitle,
    this.availableLanguages,
    this.onContentLanguageChanged,
  });

  @override
  ConsumerState<BookReaderWidget> createState() => _BookReaderWidgetState();
}

class _BookReaderWidgetState extends ConsumerState<BookReaderWidget> {
  BookData? _bookData;
  int _currentPageIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  DateTime? _lastTapTime;
  String? _currentBookUrl; // Track current book URL to detect changes

  @override
  void initState() {
    super.initState();
    _currentBookUrl = widget.bookUrl;
    _loadBook();
  }

  @override
  void didUpdateWidget(BookReaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If book URL changed (language switch), reload instantly
    if (widget.bookUrl != oldWidget.bookUrl &&
        widget.bookUrl != _currentBookUrl) {
      _currentBookUrl = widget.bookUrl;
      _loadBook(showLoading: false); // Don't show loading for instant switch
    }
  }

  Future<void> _loadBook({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Download book from URL (JSON format)
      String jsonString;
      
      if (kIsWeb) {
        // Web: Browser's fetch API automatically decompresses gzip responses
        // Just use response.body - it's already decompressed by the browser
        // This is much faster than manual decompression (native C code)
        LoggingHelper.logInfo(
          'Loading book from URL: ${widget.bookUrl}',
          source: 'BookReaderWidget',
        );
        
        final response = await http.get(
          Uri.parse(widget.bookUrl),
          headers: {
            'Accept': 'application/json',
            'Accept-Encoding': 'gzip, deflate',
          },
        ).timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw Exception('Request timeout');
          },
        );

        // Get raw bytes first (before any body access to avoid UTF-8 decoding errors)
        final bodyBytes = response.bodyBytes;
        final contentType = response.headers['content-type'] ?? '';
        final contentEncoding = response.headers['content-encoding']?.toLowerCase();
        
        LoggingHelper.logInfo(
          'Book response: status=${response.statusCode}, content-type=$contentType, content-encoding=$contentEncoding, bodyBytes-length=${bodyBytes.length}',
          source: 'BookReaderWidget',
        );

        if (response.statusCode != 200) {
          // Check if response is an error JSON (handle compression)
          String errorMessage = 'Unknown error';
          try {
            if (bodyBytes.isNotEmpty) {
              // Use common helper to extract error response (handles compression)
              try {
                final errorBody = ContentDecompressionHelper.extractContent(
                  response,
                  source: 'BookReaderWidget',
                );
                
                final errorData = jsonDecode(errorBody) as Map<String, dynamic>?;
                errorMessage = errorData?['error'] ?? 
                              errorData?['message'] ?? 
                              'Failed to load book';
                // Log full error details
                LoggingHelper.logError(
                  'Book load failed: $errorMessage (${response.statusCode})',
                  source: 'BookReaderWidget',
                );
                LoggingHelper.logError(
                  'Error details: ${errorData.toString()}',
                  source: 'BookReaderWidget',
                );
              } catch (e) {
                // If decompression/decoding fails, use generic error
                LoggingHelper.logError(
                  'Failed to parse error response: $e',
                  source: 'BookReaderWidget',
                  error: e,
                );
                errorMessage = 'Server error: ${response.statusCode}';
              }
            } else {
              LoggingHelper.logError(
                'Book load failed: Empty response body (${response.statusCode})',
                source: 'BookReaderWidget',
              );
            }
          } catch (e) {
            // If all parsing fails, use generic error
            errorMessage = 'Server error: ${response.statusCode}';
            LoggingHelper.logError(
              'Book load failed: ${response.statusCode} - $e',
              source: 'BookReaderWidget',
              error: e,
            );
          }
          throw Exception('Failed to load book: $errorMessage (${response.statusCode})');
        }

        // Check if response body is empty
        if (bodyBytes.isEmpty) {
          LoggingHelper.logError('Book file is empty',
              source: 'BookReaderWidget');
          throw Exception('Book file is empty or not found');
        }
        
        LoggingHelper.logInfo(
          'Response headers: content-type=$contentType, content-encoding=$contentEncoding, bodyBytes-length=${bodyBytes.length}',
          source: 'BookReaderWidget',
        );

        // Use common decompression helper (same as lyrics)
        jsonString = ContentDecompressionHelper.extractContent(
          response,
          source: 'BookReaderWidget',
        );
      } else {
        // Mobile: Use HttpClient with automatic gzip decompression
        jsonString = await getBookMobile(widget.bookUrl);
      }

      // Validate JSON string is not empty
      if (jsonString.isEmpty) {
        throw Exception('Book file is empty or not found');
      }

      // Validate that it looks like JSON before parsing
      final trimmed = jsonString.trim();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        LoggingHelper.logError(
          'Response does not look like valid JSON. First 200 chars: ${jsonString.substring(0, jsonString.length > 200 ? 200 : jsonString.length)}',
          source: 'BookReaderWidget',
        );
        throw Exception('Invalid book format. Expected JSON but got invalid data.');
      }

      // Parse JSON response
      Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // Log the actual JSON structure for debugging
        LoggingHelper.logInfo(
          'Parsed book JSON. Keys: ${jsonData.keys.join(", ")}. Has pages: ${jsonData.containsKey('pages')}, pages type: ${jsonData['pages']?.runtimeType}, pages is null: ${jsonData['pages'] == null}',
          source: 'BookReaderWidget',
        );
        
        // Log a sample of the pages structure if it exists
        if (jsonData.containsKey('pages') && jsonData['pages'] != null) {
          final pages = jsonData['pages'];
          if (pages is List && pages.isNotEmpty) {
            LoggingHelper.logInfo(
              'First page structure: ${pages[0].toString()}',
              source: 'BookReaderWidget',
            );
          }
        }
      } catch (e) {
        LoggingHelper.logError('Failed to parse book JSON',
            source: 'BookReaderWidget', error: e);
        // Log first 500 characters of response for debugging
        final preview = jsonString.length > 500 
            ? '${jsonString.substring(0, 500)}...' 
            : jsonString;
        LoggingHelper.logError('Response preview: $preview',
            source: 'BookReaderWidget');
        throw Exception('Invalid book format. Expected JSON but got: ${e.toString()}');
      }

      final bookData = BookData.fromJson(jsonData);

      if (mounted) {
        setState(() {
          _bookData = bookData;
          _isLoading = false;
          _currentPageIndex = 0; // Reset to first page on language change
          _errorMessage = null;
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load book',
          source: 'BookReaderWidget', error: e);
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

  void _nextPage() {
    if (_bookData != null && _currentPageIndex < _bookData!.pages.length - 1) {
      setState(() {
        _currentPageIndex++; // Go to next page (increase page number)
      });
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--; // Go to previous page (decrease page number)
      });
    }
  }

  /// Filter out inappropriate commercial use text from content
  String _filterInappropriateText(String content) {
    // Remove lines about commercial use, distribution, etc.
    final lines = content.split('\n');
    final filteredLines = lines.where((line) {
      final lowerLine = line.toLowerCase().trim();
      // Filter out inappropriate lines
      if (lowerLine.contains('commercial') ||
          lowerLine.contains('freely use') ||
          lowerLine.contains('reproduce') ||
          lowerLine.contains('distribute') ||
          lowerLine.contains('for commercial purposes')) {
        return false;
      }
      return true;
    }).toList();
    return filteredLines.join('\n').trim();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _onTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // Double tap - toggle controls immediately
      _toggleControls();
    } else {
      // Single tap - toggle controls after delay
      _lastTapTime = now;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _lastTapTime == now) {
          _toggleControls();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: ThemeHelpers.getPrimaryColor(context),
        ),
      );
    }

    // Use AnimatedSwitcher for smooth language transitions
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildBookContent(context, isDark),
    );
  }

  Widget _buildBookContent(BuildContext context, bool isDark) {
    if (_errorMessage != null) {
      return Center(
        key: ValueKey('error_$_errorMessage'),
        child: Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: ResponsiveSystem.iconSize(context, baseSize: 64),
                color: ThemeHelpers.getErrorColor(context),
              ),
              ResponsiveSystem.sizedBox(context, height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              ResponsiveSystem.sizedBox(context, height: 16),
              ElevatedButton(
                onPressed: _loadBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelpers.getPrimaryColor(context),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: ResponsiveSystem.all(context, baseSpacing: 16),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_bookData == null || _bookData!.pages.isEmpty) {
      return Center(
        key: const ValueKey('no_content'),
        child: Text(
          'No content available',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeHelpers.getSecondaryTextColor(context),
          ),
        ),
      );
    }

    final currentPage = _bookData!.pages[_currentPageIndex];
    // Use ResponsiveSystem for consistent responsive sizing
    final screenWidth = ResponsiveSystem.screenWidth(context);
    final screenHeight = ResponsiveSystemExtensions.screenHeight(context);
    final pageWidth = screenWidth * 0.9;
    final pageHeight = screenHeight * 0.85;

    // Use key to force rebuild on language change for AnimatedSwitcher
    return GestureDetector(
      key: ValueKey('book_${_bookData!.language}_$_currentPageIndex'),
      onTap: _onTap,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -500) {
            // Swipe left - next page (like turning a page)
            _nextPage();
          } else if (details.primaryVelocity! > 500) {
            // Swipe right - previous page (like going back)
            _previousPage();
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          // Physical book-like background (paper texture effect)
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F1E8),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Content Language Dropdown - Top Right (same level as back button)
              // Positioned at screen level, not inside the padding
              if (widget.availableLanguages != null &&
                  widget.availableLanguages!.isNotEmpty)
                Positioned(
                  top: ResponsiveSystem.spacing(context, baseSpacing: 16),
                  right: ResponsiveSystem.spacing(context, baseSpacing: 16),
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ThemeHelpers.getSurfaceColor(context)
                              .withValues(alpha: 0.95),
                          borderRadius: ResponsiveSystem.circular(context,
                              baseRadius: 24),
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
                        child: ContentLanguageDropdown(
                          availableLanguages: widget.availableLanguages,
                          onLanguageChanged: (value) {
                            // Notify parent screen to reload book with new language
                            widget.onContentLanguageChanged?.call(value);
                            LoggingHelper.logInfo(
                                'Content language changed to: $value');
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              // Book content with padding
              Padding(
                padding: ResponsiveSystem.only(
                  context,
                  top: ResponsiveSystem.spacing(context,
                      baseSpacing: 60), // Add top padding to avoid header overlap
                ),
                child: Stack(
                  children: [
                // Book page (physical book appearance) - centered
                Center(
                  child: Container(
                    width: pageWidth,
                    height: pageHeight,
                    margin: ResponsiveSystem.all(context, baseSpacing: 16),
                    decoration: BoxDecoration(
                      // Paper-like color
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFFFFEF9),
                      // Physical book shadow and depth
                      boxShadow: [
                        BoxShadow(
                          color: ThemeHelpers.getShadowColor(context)
                              .withValues(alpha: 0.3),
                          blurRadius: ResponsiveSystem.spacing(context,
                              baseSpacing: 20),
                          offset: Offset(
                              0,
                              ResponsiveSystem.spacing(context,
                                  baseSpacing: 5)),
                          spreadRadius:
                              ResponsiveSystem.spacing(context, baseSpacing: 2),
                        ),
                        BoxShadow(
                          color: ThemeHelpers.getShadowColor(context)
                              .withValues(alpha: 0.1),
                          blurRadius: ResponsiveSystem.spacing(context,
                              baseSpacing: 40),
                          offset: Offset(
                              0,
                              ResponsiveSystem.spacing(context,
                                  baseSpacing: 10)),
                          spreadRadius:
                              ResponsiveSystem.spacing(context, baseSpacing: 5),
                        ),
                      ],
                      // Slight border for book edge
                      border: Border.all(
                        color: ThemeHelpers.getBorderColor(context),
                        width:
                            ResponsiveSystem.borderWidth(context, baseWidth: 1),
                      ),
                    ),
                    child: Padding(
                      padding: ResponsiveSystem.symmetric(
                        context,
                        horizontal:
                            ResponsiveSystem.spacing(context, baseSpacing: 40),
                        vertical:
                            ResponsiveSystem.spacing(context, baseSpacing: 32),
                      ),
                      child: SingleChildScrollView(
                        padding: ResponsiveSystem.only(
                          context,
                          top: ResponsiveSystem.spacing(context,
                              baseSpacing: 8), // Add top padding for content
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title (if first page)
                            if (currentPage.pageNumber == 1) ...[
                              Text(
                                _bookData!.title,
                                style: TextStyle(
                                  fontSize: ResponsiveSystem.fontSize(context,
                                      baseSize: 28),
                                  fontWeight: FontWeight.bold,
                                  color: ThemeHelpers.getPrimaryTextColor(
                                      context),
                                  height: 1.3,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              ResponsiveSystem.sizedBox(context, height: 16),
                              Text(
                                _bookData!.author,
                                style: TextStyle(
                                  fontSize: ResponsiveSystem.fontSize(context,
                                      baseSize: 16),
                                  color: ThemeHelpers.getSecondaryTextColor(
                                      context),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              ResponsiveSystem.sizedBox(context, height: 40),
                              Divider(
                                color: ThemeHelpers.getSecondaryTextColor(
                                        context)
                                    .withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                              ResponsiveSystem.sizedBox(context, height: 40),
                            ],
                            // Page content (beautiful typography)
                            // Filter out inappropriate commercial use text
                            Text(
                              _filterInappropriateText(currentPage.content),
                              style: TextStyle(
                                fontSize: ResponsiveSystem.fontSize(context,
                                    baseSize: 20),
                                height: 1.8, // Optimal line spacing for reading
                                color: ThemeHelpers.getPrimaryTextColor(
                                    context),
                                fontFamily:
                                    'Georgia', // Classic serif font for book-like feel
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign
                                  .justify, // Justified text like physical books
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Navigation controls (shown/hidden on tap)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (isDark
                                    ? const Color(0xFF1A1A1A)
                                    : const Color(0xFFF5F1E8))
                                .withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                      padding: ResponsiveSystem.all(context, baseSpacing: 16),
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous page button (with padding to avoid overlap with back button)
                            Padding(
                              padding: ResponsiveSystem.only(
                                context,
                                left: ResponsiveSystem.spacing(context,
                                    baseSpacing:
                                        60), // Add left padding to avoid overlap with back button
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _currentPageIndex > 0
                                      ? _previousPage
                                      : null,
                                  borderRadius: ResponsiveSystem.circular(context, baseRadius: 24),
                                  child: Container(
                                    padding: ResponsiveSystem.all(context,
                                        baseSpacing: 12),
                                    decoration: BoxDecoration(
                                      color: _currentPageIndex > 0
                                          ? ThemeHelpers.getPrimaryColor(
                                                  context)
                                              .withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: ResponsiveSystem.circular(context, baseRadius: 24),
                                    ),
                                    child: Icon(
                                      Icons.chevron_left,
                                      size: ResponsiveSystem.iconSize(context,
                                          baseSize: 32),
                                      color: _currentPageIndex > 0
                                          ? ThemeHelpers.getPrimaryColor(
                                              context)
                                          : ThemeHelpers
                                                  .getSecondaryTextColor(
                                                      context)
                                              .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Page indicator
                            Container(
                              padding: ResponsiveSystem.symmetric(
                                context,
                                horizontal: ResponsiveSystem.spacing(context,
                                    baseSpacing: 16),
                                vertical: ResponsiveSystem.spacing(context,
                                    baseSpacing: 8),
                              ),
                              decoration: BoxDecoration(
                                color: ThemeHelpers.getSurfaceColor(context)
                                    .withValues(alpha: 0.8),
                                borderRadius: ResponsiveSystem.circular(context, baseRadius: 20),
                              ),
                              child: Text(
                                '${_currentPageIndex + 1} / ${_bookData!.totalPages}',
                                style: TextStyle(
                                  fontSize: ResponsiveSystem.fontSize(context,
                                      baseSize: 16),
                                  fontWeight: FontWeight.bold,
                                  color: ThemeHelpers.getPrimaryTextColor(
                                      context),
                                ),
                              ),
                            ),
                            // Next page button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _currentPageIndex <
                                        _bookData!.pages.length - 1
                                    ? _nextPage
                                    : null,
                                borderRadius: ResponsiveSystem.circular(context, baseRadius: 24),
                                child: Container(
                                  padding: ResponsiveSystem.all(context,
                                      baseSpacing: 12),
                                  decoration: BoxDecoration(
                                    color: _currentPageIndex <
                                            _bookData!.pages.length - 1
                                        ? ThemeHelpers.getPrimaryColor(
                                                context)
                                            .withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    borderRadius: ResponsiveSystem.circular(context, baseRadius: 24),
                                  ),
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: ResponsiveSystem.iconSize(context,
                                        baseSize: 32),
                                    color: _currentPageIndex <
                                            _bookData!.pages.length - 1
                                        ? ThemeHelpers.getPrimaryColor(
                                            context)
                                        : ThemeHelpers
                                                .getSecondaryTextColor(
                                                    context)
                                            .withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
