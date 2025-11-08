import '../../../../core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class WeeklyPredictionsTab extends StatelessWidget {
  const WeeklyPredictionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
      isEvening: false,
      useSacredFire: false,
    );

    return Container(
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
              color: ThemeProperties.getPrimaryColor(context),
            ),
            SizedBox(
                height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
            Text(
              'Weekly Predictions',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
            SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
            ),
            SizedBox(
                height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
            Container(
              padding: EdgeInsets.all(
                  ResponsiveSystem.spacing(context, baseSpacing: 16)),
              margin: EdgeInsets.symmetric(
                  horizontal:
                      ResponsiveSystem.spacing(context, baseSpacing: 32)),
              decoration: BoxDecoration(
                color: ThemeProperties.getSurfaceColor(context)
                    .withAlpha((0.8 * 255).round()),
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
              ),
              child: Text(
                'Weekly predictions will provide detailed insights for the entire week, including planetary transits, auspicious days, and comprehensive guidance.',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryTextColor(context),
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
