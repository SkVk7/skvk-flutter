/// Section Title Component
///
/// Reusable section title with responsive typography and letter spacing
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

/// Section Title - Responsive section title with overflow handling
@immutable
class SectionTitle extends StatelessWidget {
  final String title;
  final double? baseFontSize;
  final double? letterSpacingPercent;

  const SectionTitle({
    super.key,
    required this.title,
    this.baseFontSize,
    this.letterSpacingPercent,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = baseFontSize ?? 16.0;
    final letterSpacing = letterSpacingPercent ?? 0.06;

    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        // Responsive typography: section titles scale with screen size
        fontSize: ResponsiveSystem.responsive(
          context,
          mobile: ResponsiveSystem.fontSize(context, baseSize: fontSize - 1),
          tablet: ResponsiveSystem.fontSize(context, baseSize: fontSize),
          desktop: ResponsiveSystem.fontSize(context, baseSize: fontSize + 2),
          largeDesktop: ResponsiveSystem.fontSize(context, baseSize: fontSize + 4),
        ),
        // Increased font weight by +8% (w600 → w650, using w700 for bolder)
        fontWeight: FontWeight.w700,
        color: ThemeHelpers.getPrimaryTextColor(context),
        // Responsive letter spacing (percentage of fontSize) - increased by +6%
        letterSpacing: ResponsiveSystem.responsive(
          context,
          mobile: ResponsiveSystem.fontSize(context, baseSize: fontSize - 1) * (letterSpacing * 1.06),
          tablet: ResponsiveSystem.fontSize(context, baseSize: fontSize) * (letterSpacing * 1.06),
          desktop: ResponsiveSystem.fontSize(context, baseSize: fontSize + 2) * (letterSpacing * 1.06),
          largeDesktop: ResponsiveSystem.fontSize(context, baseSize: fontSize + 4) * (letterSpacing * 1.06),
        ),
      ),
    );
  }
}

