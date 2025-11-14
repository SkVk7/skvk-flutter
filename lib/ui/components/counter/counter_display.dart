/// Counter Display Component
///
/// Large central count display with animation
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

@immutable
class CounterDisplay extends StatelessWidget {
  const CounterDisplay({
    required this.count,
    required this.scaleAnimation,
    super.key,
  });
  final int count;
  final Animation<double> scaleAnimation;

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
                    mobile: -6,
                    tablet: -8,
                    desktop: -10,
                    largeDesktop: -12,
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
