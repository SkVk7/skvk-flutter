/// Theme Dropdown Component
///
/// Reusable theme selection dropdown for app bars
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Theme Dropdown - Dropdown for theme selection
@immutable
class ThemeDropdown extends StatelessWidget {
  const ThemeDropdown({
    super.key,
    this.onThemeChanged,
  });
  final ValueChanged<String>? onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Theme',
      icon: Icon(
        Icons.palette,
        color: ThemeHelpers.getAppBarTextColor(context),
        size: ResponsiveSystem.iconSize(context, baseSize: 25.92),
      ),
      onSelected: onThemeChanged,
      itemBuilder: (context) => [
        // Light Mode
        PopupMenuItem<String>(
          value: 'light',
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              Text(
                'Light',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Dark Mode
        PopupMenuItem<String>(
          value: 'dark',
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              Text(
                'Dark',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // System Mode
        PopupMenuItem<String>(
          value: 'system',
          child: Row(
            children: [
              Icon(
                Icons.settings_system_daydream,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              Text(
                'System',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
