/// Counter Buttons Component
///
/// Plus and minus buttons for the counter
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

@immutable
class CounterButtons extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isDisabled;
  final Duration remainingCooldown;
  final Animation<double> scaleAnimation;
  final AnimationController buttonAnimationController;

  const CounterButtons({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.isDisabled,
    required this.remainingCooldown,
    required this.scaleAnimation,
    required this.buttonAnimationController,
  });

  String _formatCooldown() {
    if (remainingCooldown.inHours > 0) {
      return '${remainingCooldown.inHours}h ${remainingCooldown.inMinutes % 60}m';
    } else if (remainingCooldown.inMinutes > 0) {
      return '${remainingCooldown.inMinutes}m ${remainingCooldown.inSeconds % 60}s';
    } else {
      return '${remainingCooldown.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final successColor = ThemeHelpers.getSuccessColor(context);
    
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => buttonAnimationController.forward(),
            onTapUp: (_) {
              buttonAnimationController.reverse();
              if (!isDisabled) {
                onIncrement();
              }
            },
            onTapCancel: () => buttonAnimationController.reverse(),
            child: Semantics(
              label: isDisabled 
                  ? 'Increment button disabled. Cooldown: ${_formatCooldown()}'
                  : 'Increment counter',
              button: true,
              enabled: !isDisabled,
              child: Container(
              width: double.infinity,
              height: ResponsiveSystem.spacing(context, baseSpacing: 100),
              decoration: BoxDecoration(
                color: isDisabled
                    ? successColor.withValues(alpha: 0.5)
                    : successColor,
                borderRadius: ResponsiveSystem.circular(
                  context,
                  baseRadius: 24,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 56),
                  ),
                  if (isDisabled) ...[
                    ResponsiveSystem.sizedBox(
                      context,
                      height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                    ),
                    Text(
                      _formatCooldown(),
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(
                          context,
                          baseSize: 12,
                        ),
                        color: ThemeHelpers.getPrimaryTextColor(context)
                            .withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}

