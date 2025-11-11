/// Main CTA Card Component
///
/// A reusable large, full-width CTA card with icon, title, subtitle, and arrow
/// Used across home screen and other screens for primary actions
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

/// Main CTA Card - Large, full-width card for primary actions
/// 
/// Features:
/// - Gold accent icon with background
/// - Title and subtitle text
/// - Arrow indicator
/// - Subtle border and surface color
/// - Responsive sizing
@immutable
class MainCTACard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? iconSize;
  final double? borderRadius;

  const MainCTACard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.horizontalPadding,
    this.verticalPadding,
    this.iconSize,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: subtitle != null ? '$title. $subtitle' : title,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        width: double.infinity,
        // Increased horizontal padding by 15% (24 * 1.15 = 27.6)
        padding: ResponsiveSystem.symmetric(
          context,
          horizontal: ResponsiveSystem.spacing(
            context,
            baseSpacing: horizontalPadding ?? 27.6,
          ),
          vertical: ResponsiveSystem.spacing(
            context,
            baseSpacing: verticalPadding ?? 24,
          ),
        ),
        decoration: BoxDecoration(
          // Visual: surfaces slightly lighter dark
          color: ThemeHelpers.getSurfaceColor(context),
          // Reduced corner radius by 10% (20 * 0.9 = 18)
          borderRadius: ResponsiveSystem.circular(
            context,
            baseRadius: borderRadius ?? 18,
          ),
          // Visual: border color onSurface 12-18% opacity max, 1px
          border: Border.all(
            color: ThemeHelpers.getPrimaryTextColor(context)
                .withValues(alpha: 0.15),
            width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
          ),
        ),
        child: Row(
          children: [
            // Gold accent icon (saffron for highlights only)
            Container(
              padding: ResponsiveSystem.all(context, baseSpacing: 12),
              decoration: BoxDecoration(
                // Increased icon opacity to 95% (from 0.1 alpha = 10% opacity to 0.95 alpha = 95% opacity)
                color: ThemeHelpers.getPrimaryColor(context)
                    .withValues(alpha: 0.95),
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
              ),
              child: Icon(
                icon,
                // Increased CTA icon size by 12% (32 * 1.12 = 35.84)
                size: ResponsiveSystem.iconSize(
                  context,
                  baseSize: iconSize ?? 35.84,
                ),
                // Visual: accent gold/saffron only for icons
                color: ThemeHelpers.getPrimaryColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Expanded to prevent overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      // Typography: primary CTA title 18 semi-bold
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                      fontWeight: FontWeight.w600,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                  if (subtitle != null) ...[
                    ResponsiveSystem.sizedBox(
                      context,
                      height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                    ),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        fontWeight: FontWeight.normal,
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Fixed size icon to prevent overflow
            SizedBox(
              width: ResponsiveSystem.iconSize(context, baseSize: 16) + ResponsiveSystem.spacing(context, baseSpacing: 4),
              child: Icon(
                Icons.arrow_forward_ios,
                size: ResponsiveSystem.iconSize(context, baseSize: 16),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

