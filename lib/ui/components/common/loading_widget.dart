/// Loading Widget Component
///
/// Reusable loading indicator with optional message
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Loading Widget - Displays a loading indicator with optional message
@immutable
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });
  final String? message;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size ?? ResponsiveSystem.iconSize(context, baseSize: 48),
              height: size ?? ResponsiveSystem.iconSize(context, baseSize: 48),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeHelpers.getPrimaryColor(context),
                ),
              ),
            ),
            if (message != null) ...[
              ResponsiveSystem.sizedBox(context, height: 16),
              Text(
                message!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
