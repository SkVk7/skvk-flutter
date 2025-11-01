/// Reusable Card Components
///
/// Common card components that can be used across all screens
/// to ensure consistent card styling and behavior
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/theme/theme_provider.dart';

/// Reusable info card with consistent styling
class ReusableInfoCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final IconData? icon;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;

  const ReusableInfoCard({
    super.key,
    this.title,
    required this.child,
    this.icon,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use a simple approach without complex dependencies
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Safe color handling
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final surfaceContainerColor = Theme.of(context).colorScheme.surfaceContainer;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final shadowColor = isDarkMode ? Colors.black54 : Colors.black12;

    Widget card = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColor != null
              ? [backgroundColor!, backgroundColor!.withValues(alpha: 0.8)]
              : isDarkMode
                  ? [surfaceContainerColor, surfaceColor]
                  : [surfaceColor, surfaceContainerColor],
        ),
        borderRadius: BorderRadius.circular(16),
        border: showBorder
            ? Border.all(
                color: borderColor ?? primaryColor.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: primaryColor,
                    ),
                    SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }

    return card;
  }
}

/// Reusable stat card for displaying metrics
class ReusableStatCard extends ConsumerWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? valueColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ReusableStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.valueColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final primaryColor = ThemeProperties.getPrimaryColor(context);

    Widget card = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColor != null
              ? [backgroundColor!, backgroundColor!.withValues(alpha: 0.8)]
              : isDarkMode
                  ? [
                      ThemeProperties.getSurfaceContainerColor(context),
                      ThemeProperties.getSurfaceContainerHighColor(context),
                    ]
                  : [
                      ThemeProperties.getSurfaceColor(context),
                      ThemeProperties.getSurfaceContainerColor(context),
                    ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 12)),
        boxShadow: [
          BoxShadow(
            color: ThemeProperties.getShadowColor(context).withAlpha(76),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 12),
            offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 6)),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: ResponsiveSystem.iconSize(context, baseSize: 18),
                    color: primaryColor,
                  ),
                  ResponsiveSystem.sizedBox(context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                      fontWeight: FontWeight.w500,
                      color: ThemeProperties.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                fontWeight: FontWeight.bold,
                color: valueColor ?? primaryColor,
              ),
            ),
            if (subtitle != null) ...[
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 12)),
        child: card,
      );
    }

    return card;
  }
}

/// Reusable feature card for displaying features or options
class ReusableFeatureCard extends ConsumerWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;
  final EdgeInsets? padding;

  const ReusableFeatureCard({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final effectiveSelectedColor = selectedColor ?? primaryColor;

    Widget card = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  effectiveSelectedColor.withValues(alpha: 0.1),
                  effectiveSelectedColor.withValues(alpha: 0.05),
                ]
              : isDarkMode
                  ? [
                      ThemeProperties.getSurfaceContainerColor(context),
                      ThemeProperties.getSurfaceContainerHighColor(context),
                    ]
                  : [
                      ThemeProperties.getSurfaceColor(context),
                      ThemeProperties.getSurfaceContainerColor(context),
                    ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 12)),
        border: isSelected
            ? Border.all(
                color: effectiveSelectedColor,
                width: 2,
              )
            : Border.all(
                color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.2),
                width: 1,
              ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: effectiveSelectedColor.withValues(alpha: 0.3),
                  blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
                ),
              ]
            : [
                BoxShadow(
                  color: ThemeProperties.getShadowColor(context).withAlpha(38),
                  blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
                ),
              ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 16)),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: ResponsiveSystem.iconSize(context, baseSize: 24),
                color: isSelected ? effectiveSelectedColor : primaryColor,
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? effectiveSelectedColor : ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                  if (description != null) ...[
                    ResponsiveSystem.sizedBox(context,
                        height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeProperties.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
              trailing!,
            ],
            if (isSelected) ...[
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
              Icon(
                Icons.check_circle,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
                color: effectiveSelectedColor,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 12)),
        child: card,
      );
    }

    return card;
  }
}

/// Reusable list card for displaying lists of items
class ReusableListCard extends ConsumerWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;
  final Widget? headerTrailing;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ReusableListCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.headerTrailing,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  ThemeProperties.getSurfaceContainerColor(context),
                  ThemeProperties.getSurfaceContainerHighColor(context),
                ]
              : [
                  ThemeProperties.getSurfaceColor(context),
                  ThemeProperties.getSurfaceContainerColor(context),
                ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 16)),
        boxShadow: [
          BoxShadow(
            color: ThemeProperties.getShadowColor(context).withAlpha(76),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 16),
            offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 8)),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    color: ThemeProperties.getPrimaryColor(context),
                  ),
                  ResponsiveSystem.sizedBox(context,
                      width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                      fontWeight: FontWeight.w600,
                      color: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                ),
                if (headerTrailing != null) headerTrailing!,
              ],
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Reusable loading card
class ReusableLoadingCard extends StatelessWidget {
  final String? message;
  final double? height;
  final Color? color;

  const ReusableLoadingCard({
    super.key,
    this.message,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200,
      decoration: BoxDecoration(
        color: ThemeProperties.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 16)),
        boxShadow: [
          BoxShadow(
            color: ThemeProperties.getShadowColor(context).withAlpha(76),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 16),
            offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 8)),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? ThemeProperties.getPrimaryColor(context),
              ),
            ),
            if (message != null) ...[
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
              Text(
                message!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
