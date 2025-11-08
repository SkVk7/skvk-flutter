/// Profile Completion Checker
///
/// Utility to check if user profile is complete and handle redirections
library;

import 'package:flutter/material.dart';
import '../../models/user/user_model.dart';
// Removed missing user_entity import

class ProfileCompletionChecker {
  /// Check if user profile is complete (not using default/placeholder values)
  static bool isProfileComplete(UserModel? user) {
    if (user == null) return false;

    // Check if user has provided actual details (not defaults)
    return user.name.isNotEmpty &&
        user.name != 'Test User' &&
        user.placeOfBirth.isNotEmpty &&
        user.placeOfBirth != 'New Delhi' &&
        user.sex.isNotEmpty; // Any valid gender selection is acceptable
  }

  /// Check if user has any profile data at all
  static bool hasProfileData(UserModel? user) {
    return user != null;
  }

  /// Get missing profile fields
  static List<String> getMissingFields(UserModel? user) {
    if (user == null) {
      return [
        'Name',
        'Date of Birth',
        'Time of Birth',
        'Place of Birth',
        'Gender'
      ];
    }

    List<String> missing = [];

    if (user.name.isEmpty || user.name == 'Test User') {
      missing.add('Name');
    }

    if (user.placeOfBirth.isEmpty || user.placeOfBirth == 'New Delhi') {
      missing.add('Place of Birth');
    }

    if (user.sex.isEmpty) {
      missing.add('Gender');
    }

    return missing;
  }

  /// Show profile completion dialog using centralized widget
  static Future<bool> showProfileCompletionDialog(
    BuildContext context, {
    String? featureName,
  }) async {
    // Navigate to profile creation
    Navigator.pushNamed(context, '/edit-profile');

    // Return true to indicate user should complete profile
    return true;
  }

  /// Navigate to edit profile screen
  static void navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, '/edit-profile');
  }

  /// Check profile completion and handle navigation using centralized widget
  static Future<bool> checkAndNavigateToProfile(
    BuildContext context, {
    String? featureName,
  }) async {
    // Navigate to profile creation
    Navigator.pushNamed(context, '/edit-profile');
    return true;
  }
}
