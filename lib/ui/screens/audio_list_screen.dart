/// Audio List Screen
///
/// Displays a list of audio tracks with search functionality.
/// Uses padding to avoid mini player overlap.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/audio/audio_controller.dart';
import '../../core/models/audio/track.dart';
import '../components/audio/mini_player.dart';
import '../utils/theme_helpers.dart';
import '../utils/responsive_system.dart';
import '../../core/services/content/content_api_service.dart';
import '../../core/services/network/network_connectivity_service.dart';
import '../../core/logging/logging_helper.dart';

/// Audio List Screen
///
/// Shows a scrollable list of tracks with proper bottom padding
/// to account for the mini player.
class AudioListScreen extends ConsumerStatefulWidget {
  const AudioListScreen({super.key});

  @override
  ConsumerState<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends ConsumerState<AudioListScreen> {
  List<Track> _tracks = [];
  List<Track> _filteredTracks = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTracks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Check network connectivity
    final hasInternet =
        await NetworkConnectivityService.instance.hasInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              NetworkConnectivityService.instance.getOfflineMessage();
        });
      }
      return;
    }

    try {
      final musicList = await ContentApiService.instance.getMusicList();
      if (mounted) {
        final tracks = (musicList['music'] as List<dynamic>?)
                ?.map((music) => Track.fromMusicMap(music as Map<String, dynamic>))
                .toList() ??
            [];
        setState(() {
          _tracks = tracks;
          _filteredTracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load music list',
          source: 'AudioListScreen', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load tracks. Please try again.';
        });
      }
    }
  }

  void _filterTracks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTracks = _tracks;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredTracks = _tracks.where((track) {
          final title = track.title.toLowerCase();
          final subtitle = track.displaySubtitle.toLowerCase();
          return title.contains(lowerQuery) || subtitle.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioControllerProvider);

    // Calculate bottom padding for mini player (responsive height)
    final bottomPadding = playerState.showMiniPlayer
        ? ResponsiveSystem.responsive(
            context,
            mobile: ResponsiveSystem.spacing(context, baseSpacing: 88),
            tablet: ResponsiveSystem.spacing(context, baseSpacing: 96),
            desktop: ResponsiveSystem.spacing(context, baseSpacing: 104),
            largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 112),
          ) +
            MediaQuery.of(context).padding.bottom +
            ResponsiveSystem.spacing(context, baseSpacing: 16)
        : ResponsiveSystem.spacing(context, baseSpacing: 16);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devotional Audio'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredTracks = _tracks;
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content with bottom padding
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: RefreshIndicator(
              onRefresh: _loadTracks,
              child: _buildContent(),
            ),
          ),
          // Mini player overlay (positioned at bottom)
          if (playerState.showMiniPlayer)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const MiniPlayer(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
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
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getErrorColor(context),
                ),
              ),
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              ElevatedButton(
                onPressed: _loadTracks,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredTracks.isEmpty) {
      return Center(
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
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        if (_isSearching)
          Padding(
            padding: ResponsiveSystem.all(context, baseSpacing: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tracks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterTracks('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterTracks,
            ),
          ),
        // Track list
        Expanded(
          child: ListView.builder(
            padding: ResponsiveSystem.symmetric(
              context,
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            itemCount: _filteredTracks.length,
            itemBuilder: (context, index) {
              final currentPlayerState = ref.watch(audioControllerProvider);
              return _TrackListItem(
                track: _filteredTracks[index],
                isCurrentTrack: currentPlayerState.currentTrack?.id ==
                    _filteredTracks[index].id,
                isPlaying: currentPlayerState.currentTrack?.id ==
                        _filteredTracks[index].id &&
                    currentPlayerState.isPlaying,
                onTap: () {
                  final audioController = ref.read(audioControllerProvider.notifier);
                  audioController.playTrack(_filteredTracks[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Track list item widget
class _TrackListItem extends StatelessWidget {
  final Track track;
  final bool isCurrentTrack;
  final bool isPlaying;
  final VoidCallback onTap;

  const _TrackListItem({
    required this.track,
    required this.isCurrentTrack,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 8),
      ),
      child: ListTile(
        leading: Container(
          width: ResponsiveSystem.spacing(context, baseSpacing: 56),
          height: ResponsiveSystem.spacing(context, baseSpacing: 56),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.2),
            image: track.artworkUrl != null
                ? DecorationImage(
                    image: NetworkImage(track.artworkUrl!),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  )
                : null,
          ),
          child: track.artworkUrl == null
              ? Icon(
                  Icons.music_note,
                  color: ThemeHelpers.getPrimaryColor(context),
                )
              : null,
        ),
        title: Text(
          track.title,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
            color: isCurrentTrack
                ? ThemeHelpers.getPrimaryColor(context)
                : ThemeHelpers.getPrimaryTextColor(context),
          ),
        ),
        subtitle: Text(
          track.displaySubtitle,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
          ),
        ),
        trailing: isPlaying
            ? Icon(
                Icons.equalizer,
                color: ThemeHelpers.getPrimaryColor(context),
              )
            : const Icon(Icons.play_circle_outline),
        onTap: onTap,
      ),
    );
  }
}

