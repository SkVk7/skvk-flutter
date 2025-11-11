/// Audio Screen - Modern Music App UI Template
///
/// Redesigned with:
/// - Hero section with featured artwork
/// - Card-based track list
/// - Search functionality
/// - Modern, clean layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
// UI Utils - Use only these for consistency
import '../utils/theme_helpers.dart';
import '../utils/responsive_system.dart';
import '../utils/screen_handlers.dart';
// Core imports
import '../../core/services/content/content_api_service.dart';
import '../../core/services/network/network_connectivity_service.dart';
import '../../core/design_system/theme/background_gradients.dart';
import '../../core/services/language/translation_service.dart';
import '../../core/logging/logging_helper.dart';
// UI Components
import '../components/common/index.dart';
// Audio Player
import '../../core/services/audio/audio_controller.dart';
import '../../core/services/audio/favorites_service.dart';
import '../../core/services/audio/recently_played_service.dart';
import '../../core/models/audio/track.dart';
import '../screens/now_playing_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMusicList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMusicList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Check network connectivity first
    final hasInternet = await NetworkConnectivityService.instance.hasInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = NetworkConnectivityService.instance.getOfflineMessage();
        });
      }
      return;
    }

    try {
      final musicList = await ContentApiService.instance.getMusicList();
      if (mounted) {
        setState(() {
          _musicList = List<Map<String, dynamic>>.from(musicList['music'] ?? []);
          _filteredMusicList = _musicList;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load music list', source: 'AudioScreen', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          final errorString = e.toString().toLowerCase();
          final isNetworkError = errorString.contains('connection') ||
              errorString.contains('network') ||
              errorString.contains('socketexception') ||
              errorString.contains('failed host lookup');
          
          _errorMessage = isNetworkError
              ? NetworkConnectivityService.instance.getOfflineMessage()
              : 'Failed to load music. Please try again.';
        });
      }
    }
  }

  void _filterTracks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMusicList = _musicList;
      } else {
        _filteredMusicList = _musicList.where((track) {
          final title = (track['title'] as String? ?? '').toLowerCase();
          final subtitle = (track['subtitle'] as String? ?? track['artist'] as String? ?? '').toLowerCase();
          final searchQuery = query.toLowerCase();
          return title.contains(searchQuery) || subtitle.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final translationService = ref.watch(translationServiceProvider);
    final playerState = ref.watch(audioControllerProvider);
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
      isEvening: false,
      useSacredFire: false,
    );

    // Get featured track (first track or currently playing)
    final featuredTrack = playerState.currentTrack != null && _musicList.isNotEmpty
        ? _musicList.firstWhere(
            (track) => track['id'] == playerState.currentTrack!.id,
            orElse: () => _musicList.first,
          )
        : _musicList.isNotEmpty
            ? _musicList.first
            : null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadMusicList,
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
                  translationService.translateHeader('devotional_audio',
                      fallback: 'Devotional Audio'),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 22),
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
                    onLanguageChanged: (value) => ScreenHandlers.handleLanguageChange(ref, value),
                  ),
                  // Theme Dropdown
                  ThemeDropdown(
                    onThemeChanged: (value) => ScreenHandlers.handleThemeChange(ref, value),
                  ),
                  // Profile Photo
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
              ),

              // Search Bar (when searching)
              if (_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveSystem.symmetric(
                      context,
                      horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
                      vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
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
                                  color: ThemeHelpers.getSecondaryTextColor(context),
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
                      onChanged: _filterTracks,
                    ),
                  ),
                ),

              // Hero Section with Featured Track
              if (!_isSearching && featuredTrack != null && _filteredMusicList.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildHeroSection(featuredTrack),
                ),

              // Recently Played Section
              if (!_isSearching)
                _buildRecentlyPlayedSection(),

              // Favorites Section
              if (!_isSearching)
                _buildFavoritesSection(),

              // Section Header
              if (!_isSearching)
                SliverToBoxAdapter(
                          child: Padding(
                    padding: ResponsiveSystem.symmetric(
                              context,
                      horizontal: ResponsiveSystem.spacing(context, baseSpacing: 20),
                      vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isSearching ? 'Search Results' : 'All Tracks',
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                            fontWeight: FontWeight.bold,
                            color: ThemeHelpers.getPrimaryTextColor(context),
                          ),
                        ),
                        Text(
                          '${_filteredMusicList.length}',
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                            fontWeight: FontWeight.w500,
                            color: ThemeHelpers.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Track List - Card Based with Animations
              if (_isLoading)
                SliverPadding(
                  padding: ResponsiveSystem.symmetric(
                    context,
                    horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveSystem.spacing(context, baseSpacing: 12),
                          ),
                          child: _buildSkeletonCard(),
                        );
                      },
                      childCount: 8,
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
                            padding: ResponsiveSystem.all(context, baseSpacing: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: ThemeHelpers.getErrorColor(context),
                              size: ResponsiveSystem.iconSize(context, baseSize: 24),
                                ),
                                ResponsiveSystem.sizedBox(
                                  context,
                              width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                                ),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
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
                          size: ResponsiveSystem.iconSize(context, baseSize: 64),
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                        ResponsiveSystem.sizedBox(
                              context,
                          height: ResponsiveSystem.spacing(context, baseSpacing: 16),
                            ),
                        Text(
                          _isSearching ? 'No tracks found' : 'No tracks available',
                              style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                            color: ThemeHelpers.getSecondaryTextColor(context),
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
                    horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: ResponsiveSystem.spacing(context, baseSpacing: 12),
                                  ),
                                  child: _buildTrackCard(_filteredMusicList[index]),
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

  /// Hero Section - Featured Track with Parallax
  Widget _buildHeroSection(Map<String, dynamic> featuredTrack) {
    final coverArtUrl = featuredTrack['coverArtUrl'] as String?;
    final title = featuredTrack['title'] as String? ?? '';
    final subtitle = featuredTrack['subtitle'] as String? ?? featuredTrack['artist'] as String? ?? '';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: child,
          ),
        );
      },
      child: Container(
      margin: ResponsiveSystem.all(context, baseSpacing: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.3),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 30),
            offset: Offset(
              0,
              ResponsiveSystem.spacing(context, baseSpacing: 10),
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        child: Stack(
          children: [
            // Background Image or Gradient
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.8),
                    ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.4),
                  ],
                ),
                image: coverArtUrl != null
                    ? DecorationImage(
                        image: NetworkImage(coverArtUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.3),
                          BlendMode.darken,
                        ),
                        onError: (_, __) {},
                      )
                    : null,
              ),
            ),
            // Content Overlay
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              padding: ResponsiveSystem.all(context, baseSpacing: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured',
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 1.2,
                    ),
                  ),
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    ResponsiveSystem.sizedBox(
                      context,
                      height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Track Card - Modern Card Design
  Widget _buildTrackCard(Map<String, dynamic> music) {
    final playerState = ref.watch(audioControllerProvider);
    final audioController = ref.read(audioControllerProvider.notifier);

    final trackId = music['id'] as String? ?? '';
    final title = music['title'] as String? ?? music['id'] as String? ?? '';
    final subtitle = music['subtitle'] as String? ?? music['artist'] as String? ?? 'Tap to play';
    final coverArtUrl = music['coverArtUrl'] as String?;

    final isCurrentTrack = playerState.currentTrack?.id == trackId;
    final isPlaying = isCurrentTrack && playerState.isPlaying;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveSystem.spacing(context, baseSpacing: 16),
        ),
      ),
      color: ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.9),
      child: InkWell(
        onTap: () {
          if (isCurrentTrack) {
            audioController.togglePlayPause();
          } else {
            final track = Track.fromMusicMap(music);
            // Play track and show mini player only (NOT full player)
            audioController.playTrack(track).catchError((e) {});
          }
        },
        borderRadius: BorderRadius.circular(
          ResponsiveSystem.spacing(context, baseSpacing: 16),
        ),
        child: Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 16),
          child: Row(
            children: [
              // Artwork
              Container(
                width: ResponsiveSystem.spacing(context, baseSpacing: 64),
                height: ResponsiveSystem.spacing(context, baseSpacing: 64),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                  color: ThemeHelpers.getPrimaryColor(context)
                      .withValues(alpha: 0.2),
                  image: coverArtUrl != null
                      ? DecorationImage(
                          image: NetworkImage(coverArtUrl),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: coverArtUrl == null
                    ? Icon(
                        Icons.music_note,
                        color: ThemeHelpers.getPrimaryColor(context),
                        size: ResponsiveSystem.iconSize(context, baseSize: 32),
                      )
                    : null,
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              // Track Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                        fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.w600,
                        color: isCurrentTrack
                            ? ThemeHelpers.getPrimaryColor(context)
                            : ThemeHelpers.getPrimaryTextColor(context),
                      ),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Play/Pause or More Button
              if (isPlaying)
                Icon(
                  Icons.equalizer,
                  color: ThemeHelpers.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                )
              else
                IconButton(
                  icon: Icon(
                    isCurrentTrack ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    color: ThemeHelpers.getPrimaryColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 32),
                  ),
                  onPressed: () {
                    if (isCurrentTrack) {
                      audioController.togglePlayPause();
                    } else {
                      final track = Track.fromMusicMap(music);
                      audioController.playTrack(track).then((_) {
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const NowPlayingScreen(),
                            ),
                          );
                        }
                      }).catchError((e) {});
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Recently Played Section
  Widget _buildRecentlyPlayedSection() {
    final recentlyPlayed = ref.watch(recentlyPlayedServiceProvider);
    
    if (recentlyPlayed.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Get recently played tracks from music list
    final recentlyPlayedTracks = recentlyPlayed
        .map((trackId) => _musicList.firstWhere(
              (track) => track['id'] == trackId,
              orElse: () => <String, dynamic>{},
            ))
        .where((track) => track.isNotEmpty)
        .take(5)
        .toList();

    if (recentlyPlayedTracks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
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
                Text(
                  'Recently Played',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                if (recentlyPlayed.length > 5)
                  TextButton(
                    onPressed: () {
                      // Show all recently played
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getPrimaryColor(context),
                      ),
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
              itemCount: recentlyPlayedTracks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                  child: _buildHorizontalTrackCard(recentlyPlayedTracks[index]),
                );
              },
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
        ],
      ),
    );
  }

  /// Favorites Section
  Widget _buildFavoritesSection() {
    final favorites = ref.watch(favoritesServiceProvider);
    
    if (favorites.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Get favorite tracks from music list
    final favoriteTracks = _musicList
        .where((track) => favorites.contains(track['id']))
        .take(5)
        .toList();

    if (favoriteTracks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
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
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: ThemeHelpers.getPrimaryColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    Text(
                      'Favorites',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                        fontWeight: FontWeight.bold,
                        color: ThemeHelpers.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                if (favorites.length > 5)
                  TextButton(
                    onPressed: () {
                      // Show all favorites
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getPrimaryColor(context),
                      ),
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
              itemCount: favoriteTracks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                  child: _buildHorizontalTrackCard(favoriteTracks[index]),
                );
              },
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
        ],
      ),
    );
  }

  /// Horizontal Track Card (for Recently Played and Favorites)
  Widget _buildHorizontalTrackCard(Map<String, dynamic> music) {
    final playerState = ref.watch(audioControllerProvider);
    final audioController = ref.read(audioControllerProvider.notifier);

    final trackId = music['id'] as String? ?? '';
    final title = music['title'] as String? ?? music['id'] as String? ?? '';
    final subtitle = music['subtitle'] as String? ?? music['artist'] as String? ?? '';
    final coverArtUrl = music['coverArtUrl'] as String?;

    final isCurrentTrack = playerState.currentTrack?.id == trackId;
    final isPlaying = isCurrentTrack && playerState.isPlaying;

    return GestureDetector(
      onTap: () {
        ref.read(recentlyPlayedServiceProvider.notifier).addTrack(trackId);
        final track = Track.fromMusicMap(music);
        // Play track and show mini player only (NOT full player)
        audioController.playTrack(track).catchError((e) {});
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
          children: [
            // Artwork
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
                    image: coverArtUrl != null
                        ? DecorationImage(
                            image: NetworkImage(coverArtUrl),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : null,
                  ),
                  child: coverArtUrl == null
                      ? Icon(
                          Icons.music_note,
                          color: ThemeHelpers.getPrimaryColor(context),
                          size: ResponsiveSystem.iconSize(context, baseSize: 40),
                        )
                      : null,
                ),
                // Play button overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          ResponsiveSystem.spacing(context, baseSpacing: 12),
                        ),
                        topRight: Radius.circular(
                          ResponsiveSystem.spacing(context, baseSpacing: 12),
                        ),
                      ),
                      color: Colors.black.withValues(alpha: isPlaying ? 0.3 : 0.0),
                    ),
                    child: Center(
                      child: isPlaying
                          ? Icon(
                              Icons.equalizer,
                              color: Colors.white,
                              size: ResponsiveSystem.iconSize(context, baseSize: 32),
                            )
                          : Icon(
                              Icons.play_circle_filled,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: ResponsiveSystem.iconSize(context, baseSize: 48),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            // Track Info
            Padding(
              padding: ResponsiveSystem.all(context, baseSpacing: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                      fontWeight: FontWeight.w600,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton Loading Card
  Widget _buildSkeletonCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveSystem.spacing(context, baseSpacing: 16),
        ),
      ),
      color: ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.9),
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 16),
        child: Row(
          children: [
            // Skeleton Artwork
            Container(
              width: ResponsiveSystem.spacing(context, baseSpacing: 64),
              height: ResponsiveSystem.spacing(context, baseSpacing: 64),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                color: ThemeHelpers.getSecondaryTextColor(context)
                    .withValues(alpha: 0.1),
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Skeleton Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: ResponsiveSystem.fontSize(context, baseSize: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: ThemeHelpers.getSecondaryTextColor(context)
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: ResponsiveSystem.fontSize(context, baseSize: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: ThemeHelpers.getSecondaryTextColor(context)
                          .withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate bottom padding based on mini player height and platform
  Widget _buildBottomPadding(BuildContext context) {
    final playerState = ref.watch(audioControllerProvider);
    
    // Only add padding if mini player is visible
    if (!playerState.hasTrack || !playerState.showMiniPlayer) {
      return SizedBox(
        height: ResponsiveSystem.spacing(context, baseSpacing: 20),
      );
    }
    
    // Calculate responsive mini player height (same logic as MiniPlayer)
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
    
    // Add extra padding for safe scrolling
    final bottomPadding = totalPlayerHeight + ResponsiveSystem.spacing(context, baseSpacing: 20);
    
    return SizedBox(height: bottomPadding);
  }
}
