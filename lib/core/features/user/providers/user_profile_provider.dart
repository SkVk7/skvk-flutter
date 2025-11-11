/// User Profile State Management
///
/// Proper state management following Flutter best practices
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user/user_service.dart';
import '../../../utils/either.dart';
import '../../../utils/validation/error_message_helper.dart';
import '../../../../ui/components/user/user_profile_form.dart';

/// User profile state
class UserProfileState {
  final UserProfileFormData? formData;
  final bool isLoading;
  final bool isEditing;
  final String? errorMessage;
  final String? successMessage;

  const UserProfileState({
    this.formData,
    this.isLoading = false,
    this.isEditing = false,
    this.errorMessage,
    this.successMessage,
  });

  UserProfileState copyWith({
    UserProfileFormData? formData,
    bool? isLoading,
    bool? isEditing,
    String? errorMessage,
    String? successMessage,
  }) {
    return UserProfileState(
      formData: formData ?? this.formData,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get hasUser => formData != null;
  bool get canEdit => hasUser && !isLoading;
}

/// User profile notifier
class UserProfileNotifier extends Notifier<UserProfileState> {
  late final UserService _userService;

  @override
  UserProfileState build() {
    _userService = ref.read(userServiceProvider.notifier);
    _loadUserData();
    return const UserProfileState();
  }

  /// Load user data from service
  Future<void> _loadUserData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _userService.getCurrentUser();

      if (result.isSuccess && result.value != null) {
        final user = result.value!;
        final formData = UserProfileFormData(
          name: user.name,
          dateOfBirth: user.dateOfBirth,
          timeOfBirth: TimeOfDay(
            hour: user.timeOfBirth.hour,
            minute: user.timeOfBirth.minute,
          ),
          placeOfBirth: user.placeOfBirth,
          latitude: user.latitude,
          longitude: user.longitude,
          ayanamsha: user.ayanamsha,
        );

        state = state.copyWith(
          formData: formData,
          isLoading: false,
          isEditing: false,
        );
      } else {
        // Convert technical error to user-friendly message
        final errorMessage =
            result.failure?.message ?? 'Failed to load user data';
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(errorMessage);
        state = state.copyWith(
          isLoading: false,
          errorMessage: userFriendlyMessage,
        );
      }
    } catch (e) {
      // Convert technical error to user-friendly message
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
      );
    }
  }

  /// Start editing mode
  void startEditing() {
    if (state.canEdit) {
      state = state.copyWith(isEditing: true, errorMessage: null);
    }
  }

  /// Cancel editing mode
  void cancelEditing() {
    state = state.copyWith(isEditing: false, errorMessage: null);
    // Reload data to reset any changes
    _loadUserData();
  }

  /// Update form data
  void updateFormData(UserProfileFormData formData) {
    state = state.copyWith(formData: formData);
  }

  /// Save user data
  Future<void> saveUser(UserProfileFormData formData) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);

    try {
      final userModel = formData.toUserModel();
      final result = await _userService.saveUser(userModel);

      if (result.isSuccess) {
        state = state.copyWith(
          formData: formData,
          isLoading: false,
          isEditing: false,
          successMessage: 'Profile saved successfully!',
        );

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          state = state.copyWith(successMessage: null);
        });
      } else {
        // Convert technical error to user-friendly message
        final errorMessage =
            result.failure?.message ?? 'Failed to save profile';
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(errorMessage);
        state = state.copyWith(
          isLoading: false,
          errorMessage: userFriendlyMessage,
        );
      }
    } catch (e) {
      // Convert technical error to user-friendly message
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
      );
    }
  }

  /// Delete user data
  Future<void> deleteUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _userService.deleteUser();

      if (result.isSuccess) {
        state = const UserProfileState(
          successMessage: 'Profile deleted successfully!',
        );
      } else {
        // Convert technical error to user-friendly message
        final errorMessage =
            result.failure?.message ?? 'Failed to delete profile';
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(errorMessage);
        state = state.copyWith(
          isLoading: false,
          errorMessage: userFriendlyMessage,
        );
      }
    } catch (e) {
      // Convert technical error to user-friendly message
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  /// Refresh user data
  Future<void> refresh() async {
    await _loadUserData();
  }
}

/// User profile provider
final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(() {
  return UserProfileNotifier();
});

/// Convenience providers for specific state parts
final userProfileFormDataProvider = Provider<UserProfileFormData?>((ref) {
  return ref.watch(userProfileProvider).formData;
});

final userProfileIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isLoading;
});

final userProfileIsEditingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isEditing;
});

final userProfileErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(userProfileProvider).errorMessage;
});

final userProfileSuccessMessageProvider = Provider<String?>((ref) {
  return ref.watch(userProfileProvider).successMessage;
});

final userProfileHasUserProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).hasUser;
});
