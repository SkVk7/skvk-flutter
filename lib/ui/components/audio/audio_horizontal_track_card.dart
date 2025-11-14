/// Audio Horizontal Track Card Component
///
/// Reusable horizontal track card for horizontal scrolling sections
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/models/audio/track.dart';
import 'package:skvk_application/core/services/audio/audio_controller.dart';
import 'package:skvk_application/core/services/audio/favorites_service.dart';
import 'package:skvk_application/core/services/audio/recently_played_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Audio Horizontal Track Card - Horizontal card for section lists
class AudioHorizontalTrackCard extends ConsumerWidget {
  const AudioHorizontalTrackCard({
    required this.music,
    this.onTap,
    super.key,
  });

  final Map<String, dynamic> music;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioControllerProvider);
    final favorites = ref.watch(favoritesServiceProvider);

    final trackId = music['id'] as String? ?? '';
    final title = music['title'] as String? ?? music['id'] as String? ?? '';
    final subtitle =
        music['subtitle'] as String? ?? music['artist'] as String? ?? '';
    final coverArtUrl = music['coverArtUrl'] as String?;

    final isCurrentTrack = playerState.currentTrack?.id == trackId;
    final isPlaying = isCurrentTrack && playerState.isPlaying;
    final isFavorite = favorites.contains(trackId);

    return GestureDetector(
      onTap: onTap ??
          () {
            final recentlyPlayedNotifier =
                ref.read(recentlyPlayedServiceProvider.notifier);
            final audioController = ref.read(audioControllerProvider.notifier);

            recentlyPlayedNotifier.addTrack(trackId);
            final track = Track.fromMusicMap(music);
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
              color:
                  ThemeHelpers.getShadowColor(context).withValues(alpha: 0.1),
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
                          size:
                              ResponsiveSystem.iconSize(context, baseSize: 40),
                        )
                      : null,
                ),
                // Play button overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          ResponsiveSystem.spacing(context, baseSpacing: 12),
                        ),
                        topRight: Radius.circular(
                          ResponsiveSystem.spacing(context, baseSpacing: 12),
                        ),
                      ),
                      color: ThemeHelpers.getShadowColor(context)
                          .withValues(alpha: isPlaying ? 0.5 : 0.0),
                    ),
                    child: Center(
                      child: isPlaying
                          ? Icon(
                              Icons.equalizer,
                              color: ThemeHelpers.getAppBarTextColor(context),
                              size: ResponsiveSystem.iconSize(context,
                                  baseSize: 32,),
                            )
                          : Icon(
                              Icons.play_circle_filled,
                              color: ThemeHelpers.getAppBarTextColor(context)
                                  .withValues(alpha: 0.9),
                              size: ResponsiveSystem.iconSize(context,
                                  baseSize: 48,),
                            ),
                    ),
                  ),
                ),
                // Favorite Star Button (top right corner)
                Positioned(
                  top: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  right: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(favoritesServiceProvider.notifier)
                          .toggleFavorite(trackId);
                    },
                    child: Container(
                      padding: ResponsiveSystem.all(context, baseSpacing: 4),
                      decoration: BoxDecoration(
                        color: ThemeHelpers.getShadowColor(context)
                            .withValues(alpha: 0.7),
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
            // Track Info
            Flexible(
              child: Padding(
                padding: ResponsiveSystem.all(context, baseSpacing: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: title,
                      preferBelow: false,
                      waitDuration: const Duration(milliseconds: 500),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 14),
                          fontWeight: FontWeight.w600,
                          color: ThemeHelpers.getPrimaryTextColor(context),
                        ),
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Tooltip(
                        message: subtitle,
                        preferBelow: false,
                        waitDuration: const Duration(milliseconds: 500),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context,
                                baseSize: 12,),
                            color: ThemeHelpers.getSecondaryTextColor(context),
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
    );
  }
}
