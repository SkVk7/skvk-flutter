/// Standard App Bar Component
///
/// A reusable app bar with title, back button, and action buttons
/// Used across all screens for consistent navigation and controls
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../common/index.dart';
import '../../../core/services/language/translation_service.dart';
import '../../../core/logging/logging_helper.dart';
import '../../utils/screen_handlers.dart';

/// Standard App Bar - Consistent app bar across all screens
/// 
/// Features:
/// - Title with optional icon
/// - Back button (optional)
/// - Language dropdown
/// - Theme dropdown
/// - Profile photo
/// - Responsive sizing
class StandardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final IconData? titleIcon;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;
  final double? toolbarHeight;

  const StandardAppBar({
    super.key,
    required this.title,
    this.titleIcon,
    this.showBackButton = true,
    this.onBackPressed,
    this.onProfileTap,
    this.toolbarHeight,
  });

  @override
  Size get preferredSize {
    // Use base value that will be scaled by ResponsiveSystem in build method
    // The actual height is controlled by toolbarHeight in AppBar which uses ResponsiveSystem
    return Size.fromHeight(toolbarHeight ?? 60);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationService = ref.watch(translationServiceProvider);

    return AppBar(
      elevation: 0,
      backgroundColor: ThemeHelpers.getBackgroundColor(context),
      toolbarHeight: ResponsiveSystem.spacing(
        context,
        baseSpacing: toolbarHeight ?? 60,
      ),
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: ResponsiveSystem.iconSize(context, baseSize: 24),
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Row(
        children: [
          if (titleIcon != null) ...[
            Icon(
              titleIcon,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
          ],
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Language Dropdown Widget
        LanguageDropdown(
          onLanguageChanged: (value) {
            LoggingHelper.logInfo('Language changed to: $value');
            ScreenHandlers.handleLanguageChange(ref, value);
          },
        ),
        // Theme Dropdown Widget
        ThemeDropdown(
          onThemeChanged: (value) {
            LoggingHelper.logInfo('Theme changed to: $value');
            ScreenHandlers.handleThemeChange(ref, value);
          },
        ),
        // Profile Photo with Hover Effect
        Padding(
          padding: ResponsiveSystem.only(
            context,
            right: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          child: ProfilePhoto(
            key: const ValueKey('profile_icon'),
            onTap: onProfileTap ??
                () {
                  // Default profile tap behavior
                  // Can be overridden by parent
                },
            tooltip: translationService.translateContent(
              'my_profile',
              fallback: 'My Profile',
            ),
          ),
        ),
      ],
    );
  }

}

