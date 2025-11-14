/// Audio Hero Skeleton Component
///
/// Loading skeleton for hero section
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Audio Hero Skeleton - Loading state for hero section
class AudioHeroSkeleton extends StatelessWidget {
  const AudioHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveSystem.all(context, baseSpacing: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        color: ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.3),
      ),
      height: ResponsiveSystem.responsive(
        context,
        mobile: MediaQuery.of(context).size.height * 0.35,
        tablet: MediaQuery.of(context).size.height * 0.30,
        desktop: MediaQuery.of(context).size.height * 0.25,
        largeDesktop: MediaQuery.of(context).size.height * 0.25,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: ThemeHelpers.getPrimaryColor(context),
        ),
      ),
    );
  }
}
