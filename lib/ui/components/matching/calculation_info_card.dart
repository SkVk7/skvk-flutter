/// Calculation Info Card Component
///
/// Reusable card for displaying calculation approach information
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Calculation Info Card - Displays calculation approach and key features
@immutable
class CalculationInfoCard extends StatelessWidget {
  const CalculationInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.info,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
                color: ThemeHelpers.getPrimaryColor(context),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 8),
              ),
              Text(
                'Our Calculation Approach',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          Text(
            'We use the traditional Ashta Koota system based on classical Vedic astrology texts (Brihat Parashara Hora Shastra) with Swiss Ephemeris precision (99.9% accuracy).',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeHelpers.getSecondaryTextColor(context),
              height: ResponsiveSystem.lineHeight(context, baseHeight: 1.5),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          Container(
            padding: ResponsiveSystem.all(context, baseSpacing: 12),
            decoration: BoxDecoration(
              color: ThemeHelpers.getPrimaryColor(context).withAlpha(25),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              border: Border.all(
                color: ThemeHelpers.getPrimaryColor(context).withAlpha(50),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Features:',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight: FontWeight.w600,
                    color: ThemeHelpers.getPrimaryColor(context),
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
                _buildFeatureItem(
                  context,
                  '✓ Traditional Nadi Dosha Rules',
                  'Same nakshatra + different pada = Nadi dosha nullified (8 points)',
                ),
                _buildFeatureItem(
                  context,
                  '✓ Swiss Ephemeris Accuracy',
                  '99.9% astronomical precision for all calculations',
                ),
                _buildFeatureItem(
                  context,
                  '✓ Classical Text Compliance',
                  'Follows Brihat Parashara Hora Shastra principles',
                ),
                _buildFeatureItem(
                  context,
                  '✓ Industry Standard Scoring',
                  '36-point system with authentic Vedic rules',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, String title, String description,) {
    return Padding(
      padding: ResponsiveSystem.only(
        context,
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 13),
              fontWeight: FontWeight.w500,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            width: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: ThemeHelpers.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
