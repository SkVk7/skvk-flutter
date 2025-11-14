/// Time Selector Button Component
///
/// Reusable button for selecting time/duration with display
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Time Selector Button - Button for selecting and displaying time/duration
class TimeSelectorButton extends StatelessWidget {
  const TimeSelectorButton({
    required this.translationService,
    required this.duration,
    required this.onTap,
    super.key,
    this.customText,
  });
  final TranslationService translationService;
  final Duration duration;
  final VoidCallback onTap;
  final String? customText;

  String _formatDuration(Duration duration) {
    if (duration.inSeconds == 0) {
      return translationService.translateContent(
        'set_time',
        fallback: 'Set Time',
      );
    }
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveSystem.symmetric(
          context,
          horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
          vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
        ),
        decoration: BoxDecoration(
          color:
              ThemeHelpers.getPrimaryTextColor(context).withValues(alpha: 0.1),
          borderRadius: ResponsiveSystem.circular(
            context,
            baseRadius: 12,
          ),
          border: Border.all(
            color: ThemeHelpers.getPrimaryTextColor(context)
                .withValues(alpha: 0.3),
            width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              color: ThemeHelpers.getPrimaryTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 18),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            Text(
              customText ?? _formatDuration(duration),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(
                  context,
                  baseSize: 14,
                ),
                color: ThemeHelpers.getPrimaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
