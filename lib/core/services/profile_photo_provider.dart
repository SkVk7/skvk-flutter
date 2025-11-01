/// Profile Photo Provider
///
/// Manages the global state of the user's profile photo
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_photo_service.dart';

/// Provider for loading the profile photo
final profilePhotoNotifierProvider = AsyncNotifierProvider<ProfilePhotoNotifier, String?>(() {
  return ProfilePhotoNotifier();
});

/// Notifier for profile photo state
class ProfilePhotoNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return await ProfilePhotoService.getProfilePhotoPath();
  }

  /// Update the profile photo path
  void updatePhotoPath(String? photoPath) {
    state = AsyncValue.data(photoPath);
  }

  /// Clear the profile photo
  void clearPhoto() {
    state = const AsyncValue.data(null);
  }
}
