/// Reusable Button Components
///
/// Common button components that can be used across all screens
/// to ensure consistent button styling and behavior
library;

import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// Reusable primary button
class ReusablePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;

  const ReusablePrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : (isEnabled ? onPressed : null),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: (backgroundColor ?? primaryColor).withValues(alpha: 0.4),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: textColor ?? Colors.white,
                    ),
                    SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Reusable secondary button
class ReusableSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const ReusableSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? ResponsiveSystem.screenWidth(context),
      height: height ?? ResponsiveSystem.buttonHeight(context, baseHeight: 56),
      child: OutlinedButton(
        onPressed: isLoading ? null : (isEnabled ? onPressed : null),
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeProperties.getPrimaryColor(context),
          padding: padding ?? ResponsiveSystem.symmetric(context, horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
          ),
          side: BorderSide(
            color: ThemeProperties.getPrimaryColor(context),
            width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: ResponsiveSystem.iconSize(context, baseSize: 20),
                height: ResponsiveSystem.iconSize(context, baseSize: 20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ThemeProperties.getPrimaryColor(context)),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                      color: ThemeProperties.getPrimaryColor(context),
                    ),
                    ResponsiveSystem.sizedBox(context, width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w600,
                      color: ThemeProperties.getPrimaryColor(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Reusable outline button
class ReusableOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsets? padding;

  const ReusableOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.borderColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final effectiveBorderColor = borderColor ?? primaryColor;
    final effectiveTextColor = textColor ?? primaryColor;

    return Container(
      width: width,
      height: height ?? ResponsiveSystem.buttonHeight(context, baseHeight: 48),
      decoration: BoxDecoration(
        border: Border.all(
          color: isEnabled ? effectiveBorderColor : effectiveBorderColor.withValues(alpha: 0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 8)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 8)),
          child: Container(
            padding: padding ?? ResponsiveSystem.symmetric(
              context,
              horizontal: 16,
              vertical: 12,
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: ResponsiveSystem.iconSize(context, baseSize: 16),
                          color: isEnabled ? effectiveTextColor : effectiveTextColor.withValues(alpha: 0.3),
                        ),
                        ResponsiveSystem.sizedBox(context,
                            width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? effectiveTextColor : effectiveTextColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Reusable text button
class ReusableTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ReusableTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final effectiveTextColor = textColor ?? primaryColor;

    return TextButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: isEnabled ? effectiveTextColor : effectiveTextColor.withValues(alpha: 0.3),
        padding: ResponsiveSystem.symmetric(
          context,
          horizontal: 16,
          vertical: 8,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: ResponsiveSystem.iconSize(context, baseSize: 16),
                    color: isEnabled ? effectiveTextColor : effectiveTextColor.withValues(alpha: 0.3),
                  ),
                  ResponsiveSystem.sizedBox(context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? ResponsiveSystem.fontSize(context, baseSize: 16),
                    fontWeight: fontWeight ?? FontWeight.w500,
                    color: isEnabled ? effectiveTextColor : effectiveTextColor.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Reusable icon button
class ReusableIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final bool isEnabled;

  const ReusableIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final effectiveIconColor = iconColor ?? primaryColor;

    Widget button = IconButton(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(
        icon,
        color: isEnabled ? effectiveIconColor : effectiveIconColor.withValues(alpha: 0.3),
        size: size ?? ResponsiveSystem.iconSize(context, baseSize: 24),
      ),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 8)),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Reusable floating action button
class ReusableFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isEnabled;

  const ReusableFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final effectiveBackgroundColor = backgroundColor ?? primaryColor;
    final effectiveForegroundColor = foregroundColor ?? Colors.white;

    Widget fab = FloatingActionButton(
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isEnabled ? effectiveBackgroundColor : effectiveBackgroundColor.withValues(alpha: 0.3),
      foregroundColor: isEnabled ? effectiveForegroundColor : effectiveForegroundColor.withValues(alpha: 0.3),
      child: Icon(
        icon,
        size: ResponsiveSystem.iconSize(context, baseSize: 24),
      ),
    );

    if (tooltip != null) {
      fab = Tooltip(
        message: tooltip!,
        child: fab,
      );
    }

    return fab;
  }
}

/// Reusable button group
class ReusableButtonGroup extends StatelessWidget {
  final List<Widget> buttons;
  final MainAxisAlignment alignment;
  final double spacing;

  const ReusableButtonGroup({
    super.key,
    required this.buttons,
    this.alignment = MainAxisAlignment.spaceEvenly,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: buttons
          .expand((button) => [
                button,
                if (button != buttons.last)
                  ResponsiveSystem.sizedBox(context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: spacing)),
              ])
          .toList(),
    );
  }
}

/// Reusable action sheet button
class ReusableActionSheetButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;
  final bool isDestructive;

  const ReusableActionSheetButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.textColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ??
        (isDestructive
            ? ThemeProperties.getErrorColor(context)
            : ThemeProperties.getPrimaryTextColor(context));

    return ListTile(
      leading: icon != null
          ? Icon(
              icon,
              color: effectiveTextColor,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            )
          : null,
      title: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
          color: effectiveTextColor,
          fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onPressed,
    );
  }
}
