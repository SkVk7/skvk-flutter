/// Feature Access Dialog Component
///
/// Reusable dialog for feature access when profile is incomplete
library;

import 'package:flutter/material.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/services/language/translation_service.dart';

/// Feature Access Dialog - Dialog shown when user tries to access a feature without completing profile
class FeatureAccessDialog extends StatelessWidget {
  final TranslationService translationService;
  final String featureName;
  final VoidCallback onCompleteProfile;
  final VoidCallback? onCancel;

  const FeatureAccessDialog({
    super.key,
    required this.translationService,
    required this.featureName,
    required this.onCompleteProfile,
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
              translationService.translateContent('complete_your_profile',
                  fallback: 'Complete Your Profile'),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: ResponsiveSystem.iconSize(context, baseSize: 48),
                    color: ThemeHelpers.getPrimaryColor(context),
                  ),
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16),
                  ),
                  Text(
                    'To access $featureName, please complete your profile first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                ],
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
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                      child: Text(
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
                      Navigator.of(context).pop();
                      onCompleteProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeHelpers.getPrimaryColor(context),
                      foregroundColor: ThemeHelpers.getPrimaryTextColor(context),
                      padding: ResponsiveSystem.symmetric(
                        context,
                        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
                        vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
                      ),
                    ),
                    child: Text(
                      translationService.translateContent(
                          'complete_profile', fallback: 'Complete Profile'),
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
  static void show(
    BuildContext context, {
    required TranslationService translationService,
    required String featureName,
    required VoidCallback onCompleteProfile,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => FeatureAccessDialog(
        translationService: translationService,
        featureName: featureName,
        onCompleteProfile: onCompleteProfile,
        onCancel: onCancel,
      ),
    );
  }
}

