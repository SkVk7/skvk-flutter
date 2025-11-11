/// Screen Handlers Utility
///
/// Common handlers for theme, language, and profile interactions
/// Used across all screens to avoid code duplication
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/theme_provider.dart';
import '../../core/services/language/language_service.dart';
import '../../core/services/user/user_service.dart';
import '../../core/utils/either.dart';
import '../../core/utils/validation/profile_completion_checker.dart';
import '../components/dialogs/profile_completion_dialog.dart';
import '../../core/services/language/translation_service.dart';
import '../../core/navigation/hero_navigation.dart';
import '../screens/user_edit_screen.dart';

/// Screen Handlers - Common handlers for screens
class ScreenHandlers {
  /// Handle theme change
  /// Used across all screens to avoid duplication
  static void handleThemeChange(WidgetRef ref, String themeValue) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    switch (themeValue) {
      case 'light':
        themeNotifier.setThemeMode(AppThemeMode.light);
        break;
      case 'dark':
        themeNotifier.setThemeMode(AppThemeMode.dark);
        break;
      case 'system':
        themeNotifier.setThemeMode(AppThemeMode.system);
        break;
      default:
        themeNotifier.setThemeMode(AppThemeMode.system);
    }
  }

  /// Handle language change
  /// Used across all screens to avoid duplication
  static void handleLanguageChange(WidgetRef ref, String languageValue) {
    final language = switch (languageValue) {
      'en' => SupportedLanguage.english,
      'hi' => SupportedLanguage.hindi,
      'te' => SupportedLanguage.telugu,
      _ => SupportedLanguage.english,
    };

    // Change both header and content language
    ref.read(languageServiceProvider.notifier).setHeaderLanguage(language);
    ref.read(languageServiceProvider.notifier).setContentLanguage(language);
  }

  /// Handle profile icon tap - show popup if profile incomplete, otherwise navigate to profile
  /// Used across all screens to avoid duplication
  static Future<void> handleProfileTap(
    BuildContext context,
    WidgetRef ref,
    TranslationService translationService, {
    String? profileRoute,
    String? editProfileRoute,
  }) async {
    final currentContext = context;
    final profileNavRoute = profileRoute ?? '/profile';
    final editNavRoute = editProfileRoute ?? '/edit-profile';

    try {
      final userService = ref.read(userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      final user =
          ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

      // Use ProfileCompletionChecker to determine if user has real profile data
      if (user == null || !ProfileCompletionChecker.isProfileComplete(user)) {
        // Show "Complete Your Profile" popup instead of directly navigating
        showProfileCompletionPopup(currentContext, translationService, editNavRoute);
      } else {
        // Navigate to profile view screen
        Navigator.pushNamed(currentContext, profileNavRoute);
      }
    } catch (e) {
      // On error, show profile completion popup
      showProfileCompletionPopup(currentContext, translationService, editNavRoute);
    }
  }

  /// Show profile completion popup
  /// Used across all screens to avoid duplication
  static void showProfileCompletionPopup(
    BuildContext context,
    TranslationService translationService,
    String editProfileRoute,
  ) {
    ProfileCompletionDialog.show(
      context,
      translationService,
      onCompleteProfile: () {
        Navigator.pushNamed(context, editProfileRoute); // Navigate to edit screen
      },
      onSkip: () {
        // Skip action - dialog closes automatically
      },
    );
  }

  /// Navigate to profile with hero animation (if needed)
  /// Used across screens that need hero navigation
  static void navigateToProfileWithHero(
    BuildContext context,
    Offset sourcePosition,
    Size sourceSize,
  ) {
    // Use hero navigation with zoom-out effect from profile icon
    HeroNavigationWithRipple.pushWithRipple(
      context,
      const UserEditScreen(),
      sourcePosition,
      sourceSize,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      rippleColor: Theme.of(context).colorScheme.primary,
      rippleRadius: 100.0,
    );
  }
}

