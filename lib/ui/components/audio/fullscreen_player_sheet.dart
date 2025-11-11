/// Fullscreen Player Sheet
///
/// Full-screen audio player with smooth transitions, proper state management,
/// and production-grade UI/UX
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/services/audio/global_audio_player_controller.dart';
import '../../../core/services/audio/player_queue_service.dart';
import 'player_state_provider.dart';
import 'lyrics_language_selector.dart';

/// Fullscreen Player Sheet
class FullscreenPlayerSheet extends ConsumerStatefulWidget {
  const FullscreenPlayerSheet({super.key});

  static void show(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final playerState = container.read(globalAudioPlayerProvider);
    
    if (!playerState.hasTrack) {
      return;
    }
    
    // Set maximized state before showing
    container.read(playerViewStateProvider.notifier).maximize();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const FullscreenPlayerSheet(),
    ).then((value) {
      // Always minimize when modal is dismissed (whether by drag, tap outside, or back button)
      Future.microtask(() {
        container.read(playerViewStateProvider.notifier).minimize();
      });
    }).catchError((error) {
      // Ensure state is reset even on error
      Future.microtask(() {
        container.read(playerViewStateProvider.notifier).minimize();
      });
    });
  }

  @override
  ConsumerState<FullscreenPlayerSheet> createState() =>
      _FullscreenPlayerSheetState();
}

