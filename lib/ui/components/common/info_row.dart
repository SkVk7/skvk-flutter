/// Info Row Component
///
/// Reusable component for displaying key-value pairs in a row
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Info Row - Displays label and value in a row with optional icon
@immutable
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.label,
    required this.value,
    super.key,
    this.icon,
    this.iconColor,
    this.onTap,
  });
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
      child: Padding(
        padding:
            ResponsiveSystem.symmetric(context, horizontal: 8, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
                color: iconColor ?? ThemeHelpers.getPrimaryColor(context),
              ),
              ResponsiveSystem.sizedBox(context, width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 12),
                      fontWeight: FontWeight.w500,
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w600,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
