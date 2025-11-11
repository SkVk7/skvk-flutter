/// Pill Action Card Component
///
/// A reusable small, compact pill-shaped card with icon and text
/// Used for quick actions like Birth Chart, Calendar, etc.
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

/// Pill Action Card - Small, compact card for quick actions
/// 
/// Features:
/// - Icon and text in a row
/// - Compact pill shape
/// - Subtle border and surface color
/// - Responsive sizing
@immutable
class PillActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? iconSize;
  final double? borderRadius;

  const PillActionCard({
    super.key,
    required this.title,
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
      label: title,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: ResponsiveSystem.symmetric(
          context,
          horizontal: ResponsiveSystem.spacing(
            context,
            baseSpacing: horizontalPadding ?? 16,
          ),
          // Reduced pill card height by 22% (12 * 0.78 = 9.36)
          vertical: ResponsiveSystem.spacing(
            context,
            baseSpacing: verticalPadding ?? 9.36,
          ),
        ),
        decoration: BoxDecoration(
          // Visual: surfaces slightly lighter dark
          color: ThemeHelpers.getSurfaceColor(context),
          borderRadius: ResponsiveSystem.circular(
            context,
            baseRadius: borderRadius ?? 12,
          ),
          // Visual: border color onSurface 12-18% opacity max
          // Increased stroke width by +0.25px (1.0 → 1.25)
          border: Border.all(
            color: ThemeHelpers.getPrimaryTextColor(context)
                .withValues(alpha: 0.15),
            width: ResponsiveSystem.borderWidth(context, baseWidth: 1.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed size icon
            SizedBox(
              width: ResponsiveSystem.iconSize(context, baseSize: iconSize ?? 18),
              height: ResponsiveSystem.iconSize(context, baseSize: iconSize ?? 18),
              child: Icon(
                icon,
                // Reduced pill icon size by 10% (20 * 0.9 = 18)
                size: ResponsiveSystem.iconSize(
                  context,
                  baseSize: iconSize ?? 18,
                ),
                // Visual: accent gold/saffron only for icons
                color: ThemeHelpers.getPrimaryColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            // Flexible to prevent overflow
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // Typography: mini actions 14 medium
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  fontWeight: FontWeight.w500,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

