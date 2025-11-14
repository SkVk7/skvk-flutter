/// Profile Completion Dialog Component
///
/// Reusable dialog for prompting users to complete their profile
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/ui/components/common/modern_button.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Profile Completion Dialog - Dialog shown when user needs to complete profile
@immutable
class ProfileCompletionDialog extends StatelessWidget {
  const ProfileCompletionDialog({
    required this.translationService,
    required this.onCompleteProfile,
    super.key,
    this.onSkip,
  });
  final TranslationService translationService;
  final VoidCallback onCompleteProfile;
  final VoidCallback? onSkip;

  static void show(
    BuildContext context,
    TranslationService translationService, {
    required VoidCallback onCompleteProfile,
    VoidCallback? onSkip,
  }) {
    showDialog(
      context: context,
      builder: (context) => ProfileCompletionDialog(
        translationService: translationService,
        onCompleteProfile: onCompleteProfile,
        onSkip: onSkip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = ResponsiveSystem.dialogWidth(context);
    final dialogPadding = ResponsiveSystem.dialogPadding(context);

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
            // Title Row
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: ThemeHelpers.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                Expanded(
                  child: Text(
                    translationService.translateHeader(
                      'complete_your_profile',
                      fallback: 'Complete Your Profile',
                    ),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 18),
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.only(
                top: ResponsiveSystem.spacing(context, baseSpacing: 16),
                bottom: ResponsiveSystem.spacing(context, baseSpacing: 24),
              ),
              child: Text(
                translationService.translateContent(
                  'profile_completion_message',
                  fallback:
                      'Please complete your profile with accurate birth details to unlock personalized astrology features.',
                ),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
            ),

            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onSkip != null)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right:
                            ResponsiveSystem.spacing(context, baseSpacing: 8),
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onSkip?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: ResponsiveSystem.symmetric(
                            context,
                            horizontal: ResponsiveSystem.spacing(context,
                                baseSpacing: 16,),
                            vertical: ResponsiveSystem.spacing(context,
                                baseSpacing: 12,),
                          ),
                          side: BorderSide(
                            color: ThemeHelpers.getSecondaryTextColor(context),
                            width: ResponsiveSystem.borderWidth(context,
                                baseWidth: 1,),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: ResponsiveSystem.circular(context,
                                baseRadius: 8,),
                          ),
                        ),
                        child: Text(
                          translationService.translateContent('close',
                              fallback: 'Close',),
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context,
                                baseSize: 14,),
                            fontWeight: FontWeight.w600,
                            color: ThemeHelpers.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: onSkip != null
                          ? ResponsiveSystem.spacing(context, baseSpacing: 8)
                          : 0,
                    ),
                    child: ModernButton(
                      text: translationService.translateContent(
                        'complete_profile',
                        fallback: 'Complete Profile',
                      ),
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onCompleteProfile();
                      },
                      height: ResponsiveSystem.buttonHeight(context,
                          baseHeight: 40,),
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
}
