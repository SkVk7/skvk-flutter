/// Name Field Component
///
/// Reusable name input field for matching forms
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Name Field - Reusable text field for names
@immutable
class NameField extends StatelessWidget {
  const NameField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hintText,
    super.key,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            fontWeight: FontWeight.w500,
            color: ThemeHelpers.getPrimaryTextColor(context),
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        Semantics(
          label: label,
          textField: true,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(
                icon,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
              border: OutlineInputBorder(
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                borderSide: BorderSide(
                  color: ThemeHelpers.getBorderColor(context),
                  width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                borderSide: BorderSide(
                  color: ThemeHelpers.getBorderColor(context),
                  width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                borderSide: BorderSide(
                  color: ThemeHelpers.getPrimaryColor(context),
                  width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
                ),
              ),
              filled: true,
              fillColor: ThemeHelpers.getSurfaceColor(context),
              contentPadding: ResponsiveSystem.all(context, baseSpacing: 16),
            ),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
