/// Content Language Service
///
/// Service for storing and retrieving content language preference
/// for books and lyrics across the application
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';

/// Supported content languages (ISO 639-1 codes)
enum ContentLanguage {
  english('en', 'English'),
  hindi('hi', 'हिंदी'),
  telugu('te', 'తెలుగు'),
  tamil('ta', 'தமிழ்'),
  kannada('kn', 'ಕನ್ನಡ'),
  marathi('mr', 'मराठी'),
  gujarati('gu', 'ગુજરાતી'),
  bengali('bn', 'বাংলা'),
  odia('or', 'ଓଡ଼ିଆ'),
  punjabi('pa', 'ਪੰਜਾਬੀ'),
  malayalam('ml', 'മലയാളം'),
  assamese('as', 'অসমীয়া'),
  nepali('ne', 'नेपाली'),
  urdu('ur', 'اردو'),
  sanskrit('sa', 'संस्कृतम्');

  const ContentLanguage(this.code, this.displayName);

  final String code;
  final String displayName;

  static ContentLanguage fromCode(String code) {
    return ContentLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => ContentLanguage.english,
    );
  }
}

/// Content language preferences state
class ContentLanguagePreferences {
  const ContentLanguagePreferences({
    this.selectedLanguage = ContentLanguage.english,
  });
  final ContentLanguage selectedLanguage;

  ContentLanguagePreferences copyWith({
    ContentLanguage? selectedLanguage,
  }) {
    return ContentLanguagePreferences(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

/// Content language service provider
final contentLanguageServiceProvider =
    NotifierProvider<ContentLanguageService, ContentLanguagePreferences>(
  ContentLanguageService.new,
);

/// Content language service
class ContentLanguageService extends Notifier<ContentLanguagePreferences> {
  static const String _contentLanguageKey = 'content_language_preference';

  @override
  ContentLanguagePreferences build() {
    _loadPreferences();
    return const ContentLanguagePreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_contentLanguageKey) ?? 'en';
      final language = ContentLanguage.fromCode(languageCode);

      state = ContentLanguagePreferences(selectedLanguage: language);
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to load content language preference',
        source: 'ContentLanguageService',
        error: e,
      );
      // Keep default value
    }
  }

  Future<void> setContentLanguage(ContentLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_contentLanguageKey, language.code);

      state = state.copyWith(selectedLanguage: language);
      await LoggingHelper.logInfo(
        'Content language set to: ${language.displayName} (${language.code})',
        source: 'ContentLanguageService',
      );
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Failed to save content language preference',
        source: 'ContentLanguageService',
        error: e,
      );
    }
  }

  String getCurrentLanguageCode() {
    return state.selectedLanguage.code;
  }
}
