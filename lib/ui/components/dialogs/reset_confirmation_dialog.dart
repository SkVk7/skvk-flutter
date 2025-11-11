/// Reset Confirmation Dialog Component
///
/// Reusable confirmation dialog for reset operations
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/services/language/translation_service.dart';

/// Reset Confirmation Dialog - Dialog for confirming reset operations
class ResetConfirmationDialog extends StatelessWidget {
  final TranslationService translationService;
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ResetConfirmationDialog({
    super.key,
    required this.translationService,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive dimensions based on screen size and aspect ratio
    final dialogWidth = ResponsiveSystem.dialogWidth(context);
    final dialogPadding = ResponsiveSystem.dialogPadding(context);
    
    // Calculate button count for proper sizing
    final buttonCount = onCancel != null ? 2 : 1;
    final buttonConstraints = ResponsiveSystem.dialogActionConstraints(
      context,
      buttonCount: buttonCount,
    );
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: ResponsiveSystemExtensions.screenHeight(context) * 0.8,
        ),
        padding: dialogPadding,
        decoration: BoxDecoration(
          color: ThemeHelpers.getSurfaceColor(context),
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                fontWeight: FontWeight.bold,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.only(
                top: ResponsiveSystem.spacing(context, baseSpacing: 16),
                bottom: ResponsiveSystem.spacing(context, baseSpacing: 24),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
            ),
            
            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onCancel != null) ...[
                  SizedBox(
                    width: buttonConstraints.maxWidth,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        onCancel?.call();
                      },
                      child: Text(
                        cancelText ??
                            translationService.translateContent('cancel', fallback: 'Cancel'),
                        style: TextStyle(
                          fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(
                    context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                  ),
                ],
                SizedBox(
                  width: buttonConstraints.maxWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeHelpers.getErrorColor(context),
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: ResponsiveSystem.symmetric(
                        context,
                        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
                        vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
                      ),
                    ),
                    child: Text(
                      confirmText ??
                          translationService.translateContent('reset', fallback: 'Reset'),
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show the dialog
  static Future<bool?> show(
    BuildContext context, {
    required TranslationService translationService,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ResetConfirmationDialog(
        translationService: translationService,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}

