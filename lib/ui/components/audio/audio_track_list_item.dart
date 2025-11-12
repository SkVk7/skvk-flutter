/// Audio Track List Item Component
///
/// Flat list item (Material3 ListTile) for audio tracks with:
/// - Leading thumb
/// - Title, subtitle
/// - Trailing overflow menu
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/services/audio/audio_controller.dart';
import '../../../core/services/audio/favorites_service.dart';
import '../../../core/services/audio/recently_played_service.dart';
import '../../../core/services/audio/player_queue_service.dart';
import '../../../core/models/audio/track.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Audio Track List Item - Material3 ListTile for track display
class AudioTrackListItem extends ConsumerWidget {
  final Map<String, dynamic> music;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const AudioTrackListItem({
    super.key,
    required this.music,
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioControllerProvider);
    final favorites = ref.watch(favoritesServiceProvider);
    final favoritesService = ref.read(favoritesServiceProvider.notifier);

    final trackId = music['id'] as String? ?? '';
    final title = music['title'] as String? ?? music['id'] as String? ?? '';
    final subtitle = music['subtitle'] as String? ?? music['artist'] as String? ?? 'Tap to play';
    final coverArtUrl = music['coverArtUrl'] as String?;

    final isCurrentTrack = playerState.currentTrack?.id == trackId;
    final isPlaying = isCurrentTrack && playerState.isPlaying;
    final isFavorite = favorites.contains(trackId);

    return ListTile(
      contentPadding: ResponsiveSystem.symmetric(
        context,
        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
        vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
      ),
      leading: Container(
        width: ResponsiveSystem.spacing(context, baseSpacing: 56),
        height: ResponsiveSystem.spacing(context, baseSpacing: 56),
        decoration: BoxDecoration(
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
          color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.2),
          image: coverArtUrl != null
              ? DecorationImage(
                  image: NetworkImage(coverArtUrl),
                  fit: BoxFit.cover,
                  onError: (_, __) {
                    // Handle image load error
                  },
                )
              : null,
        ),
        child: coverArtUrl == null
            ? Icon(
                Icons.music_note,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 28),
              )
            : null,
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
          fontWeight: isCurrentTrack ? FontWeight.w600 : FontWeight.w500,
          color: isCurrentTrack
              ? ThemeHelpers.getPrimaryColor(context)
              : ThemeHelpers.getPrimaryTextColor(context),
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Favorite button
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? ThemeHelpers.getPrimaryColor(context)
                  : ThemeHelpers.getSecondaryTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
            onPressed: () {
              favoritesService.toggleFavorite(trackId);
            },
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
          // Playing indicator
          if (isPlaying)
            Padding(
              padding: ResponsiveSystem.only(
                context,
                right: ResponsiveSystem.spacing(context, baseSpacing: 8),
              ),
              child: Icon(
                Icons.equalizer,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
            ),
          // Overflow menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: ThemeHelpers.getSecondaryTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'play',
                child: Row(
                  children: [
                    Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: ThemeHelpers.getPrimaryColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                    Text(
                      isPlaying ? 'Pause' : 'Play',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'add_to_queue',
                child: Row(
                  children: [
                    Icon(
                      Icons.queue_music,
                      color: ThemeHelpers.getPrimaryColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                    Text(
                      'Add to Queue',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'add_to_favorites',
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      color: ThemeHelpers.getPrimaryColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                    Text(
                      'Add to Favorites',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.share2,
                      color: ThemeHelpers.getPrimaryColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              final audioController = ref.read(audioControllerProvider.notifier);
              final track = Track.fromMusicMap(music);
              
              switch (value) {
                case 'play':
                  if (isCurrentTrack) {
                    audioController.togglePlayPause();
                  } else {
                    // Play track and show mini player only (NOT full player)
                    audioController.playTrack(track);
                  }
                  break;
                case 'add_to_queue':
                  // Add track to queue
                  try {
                    final queueService = ref.read(playerQueueServiceProvider.notifier);
                    await queueService.appendTracks([track]);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added "$title" to queue'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add to queue'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                  break;
                case 'add_to_favorites':
                  // Toggle favorite
                  favoritesService.toggleFavorite(trackId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Removed from favorites'
                              : 'Added to favorites',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                  break;
                case 'share':
                  // Share track information
                  try {
                    final shareText = '$title${subtitle.isNotEmpty ? ' - $subtitle' : ''}';
                    // Use Flutter's share functionality if available, otherwise show snackbar
                    // For now, we'll use a simple approach with clipboard
                    if (context.mounted) {
                      // Copy to clipboard would require clipboard package
                      // For now, show a message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Share: $shareText'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to share'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                  break;
              }
            },
          ),
        ],
      ),
      onTap: onTap ??
          () {
            // Load and play track automatically (show mini player only, NOT full player)
            final trackId = music['id'] as String? ?? '';
            final isCurrentTrack = playerState.currentTrack?.id == trackId;
            
            if (isCurrentTrack) {
              // If same track, just toggle play/pause
              final audioController = ref.read(audioControllerProvider.notifier);
              audioController.togglePlayPause();
            } else {
              // Track recently played
              ref.read(recentlyPlayedServiceProvider.notifier).addTrack(trackId);
              
              // Load track using new audio controller (only shows mini player)
              final audioController = ref.read(audioControllerProvider.notifier);
              final track = Track.fromMusicMap(music);
              audioController.playTrack(track).catchError((e) {
                // Handle error silently - track loading failed
                // The error will be shown in the player state
              });
            }
          },
    );
  }
}

