/// Empty State Widget Component
///
/// Reusable empty state display with optional action
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Empty State Widget - Displays empty state with icon, title, subtitle, and optional action
@immutable
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.action,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: ResponsiveSystem.iconSize(context, baseSize: 64),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                fontWeight: FontWeight.w600,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              ResponsiveSystem.sizedBox(context, height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              ResponsiveSystem.sizedBox(context, height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
