/// Reset Button Component
///
/// Reusable reset button with text styling
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/services/language/translation_service.dart';

/// Reset Button - Simple text button for reset operations
class ResetButton extends StatelessWidget {
  final TranslationService translationService;
  final VoidCallback onTap;
  final String? customText;
  final double? fontSize;

  const ResetButton({
    super.key,
    required this.translationService,
    required this.onTap,
    this.customText,
    this.fontSize,
  });

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

