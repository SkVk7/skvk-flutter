/// Match Button Component
///
/// Large minimalist button for performing matching, similar to Pradakshana counter
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

@immutable
class MatchButton extends StatelessWidget {
  const MatchButton({
    required this.onPressed,
    required this.isLoading,
    required this.text,
    required this.icon,
    super.key,
  });
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeHelpers.getPrimaryColor(context);
    final textColor = ThemeHelpers.getPrimaryTextColor(context);

    return Semantics(
      label: text,
      button: true,
      enabled: !isLoading,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          width: double.infinity,
          height: ResponsiveSystem.spacing(context, baseSpacing: 100),
          decoration: BoxDecoration(
            color:
                isLoading ? primaryColor.withValues(alpha: 0.5) : primaryColor,
            borderRadius: ResponsiveSystem.circular(
              context,
              baseRadius: 24,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: ResponsiveSystem.iconSize(context, baseSize: 32),
                  height: ResponsiveSystem.iconSize(context, baseSize: 32),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              else ...[
                Icon(
                  icon,
                  color: textColor,
                  size: ResponsiveSystem.iconSize(context, baseSize: 56),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  height:
                      8, // baseSpacing - will be scaled by ResponsiveSystem internally
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
