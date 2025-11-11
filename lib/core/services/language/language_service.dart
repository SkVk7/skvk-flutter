/// Language Service
///
/// Manages language preferences for headers and content
/// Supports multiple Indian languages popular among Hindus
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SupportedLanguage {
  english,
  hindi,
  telugu,
  tamil,
  kannada,
  malayalam,
  bengali,
  gujarati,
  marathi,
  punjabi,
  odia,
  assamese,
}

enum LanguageType {
  header,
  content,
}

class LanguagePreferences {
  final SupportedLanguage headerLanguage;
  final SupportedLanguage contentLanguage;

  const LanguagePreferences({
    required this.headerLanguage,
    required this.contentLanguage,
  });

  LanguagePreferences copyWith({
    SupportedLanguage? headerLanguage,
    SupportedLanguage? contentLanguage,
  }) {
    return LanguagePreferences(
      headerLanguage: headerLanguage ?? this.headerLanguage,
      contentLanguage: contentLanguage ?? this.contentLanguage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguagePreferences &&
        other.headerLanguage == headerLanguage &&
        other.contentLanguage == contentLanguage;
  }

  @override
  int get hashCode => headerLanguage.hashCode ^ contentLanguage.hashCode;

  @override
  String toString() =>
      'LanguagePreferences(header: $headerLanguage, content: $contentLanguage)';
}

class LanguageService extends Notifier<LanguagePreferences> {
  static const String _headerLanguageKey = 'header_language';
  static const String _contentLanguageKey = 'content_language';

  @override
  LanguagePreferences build() {
    _loadPreferences();
    return const LanguagePreferences(
      headerLanguage: SupportedLanguage.english,
      contentLanguage: SupportedLanguage.english,
    );
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final headerIndex =
          prefs.getInt(_headerLanguageKey) ?? SupportedLanguage.english.index;
      final contentIndex =
          prefs.getInt(_contentLanguageKey) ?? SupportedLanguage.english.index;

      state = LanguagePreferences(
        headerLanguage: SupportedLanguage.values[headerIndex],
        contentLanguage: SupportedLanguage.values[contentIndex],
      );
    } catch (e) {
      // Keep default values
    }
  }

  Future<void> setHeaderLanguage(SupportedLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_headerLanguageKey, language.index);

      state = state.copyWith(headerLanguage: language);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setContentLanguage(SupportedLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_contentLanguageKey, language.index);

      state = state.copyWith(contentLanguage: language);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setBothLanguages(SupportedLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_headerLanguageKey, language.index);
      await prefs.setInt(_contentLanguageKey, language.index);

      state = LanguagePreferences(
        headerLanguage: language,
        contentLanguage: language,
      );
    } catch (e) {
      // Handle error silently
    }
  }
}

// Provider for language service
final languageServiceProvider =
    NotifierProvider<LanguageService, LanguagePreferences>(() {
  return LanguageService();
});

// Extension for language display names
extension SupportedLanguageExtension on SupportedLanguage {
  String get displayName {
    switch (this) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.hindi:
        return 'हिन्दी';
      case SupportedLanguage.telugu:
        return 'తెలుగు';
      case SupportedLanguage.tamil:
        return 'தமிழ்';
      case SupportedLanguage.kannada:
        return 'ಕನ್ನಡ';
      case SupportedLanguage.malayalam:
        return 'മലയാളം';
      case SupportedLanguage.bengali:
        return 'বাংলা';
      case SupportedLanguage.gujarati:
        return 'ગુજરાતી';
      case SupportedLanguage.marathi:
        return 'मराठी';
      case SupportedLanguage.punjabi:
        return 'ਪੰਜਾਬੀ';
      case SupportedLanguage.odia:
        return 'ଓଡ଼ିଆ';
      case SupportedLanguage.assamese:
        return 'অসমীয়া';
    }
  }

  String get nativeName {
    switch (this) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.hindi:
        return 'हिन्दी';
      case SupportedLanguage.telugu:
        return 'తెలుగు';
      case SupportedLanguage.tamil:
        return 'தமிழ்';
      case SupportedLanguage.kannada:
        return 'ಕನ್ನಡ';
      case SupportedLanguage.malayalam:
        return 'മലയാളം';
      case SupportedLanguage.bengali:
        return 'বাংলা';
      case SupportedLanguage.gujarati:
        return 'ગુજરાતી';
      case SupportedLanguage.marathi:
        return 'मराठी';
      case SupportedLanguage.punjabi:
        return 'ਪੰਜਾਬੀ';
      case SupportedLanguage.odia:
        return 'ଓଡ଼ିଆ';
      case SupportedLanguage.assamese:
        return 'অসমীয়া';
    }
  }

  String get flag {
    switch (this) {
      case SupportedLanguage.english:
        return '🇺🇸';
      case SupportedLanguage.hindi:
        return '🇮🇳';
      case SupportedLanguage.telugu:
        return '🇮🇳';
      case SupportedLanguage.tamil:
        return '🇮🇳';
      case SupportedLanguage.kannada:
        return '🇮🇳';
      case SupportedLanguage.malayalam:
        return '🇮🇳';
      case SupportedLanguage.bengali:
        return '🇮🇳';
      case SupportedLanguage.gujarati:
        return '🇮🇳';
      case SupportedLanguage.marathi:
        return '🇮🇳';
      case SupportedLanguage.punjabi:
        return '🇮🇳';
      case SupportedLanguage.odia:
        return '🇮🇳';
      case SupportedLanguage.assamese:
        return '🇮🇳';
    }
  }
}
