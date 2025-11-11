/// Info Card Component
///
/// Reusable card component for displaying content in a card layout
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

/// Info Card - Simple card component for displaying content
@immutable
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const InfoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? ResponsiveSystem.all(context, baseSpacing: 0),
      padding: padding ?? ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeHelpers.getSurfaceColor(context),
        borderRadius: borderRadius ?? ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeHelpers.getPrimaryTextColor(context).withValues(alpha: 0.12),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.1),
                  blurRadius: elevation! * 4,
                  offset: Offset(0, elevation! * 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

