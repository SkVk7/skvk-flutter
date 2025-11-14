/// Sliver App Bar with Hero Section Component
///
/// Reusable SliverAppBar with hero section for screens like matching
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Sliver App Bar with Hero Section - Reusable SliverAppBar with hero background
class SliverAppBarWithHero extends ConsumerWidget {
  const SliverAppBarWithHero({
    required this.title,
    super.key,
    this.subtitle,
    this.titleIcon,
    this.heroBackground,
    this.expandedHeight,
    this.floating = true,
    this.pinned = true,
    this.snap = true,
    this.leadingIcon,
    this.onLeadingTap,
    this.onProfileTap,
    this.onLanguageChanged,
    this.onThemeChanged,
  });
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final Widget? heroBackground;
  final double? expandedHeight;
  final bool floating;
  final bool pinned;
  final bool snap;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onProfileTap;
  final Function(String)? onLanguageChanged;
  final Function(String)? onThemeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationService = ref.watch(translationServiceProvider);

    return SliverAppBar(
      expandedHeight:
          expandedHeight ?? ResponsiveSystem.spacing(context, baseSpacing: 250),
      floating: floating,
      pinned: pinned,
      snap: snap,
      backgroundColor: ThemeHelpers.getTransparentColor(context),
      elevation: 0,
      toolbarHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
          fontWeight: FontWeight.bold,
          color: ThemeHelpers.getAppBarTextColor(context),
        ),
      ),
      leading: leadingIcon != null
          ? IconButton(
              icon: Icon(
                leadingIcon,
                color: ThemeHelpers.getAppBarTextColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 24),
              ),
              onPressed: onLeadingTap ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: [
        // Language Dropdown Widget
        LanguageDropdown(
          onLanguageChanged: (value) async {
            await LoggingHelper.logInfo('Language changed to: $value');
            if (onLanguageChanged != null) {
              onLanguageChanged!(value);
            } else {
              ScreenHandlers.handleLanguageChange(ref, value);
            }
          },
        ),
        // Theme Dropdown Widget
        ThemeDropdown(
          onThemeChanged: (value) async {
            await LoggingHelper.logInfo('Theme changed to: $value');
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
      flexibleSpace: heroBackground != null
          ? FlexibleSpaceBar(
              background: heroBackground,
            )
          : null,
    );
  }
}
