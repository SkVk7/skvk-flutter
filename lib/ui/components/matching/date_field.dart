/// Date Field Component
///
/// Reusable date picker field for matching forms
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Date Field - Reusable date picker field
class DateField extends StatelessWidget {
  const DateField({
    required this.label,
    required this.selectedDate,
    required this.onDateChanged,
    super.key,
  });
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

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
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: ThemeHelpers.getPrimaryColor(context),
                      onPrimary: ThemeHelpers.getSurfaceColor(context),
                      surface: ThemeHelpers.getSurfaceColor(context),
                      onSurface: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDateChanged(date);
            }
          },
          child: Container(
            padding: ResponsiveSystem.all(context, baseSpacing: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: ThemeHelpers.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              color: ThemeHelpers.getSurfaceColor(context),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 12),
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronDown,
                  size: ResponsiveSystem.iconSize(context, baseSize: 16),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
