/// Koota Info Helper
///
/// Helper class for koota information and utilities
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Koota Info Helper - Provides koota information and utility methods
class KootaInfoHelper {
  /// Get koota information by name
  static Map<String, dynamic> getKootaInfo(String kootaName) {
    switch (kootaName) {
      case 'Varna':
        return {
          'maxScore': 1,
          'description':
              "Varna Koota represents the spiritual and ego compatibility between partners. It indicates how well the couple's spiritual values and social status align.",
          'significance':
              'This koota is crucial for long-term harmony. Higher scores indicate better spiritual alignment and mutual respect in the relationship.',
        };
      case 'Vashya':
        return {
          'maxScore': 2,
          'description':
              'Vashya Koota measures the mutual attraction and control dynamics in the relationship. It shows how well partners can influence and be influenced by each other.',
          'significance':
              'Essential for understanding power dynamics. Good scores indicate healthy mutual influence without dominance issues.',
        };
      case 'Tara':
        return {
          'maxScore': 3,
          'description':
              'Tara Koota is related to fortune, longevity, and overall well-being of the couple. It indicates the positive or negative influences on the relationship.',
          'significance':
              'Critical for marital happiness and longevity. Higher scores suggest better fortune and fewer obstacles in married life.',
        };
      case 'Yoni':
        return {
          'maxScore': 4,
          'description':
              'Yoni Koota represents sexual and physical compatibility between partners. It indicates the level of physical attraction and intimate harmony.',
          'significance':
              'Important for physical intimacy and attraction. Good scores indicate strong physical compatibility and mutual attraction.',
        };
      case 'Graha Maitri':
        return {
          'maxScore': 5,
          'description':
              'Graha Maitri Koota shows the friendship between the planetary lords of the Moon signs. It indicates mental compatibility and understanding.',
          'significance':
              'Vital for mental compatibility and friendship. Higher scores suggest better mental rapport and mutual understanding.',
        };
      case 'Gana':
        return {
          'maxScore': 6,
          'description':
              'Gana Koota categorizes partners into Deva (divine), Manushya (human), or Rakshasa (demonic) nature. It shows temperament compatibility.',
          'significance':
              'Crucial for temperament matching. Same Gana indicates similar nature and better compatibility in daily life.',
        };
      case 'Bhakoot':
        return {
          'maxScore': 7,
          'description':
              'Bhakoot Koota examines the relative positions of Moon signs. It indicates auspicious or inauspicious combinations for marital life.',
          'significance':
              'Very important for marital harmony. Good scores indicate favorable planetary positions for a successful marriage.',
        };
      case 'Nadi':
        return {
          'maxScore': 8,
          'description':
              'Nadi Koota is the most important factor, related to progeny and genetic compatibility. It indicates the health and well-being of future children.',
          'significance':
              'Most critical for progeny and genetic compatibility. Traditional rule: Same nakshatra + different pada = Nadi dosha nullified (8 points). Same nadi + same pada = Nadi dosha (0 points).',
        };
      default:
        return {
          'maxScore': 1,
          'description':
              'This koota represents an important aspect of compatibility analysis.',
          'significance':
              'This factor plays a significant role in determining overall compatibility.',
        };
    }
  }

  /// Get score color based on percentage
  static Color getScoreColor(BuildContext context, int percentage) {
    if (percentage >= 80) {
      return ThemeHelpers.getSecondaryColor(context);
    } else if (percentage >= 60) {
      return ThemeHelpers.getPrimaryColor(context);
    } else if (percentage >= 40) {
      return ThemeHelpers.getPrimaryColor(context);
    } else {
      return ThemeHelpers.getErrorColor(context);
    }
  }

  /// Check if a key represents a koota score (not birth data)
  static bool isKootaScore(String key) {
    const kootaKeys = [
      'Varna',
      'Vashya',
      'Tara',
      'Yoni',
      'Graha Maitri',
      'Gana',
      'Bhakoot',
      'Nadi',
      'totalPoints',
    ];
    return kootaKeys.contains(key);
  }
}
