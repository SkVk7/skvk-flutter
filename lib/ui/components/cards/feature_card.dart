/// Feature Card Component
///
/// A reusable card with icon and label for feature grid
/// Used in home screen and other screens for feature displays
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Feature Card - Card with icon and label for feature grid
///
/// Features:
/// - Large icon at top
/// - Title text below
/// - Subtle border and surface color
/// - Responsive sizing
@immutable
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
    super.key,
    this.horizontalPadding,
    this.verticalPadding,
    this.iconSize,
    this.borderRadius,
    this.maxLines,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? iconSize;
  final double? borderRadius;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // Reduced feature card vertical padding by 19% (16 * 0.81 = 12.96)
          padding: ResponsiveSystem.symmetric(
            context,
            horizontal: ResponsiveSystem.spacing(
              context,
              baseSpacing: horizontalPadding ?? 16,
            ),
            vertical: ResponsiveSystem.spacing(
              context,
              baseSpacing: verticalPadding ?? 12.96,
            ),
          ),
          decoration: BoxDecoration(
            // Visual: surfaces slightly lighter dark
            color: ThemeHelpers.getSurfaceColor(context),
            borderRadius: ResponsiveSystem.circular(
              context,
              baseRadius: borderRadius ?? 16,
            ),
            // Visual: border color onSurface 12-18% opacity max, 1px
            border: Border.all(
              color: ThemeHelpers.getPrimaryTextColor(context)
                  .withValues(alpha: 0.15),
              width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fixed size icon container to prevent overflow
                  SizedBox(
                    width: ResponsiveSystem.iconSize(context,
                        baseSize: iconSize ?? 31.92,),
                    height: ResponsiveSystem.iconSize(context,
                        baseSize: iconSize ?? 31.92,),
                    child: Icon(
                      icon,
                      // Increased feature icon size by 14% (28 * 1.14 = 31.92)
                      size: ResponsiveSystem.iconSize(
                        context,
                        baseSize: iconSize ?? 31.92,
                      ),
                      // Visual: accent gold/saffron only for icons
                      color: ThemeHelpers.getPrimaryColor(context),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  ),
                  // Text with proper constraints for zoom - use available space
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight > 0
                          ? constraints.maxHeight -
                              ResponsiveSystem.iconSize(context,
                                  baseSize: iconSize ?? 31.92,) -
                              ResponsiveSystem.spacing(context, baseSpacing: 8)
                          : double.infinity,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: maxLines ?? 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          // Typography: feature labels 13-14 medium
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 13),
                          fontWeight: FontWeight.w500,
                          color: ThemeHelpers.getPrimaryTextColor(context),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
