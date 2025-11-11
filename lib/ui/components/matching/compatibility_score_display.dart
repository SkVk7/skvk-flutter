/// Compatibility Score Display Component
///
/// Large score display similar to Pradakshana counter
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

@immutable
class CompatibilityScoreDisplay extends StatelessWidget {
  final double? score;
  final int? totalPoints;
  final int? maxPoints;
  final Animation<double>? scaleAnimation;

  const CompatibilityScoreDisplay({
    super.key,
    required this.score,
    this.totalPoints,
    this.maxPoints,
    this.scaleAnimation,
  });

  Color _getScoreColor(BuildContext context, double score) {
    if (score >= 70) {
      return ThemeHelpers.getSuccessColor(context);
    } else if (score >= 50) {
      return ThemeHelpers.getPrimaryColor(context);
    } else {
      return ThemeHelpers.getErrorColor(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: ThemeHelpers.getErrorColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 48),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: 16, // baseSpacing - will be scaled by ResponsiveSystem internally
            ),
            Text(
              'Score not available',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    final scoreColor = _getScoreColor(context, score!);
    final displayScore = score!.toStringAsFixed(0);

    Widget scoreWidget = RepaintBoundary(
      child: Semantics(
        label: 'Compatibility score: $displayScore percent',
        value: '$displayScore%',
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$displayScore%',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 140),
            fontWeight: FontWeight.bold,
            color: scoreColor,
            letterSpacing: ResponsiveSystem.responsive(
              context,
              mobile: -6.0,
              tablet: -8.0,
              desktop: -10.0,
              largeDesktop: -12.0,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        if (totalPoints != null && maxPoints != null) ...[
          ResponsiveSystem.sizedBox(
            context,
            height: 8, // baseSpacing - will be scaled by ResponsiveSystem internally
          ),
          Text(
            '$totalPoints/$maxPoints Points',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.w600,
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
        ],
        ResponsiveSystem.sizedBox(
          context,
          height: 16, // baseSpacing - will be scaled by ResponsiveSystem internally
        ),
        // Progress bar
        Container(
          width: double.infinity,
          height: ResponsiveSystem.spacing(context, baseSpacing: 8),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.2),
            borderRadius: ResponsiveSystem.circular(
              context,
              baseRadius: 4,
            ),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score! / 100,
            child: Container(
              decoration: BoxDecoration(
                color: scoreColor,
                borderRadius: ResponsiveSystem.circular(
                  context,
                  baseRadius: 4,
                ),
              ),
            ),
          ),
        ),
        ],
      ),
      ),
    );

    if (scaleAnimation != null) {
      return AnimatedBuilder(
        animation: scaleAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation!.value,
            child: scoreWidget,
          );
        },
      );
    }

    return scoreWidget;
  }
}

