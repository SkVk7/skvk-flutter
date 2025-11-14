/// Audio Screen - Modern Music App UI Template
///
/// Redesigned with:
/// - Hero section with featured artwork
/// - Card-based track list
/// - Search functionality
/// - Modern, clean layout
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/analytics/analytics_service.dart';
import 'package:skvk_application/core/services/audio/audio_controller.dart';
import 'package:skvk_application/core/services/content/content_api_service.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/core/services/network/network_connectivity_service.dart';
import 'package:skvk_application/ui/components/audio/index.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/screens/audio_content_list_view_screen.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Audio Screen - Modern Music App UI Template
class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});

  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  List<Map<String, dynamic>> _musicList = [];
  List<Map<String, dynamic>> _filteredMusicList = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Analytics data
  List<Map<String, dynamic>> _mostPlayed = [];
  List<Map<String, dynamic>> _trending = [];
  bool _isLoadingAnalytics = false;

  // Performance optimization: Cache featured track to avoid expensive firstWhere in build
  Map<String, dynamic>? _featuredTrack;
  String? _lastCurrentTrackId; // Track ID to detect changes

  // Debounce timer for search filtering
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _loadMusicList();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Update featured track cache - call when music list or player state changes
  void _updateFeaturedTrack(String? currentTrackId) {
    if (_musicList.isEmpty) {
      _featuredTrack = null;
      _lastCurrentTrackId = null;
      return;
    }

    if (_lastCurrentTrackId == currentTrackId && _featuredTrack != null) {
      return;
    }

    _lastCurrentTrackId = currentTrackId;

    if (currentTrackId != null) {
      try {
        _featuredTrack = _musicList.firstWhere(
          (track) => track['id'] == currentTrackId,
          orElse: () => _musicList.first,
        );
      } on Exception {
        _featuredTrack = _musicList.first;
      }
    } else {
      _featuredTrack = _musicList.first;
    }
  }

  /// Load analytics data (Most Played, Trending)
  Future<void> _loadAnalytics() async {
    if (_isLoadingAnalytics) return;

    setState(() {
      _isLoadingAnalytics = true;
    });

    try {
      final results = await Future.wait([
        AnalyticsService.instance().getMostPlayed(),
        AnalyticsService.instance().getTrending(type: 'audio'),
      ]);

      if (mounted) {
        setState(() {
          _mostPlayed = results[0];
          _trending = results[1];
          _isLoadingAnalytics = false;
        });
      }
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to load analytics',
          source: 'AudioScreen', error: e,);
      if (mounted) {
        setState(() {
          _isLoadingAnalytics = false;
        });
      }
    }
  }

  /// Navigate to filtered list screen
  void _navigateToFilteredList(
      String title, List<Map<String, dynamic>> tracks,) {
    if (!mounted || tracks.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AudioContentListViewScreen(
          title: title,
          tracks: tracks,
        ),
      ),
    );
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

  /// Categorize tracks by parsing category from ID
  Map<String, List<Map<String, dynamic>>> _categorizeTracks() {
    final categories = <String, List<Map<String, dynamic>>>{};

    for (final track in _musicList) {
      final trackId = track['id'] as String? ?? '';
      final category = _extractCategoryFromId(trackId);

      if (!categories.containsKey(category)) {
        categories[category] = [];
      }
      categories[category]!.add(track);
    }

    // Sort categories alphabetically for consistent display
    final sortedCategories = Map.fromEntries(
      categories.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return sortedCategories;
  }

  Future<void> _loadMusicList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final hasInternet =
        await NetworkConnectivityService.instance().hasInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              NetworkConnectivityService.instance().getOfflineMessage();
        });
      }
      return;
    }

    try {
      final musicList = await ContentApiService.instance().getMusicList();
      if (mounted) {
        setState(() {
          _musicList =
              List<Map<String, dynamic>>.from(musicList['music'] ?? []);
          _filteredMusicList = _musicList;
          _isLoading = false;
        });
        final playerState = ref.read(audioControllerProvider);
        _updateFeaturedTrack(playerState.currentTrack?.id);
      }
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to load music list',
          source: 'AudioScreen', error: e,);
      if (mounted) {
        setState(() {
          _isLoading = false;
          final errorString = e.toString().toLowerCase();
          final isNetworkError = errorString.contains('connection') ||
              errorString.contains('network') ||
              errorString.contains('socketexception') ||
              errorString.contains('failed host lookup');

          _errorMessage = isNetworkError
              ? NetworkConnectivityService.instance().getOfflineMessage()
              : 'Failed to load music. Please try again.';
        });
      }
    }
  }

  void _filterTracks(String query) {
    // Cancel previous debounce timer
    _searchDebounceTimer?.cancel();

    // Debounce search filtering to avoid excessive rebuilds
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        if (query.isEmpty) {
          _filteredMusicList = _musicList;
        } else {
          _filteredMusicList = _musicList.where((track) {
            final title = (track['title'] as String? ?? '').toLowerCase();
            final subtitle = (track['subtitle'] as String? ??
                    track['artist'] as String? ??
                    '')
                .toLowerCase();
            final searchQuery = query.toLowerCase();
            return title.contains(searchQuery) ||
                subtitle.contains(searchQuery);
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final translationService = ref.watch(translationServiceProvider);
    final playerState = ref.watch(audioControllerProvider);
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
    );

    // Performance optimization: Update featured track cache only when needed
    final currentTrackId = playerState.currentTrack?.id;
    _updateFeaturedTrack(currentTrackId);
    final featuredTrack = _featuredTrack;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadMusicList();
              await _loadAnalytics();
            },
            color: ThemeHelpers.getPrimaryColor(context),
            child: CustomScrollView(
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: true,
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
                  title: Text(
                    translationService.translateHeader(
                      'devotional_audio',
                      fallback: 'Devotional Audio',
                    ),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 22),
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getAppBarTextColor(context),
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    // Search button
                    IconButton(
                      icon: Icon(
                        _isSearching ? Icons.close : Icons.search,
                        color: ThemeHelpers.getAppBarTextColor(context),
                        size: ResponsiveSystem.iconSize(context, baseSize: 24),
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchController.clear();
                            _filteredMusicList = _musicList;
                          }
                        });
                      },
                    ),
                    // Language Dropdown
                    LanguageDropdown(
                      onLanguageChanged: (value) =>
                          ScreenHandlers.handleLanguageChange(ref, value),
                    ),
                    // Theme Dropdown
                    ThemeDropdown(
                      onThemeChanged: (value) =>
                          ScreenHandlers.handleThemeChange(ref, value),
                    ),
                    // Profile Photo
                    Padding(
                      padding: ResponsiveSystem.only(
                        context,
                        right:
                            ResponsiveSystem.spacing(context, baseSpacing: 8),
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
                ),

                // Search Bar (when searching)
                if (_isSearching)
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
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search tracks...',
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
                                    _filterTracks('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: ThemeHelpers.getSurfaceColor(context)
                              .withValues(alpha: 0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveSystem.spacing(context,
                                  baseSpacing: 12,),
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
                        onChanged: _filterTracks,
                      ),
                    ),
                  ),

                // Hero Section with Featured Track (show skeleton if loading)
                if (!_isSearching)
                  _isLoading || _filteredMusicList.isEmpty
                      ? const SliverToBoxAdapter(
                          child: AudioHeroSkeleton(),
                        )
                      : featuredTrack != null
                          ? SliverToBoxAdapter(
                              child: AudioHeroSection(
                                  featuredTrack: featuredTrack,),
                            )
                          : const SliverToBoxAdapter(child: SizedBox.shrink()),

                // Recently Played Section (Local Cache)
                if (!_isSearching)
                  RecentlyPlayedSection(
                    musicList: _musicList,
                    onNavigateToFilteredList: _navigateToFilteredList,
                  ),

                // Favorites Section (Local Cache - User Specific)
                if (!_isSearching)
                  FavoritesSection(
                    musicList: _musicList,
                    onNavigateToFilteredList: _navigateToFilteredList,
                  ),

                // Queued Songs Section (Local Cache)
                if (!_isSearching)
                  QueuedSongsSection(
                    onNavigateToFilteredList: _navigateToFilteredList,
                  ),

                // Most Played Section (Analytics - Server)
                if (!_isSearching)
                  MostPlayedSection(
                    musicList: _musicList,
                    mostPlayed: _mostPlayed,
                    isLoading: _isLoadingAnalytics || _isLoading,
                    onNavigateToFilteredList: _navigateToFilteredList,
                  ),

                // Trending Section (Analytics - Server)
                if (!_isSearching)
                  TrendingSection(
                    musicList: _musicList,
                    trending: _trending,
                    isLoading: _isLoadingAnalytics || _isLoading,
                    onNavigateToFilteredList: _navigateToFilteredList,
                  ),

                // Categories Sections (Mantras, Chalisa, Stotrams, etc.) - show skeleton if loading
                if (!_isSearching)
                  if (_isLoading || _musicList.isEmpty)
                    SliverToBoxAdapter(
                      child: CategorySectionsBuilder.buildSkeleton(context),
                    )
                  else
                    ...CategorySectionsBuilder.buildSections(
                      categories: _categorizeTracks(),
                      onNavigateToFilteredList: _navigateToFilteredList,
                    ),

                // Section Header
                if (!_isSearching)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: ResponsiveSystem.symmetric(
                        context,
                        horizontal:
                            ResponsiveSystem.spacing(context, baseSpacing: 20),
                        vertical:
                            ResponsiveSystem.spacing(context, baseSpacing: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isSearching ? 'Search Results' : 'All Tracks',
                            style: TextStyle(
                              fontSize: ResponsiveSystem.fontSize(context,
                                  baseSize: 24,),
                              fontWeight: FontWeight.bold,
                              color: ThemeHelpers.getPrimaryTextColor(context),
                            ),
                          ),
                          if (!_isLoading)
                            Text(
                              '${_filteredMusicList.length}',
                              style: TextStyle(
                                fontSize: ResponsiveSystem.fontSize(context,
                                    baseSize: 16,),
                                fontWeight: FontWeight.w500,
                                color:
                                    ThemeHelpers.getSecondaryTextColor(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Track List - Card Based with Animations (show skeleton if loading)
                if (!_isSearching && _isLoading)
                  SliverPadding(
                    padding: ResponsiveSystem.symmetric(
                      context,
                      horizontal:
                          ResponsiveSystem.spacing(context, baseSpacing: 16),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: ResponsiveSystem.spacing(context,
                                  baseSpacing: 12,),
                            ),
                            child: const AudioHorizontalSkeletonCard(),
                          );
                        },
                        childCount: 5,
                      ),
                    ),
                  )
                else if (_errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: ResponsiveSystem.all(context, baseSpacing: 24),
                      child: Card(
                        color: ThemeHelpers.getErrorColor(context)
                            .withValues(alpha: 0.1),
                        child: Padding(
                          padding:
                              ResponsiveSystem.all(context, baseSpacing: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: ThemeHelpers.getErrorColor(context),
                                size: ResponsiveSystem.iconSize(context,
                                    baseSize: 24,),
                              ),
                              ResponsiveSystem.sizedBox(
                                context,
                                width: ResponsiveSystem.spacing(context,
                                    baseSpacing: 12,),
                              ),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: ResponsiveSystem.fontSize(context,
                                        baseSize: 14,),
                                    color: ThemeHelpers.getErrorColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else if (_filteredMusicList.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_off,
                            size: ResponsiveSystem.iconSize(context,
                                baseSize: 64,),
                            color: ThemeHelpers.getSecondaryTextColor(context),
                          ),
                          ResponsiveSystem.sizedBox(
                            context,
                            height: ResponsiveSystem.spacing(context,
                                baseSpacing: 16,),
                          ),
                          Text(
                            _isSearching
                                ? 'No tracks found'
                                : 'No tracks available',
                            style: TextStyle(
                              fontSize: ResponsiveSystem.fontSize(context,
                                  baseSize: 18,),
                              color:
                                  ThemeHelpers.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: ResponsiveSystem.symmetric(
                      context,
                      horizontal:
                          ResponsiveSystem.spacing(context, baseSpacing: 16),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration:
                                Duration(milliseconds: 300 + (index * 50)),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: ResponsiveSystem.spacing(context,
                                          baseSpacing: 12,),
                                    ),
                                    child: AudioTrackCard(
                                        music: _filteredMusicList[index],),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: _filteredMusicList.length,
                      ),
                    ),
                  ),

                // Bottom padding for mini player - responsive based on platform
                SliverToBoxAdapter(
                  child: _buildBottomPadding(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate bottom padding based on mini player height and platform
  Widget _buildBottomPadding(BuildContext context) {
    final playerState = ref.watch(audioControllerProvider);

    if (!playerState.hasTrack || !playerState.showMiniPlayer) {
      return SizedBox(
        height: ResponsiveSystem.spacing(context, baseSpacing: 20),
      );
    }

    final miniPlayerHeight = ResponsiveSystem.responsive(
      context,
      mobile: ResponsiveSystem.spacing(context, baseSpacing: 88),
      tablet: ResponsiveSystem.spacing(context, baseSpacing: 96),
      desktop: ResponsiveSystem.spacing(context, baseSpacing: 104),
      largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 112),
    );

    // Account for SafeArea bottom padding (same as MiniPlayer)
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final totalPlayerHeight = miniPlayerHeight + safeAreaBottom;

    final bottomPadding =
        totalPlayerHeight + ResponsiveSystem.spacing(context, baseSpacing: 20);

    return SizedBox(height: bottomPadding);
  }
}
