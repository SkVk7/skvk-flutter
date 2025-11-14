/// Audio Sections Components
///
/// Reusable section builders for audio screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/services/audio/favorites_service.dart';
import 'package:skvk_application/core/services/audio/player_queue_service.dart';
import 'package:skvk_application/core/services/audio/recently_played_service.dart';
import 'package:skvk_application/ui/components/audio/audio_horizontal_track_card.dart';
import 'package:skvk_application/ui/components/content/horizontal_section.dart';
import 'package:skvk_application/ui/components/content/horizontal_skeleton_section.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Recently Played Section Builder
class RecentlyPlayedSection extends ConsumerWidget {
  const RecentlyPlayedSection({
    required this.musicList,
    required this.onNavigateToFilteredList,
    super.key,
  });

  final List<Map<String, dynamic>> musicList;
  final void Function(String title, List<Map<String, dynamic>> tracks)
      onNavigateToFilteredList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayed = ref.watch(recentlyPlayedServiceProvider);

    if (recentlyPlayed.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final recentlyPlayedTracks = recentlyPlayed
        .map(
          (trackId) => musicList.firstWhere(
            (track) => track['id'] == trackId,
            orElse: () => <String, dynamic>{},
          ),
        )
        .where((track) => track.isNotEmpty)
        .take(5)
        .toList();

    if (recentlyPlayedTracks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final trackCards = recentlyPlayedTracks
        .map((track) => AudioHorizontalTrackCard(music: track))
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Recently Played',
        icon: Icons.history,
        items: trackCards,
        totalCount: recentlyPlayed.length,
        onSeeAll: recentlyPlayed.length > 5
            ? () {
                final allRecentlyPlayed = recentlyPlayed
                    .map(
                      (trackId) => musicList.firstWhere(
                        (track) => track['id'] == trackId,
                        orElse: () => <String, dynamic>{},
                      ),
                    )
                    .where((track) => track.isNotEmpty)
                    .toList();
                onNavigateToFilteredList('Recently Played', allRecentlyPlayed);
              }
            : null,
      ),
    );
  }
}

/// Favorites Section Builder
class FavoritesSection extends ConsumerWidget {
  const FavoritesSection({
    required this.musicList,
    required this.onNavigateToFilteredList,
    super.key,
  });

  final List<Map<String, dynamic>> musicList;
  final void Function(String title, List<Map<String, dynamic>> tracks)
      onNavigateToFilteredList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesServiceProvider);

    if (favorites.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final favoriteTracks = musicList
        .where((track) => favorites.contains(track['id']))
        .take(5)
        .toList();

    if (favoriteTracks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final trackCards = favoriteTracks
        .map((track) => AudioHorizontalTrackCard(music: track))
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Favorites',
        icon: Icons.favorite,
        items: trackCards,
        totalCount: favorites.length,
        onSeeAll: favorites.length > 5
            ? () {
                final allFavorites = musicList
                    .where((track) => favorites.contains(track['id']))
                    .toList();
                onNavigateToFilteredList('Favorites', allFavorites);
              }
            : null,
      ),
    );
  }
}

/// Most Played Section Builder
class MostPlayedSection extends ConsumerWidget {
  const MostPlayedSection({
    required this.musicList,
    required this.mostPlayed,
    required this.isLoading,
    required this.onNavigateToFilteredList,
    super.key,
  });

  final List<Map<String, dynamic>> musicList;
  final List<Map<String, dynamic>> mostPlayed;
  final bool isLoading;
  final void Function(String title, List<Map<String, dynamic>> tracks)
      onNavigateToFilteredList;

