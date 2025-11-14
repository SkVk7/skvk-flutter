/// Queue View Component
///
/// Shows current queue with drag-to-reorder, remove swipe, play index tap
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/models/audio/track.dart';
import 'package:skvk_application/core/services/audio/player_queue_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Queue View - Shows current queue with reorder support
class QueueView extends ConsumerStatefulWidget {
  const QueueView({super.key});

  @override
  ConsumerState<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends ConsumerState<QueueView> {
  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(playerQueueServiceProvider);
    final queueService = ref.read(playerQueueServiceProvider.notifier);

    if (queueState.queue.isEmpty) {
      return Center(
        child: Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 24),
          child: Text(
            'Queue is empty',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: queueState.queue.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        queueService.move(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final track = queueState.queue[index];
        final isCurrent = index == queueState.currentIndex;

        return _QueueItem(
          key: ValueKey(track.id),
          track: track,
          index: index,
          isCurrent: isCurrent,
          onTap: () => queueService.playIndex(index),
          onRemove: () => queueService.removeAt(index),
        );
      },
    );
  }
}

/// Queue Item Widget
class _QueueItem extends StatelessWidget {
  const _QueueItem({
    required super.key,
    required this.track,
    required this.index,
    required this.isCurrent,
    required this.onTap,
    required this.onRemove,
  });
  final Track track;
  final int index;
  final bool isCurrent;
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
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            color: isCurrent
                ? ThemeHelpers.getPrimaryColor(context)
                : ThemeHelpers.getPrimaryTextColor(context),
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
        trailing: isCurrent
            ? Icon(
                Icons.equalizer,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              )
            : Icon(
                LucideIcons.gripVertical,
                color: ThemeHelpers.getSecondaryTextColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
        onTap: onTap,
      ),
    );
  }
}
