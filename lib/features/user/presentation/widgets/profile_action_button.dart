/// Profile Action Button Widget
///
/// A styled action button for profile screen actions
/// with Hindu traditional design
library;

import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/widgets/centralized_widgets.dart';

class ProfileActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const ProfileActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CentralizedModernButton(
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
