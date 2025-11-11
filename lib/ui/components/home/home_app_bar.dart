/// Home App Bar Component
///
/// Reusable SliverAppBar for home screen with title, icon, and action buttons
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../common/index.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/language/translation_service.dart';
import '../../../core/logging/logging_helper.dart';
import '../../utils/screen_handlers.dart';

/// Home App Bar - SliverAppBar with title, icon, and action buttons
class HomeAppBar extends ConsumerWidget {
  final VoidCallback? onProfileTap;
  final Function(String)? onLanguageChanged;
  final Function(String)? onThemeChanged;

  const HomeAppBar({
    super.key,
    this.onProfileTap,
    this.onLanguageChanged,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationService = ref.watch(translationServiceProvider);

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: ThemeHelpers.getBackgroundColor(context),
      // Responsive toolbar height
      toolbarHeight: ResponsiveSystem.responsive(
        context,
        mobile: ResponsiveSystem.spacing(context, baseSpacing: 56),
        tablet: ResponsiveSystem.spacing(context, baseSpacing: 64),
        desktop: ResponsiveSystem.spacing(context, baseSpacing: 72),
        largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 80),
      ),
      title: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            // Responsive icon size
            size: ResponsiveSystem.responsive(
              context,
              mobile: ResponsiveSystem.iconSize(context, baseSize: 18),
              tablet: ResponsiveSystem.iconSize(context, baseSize: 20),
              desktop: ResponsiveSystem.iconSize(context, baseSize: 22),
              largeDesktop: ResponsiveSystem.iconSize(context, baseSize: 24),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            width: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          Flexible(
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                // Responsive typography: app title scales with screen size
                fontSize: ResponsiveSystem.responsive(
                  context,
                  mobile: ResponsiveSystem.fontSize(context, baseSize: 20),
                  tablet: ResponsiveSystem.fontSize(context, baseSize: 22),
                  desktop: ResponsiveSystem.fontSize(context, baseSize: 24),
                  largeDesktop: ResponsiveSystem.fontSize(context, baseSize: 26),
                ),
                fontWeight: FontWeight.w600,
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
            if (onLanguageChanged != null) {
              onLanguageChanged!(value);
            } else {
              ScreenHandlers.handleLanguageChange(ref, value);
            }
          },
        ),
        // Theme Dropdown Widget
        ThemeDropdown(
          onThemeChanged: (value) {
            LoggingHelper.logInfo('Theme changed to: $value');
            if (onThemeChanged != null) {
              onThemeChanged!(value);
            } else {
              ScreenHandlers.handleThemeChange(ref, value);
            }
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
                  // Default empty handler
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

