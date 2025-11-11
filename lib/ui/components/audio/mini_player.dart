/// Mini Player Widget
///
/// Sticky mini player at the bottom of the app.
/// Expands to full-screen Now Playing when tapped.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio/audio_controller.dart';
import '../../screens/now_playing_screen.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../utils/animations.dart';
import '../../../../main.dart' show navigatorKey;

/// Mini Player Widget
///
/// Sticky at bottom, shows current track info and play/pause.
/// Tapping anywhere expands to Now Playing screen.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioControllerProvider);
    final controller = ref.read(audioControllerProvider.notifier);

    // Hide if no track or mini player is disabled
    if (!playerState.hasTrack || !playerState.showMiniPlayer) {
      return const SizedBox.shrink();
    }

    final track = playerState.currentTrack!;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    // Calculate responsive mini player height
    final miniPlayerHeight = ResponsiveSystem.responsive(
      context,
      mobile: ResponsiveSystem.spacing(context, baseSpacing: 88),
      tablet: ResponsiveSystem.spacing(context, baseSpacing: 96),
      desktop: ResponsiveSystem.spacing(context, baseSpacing: 104),
      largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 112),
    );

    return Material(
      elevation: ResponsiveSystem.responsive(
        context,
        mobile: 6.0,
        tablet: 8.0,
        desktop: 10.0,
      ),
      color: Colors.transparent,
      child: Container(
        height: miniPlayerHeight + safeAreaBottom,
        decoration: BoxDecoration(
          color: ThemeHelpers.getSurfaceColor(context),
          boxShadow: [
            BoxShadow(
              color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.1),
              blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 20),
              offset: Offset(
                0,
                -ResponsiveSystem.spacing(context, baseSpacing: 4),
              ),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Container(
            height: miniPlayerHeight,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Artwork, Track Info, Controls (tappable to expand)
                Flexible(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      debugPrint('Mini player tapped - expanding to full player');
                      _expandToNowPlaying(context, ref);
                    },
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Artwork
                          Hero(
                            tag: 'artwork-${track.id}',
                            child: Container(
                              width: ResponsiveSystem.spacing(context, baseSpacing: 48),
                              height: ResponsiveSystem.spacing(context, baseSpacing: 48),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              ResponsiveSystem.spacing(context, baseSpacing: 8),
                            ),
                            color: ThemeHelpers.getPrimaryColor(context)
                                .withValues(alpha: 0.2),
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
                                  size: ResponsiveSystem.iconSize(context, baseSize: 28),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                      ),
                      // Track Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ResponsiveSystem.fontSize(
                                  context,
                                  baseSize: 16,
                                ),
                                fontWeight: FontWeight.w600,
                                color: ThemeHelpers.getPrimaryTextColor(context),
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveSystem.spacing(context, baseSpacing: 2),
                            ),
                            Text(
                              track.displaySubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ResponsiveSystem.fontSize(
                                  context,
                                  baseSize: 13,
                                ),
                                color: ThemeHelpers.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Previous button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.prev();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: ResponsiveSystem.spacing(context, baseSpacing: 32),
                          height: ResponsiveSystem.spacing(context, baseSpacing: 32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ThemeHelpers.getSurfaceColor(context),
                          ),
                          child: Icon(
                            Icons.skip_previous,
                            color: ThemeHelpers.getPrimaryTextColor(context),
                            size: ResponsiveSystem.iconSize(context, baseSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                      ),
                      // Play/Pause button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.togglePlayPause();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: ResponsiveSystem.spacing(context, baseSpacing: 36),
                          height: ResponsiveSystem.spacing(context, baseSpacing: 36),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ThemeHelpers.getPrimaryColor(context),
                          ),
                          child: playerState.isLoading
                              ? Center(
                                  child: SizedBox(
                                    width: ResponsiveSystem.spacing(context, baseSpacing: 20),
                                    height: ResponsiveSystem.spacing(context, baseSpacing: 20),
                                    child: CircularProgressIndicator(
                                      strokeWidth: ResponsiveSystem.responsive(
                                        context,
                                        mobile: 2.0,
                                        tablet: 2.5,
                                        desktop: 3.0,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeHelpers.getSurfaceColor(context),
                                      ),
                                    ),
                                  ),
                                )
                              : Icon(
                                  playerState.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: ThemeHelpers.getSurfaceColor(context),
                                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                      ),
                      // Next button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.next();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: ResponsiveSystem.spacing(context, baseSpacing: 32),
                          height: ResponsiveSystem.spacing(context, baseSpacing: 32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ThemeHelpers.getSurfaceColor(context),
                          ),
                          child: Icon(
                            Icons.skip_next,
                            color: ThemeHelpers.getPrimaryTextColor(context),
                            size: ResponsiveSystem.iconSize(context, baseSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                      ),
                      // Close button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Stop playback when closing mini player
                          controller.stop();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: ResponsiveSystem.spacing(context, baseSpacing: 32),
                          height: ResponsiveSystem.spacing(context, baseSpacing: 32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: Icon(
                            Icons.close,
                            color: ThemeHelpers.getSecondaryTextColor(context),
                            size: ResponsiveSystem.iconSize(context, baseSize: 20),
                          ),
                        ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                ),
                // Progress bar row (not tappable for expansion, only for scrubbing)
                Flexible(
                  flex: 1,
                  child: Row(
                  children: [
                    // Current time
                    SizedBox(
                      width: ResponsiveSystem.spacing(context, baseSpacing: 40),
                      child: Text(
                        _formatDuration(playerState.position),
                        style: TextStyle(
                          fontSize: ResponsiveSystem.fontSize(context, baseSize: 11),
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    // Progress bar (custom implementation to avoid Overlay requirement)
                    Expanded(
                      child: _CustomProgressBar(
                        value: playerState.duration.inMilliseconds > 0
                            ? playerState.position.inMilliseconds.clamp(
                                0, playerState.duration.inMilliseconds).toDouble()
                            : 0.0,
                        max: playerState.duration.inMilliseconds > 0
                            ? playerState.duration.inMilliseconds.toDouble()
                            : 100.0,
                        onChanged: (value) {
                          // Allow scrubbing in mini player
                          controller.seek(Duration(milliseconds: value.toInt()));
                        },
                        activeColor: ThemeHelpers.getPrimaryColor(context),
                        inactiveColor: ThemeHelpers.getPrimaryColor(context)
                            .withValues(alpha: 0.3),
                        trackHeight: ResponsiveSystem.responsive(
                          context,
                          mobile: 2.0,
                          tablet: 2.5,
                          desktop: 3.0,
                        ),
                        thumbRadius: ResponsiveSystem.responsive(
                          context,
                          mobile: 6.0,
                          tablet: 7.0,
                          desktop: 8.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    // Total duration
                    SizedBox(
                      width: ResponsiveSystem.spacing(context, baseSpacing: 40),
                      child: Text(
                        _formatDuration(playerState.duration),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: ResponsiveSystem.fontSize(context, baseSize: 11),
                          color: ThemeHelpers.getSecondaryTextColor(context),
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
        ),
    );
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Expand to Now Playing screen with smooth expansion animation
  /// Makes it feel like the same player expanding from mini to full
  void _expandToNowPlaying(BuildContext context, WidgetRef ref) {
    debugPrint('Navigating to NowPlayingScreen');
    
    // Use the global Navigator key to access Navigator from anywhere
    final navigator = navigatorKey.currentState;
    
    if (navigator != null) {
      debugPrint('Found Navigator via navigatorKey, navigating...');
      navigator.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const NowPlayingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth shared axis transition - makes it feel like the same player expanding
            // Slide up from bottom with scale effect
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: AnimationCurves.smooth,
              ),
            );
            
            final scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: AnimationCurves.smooth,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 520),
          reverseTransitionDuration: const Duration(milliseconds: 520),
          opaque: true,
          fullscreenDialog: false,
        ),
      );
    } else {
      debugPrint('Navigator key not available - MaterialApp may not be initialized yet');
    }
  }
}

/// Custom progress bar widget that doesn't require an Overlay
/// Used in mini player where Overlay widget is not available
class _CustomProgressBar extends StatefulWidget {
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double trackHeight;
  final double thumbRadius;

  const _CustomProgressBar({
    required this.value,
    required this.max,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
    required this.trackHeight,
    required this.thumbRadius,
  });

  @override
  State<_CustomProgressBar> createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<_CustomProgressBar> {
  bool _isDragging = false;
  double? _dragValue;

  void _updateValueFromPosition(Offset localPosition, double width) {
    final newValue = (localPosition.dx / width).clamp(0.0, 1.0) * widget.max;
    setState(() {
      _dragValue = newValue;
    });
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = _isDragging && _dragValue != null
        ? _dragValue!
        : widget.value;
    final normalizedValue = widget.max > 0
        ? (currentValue / widget.max).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _isDragging = true;
        });
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          _updateValueFromPosition(details.localPosition, box.size.width);
        }
      },
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
        });
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          _updateValueFromPosition(details.localPosition, box.size.width);
        }
      },
      onPanUpdate: (details) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          _updateValueFromPosition(details.localPosition, box.size.width);
        }
      },
      onPanEnd: (_) {
        setState(() {
          _isDragging = false;
          _dragValue = null;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isDragging = false;
          _dragValue = null;
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final thumbPosition = normalizedValue * width;

          return Container(
            height: widget.trackHeight * 3, // Extra height for thumb touch area
            alignment: Alignment.center,
            child: Stack(
              children: [
                // Inactive track
                Container(
                  height: widget.trackHeight,
                  decoration: BoxDecoration(
                    color: widget.inactiveColor,
                    borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                  ),
                ),
                // Active track
                Positioned(
                  left: 0,
                  child: Container(
                    width: thumbPosition,
                    height: widget.trackHeight,
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: thumbPosition - widget.thumbRadius,
                  top: (widget.trackHeight * 3 - widget.thumbRadius * 2) / 2,
                  child: Container(
                    width: widget.thumbRadius * 2,
                    height: widget.thumbRadius * 2,
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.activeColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

