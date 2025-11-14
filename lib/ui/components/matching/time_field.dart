/// Time Field Component
///
/// Reusable time picker field for matching forms
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Time Field - Reusable time picker field
class TimeField extends StatelessWidget {
  const TimeField({
    required this.label,
    required this.selectedTime,
    required this.onTimeChanged,
    super.key,
  });
  final String label;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

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
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
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
            if (time != null) {
              onTimeChanged(time);
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
                  LucideIcons.clock,
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 12),
                Expanded(
                  child: Text(
                    selectedTime.format(context),
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
