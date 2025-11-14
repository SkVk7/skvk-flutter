/// Audio Track Card Component
///
/// Reusable vertical track card for list views
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/models/audio/track.dart';
import 'package:skvk_application/core/services/audio/audio_controller.dart';
import 'package:skvk_application/core/services/audio/favorites_service.dart';
import 'package:skvk_application/ui/screens/now_playing_screen.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Audio Track Card - Vertical card design for track list
class AudioTrackCard extends ConsumerWidget {
  const AudioTrackCard({
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
    final subtitle = music['subtitle'] as String? ??
        music['artist'] as String? ??
        'Tap to play';
    final coverArtUrl = music['coverArtUrl'] as String?;

    final isCurrentTrack = playerState.currentTrack?.id == trackId;
    final isPlaying = isCurrentTrack && playerState.isPlaying;
    final isFavorite = favorites.contains(trackId);

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
        onTap: onTap ??
            () {
              final audioController =
                  ref.read(audioControllerProvider.notifier);

              if (isCurrentTrack) {
                audioController.togglePlayPause();
              } else {
                final track = Track.fromMusicMap(music);
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
                              ResponsiveSystem.fontSize(context, baseSize: 16),
                          fontWeight: isCurrentTrack
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isCurrentTrack
                              ? ThemeHelpers.getPrimaryColor(context)
                              : ThemeHelpers.getPrimaryTextColor(context),
                        ),
                      ),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                    ),
                    Tooltip(
                      message: subtitle,
                      preferBelow: false,
                      waitDuration: const Duration(milliseconds: 500),
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 14),
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Favorite Star Button
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite
                      ? ThemeHelpers.getPrimaryColor(context)
                      : ThemeHelpers.getSecondaryTextColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                ),
                onPressed: () {
                  ref
                      .read(favoritesServiceProvider.notifier)
                      .toggleFavorite(trackId);
                },
                tooltip:
                    isFavorite ? 'Remove from favorites' : 'Add to favorites',
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
                    isCurrentTrack
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: ThemeHelpers.getPrimaryColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 32),
                  ),
                  onPressed: () {
                    final audioController =
                        ref.read(audioControllerProvider.notifier);

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
}
