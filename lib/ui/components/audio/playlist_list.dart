/// Playlist List Component
///
/// List of playlists with counts, overflow menu (rename, delete, share)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/services/audio/playlist_service.dart';
import '../../../core/services/audio/models/playlist.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Playlist List - Shows all playlists
class PlaylistList extends ConsumerWidget {
  const PlaylistList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistServiceProvider);
    final playlistService = ref.read(playlistServiceProvider.notifier);

    if (playlists.isEmpty) {
      return Center(
        child: Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.music,
                size: ResponsiveSystem.iconSize(context, baseSize: 48),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              Text(
                'No playlists yet',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return _PlaylistItem(
          playlist: playlist,
          onTap: () {
            // TODO: Navigate to playlist detail
          },
          onRename: () async {
            // TODO: Show rename dialog
          },
          onDelete: () async {
            await playlistService.deletePlaylist(playlist.id);
          },
          onShare: () async {
            // TODO: Share playlist
            await playlistService.exportPlaylist(playlist.id);
            // TODO: Implement share functionality
          },
        );
      },
    );
  }
}

/// Playlist Item Widget
class _PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _PlaylistItem({
    required this.playlist,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: ResponsiveSystem.spacing(context, baseSpacing: 48),
        height: ResponsiveSystem.spacing(context, baseSpacing: 48),
        decoration: BoxDecoration(
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
          color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.2),
        ),
        child: Icon(
          LucideIcons.music,
          color: ThemeHelpers.getPrimaryColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 24),
        ),
      ),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
          fontWeight: FontWeight.w600,
          color: ThemeHelpers.getPrimaryTextColor(context),
        ),
      ),
      subtitle: Text(
        '${playlist.trackCount} tracks',
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
          color: ThemeHelpers.getSecondaryTextColor(context),
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: ThemeHelpers.getSecondaryTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 20),
        ),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'rename',
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: ThemeHelpers.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                Text(
                  'Rename',
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
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: ThemeHelpers.getErrorColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    color: ThemeHelpers.getErrorColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'rename':
              onRename();
              break;
            case 'share':
              onShare();
              break;
            case 'delete':
              onDelete();
              break;
          }
        },
      ),
      onTap: onTap,
    );
  }
}