class _FullscreenPlayerSheetState
    extends ConsumerState<FullscreenPlayerSheet>
    with TickerProviderStateMixin {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();
  final ScrollController _lyricsScrollController = ScrollController();
  StreamSubscription<Duration>? _positionSubscription;
  int _currentLyricIndex = -1;
  bool _isUserScrolling = false;
  Timer? _autoScrollResumeTimer;
  double _lyricsFontSize = 1.0;
  String _currentLyricsLanguage = 'en';
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupPositionListener();
    
    // Auto-expand to full screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            try {
              _scrollController.animateTo(
                1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            } catch (e) {
              // Ignore if controller not ready
            }
          }
        });
      }
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  void _setupPositionListener() {
    final playerController = ref.read(globalAudioPlayerProvider.notifier);
    _positionSubscription = playerController.positionStream.listen((position) {
      if (!_isUserScrolling && mounted) {
        _updateCurrentLyric(position);
      }
    });
  }

  void _updateCurrentLyric(Duration position) {
    final playerState = ref.read(globalAudioPlayerProvider);
    final lyrics = playerState.lyrics;
    
    if (lyrics.isEmpty) return;
    
    int newIndex = -1;
    for (int i = 0; i < lyrics.length; i++) {
      if (position >= lyrics[i].timestamp) {
        newIndex = i;
      } else {
        break;
      }
    }
    
    if (newIndex != _currentLyricIndex && newIndex >= 0) {
      setState(() {
        _currentLyricIndex = newIndex;
      });
      _scrollToCurrentLine(newIndex);
    }
  }

  void _scrollToCurrentLine(int index) {
    if (!_lyricsScrollController.hasClients) return;
    
    final baseFontSize = ResponsiveSystem.fontSize(context, baseSize: 18) * _lyricsFontSize;
    final lineHeight = baseFontSize * 1.4;
    final padding = ResponsiveSystem.spacing(context, baseSpacing: 16);
    final itemHeight = lineHeight + padding;
    
    final viewportHeight = _lyricsScrollController.position.viewportDimension;
    final scrollPosition = (index * itemHeight) - (viewportHeight / 2) + (itemHeight / 2);
    
    _lyricsScrollController.animateTo(
      scrollPosition.clamp(0.0, _lyricsScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _autoScrollResumeTimer?.cancel();
    _scrollController.dispose();
    _lyricsScrollController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(globalAudioPlayerProvider);
    final playerController = ref.read(globalAudioPlayerProvider.notifier);
    
    if (!playerState.hasTrack) {
      return const SizedBox.shrink();
    }
    
    final track = playerState.currentTrack!;
    final hasLyrics = playerState.lyrics.isNotEmpty;
    
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          // Minimize state when back button is pressed
          Future.microtask(() {
            ref.read(playerViewStateProvider.notifier).minimize();
          });
        }
      },
      child: DraggableScrollableSheet(
        controller: _scrollController,
        initialChildSize: 0.10,
        minChildSize: 0.10,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: ThemeHelpers.getSurfaceColor(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isExpanded = constraints.maxHeight > MediaQuery.of(context).size.height * 0.5;
                
                if (isExpanded) {
                  return _buildMaximizedView(track, playerState, playerController, hasLyrics);
                } else {
                  return _buildMinimizedView(track, playerState, playerController);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMinimizedView(
    AudioTrack track,
    AudioPlayerState playerState,
    GlobalAudioPlayerController playerController,
  ) {
    return GestureDetector(
      onTap: () {
        // Expand to full screen when tapped
        _scrollController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: Container(
        padding: ResponsiveSystem.all(context, baseSpacing: 16),
        child: Row(
          children: [
            // Artwork
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.2),
                image: track.coverArtUrl != null
                    ? DecorationImage(
                        image: NetworkImage(track.coverArtUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: track.coverArtUrl == null
                  ? Icon(
                      Icons.music_note,
                      color: ThemeHelpers.getPrimaryColor(context),
                    )
                  : null,
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            // Track Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 15),
                      fontWeight: FontWeight.w600,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                  Text(
                    track.artist ?? track.subtitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 13),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            // Controls - stop propagation
            GestureDetector(
              onTap: () {
                playerController.playPause();
              },
              child: IconButton(
                icon: Icon(
                  playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
                onPressed: () => playerController.playPause(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaximizedView(
    AudioTrack track,
    AudioPlayerState playerState,
    GlobalAudioPlayerController playerController,
    bool hasLyrics,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            // Header with close button and lyrics language selector
            SafeArea(
              bottom: false,
              child: Padding(
                padding: ResponsiveSystem.all(context, baseSpacing: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lyrics language selector (only when lyrics available)
                    if (hasLyrics)
                      LyricsLanguageSelector(
                        trackId: track.id,
                        currentLanguage: _currentLyricsLanguage,
                        onLanguageChanged: (languageCode) {
                          setState(() {
                            _currentLyricsLanguage = languageCode;
                          });
                        },
                      )
                    else
                      const SizedBox.shrink(),
                    // Close button
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: ThemeHelpers.getPrimaryTextColor(context),
                        size: ResponsiveSystem.iconSize(context, baseSize: 28),
                      ),
                      onPressed: () {
                        // Close the modal and minimize state
                        Navigator.of(context).pop();
                        Future.microtask(() {
                          ref.read(playerViewStateProvider.notifier).minimize();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Main Content - Lyrics or Artwork
            Expanded(
              child: hasLyrics
                  ? _buildLyricsView(playerState, playerController)
                  : _buildArtworkView(track),
            ),
            // Player Controls
            _buildPlayerControls(track, playerState, playerController),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsView(
    AudioPlayerState playerState,
    GlobalAudioPlayerController playerController,
  ) {
    final lyrics = playerState.lyrics;
    
    if (lyrics.isEmpty) {
      return _buildArtworkView(playerState.currentTrack!);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _isUserScrolling = true;
          _autoScrollResumeTimer?.cancel();
          _autoScrollResumeTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isUserScrolling = false;
              });
            }
          });
        }
        return false;
      },
      child: ListView.builder(
        controller: _lyricsScrollController,
        padding: ResponsiveSystem.symmetric(
          context,
          horizontal: ResponsiveSystem.spacing(context, baseSpacing: 32),
          vertical: ResponsiveSystem.spacing(context, baseSpacing: 40),
        ),
        itemCount: lyrics.length,
        itemBuilder: (context, index) {
          final lyric = lyrics[index];
          final isCurrent = index == _currentLyricIndex;
          final isNext = index == _currentLyricIndex + 1;
          final isPrevious = index == _currentLyricIndex - 1;

          return GestureDetector(
            onTap: () {
              playerController.seekTo(lyric.timestamp);
            },
            child: Container(
              padding: ResponsiveSystem.symmetric(
                context,
                vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
                horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              child: Text(
                lyric.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(
                    context,
                    baseSize: (isCurrent ? 28 : (isNext || isPrevious ? 18 : 20)) * _lyricsFontSize,
                  ),
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent
                      ? ThemeHelpers.getPrimaryColor(context)
                      : ThemeHelpers.getPrimaryTextColor(context)
                          .withValues(alpha: isNext || isPrevious ? 0.7 : 0.5),
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtworkView(AudioTrack track) {
    final screenWidth = MediaQuery.of(context).size.width;
    final artworkSize = screenWidth * 0.75;

    return Center(
      child: Container(
        width: artworkSize,
        height: artworkSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.3),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
          color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.2),
          image: track.coverArtUrl != null
              ? DecorationImage(
                  image: NetworkImage(track.coverArtUrl!),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                )
              : null,
        ),
        child: track.coverArtUrl == null
            ? Icon(
                Icons.music_note,
                color: ThemeHelpers.getPrimaryColor(context),
                size: artworkSize * 0.4,
              )
            : null,
      ),
    );
  }

  Widget _buildPlayerControls(
    AudioTrack track,
    AudioPlayerState playerState,
    GlobalAudioPlayerController playerController,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          children: [
            // Track Info
            Column(
              children: [
                Text(
                  track.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (track.artist != null || track.subtitle != null) ...[
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                  ),
                  Text(
                    track.artist ?? track.subtitle ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 24),
            ),
            // Progress Bar
            _buildProgressBar(playerState, playerController),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 24),
            ),
            // Main Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Shuffle
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: ThemeHelpers.getSecondaryTextColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  ),
                  onPressed: () {
                    // TODO: Implement shuffle
                  },
                ),
                // Previous
                IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 32),
                  ),
                  onPressed: () {
                    final queueService = ref.read(playerQueueServiceProvider.notifier);
                    queueService.previous();
                  },
                ),
                // Play/Pause
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeHelpers.getPrimaryColor(context),
                  ),
                  child: IconButton(
                    icon: playerState.isLoading
                        ? SizedBox(
                            width: ResponsiveSystem.iconSize(context, baseSize: 32),
                            height: ResponsiveSystem.iconSize(context, baseSize: 32),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: ResponsiveSystem.iconSize(context, baseSize: 40),
                          ),
                    onPressed: () {
                      playerController.playPause();
                    },
                  ),
                ),
                // Next
                IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 32),
                  ),
                  onPressed: () {
                    final queueService = ref.read(playerQueueServiceProvider.notifier);
                    queueService.next();
                  },
                ),
                // Repeat
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    color: ThemeHelpers.getSecondaryTextColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  ),
                  onPressed: () {
                    // TODO: Implement repeat
                  },
                ),
              ],
            ),
            // Lyrics font size controls (only when lyrics available)
            if (playerState.lyrics.isNotEmpty) ...[
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.text_decrease,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        _lyricsFontSize = (_lyricsFontSize - 0.1).clamp(0.8, 1.5);
                      });
                    },
                  ),
                  Text(
                    '${(_lyricsFontSize * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.text_increase,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        _lyricsFontSize = (_lyricsFontSize + 0.1).clamp(0.8, 1.5);
                      });
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    AudioPlayerState playerState,
    GlobalAudioPlayerController playerController,
  ) {
    final position = playerState.position;
    final duration = playerState.duration;
    
    if (duration == Duration.zero) {
      return const SizedBox.shrink();
    }
    
    final progress = position.inMilliseconds / duration.inMilliseconds;
    
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final newPosition = Duration(
                milliseconds: (value * duration.inMilliseconds).toInt(),
              );
              playerController.seekTo(newPosition);
            },
            activeColor: ThemeHelpers.getPrimaryColor(context),
            inactiveColor: ThemeHelpers.getPrimaryTextColor(context)
                .withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: ResponsiveSystem.symmetric(
            context,
            horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

