import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/design_system.dart';

class WeeklyPredictionsTab extends StatelessWidget {
  const WeeklyPredictionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: backgroundGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendar,
              size: ResponsiveSystem.iconSize(context, baseSize: 64),
              color: ThemeHelpers.getPrimaryColor(context),
            ),
            SizedBox(
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            Text(
              'Weekly Predictions',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
            SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
            SizedBox(
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            Container(
              padding: EdgeInsets.all(
                ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveSystem.spacing(context, baseSpacing: 32),
              ),
              decoration: BoxDecoration(
                color: ThemeHelpers.getSurfaceColor(context)
                    .withValues(alpha: 0.8),
                borderRadius:
                    ResponsiveSystem.circular(context, baseRadius: 12),
              ),
              child: Text(
                'Weekly predictions will provide detailed insights for the entire week, including planetary transits, auspicious days, and comprehensive guidance.',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
