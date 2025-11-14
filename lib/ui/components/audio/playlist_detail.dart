/// Playlist Detail Component
///
/// Shows tracks in playlist with reorder support and 'play all' button
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/models/audio/track.dart';
import 'package:skvk_application/core/services/audio/global_audio_player_controller.dart';
import 'package:skvk_application/core/services/audio/models/playlist.dart';
import 'package:skvk_application/core/services/audio/player_queue_service.dart';
import 'package:skvk_application/core/services/audio/playlist_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Playlist Detail - Shows tracks in playlist
class PlaylistDetail extends ConsumerStatefulWidget {
  const PlaylistDetail({
    required this.playlistId,
    super.key,
  });
  final String playlistId;

  @override
  ConsumerState<PlaylistDetail> createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends ConsumerState<PlaylistDetail> {
  Playlist? _playlist;
  List<Track> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final playlists = ref.read(playlistServiceProvider);

      _playlist = playlists.firstWhere(
        (p) => p.id == widget.playlistId,
        orElse: () => playlists.isNotEmpty
            ? playlists.first
            : throw Exception('Playlist not found'),
      );

      final playlistService = ref.read(playlistServiceProvider.notifier);
      _tracks = await playlistService.getTracksForPlaylist(widget.playlistId);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playAll() async {
    if (_tracks.isEmpty) return;

    final queueService = ref.read(playerQueueServiceProvider.notifier);
    final playerController = ref.read(globalAudioPlayerProvider.notifier);

    await queueService.loadQueue(_tracks);

    // Play first track
    final currentTrack = queueService.currentTrack;
    if (currentTrack != null) {
      final audioTrack = AudioTrack(
        id: currentTrack.id,
        title: currentTrack.title,
        artist: currentTrack.subtitle,
        subtitle: currentTrack.subtitle,
        coverArtUrl: currentTrack.coverUrl,
        audioUrl: currentTrack.sourceUrl,
        duration: currentTrack.duration,
      );
      await playerController.loadTrack(audioTrack);
      await playerController.playPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 24),
          child: CircularProgressIndicator(
            color: ThemeHelpers.getPrimaryColor(context),
            strokeWidth: ResponsiveSystem.borderWidth(context, baseWidth: 3),
          ),
        ),
      );
    }

    if (_playlist == null) {
      return Center(
        child: Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 24),
          child: Text(
            'Playlist not found',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Play all button
        Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _tracks.isEmpty ? null : _playAll,
              icon: Icon(
                LucideIcons.play,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              label: Text(
                'Play All',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelpers.getPrimaryColor(context),
                foregroundColor: ThemeHelpers.getPrimaryTextColor(context),
                padding: ResponsiveSystem.symmetric(
                  context,
                  horizontal:
                      ResponsiveSystem.spacing(context, baseSpacing: 24),
                  vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: ResponsiveSystem.circular(
                    context,
                    baseRadius: 12,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Track list
        Expanded(
          child: _tracks.isEmpty
              ? Center(
                  child: Padding(
                    padding: ResponsiveSystem.all(context, baseSpacing: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.music,
                          size:
                              ResponsiveSystem.iconSize(context, baseSize: 48),
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                        ResponsiveSystem.sizedBox(
                          context,
                          height: ResponsiveSystem.spacing(context,
                              baseSpacing: 16,),
                        ),
                        Text(
                          'No tracks in playlist',
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context,
                                baseSize: 16,),
                            color: ThemeHelpers.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: _tracks.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex--;
                    final playlistService =
                        ref.read(playlistServiceProvider.notifier);
                    await playlistService.reorderPlaylist(
                      widget.playlistId,
                      oldIndex,
                      newIndex,
                    );
                    await _loadPlaylist();
                  },
                  itemBuilder: (context, index) {
                    final track = _tracks[index];
                    return _PlaylistTrackItem(
                      key: ValueKey(track.id),
                      track: track,
                      onTap: () async {
                        final queueService =
                            ref.read(playerQueueServiceProvider.notifier);
                        final playerController =
                            ref.read(globalAudioPlayerProvider.notifier);

                        await queueService.loadQueue(_tracks,
                            startIndex: index,);

                        // Play track
                        final audioTrack = AudioTrack(
                          id: track.id,
                          title: track.title,
                          artist: track.subtitle,
                          subtitle: track.subtitle,
                          coverArtUrl: track.coverUrl,
                          audioUrl: track.sourceUrl,
                          duration: track.duration,
                        );
                        await playerController.loadTrack(audioTrack);
                        await playerController.playPause();
                      },
                      onRemove: () async {
                        final playlistService =
                            ref.read(playlistServiceProvider.notifier);
                        await playlistService.removeFromPlaylist(
                            widget.playlistId, track.id,);
                        await _loadPlaylist();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Playlist Track Item Widget
class _PlaylistTrackItem extends StatelessWidget {
  const _PlaylistTrackItem({
    required super.key,
    required this.track,
    required this.onTap,
    required this.onRemove,
  });
  final Track track;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: ResponsiveSystem.symmetric(
          context,
          horizontal: ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        decoration: BoxDecoration(
          color: ThemeHelpers.getErrorColor(context).withValues(alpha: 0.2),
        ),
        child: Icon(
          Icons.delete,
          color: ThemeHelpers.getErrorColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 24),
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: ListTile(
        leading: Container(
          width: ResponsiveSystem.spacing(context, baseSpacing: 48),
          height: ResponsiveSystem.spacing(context, baseSpacing: 48),
          decoration: BoxDecoration(
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
            color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.2),
            image: (track.coverUrl?.isNotEmpty ?? false)
                ? DecorationImage(
                    image: NetworkImage(track.coverUrl!),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  )
                : null,
          ),
          child: (track.coverUrl?.isEmpty ?? true)
              ? Icon(
                  Icons.music_note,
                  color: ThemeHelpers.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                )
              : null,
        ),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            fontWeight: FontWeight.w600,
            color: ThemeHelpers.getPrimaryTextColor(context),
          ),
        ),
        subtitle: Text(
          track.subtitle ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            color: ThemeHelpers.getSecondaryTextColor(context),
          ),
        ),
        trailing: Icon(
          LucideIcons.gripVertical,
          color: ThemeHelpers.getSecondaryTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 20),
        ),
        onTap: onTap,
      ),
    );
  }
}
