/// Quick Actions Section Component
///
/// Reusable section with two pill action cards (responsive layout)
library;

import 'package:flutter/material.dart';
import '../../utils/responsive_system.dart';
import '../cards/pill_action_card.dart';
import '../../../core/services/language/translation_service.dart';

/// Quick Actions Section - Two pill action cards with responsive layout
class QuickActionsSection extends StatelessWidget {
  final TranslationService translationService;
  final VoidCallback onBirthChartTap;
  final VoidCallback onCalendarTap;
  final String? birthChartTitle;
  final String? calendarTitle;

  const QuickActionsSection({
    super.key,
    required this.translationService,
    required this.onBirthChartTap,
    required this.onCalendarTap,
    this.birthChartTitle,
    this.calendarTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, screenSize, screenDimensions, aspectRatio, orientation) {
        final isVerySmall = screenDimensions.width < 400;

        if (isVerySmall) {
          // Stack vertically on very small screens to prevent overflow
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: PillActionCard(
                  title: birthChartTitle ??
                      translationService.translateHeader(
                        'my_birth_chart',
                        fallback: 'My Birth Chart',
                      ),
                  icon: Icons.star,
                  onTap: onBirthChartTap,
                ),
              ),
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              SizedBox(
                width: double.infinity,
                child: PillActionCard(
                  title: calendarTitle ??
                      translationService.translateHeader(
                        'sacred_calendar',
                        fallback: 'Sacred Calendar',
                      ),
                  icon: Icons.calendar_today,
                  onTap: onCalendarTap,
                ),
              ),
            ],
          );
        }

        // Row layout for larger screens with proper constraints
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: PillActionCard(
                title: birthChartTitle ??
                    translationService.translateHeader(
                      'my_birth_chart',
                      fallback: 'My Birth Chart',
                    ),
                icon: Icons.star,
                onTap: onBirthChartTap,
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            Expanded(
              child: PillActionCard(
                title: calendarTitle ??
                    translationService.translateHeader(
                      'sacred_calendar',
                      fallback: 'Sacred Calendar',
                    ),
                icon: Icons.calendar_today,
                onTap: onCalendarTap,
              ),
            ),
          ],
        );
      },
    );
  }
}

