/// Counter Display Component
///
/// Large central count display with animation
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

@immutable
class CounterDisplay extends StatelessWidget {
  final int count;
  final Animation<double> scaleAnimation;

  const CounterDisplay({
    super.key,
    required this.count,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: Semantics(
              label: 'Count: $count',
              value: '$count',
              child: Text(
                '$count',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 140),
              fontWeight: FontWeight.bold,
              color: ThemeHelpers.getPrimaryColor(context),
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
            ),
          );
        },
      ),
    );
  }
}

