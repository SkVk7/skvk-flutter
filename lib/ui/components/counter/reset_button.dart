/// Reset Button Component
///
/// Reusable reset button with text styling
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Reset Button - Simple text button for reset operations
class ResetButton extends StatelessWidget {
  const ResetButton({
    required this.translationService,
    required this.onTap,
    super.key,
    this.customText,
    this.fontSize,
  });
  final TranslationService translationService;
  final VoidCallback onTap;
  final String? customText;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        customText ??
            translationService.translateContent(
              'reset',
              fallback: 'Reset',
            ),
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(
            context,
            baseSize: fontSize ?? 18,
          ),
          fontWeight: FontWeight.w500,
          color: ThemeHelpers.getPrimaryTextColor(context),
        ),
      ),
    );
  }
}
