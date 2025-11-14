/// Welcome Tagline Component
///
/// Reusable welcome tagline text with responsive typography
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Welcome Tagline - Responsive tagline text with overflow handling
class WelcomeTagline extends StatelessWidget {
  const WelcomeTagline({
    required this.translationService,
    super.key,
    this.customText,
  });
  final TranslationService translationService;
  final String? customText;

  @override
  Widget build(BuildContext context) {
    return Text(
      customText ??
          translationService.translateContent(
            'welcome_subtitle',
            fallback:
                'Discover what the stars have in store for you with personalized insights and guidance',
          ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        // Responsive typography: tagline scales with screen size
        fontSize: ResponsiveSystem.responsive(
          context,
          mobile: ResponsiveSystem.fontSize(context, baseSize: 13),
          tablet: ResponsiveSystem.fontSize(context, baseSize: 14),
          desktop: ResponsiveSystem.fontSize(context, baseSize: 15),
          largeDesktop: ResponsiveSystem.fontSize(context, baseSize: 16),
        ),
        fontWeight: FontWeight.normal,
        color: ThemeHelpers.getSecondaryTextColor(context),
        height: ResponsiveSystem.responsive(
          context,
          mobile: 1.4,
          tablet: 1.5,
          desktop: 1.6,
          largeDesktop: 1.6,
        ),
      ),
    );
  }
}