  String _formatPlayCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Map<String, dynamic>? _getTrackById(String trackId) {
    try {
      return musicList.firstWhere((track) => track['id'] == trackId);
    } on Exception {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const HorizontalSkeletonSection(
        title: 'Most Played',
        icon: Icons.trending_up,
      );
    }

    // Don't show if music list is empty (data not loaded yet)
    if (musicList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (mostPlayed.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final mostPlayedTracks = mostPlayed
        .map((item) {
          final trackId = item['id'] as String? ?? '';
          final playCount = item['count'] as int? ?? 0;
          final track = _getTrackById(trackId);
          if (track != null) {
            track['playCount'] = playCount;
          }
          return track;
        })
        .whereType<Map<String, dynamic>>()
        .take(5)
        .toList();

    if (mostPlayedTracks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final trackCards = mostPlayedTracks.map((track) {
      final playCount = track['playCount'] as int? ?? 0;
      return Stack(
        children: [
          AudioHorizontalTrackCard(music: track),
          if (playCount > 0)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                margin: ResponsiveSystem.all(context, baseSpacing: 4),
                padding: ResponsiveSystem.symmetric(
                  context,
                  horizontal: ResponsiveSystem.spacing(context, baseSpacing: 6),
                  vertical: ResponsiveSystem.spacing(context, baseSpacing: 2),
                ),
                decoration: BoxDecoration(
                  color: ThemeHelpers.getPrimaryColor(context),
                  borderRadius: BorderRadius.circular(
                    ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: ThemeHelpers.getAppBarTextColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 12),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 2),
                    ),
                    Text(
                      _formatPlayCount(playCount),
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 10),
                        fontWeight: FontWeight.bold,
                        color: ThemeHelpers.getAppBarTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }).toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Most Played',
        icon: Icons.trending_up,
        items: trackCards,
        totalCount: mostPlayed.length,
        onSeeAll: mostPlayed.length > 5
            ? () {
                final allMostPlayed = mostPlayed
                    .map((item) {
                      final trackId = item['id'] as String? ?? '';
                      final playCount = item['count'] as int? ?? 0;
                      final track = _getTrackById(trackId);
                      if (track != null) {
                        track['playCount'] = playCount;
                      }
                      return track;
                    })
                    .whereType<Map<String, dynamic>>()
                    .toList();
                onNavigateToFilteredList('Most Played', allMostPlayed);
              }
            : null,
      ),
    );
  }
}

/// Trending Section Builder
class TrendingSection extends ConsumerWidget {
  const TrendingSection({
    required this.musicList,
    required this.trending,
    required this.isLoading,
    required this.onNavigateToFilteredList,
    super.key,
  });

  final List<Map<String, dynamic>> musicList;
  final List<Map<String, dynamic>> trending;
  final bool isLoading;
  final void Function(String title, List<Map<String, dynamic>> tracks)
      onNavigateToFilteredList;

  Map<String, dynamic>? _getTrackById(String trackId) {
    try {
      return musicList.firstWhere((track) => track['id'] == trackId);
    } on Exception {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const HorizontalSkeletonSection(
        title: 'Trending Now',
        icon: Icons.local_fire_department,
      );
    }

    // Don't show if music list is empty (data not loaded yet)
    if (musicList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (trending.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final trendingTracks = trending
        .map((item) {
          final trackId = item['id'] as String? ?? '';
          return _getTrackById(trackId);
        })
        .whereType<Map<String, dynamic>>()
        .take(5)
        .toList();

    if (trendingTracks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final trackCards = trendingTracks
        .map((track) => AudioHorizontalTrackCard(music: track))
        .toList();

    return HorizontalSection(
      config: HorizontalSectionConfig(
        title: 'Trending Now',
        icon: Icons.local_fire_department,
        items: trackCards,
        totalCount: trending.length,
        onSeeAll: trending.length > 5
            ? () {
                final allTrending = trending
                    .map((item) {
                      final trackId = item['id'] as String? ?? '';
                      return _getTrackById(trackId);
                    })
                    .whereType<Map<String, dynamic>>()
                    .toList();
                onNavigateToFilteredList('Trending Now', allTrending);
              }
            : null,
      ),
    );
  }
}

/// Queued Songs Section Builder
class QueuedSongsSection extends ConsumerWidget {
  const QueuedSongsSection({
    required this.onNavigateToFilteredList,
    super.key,
  });

  final void Function(String title, List<Map<String, dynamic>> tracks)
      onNavigateToFilteredList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(playerQueueServiceProvider);

    if (queueState.queue.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final queuedTracks = queueState.queue
        .map(
          (track) => {
            'id': track.id,
            'title': track.title,
            'subtitle': (track.subtitle?.isNotEmpty ?? false)
                ? track.subtitle!
                : ((track.album?.isNotEmpty ?? false) ? track.album! : ''),
            'artist': track.subtitle,
            'coverArtUrl': track.coverUrl,
            'audioUrl': track.sourceUrl,
          },
        )
        .take(5)
        .toList();

    if (queuedTracks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final trackCards = queuedTracks.asMap().entries.map((entry) {
      final track = entry.value;
      final isCurrentTrack = queueState.currentIndex ==
          queueState.queue.indexWhere((t) => t.id == track['id']);
      return Stack(
        children: [
          AudioHorizontalTrackCard(music: track),
          if (isCurrentTrack)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: ResponsiveSystem.all(context, baseSpacing: 4),
                decoration: BoxDecoration(
                  color: ThemeHelpers.getPrimaryColor(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: ThemeHelpers.getAppBarTextColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 12),
                ),
              ),
            ),
        ],
      );
    }).toList();

    // Custom title with count badge
    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Queued Songs',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
            fontWeight: FontWeight.bold,
            color: ThemeHelpers.getPrimaryTextColor(context),
          ),
        ),
        if (queueState.queue.length > 1)
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            child: Container(
              padding: ResponsiveSystem.symmetric(
                context,
                horizontal: ResponsiveSystem.spacing(context, baseSpacing: 6),
                vertical: ResponsiveSystem.spacing(context, baseSpacing: 2),
              ),
              decoration: BoxDecoration(
                color: ThemeHelpers.getPrimaryColor(context)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
              ),
              child: Text(
                '${queueState.queue.length}',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  fontWeight: FontWeight.w600,
                  color: ThemeHelpers.getPrimaryColor(context),
                ),
              ),
            ),
          ),
      ],
    );

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
                      Icons.queue_music,
                      color: ThemeHelpers.getPrimaryColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    titleWidget,
                  ],
                ),
                if (queueState.queue.length > 5)
                  TextButton(
                    onPressed: () {
                      final allQueued = queueState.queue
                          .map(
                            (track) => {
                              'id': track.id,
                              'title': track.title,
                              'subtitle': (track.subtitle?.isNotEmpty ?? false)
                                  ? track.subtitle!
                                  : ((track.album?.isNotEmpty ?? false)
                                      ? track.album!
                                      : ''),
                              'artist': track.subtitle,
                              'coverArtUrl': track.coverUrl,
                              'audioUrl': track.sourceUrl,
                            },
                          )
                          .toList();
                      onNavigateToFilteredList('Queued Songs', allQueued);
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 14),
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
              itemCount: trackCards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                  child: trackCards[index],
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
}
