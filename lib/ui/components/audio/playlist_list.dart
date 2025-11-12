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
import 'playlist_detail.dart';
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
            // Navigate to playlist detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistDetail(playlistId: playlist.id),
              ),
            );
          },
          onRename: () async {
            // Show rename dialog
            await PlaylistList._showRenameDialog(context, ref, playlist);
          },
          onDelete: () async {
            await playlistService.deletePlaylist(playlist.id);
          },
          onShare: () async {
            try {
              // Export playlist as JSON (for future use with share_plus package)
              await playlistService.exportPlaylist(playlist.id);
              // For now, show a snackbar with the playlist name
              // In a full implementation, this could use share_plus package
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Share playlist: ${playlist.name}'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to share playlist'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  /// Show rename dialog for playlist
  static Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final playlistService = ref.read(playlistServiceProvider.notifier);
    final textController = TextEditingController(text: playlist.name);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: ResponsiveSystem.all(context, baseSpacing: 24),
          decoration: BoxDecoration(
            color: ThemeHelpers.getSurfaceColor(context),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Rename Playlist',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              // Text field
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter playlist name',
                  border: OutlineInputBorder(
                    borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                    borderSide: BorderSide(
                      color: ThemeHelpers.getBorderColor(context),
                      width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                    borderSide: BorderSide(
                      color: ThemeHelpers.getBorderColor(context),
                      width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                    borderSide: BorderSide(
                      color: ThemeHelpers.getPrimaryColor(context),
                      width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
                    ),
                  ),
                  filled: true,
                  fillColor: ThemeHelpers.getBackgroundColor(context),
                  contentPadding: ResponsiveSystem.all(context, baseSpacing: 16),
                ),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(dialogContext).pop(value.trim());
                  }
                },
              ),
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24),
              ),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(
                    context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final newName = textController.text.trim();
                      if (newName.isNotEmpty) {
                        Navigator.of(dialogContext).pop(newName);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeHelpers.getPrimaryColor(context),
                      foregroundColor: ThemeHelpers.getPrimaryTextColor(context),
                      padding: ResponsiveSystem.symmetric(
                        context,
                        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
                        vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
                      ),
                    ),
                    child: Text(
                      'Rename',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Handle result
    if (result != null && result.isNotEmpty && result != playlist.name) {
      try {
        await playlistService.renamePlaylist(playlist.id, result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playlist renamed to "$result"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to rename playlist'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
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

