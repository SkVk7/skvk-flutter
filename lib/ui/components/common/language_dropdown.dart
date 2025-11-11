/// Language Dropdown Component
///
/// Reusable language selection dropdown for app bars
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

/// Language Dropdown - Dropdown for language selection
@immutable
class LanguageDropdown extends StatelessWidget {
  final ValueChanged<String>? onLanguageChanged;

  const LanguageDropdown({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Language',
      // Remove background circle, only icon, size +8% (24 * 1.08 = 25.92)
      icon: Icon(
        Icons.public,
        color: ThemeHelpers.getAppBarTextColor(context),
        size: ResponsiveSystem.iconSize(context, baseSize: 25.92),
      ),
      onSelected: onLanguageChanged,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Icon(
                Icons.public,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              Text(
                'English',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'hi',
          child: Row(
            children: [
              Icon(
                Icons.public,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              Text(
                'हिंदी',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'te',
          child: Row(
            children: [
              Icon(
                Icons.public,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              Text(
                'తెలుగు',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

