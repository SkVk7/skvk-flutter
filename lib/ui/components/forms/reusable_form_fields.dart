/// Reusable Form Field Widgets
///
/// Common form field components that can be used across all screens
/// to reduce code duplication and ensure consistency
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Generic form field wrapper with consistent styling
class ReusableFormField extends StatelessWidget {
  const ReusableFormField({
    required this.label,
    required this.child,
    super.key,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.isRequired = false,
    this.helperText,
  });
  final String label;
  final String? hintText;
  final String? errorText;
  final Widget child;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool isRequired;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    // Use a simple approach without Riverpod dependency for basic functionality
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  ThemeHelpers.getSurfaceContainerColor(context),
                  ThemeHelpers.getSurfaceContainerHighColor(context),
                  ThemeHelpers.getSurfaceContainerColor(context),
                ]
              : [
                  ThemeHelpers.getSurfaceColor(context),
                  ThemeHelpers.getSurfaceContainerColor(context),
                  ThemeHelpers.getSurfaceColor(context),
                ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveSystem.borderRadius(context, baseRadius: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeHelpers.getShadowColor(context).withAlpha(76),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 16),
            offset:
                Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 8)),
          ),
          BoxShadow(
            color: ThemeHelpers.getShadowColor(context).withAlpha(38),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
            offset:
                Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
          ),
        ],
      ),
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    color: ThemeHelpers.getPrimaryColor(context),
                  ),
                  ResponsiveSystem.sizedBox(
                    context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  ),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                    fontWeight: FontWeight.w600,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                if (isRequired) ...[
                  ResponsiveSystem.sizedBox(
                    context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 4),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeHelpers.getErrorColor(context),
                    ),
                  ),
                ],
                const Spacer(),
                if (suffixIcon != null) ...[
                  GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(
                      suffixIcon,
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                      color: ThemeHelpers.getPrimaryColor(context),
                    ),
                  ),
                ],
              ],
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            child,
            if (helperText != null) ...[
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 4),
              ),
              Text(
                helperText!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
            ],
            if (errorText != null) ...[
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 4),
              ),
              Text(
                errorText!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  color: ThemeHelpers.getErrorColor(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable text input field
class ReusableTextInput extends StatelessWidget {
  const ReusableTextInput({
    required this.controller,
    required this.hintText,
    super.key,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
  });
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final bool enabled;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: secondaryTextColor,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: primaryColor,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Reusable date picker field
class ReusableDatePicker extends StatelessWidget {
  const ReusableDatePicker({
    super.key,
    this.selectedDate,
    this.onDateChanged,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });
  final DateTime? selectedDate;
  final Function(DateTime)? onDateChanged;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
              color: primaryColor,
            ),
            ResponsiveSystem.sizedBox(context, width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : 'Select Date',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: selectedDate != null ? textColor : secondaryTextColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: secondaryTextColor,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null && picked != selectedDate && onDateChanged != null) {
      onDateChanged!(picked);
    }
  }
}

/// Reusable time picker field
class ReusableTimePicker extends StatelessWidget {
  const ReusableTimePicker({
    super.key,
    this.selectedTime,
    this.onTimeChanged,
    this.enabled = true,
  });
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay)? onTimeChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return InkWell(
      onTap: enabled ? () => _selectTime(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
              color: primaryColor,
            ),
            ResponsiveSystem.sizedBox(context, width: 12),
            Expanded(
              child: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : 'Select Time',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: selectedTime != null ? textColor : secondaryTextColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: secondaryTextColor,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime && onTimeChanged != null) {
      onTimeChanged!(picked);
    }
  }
}

/// Reusable dropdown field
class ReusableDropdown<T> extends StatelessWidget {
  const ReusableDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    required this.hintText,
    super.key,
    this.enabled = true,
  });
  final T value;
  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T) itemBuilder;
  final String hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: secondaryTextColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemBuilder(item),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: textColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Reusable action buttons container
class ReusableActionButtons extends StatelessWidget {
  const ReusableActionButtons({
    required this.buttons,
    super.key,
    this.alignment = MainAxisAlignment.spaceEvenly,
  });
  final List<ReusableActionButton> buttons;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: buttons.map((button) => Expanded(child: button)).toList(),
    );
  }
}

/// Reusable action button
class ReusableActionButton extends StatelessWidget {
  const ReusableActionButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.isEnabled = true,
  });
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return ModernButton(
      text: text,
      onPressed: isEnabled && !isLoading ? onPressed : null,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      isLoading: isLoading,
    );
  }
}

/// Reusable section title
class ReusableSectionTitle extends StatelessWidget {
  const ReusableSectionTitle({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.padding,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
              color: ThemeHelpers.getPrimaryColor(context),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                    fontWeight: FontWeight.w600,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                if (subtitle != null) ...[
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                  ),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
