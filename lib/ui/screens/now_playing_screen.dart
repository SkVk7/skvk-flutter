/// Now Playing Screen
///
/// Full-screen audio player with artwork, lyrics toggle, and controls.
/// Features hero animation from mini player and smooth transitions.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/core/models/audio/track.dart';
import 'package:skvk_application/core/services/audio/audio_controller.dart';
import 'package:skvk_application/core/services/audio/global_audio_player_controller.dart';
import 'package:skvk_application/ui/components/audio/lyrics_language_selector.dart';
import 'package:skvk_application/ui/components/audio/lyrics_view.dart';
import 'package:skvk_application/ui/components/audio/player_controls.dart';
import 'package:skvk_application/ui/utils/animations.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Now Playing Screen
///
/// Full-screen player with:
/// - Hero animation for artwork
/// - Artwork/lyrics toggle
/// - Bottom scrubber and controls
/// - Smooth animations
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  bool _showLyrics = false;
  Duration? _scrubbingPosition;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _currentLyricsLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AnimationDurations.standard,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AnimationCurves.smooth,
    );
    _fadeController.forward();
    // Use SchedulerBinding to ensure it runs after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        ref
            .read(audioControllerProvider.notifier)
            .setFullScreenOpen(isOpen: true);
        try {
          final prefs = await SharedPreferences.getInstance();
          final languageCode =
              prefs.getString('content_language_preference') ?? 'en';
          if (mounted) {
            setState(() {
              _currentLyricsLanguage = languageCode;
            });
          }
        } on Exception {
          // Keep default 'en' if error
        }
      }
    });
  }

  @override
  void dispose() {
    ref.read(audioControllerProvider.notifier).setFullScreenOpen(isOpen: false);
    _fadeController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioControllerProvider);
    final controller = ref.read(audioControllerProvider.notifier);

    if (!playerState.hasTrack) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    final track = playerState.currentTrack!;
    final position = _scrubbingPosition ?? playerState.position;
    final duration = playerState.duration;
    final hasLyrics = playerState.lyrics.isNotEmpty;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            ref
                .read(audioControllerProvider.notifier)
                .setFullScreenOpen(isOpen: false);
          }
        },
        child: Scaffold(
          backgroundColor: ThemeHelpers.getBackgroundColor(context),
          body: SafeArea(
            child: Column(
              children: [
                // Top bar with back button and title
                _buildTopBar(track, controller, playerState),
                // Main content area (artwork or lyrics)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _showLyrics && hasLyrics
                        ? const LyricsView(key: ValueKey('lyrics'))
                        : _buildArtworkView(track,
                            key: const ValueKey('artwork'),),
                  ),
                ),
                // Bottom controls area
                _buildBottomControls(
                  track,
                  position,
                  duration,
                  playerState,
                  controller,
                  hasLyrics,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
      Track track, AudioController controller, PlayerState playerState,) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
        vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
      ),
      child: Row(
        children: [
          // Minimize button
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref
                  .read(audioControllerProvider.notifier)
                  .setFullScreenOpen(isOpen: false);
              Navigator.of(context).pop();
            },
            tooltip: 'Minimize',
          ),
          // Title and artist
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                if (track.displaySubtitle.isNotEmpty)
                  Text(
                    track.displaySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
              ],
            ),
          ),
          // Lyrics language selector - visible when lyrics are available
          if (playerState.lyrics.isNotEmpty)
            LyricsLanguageSelector(
              trackId: track.id,
              currentLanguage: _currentLyricsLanguage,
              onLanguageChanged: (languageCode) {
                setState(() {
                  _currentLyricsLanguage = languageCode;
                });
              },
            ),
          // Lyrics toggle button - always visible when lyrics are available
          if (playerState.lyrics.isNotEmpty)
            IconButton(
              icon: Icon(
                _showLyrics ? Icons.album : Icons.lyrics,
                color: _showLyrics
                    ? ThemeHelpers.getSecondaryTextColor(context)
                    : ThemeHelpers.getPrimaryColor(context),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _showLyrics = !_showLyrics;
                });
              },
              tooltip: _showLyrics ? 'Show artwork' : 'Show lyrics',
            ),
        ],
      ),
    );
  }

  Widget _buildArtworkView(Track track, {Key? key}) {
    return Center(
      key: key,
      child: Hero(
        tag: 'artwork-${track.id}',
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveSystem.spacing(context, baseSpacing: 20),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    ThemeHelpers.getShadowColor(context).withValues(alpha: 0.3),
                blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 30),
                offset: Offset(
                  0,
                  ResponsiveSystem.spacing(context, baseSpacing: 10),
                ),
              ),
            ],
            image: track.artworkUrl != null
                ? DecorationImage(
                    image: NetworkImage(track.artworkUrl!),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  )
                : null,
            color: track.artworkUrl == null
                ? ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.2)
                : null,
          ),
          child: track.artworkUrl == null
              ? Icon(
                  Icons.music_note,
                  size: ResponsiveSystem.iconSize(context, baseSize: 80),
                  color: ThemeHelpers.getPrimaryColor(context),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBottomControls(
    Track track,
    Duration position,
    Duration duration,
    PlayerState playerState,
    AudioController controller,
    bool hasLyrics,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 24),
        vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
      ),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSurfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.1),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 10),
            offset: Offset(
              0,
              -ResponsiveSystem.spacing(context, baseSpacing: 2),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrubber
          Column(
            children: [
              Slider(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds
                        .clamp(0, duration.inMilliseconds)
                        .toDouble()
                    : 0.0,
                max: duration.inMilliseconds > 0
                    ? duration.inMilliseconds.toDouble()
                    : 100.0,
                onChanged: (value) {
                  setState(() {
                    _scrubbingPosition = Duration(milliseconds: value.toInt());
                  });
                },
                onChangeEnd: (value) {
                  setState(() {
                    _scrubbingPosition = null;
                  });
                  controller.seek(Duration(milliseconds: value.toInt()));
                },
                activeColor: ThemeHelpers.getPrimaryColor(context),
                inactiveColor: ThemeHelpers.getPrimaryColor(context)
                    .withValues(alpha: 0.3),
              ),
              // Time labels
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSystem.spacing(context, baseSpacing: 4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 12),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 12),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
          // Player controls
          const PlayerControls(),
          SizedBox(
            height: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          // Repeat/shuffle (placeholder)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _getRepeatIcon(playerState.repeatMode),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.toggleRepeatMode();
                },
                tooltip: _getRepeatTooltip(playerState.repeatMode),
              ),
              SizedBox(
                width: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              // Queue button placeholder
              IconButton(
                icon: Icon(
                  Icons.queue_music,
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
                onPressed: () {
                  // Placeholder for queue view
                },
                tooltip: 'Queue',
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat;
    }
  }

  String _getRepeatTooltip(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return 'Repeat off';
      case RepeatMode.one:
        return 'Repeat one';
      case RepeatMode.all:
        return 'Repeat all';
    }
  }
}
