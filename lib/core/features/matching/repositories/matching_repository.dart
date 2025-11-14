/// Matching Repository Interface
///
/// Domain interface for matching operations
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Matching result data
/// All data comes from the astrology-service API - no business logic here
class MatchingResult {
  // Total score out of 36 from API

  const MatchingResult({
    required this.compatibilityScore,
    required this.kootaDetails,
    required this.level,
    required this.recommendation,
    required this.totalScore,
  });
  final double compatibilityScore; // Percentage from API
  final Map<String, String> kootaDetails; // Koota scores from API
  final String
      level; // Compatibility level from API (e.g., "Excellent", "Good", "Moderate", "Challenging")
  final String recommendation; // Recommendation text from API
  final int totalScore;
}

/// Partner data for matching
class PartnerData {
  // Optional: if this is the current user

  const PartnerData({
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.latitude,
    required this.longitude,
    this.currentUser,
  });
  final String name;
  final DateTime dateOfBirth;
  final TimeOfDay timeOfBirth;
  final String placeOfBirth;
  final double latitude;
  final double longitude;
  final UserModel? currentUser;
}

/// Matching repository interface
// ignore: one_member_abstracts
abstract class MatchingRepository {
  /// Perform compatibility matching with both persons' data
  Future<Result<MatchingResult>> performMatching(
    PartnerData person1Data,
    PartnerData person2Data, {
    String? ayanamsha,
    String? houseSystem,
  });
}
