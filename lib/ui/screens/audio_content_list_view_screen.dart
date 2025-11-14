/// Audio Content List View Screen
///
/// Screen for displaying a filtered list of audio content items
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart';
import 'package:skvk_application/core/models/audio/track.dart';
import 'package:skvk_application/core/services/audio/audio_controller.dart';
import 'package:skvk_application/core/services/audio/favorites_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Audio Content List View Screen - Shows filtered list of tracks
class AudioContentListViewScreen extends ConsumerWidget {
  const AudioContentListViewScreen({
    required this.title,
    required this.tracks,
    super.key,
  });
  final String title;
  final List<Map<String, dynamic>> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
    );
    final playerState = ref.watch(audioControllerProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: ResponsiveSystem.symmetric(
                  context,
                  horizontal:
                      ResponsiveSystem.spacing(context, baseSpacing: 16),
                  vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.arrowLeft,
                        color: ThemeHelpers.getAppBarTextColor(context),
                        size: ResponsiveSystem.iconSize(context, baseSize: 24),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 22),
                          fontWeight: FontWeight.bold,
                          color: ThemeHelpers.getAppBarTextColor(context),
                        ),
                      ),
                    ),
                    Text(
                      '${tracks.length}',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 16),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Track List
              Expanded(
                child: tracks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_off,
                              size: ResponsiveSystem.iconSize(context,
                                  baseSize: 64,),
                              color:
                                  ThemeHelpers.getSecondaryTextColor(context),
                            ),
                            ResponsiveSystem.sizedBox(
                              context,
                              height: ResponsiveSystem.spacing(context,
                                  baseSpacing: 16,),
                            ),
                            Text(
                              'No tracks available',
                              style: TextStyle(
                                fontSize: ResponsiveSystem.fontSize(context,
                                    baseSize: 18,),
                                color:
                                    ThemeHelpers.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: ResponsiveSystem.symmetric(
                          context,
                          horizontal: ResponsiveSystem.spacing(context,
                              baseSpacing: 16,),
                          vertical:
                              ResponsiveSystem.spacing(context, baseSpacing: 8),
                        ),
                        itemCount: tracks.length,
                        itemBuilder: (context, index) {
                          final track = tracks[index];
                          final trackId = track['id'] as String? ?? '';
                          final isCurrentTrack =
                              playerState.currentTrack?.id == trackId;
                          final isPlaying =
                              isCurrentTrack && playerState.isPlaying;
                          final favorites = ref.watch(favoritesServiceProvider);
                          final isFavorite = favorites.contains(trackId);

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(
                              bottom: ResponsiveSystem.spacing(context,
                                  baseSpacing: 12,),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveSystem.spacing(context,
                                    baseSpacing: 16,),
                              ),
                            ),
                            color: ThemeHelpers.getSurfaceColor(context)
                                .withValues(alpha: 0.9),
                            child: InkWell(
                              onTap: () {
                                if (!context.mounted) return;
                                final audioController =
                                    ref.read(audioControllerProvider.notifier);
                                final trackObj = Track.fromMusicMap(track);
                                audioController
                                    .playTrack(trackObj)
                                    .catchError((e) {});
                              },
                              borderRadius: BorderRadius.circular(
                                ResponsiveSystem.spacing(context,
                                    baseSpacing: 16,),
                              ),
                              child: Padding(
                                padding: ResponsiveSystem.all(context,
                                    baseSpacing: 16,),
                                child: Row(
                                  children: [
                                    // Artwork
                                    Container(
                                      width: ResponsiveSystem.spacing(context,
                                          baseSpacing: 64,),
                                      height: ResponsiveSystem.spacing(context,
                                          baseSpacing: 64,),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveSystem.spacing(context,
                                              baseSpacing: 12,),
                                        ),
                                        color: ThemeHelpers.getPrimaryColor(
                                                context,)
                                            .withValues(alpha: 0.2),
                                        image: track['coverArtUrl'] != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    track['coverArtUrl']
                                                        as String,),
                                                fit: BoxFit.cover,
                                                onError: (_, __) {},
                                              )
                                            : null,
                                      ),
                                      child: track['coverArtUrl'] == null
                                          ? Icon(
                                              Icons.music_note,
                                              color:
                                                  ThemeHelpers.getPrimaryColor(
                                                      context,),
                                              size: ResponsiveSystem.iconSize(
                                                  context,
                                                  baseSize: 32,),
                                            )
                                          : null,
                                    ),
                                    ResponsiveSystem.sizedBox(
                                      context,
                                      width: ResponsiveSystem.spacing(context,
                                          baseSpacing: 16,),
                                    ),
                                    // Track Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Tooltip(
                                            message:
                                                track['title'] as String? ?? '',
                                            preferBelow: false,
                                            waitDuration: const Duration(
                                                milliseconds: 500,),
                                            child: Text(
                                              track['title'] as String? ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize:
                                                    ResponsiveSystem.fontSize(
                                                        context,
                                                        baseSize: 16,),
                                                fontWeight: isCurrentTrack
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: isCurrentTrack
                                                    ? ThemeHelpers
                                                        .getPrimaryColor(
                                                            context,)
                                                    : ThemeHelpers
                                                        .getPrimaryTextColor(
                                                            context,),
                                              ),
                                            ),
                                          ),
                                          ResponsiveSystem.sizedBox(
                                            context,
                                            height: ResponsiveSystem.spacing(
                                                context,
                                                baseSpacing: 4,),
                                          ),
                                          Tooltip(
                                            message:
                                                track['subtitle'] as String? ??
                                                    '',
                                            preferBelow: false,
                                            waitDuration: const Duration(
                                                milliseconds: 500,),
                                            child: Text(
                                              track['subtitle'] as String? ??
                                                  '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize:
                                                    ResponsiveSystem.fontSize(
                                                        context,
                                                        baseSize: 14,),
                                                color: ThemeHelpers
                                                    .getSecondaryTextColor(
                                                        context,),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Favorite Star Button
                                    IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: isFavorite
                                            ? ThemeHelpers.getPrimaryColor(
                                                context,)
                                            : ThemeHelpers
                                                .getSecondaryTextColor(context),
                                        size: ResponsiveSystem.iconSize(context,
                                            baseSize: 24,),
                                      ),
                                      onPressed: () {
                                        if (!context.mounted) return;
                                        ref
                                            .read(favoritesServiceProvider
                                                .notifier,)
                                            .toggleFavorite(trackId);
                                      },
                                      tooltip: isFavorite
                                          ? 'Remove from favorites'
                                          : 'Add to favorites',
                                    ),
                                    // Play/Pause Indicator
                                    if (isPlaying)
                                      Icon(
                                        Icons.equalizer,
                                        color: ThemeHelpers.getPrimaryColor(
                                            context,),
                                        size: ResponsiveSystem.iconSize(context,
                                            baseSize: 24,),
                                      )
                                    else
                                      Icon(
                                        Icons.play_circle_outline,
                                        color: ThemeHelpers.getPrimaryColor(
                                            context,),
                                        size: ResponsiveSystem.iconSize(context,
                                            baseSize: 32,),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Bottom padding for mini player
              if (playerState.showMiniPlayer)
                SizedBox(
                  height: ResponsiveSystem.responsive(
                        context,
                        mobile:
                            ResponsiveSystem.spacing(context, baseSpacing: 88),
                        tablet:
                            ResponsiveSystem.spacing(context, baseSpacing: 96),
                        desktop:
                            ResponsiveSystem.spacing(context, baseSpacing: 104),
                        largeDesktop:
                            ResponsiveSystem.spacing(context, baseSpacing: 112),
                      ) +
                      MediaQuery.of(context).padding.bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
