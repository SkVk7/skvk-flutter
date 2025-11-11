/// Modern Button Component
///
/// Reusable modern button with icon support
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

/// Modern Button - Reusable button with icon and loading state
@immutable
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = backgroundColor ?? ThemeHelpers.getPrimaryColor(context);
    final buttonTextColor = textColor ?? ThemeHelpers.getPrimaryTextColor(context);
    final isEnabled = onPressed != null && !isLoading;

    return Semantics(
      label: text,
      button: true,
      enabled: isEnabled,
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? ResponsiveSystem.buttonHeight(context, baseHeight: 48),
          padding: padding ?? ResponsiveSystem.symmetric(
            context,
            horizontal: ResponsiveSystem.spacing(context, baseSpacing: 24),
            vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          decoration: BoxDecoration(
            color: isEnabled
                ? primaryColor
                : primaryColor.withValues(alpha: 0.5),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: ResponsiveSystem.iconSize(context, baseSize: 20),
                  height: ResponsiveSystem.iconSize(context, baseSize: 20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
                  ),
                )
              else if (icon != null) ...[
                Icon(
                  icon,
                  color: buttonTextColor,
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  fontWeight: FontWeight.w600,
                  color: buttonTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

