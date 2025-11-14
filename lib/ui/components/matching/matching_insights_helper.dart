/// Matching Insights Helper
///
/// Helper class for generating compatibility insights and messages
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/features/matching/providers/matching_provider.dart';

/// Matching Insights Helper
///
/// Reads data from the astrology-service API response only - no business logic
/// All insights, messages, and icons come from the API
class MatchingInsightsHelper {
  /// Get overall compatibility insights text from API
  /// Returns recommendation from API, or fallback if not available
  static String getOverallInsights(MatchingState matchingState) {
    // Use recommendation from API if available
    if (matchingState.recommendation != null &&
        matchingState.recommendation!.isNotEmpty) {
      return matchingState.recommendation!;
    }
    // Fallback if API doesn't provide recommendation
    return 'Compatibility analysis completed. Review the detailed koota scores below.';
  }

  /// Get compatibility icon based on level from API
  static IconData getCompatibilityIcon(MatchingState matchingState) {
    // Use level from API to determine icon
    final level = matchingState.level?.toLowerCase() ?? '';
    if (level.contains('excellent') || level.contains('high')) {
      return LucideIcons.heart;
    } else if (level.contains('good') || level.contains('recommended')) {
      return LucideIcons.thumbsUp;
    } else if (level.contains('moderate') || level.contains('average')) {
      return LucideIcons.info;
    } else {
      return LucideIcons.triangleAlert;
    }
  }

  /// Get compatibility message from API
  /// Returns level from API, or fallback based on score
  static String getCompatibilityMessage(MatchingState matchingState) {
    // Use level from API if available
    if (matchingState.level != null && matchingState.level!.isNotEmpty) {
      return matchingState.level!;
    }
    // Fallback based on score if level not available
    final score = matchingState.compatibilityScore ?? 0;
    if (score >= 80) {
      return 'Excellent Match';
    } else if (score >= 60) {
      return 'Good Match';
    } else if (score >= 40) {
      return 'Moderate Match';
    } else {
      return 'Challenging Match';
    }
  }

  /// Get score interpretation from API
  /// Returns recommendation from API, or fallback if not available
  static String getScoreInterpretation(MatchingState matchingState) {
    // Use recommendation from API if available
    if (matchingState.recommendation != null &&
        matchingState.recommendation!.isNotEmpty) {
      return matchingState.recommendation!;
    }
    // Fallback if API doesn't provide recommendation
    final totalScore = matchingState.totalScore ?? 0;
    if (totalScore >= 30) {
      return 'Excellent compatibility - Highly recommended for marriage';
    } else if (totalScore >= 24) {
      return 'Good compatibility - Recommended with understanding';
    } else if (totalScore >= 18) {
      return 'Moderate compatibility - Requires mutual effort';
    } else if (totalScore >= 12) {
      return 'Challenging compatibility - Needs careful consideration';
    } else {
      return 'Low compatibility - Significant challenges expected';
    }
  }

  /// Get total score from matching state (from API)
  static int getTotalScore(MatchingState matchingState) {
    // Use totalScore from API if available
    if (matchingState.totalScore != null) {
      return matchingState.totalScore!;
    }
    // Fallback: try to get totalPoints from kootaDetails (from API)
    if (matchingState.kootaDetails?['totalPoints'] != null) {
      final totalPointsStr = matchingState.kootaDetails!['totalPoints'];
      return int.tryParse(totalPointsStr ?? '0') ?? 0;
    }
    return 0;
  }
}
