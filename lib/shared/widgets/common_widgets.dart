import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// Common widgets that use centralized reactive sizing and themed coloring

/// Modern Card Widget
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? ResponsiveSystem.all(context, baseSpacing: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeProperties.getSurfaceColor(context),
        borderRadius: borderRadius ?? ResponsiveSystem.circular(context, baseRadius: 12),
        boxShadow: [
          BoxShadow(
            color: ThemeProperties.getShadowColor(context),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
            offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
          ),
        ],
      ),
      child: Material(
        color: ThemeProperties.getTransparentColor(context),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? ResponsiveSystem.circular(context, baseRadius: 12),
          child: Padding(
            padding: padding ?? ResponsiveSystem.all(context, baseSpacing: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Modern Button Widget
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
    return SizedBox(
      width: width ?? ResponsiveSystem.screenWidth(context),
      height: height ?? ResponsiveSystem.buttonHeight(context, baseHeight: 56),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ThemeProperties.getPrimaryColor(context),
          foregroundColor: textColor ?? ThemeProperties.getTextColor(context),
          padding: padding ?? ResponsiveSystem.symmetric(context, horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
          ),
          elevation: ResponsiveSystem.elevation(context, baseElevation: 2),
        ),
        child: isLoading
            ? SizedBox(
                width: ResponsiveSystem.iconSize(context, baseSize: 20),
                height: ResponsiveSystem.iconSize(context, baseSize: 20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeProperties.getTextColor(context),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                    ResponsiveSystem.sizedBox(context, width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Modern Text Field Widget
class ModernTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;

  const ModernTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              fontWeight: FontWeight.w500,
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: ThemeProperties.getHintTextColor(context),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: ThemeProperties.getSurfaceColor(context),
            border: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
              borderSide: BorderSide(
                color: ThemeProperties.getDividerColor(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
              borderSide: BorderSide(
                color: ThemeProperties.getDividerColor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
              borderSide: BorderSide(
                color: ThemeProperties.getPrimaryColor(context),
                width: 2,
              ),
            ),
            contentPadding: ResponsiveSystem.symmetric(context, horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// Modern List Tile Widget
class ModernListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const ModernListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveSystem.only(context, bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeProperties.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            fontWeight: FontWeight.w500,
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        contentPadding: ResponsiveSystem.symmetric(context, horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// Modern Divider Widget
class ModernDivider extends StatelessWidget {
  final double? height;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const ModernDivider({
    super.key,
    this.height,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? ResponsiveSystem.symmetric(context, vertical: 16),
      height: height ?? 1,
      color: color ?? ThemeProperties.getDividerColor(context),
    );
  }
}

/// Modern Chip Widget
class ModernChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? avatar;

  const ModernChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
          color: textColor ?? ThemeProperties.getPrimaryTextColor(context),
        ),
      ),
      backgroundColor: backgroundColor ?? ThemeProperties.getSurfaceColor(context),
      deleteIcon: onDeleted != null
          ? Icon(
              Icons.close,
              size: ResponsiveSystem.iconSize(context, baseSize: 18),
              color: ThemeProperties.getSecondaryTextColor(context),
            )
          : null,
      onDeleted: onDeleted,
      avatar: avatar,
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
      ),
    );
  }
}

/// Modern Badge Widget
class ModernBadge extends StatelessWidget {
  final Widget child;
  final String? label;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;

  const ModernBadge({
    super.key,
    required this.child,
    this.label,
    this.backgroundColor,
    this.textColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (label != null)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: ResponsiveSystem.symmetric(context, horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: backgroundColor ?? ThemeProperties.getErrorColor(context),
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 10),
              ),
              constraints: BoxConstraints(
                minWidth: ResponsiveSystem.spacing(context, baseSpacing: 16),
                minHeight: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              child: Text(
                label!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  color: textColor ?? ThemeProperties.getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Modern Progress Indicator
class ModernProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? color;
  final double? strokeWidth;
  final String? label;

  const ModernProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.strokeWidth,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeProperties.getSecondaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
        ],
        SizedBox(
          width: ResponsiveSystem.spacing(context, baseSpacing: 40),
          height: ResponsiveSystem.spacing(context, baseSpacing: 40),
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth ?? 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? ThemeProperties.getPrimaryColor(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern Switch Widget
class ModernSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;

  const ModernSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (label != null) ...[
          Expanded(
            child: Text(
              label!,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
          ),
          ResponsiveSystem.sizedBox(context, width: 16),
        ],
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor ?? ThemeProperties.getPrimaryColor(context),
          inactiveThumbColor: inactiveColor ?? ThemeProperties.getSurfaceColor(context),
        ),
      ],
    );
  }
}

/// Modern Checkbox Widget
class ModernCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final Color? activeColor;

  const ModernCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged != null ? (bool? newValue) => onChanged!(newValue ?? false) : null,
          activeColor: activeColor ?? ThemeProperties.getPrimaryColor(context),
        ),
        if (label != null) ...[
          ResponsiveSystem.sizedBox(context, width: 8),
          Expanded(
            child: Text(
              label!,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
