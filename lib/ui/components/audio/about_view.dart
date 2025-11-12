/// About View Component
///
/// Shows track description/metadata in the fullscreen player
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/models/audio/track.dart';

/// About View - Shows track metadata and description
class AboutView extends StatelessWidget {
  final Track? track;

  const AboutView({
    super.key,
    this.track,
  });

  @override
  Widget build(BuildContext context) {
    if (track == null) {
      return Center(
        child: Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 24),
          child: Text(
            'No track information available',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
        ),
      );
    }

    final metadata = track!.metadata ?? {};

    return SingleChildScrollView(
      padding: ResponsiveSystem.all(context, baseSpacing: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            track!.title,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
              fontWeight: FontWeight.bold,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          // Subtitle/Artist
          if ((track!.subtitle?.isNotEmpty ?? false))
            Text(
              track!.subtitle!,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
          // Album
          if ((track!.album?.isNotEmpty ?? false)) ...[
            Text(
              'Album',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                fontWeight: FontWeight.w600,
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 4),
            ),
            Text(
              track!.album!,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
          ],
          // Duration
          Text(
            'Duration',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              fontWeight: FontWeight.w600,
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 4),
          ),
          Text(
            _formatDuration(track!.duration ?? Duration.zero),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          // Metadata
          if (metadata.isNotEmpty) ...[
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            Text(
              'Additional Information',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                fontWeight: FontWeight.w600,
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            ...metadata.entries.map((entry) => Padding(
                  padding: ResponsiveSystem.only(
                    context,
                    bottom: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${entry.key}:',
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                            fontWeight: FontWeight.w600,
                            color: ThemeHelpers.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                            color: ThemeHelpers.getPrimaryTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

