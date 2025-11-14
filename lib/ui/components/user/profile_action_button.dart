/// Profile Action Button Widget
///
/// A styled action button for profile screen actions
/// with Hindu traditional design
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/ui/components/common/index.dart';

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
    super.key,
    this.backgroundColor,
    this.textColor,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ModernButton(
      text: title,
      onPressed: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 20),
        vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
