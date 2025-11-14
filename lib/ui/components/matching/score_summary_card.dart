/// Score Summary Card Component
///
/// Reusable card for displaying matching score summary
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/features/matching/providers/matching_provider.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/components/matching/koota_info_helper.dart';
import 'package:skvk_application/ui/components/matching/matching_insights_helper.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Score Summary Card - Displays total score, percentage, and interpretation
class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({
    required this.matchingState,
    super.key,
  });
  final MatchingState matchingState;

  @override
  Widget build(BuildContext context) {
    // All data comes from API - no calculations here
    final totalScore = matchingState.totalScore ??
        MatchingInsightsHelper.getTotalScore(matchingState);
    const maxPossibleScore = 36;
    final percentage = matchingState.compatibilityScore?.round() ??
        (totalScore / maxPossibleScore * 100).round();

    return InfoCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Points:',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  fontWeight: FontWeight.w600,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
              Text(
                '$totalScore/$maxPossibleScore',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: KootaInfoHelper.getScoreColor(context, percentage),
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Percentage:',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  fontWeight: FontWeight.w600,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: KootaInfoHelper.getScoreColor(context, percentage),
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          LinearProgressIndicator(
            value: totalScore / maxPossibleScore,
            backgroundColor: KootaInfoHelper.getScoreColor(context, percentage)
                .withValues(alpha: 0.2),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          Text(
            MatchingInsightsHelper.getScoreInterpretation(matchingState),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeHelpers.getSecondaryTextColor(context),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
