/// Koota Card Component
///
/// Reusable card for displaying koota analysis results
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import 'koota_info_helper.dart';
import '../common/index.dart';

/// Koota Card - Displays koota analysis with score, description, and significance
class KootaCard extends StatelessWidget {
  final String kootaName;
  final String score;
  final Map<String, dynamic> kootaInfo;

  const KootaCard({
    super.key,
    required this.kootaName,
    required this.score,
    required this.kootaInfo,
  });

  @override
  Widget build(BuildContext context) {
    final maxScore = kootaInfo['maxScore'] as int;
    final scoreValue = double.tryParse(score) ?? 0.0;
    final percentage = (scoreValue / maxScore * 100).round();
    final primaryTextColor = ThemeHelpers.getPrimaryTextColor(context);
    final secondaryTextColor = ThemeHelpers.getSecondaryTextColor(context);
    final scoreColor = KootaInfoHelper.getScoreColor(context, percentage);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Koota Name and Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kootaName,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              InfoCard(
                backgroundColor: scoreColor.withAlpha(25),
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
                padding: ResponsiveSystem.symmetric(context,
                    horizontal: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    vertical: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                child: Text(
                  '$score/$maxScore',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8)),

          // Progress Bar
          LinearProgressIndicator(
            value: scoreValue / maxScore,
            backgroundColor: scoreColor.withAlpha((0.2 * 255).round()),
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12)),

          // Description
          Text(
            kootaInfo['description'] as String,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: secondaryTextColor,
              height: ResponsiveSystem.lineHeight(context, baseHeight: 1.4),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8)),

          // Significance
          InfoCard(
            backgroundColor: ThemeHelpers.getPrimaryColor(context)
                .withAlpha((0.05 * 255).round()),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
            padding: ResponsiveSystem.all(context,
                baseSpacing: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: ResponsiveSystem.iconSize(context, baseSize: 16),
                      color: ThemeHelpers.getPrimaryColor(context),
                    ),
                    ResponsiveSystem.sizedBox(context,
                        width: ResponsiveSystem.spacing(context, baseSpacing: 6)),
                    Text(
                      'Significance:',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        fontWeight: FontWeight.w600,
                        color: ThemeHelpers.getPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                Text(
                  kootaInfo['significance'] as String,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 13),
                    color: secondaryTextColor,
                    height: ResponsiveSystem.lineHeight(context, baseHeight: 1.3),
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

