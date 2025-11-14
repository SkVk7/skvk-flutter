/// Compatibility Insights Card Component
///
/// Reusable card for displaying overall compatibility insights
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/features/matching/providers/matching_provider.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/components/matching/koota_info_helper.dart';
import 'package:skvk_application/ui/components/matching/matching_insights_helper.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Compatibility Insights Card - Displays overall insights and compatibility message
class CompatibilityInsightsCard extends StatelessWidget {
  const CompatibilityInsightsCard({
    required this.matchingState,
    super.key,
  });
  final MatchingState matchingState;

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = ThemeHelpers.getSecondaryTextColor(context);
    final compatibilityScore = matchingState.compatibilityScore ?? 0;
    final scoreColor =
        KootaInfoHelper.getScoreColor(context, compatibilityScore.round());

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MatchingInsightsHelper.getOverallInsights(matchingState),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: secondaryTextColor,
              height: ResponsiveSystem.lineHeight(context, baseHeight: 1.4),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          InfoCard(
            backgroundColor: scoreColor.withValues(alpha: 0.1),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
            padding: ResponsiveSystem.all(context, baseSpacing: 12),
            child: Row(
              children: [
                Icon(
                  MatchingInsightsHelper.getCompatibilityIcon(matchingState),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  color: scoreColor,
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
                Expanded(
                  child: Text(
                    MatchingInsightsHelper.getCompatibilityMessage(
                        matchingState,),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
