/// Content Language Dropdown Widget
///
/// Dropdown widget for selecting content language (books/lyrics)
/// Stores preference across all content screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/content/content_language_service.dart';

/// Content language dropdown widget
class ContentLanguageDropdown extends ConsumerWidget {
  final Function(String)? onLanguageChanged;
  final List<String>?
      availableLanguages; // Filter to only show available languages

  const ContentLanguageDropdown({
    super.key,
    this.onLanguageChanged,
    this.availableLanguages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagePrefs = ref.watch(contentLanguageServiceProvider);

    // Filter languages to only show available ones, or all if not specified
    final languagesToShow =
        availableLanguages != null && availableLanguages!.isNotEmpty
            ? ContentLanguage.values
                .where((lang) => availableLanguages!.contains(lang.code))
                .toList()
            : ContentLanguage.values;

    // If no available languages, show empty menu
    if (languagesToShow.isEmpty) {
      return IconButton(
        icon: Icon(
          Icons.language,
          color: ThemeProperties.getAppBarTextColor(context)
              .withValues(alpha: 0.5),
          size: ResponsiveSystem.iconSize(context, baseSize: 24),
        ),
        tooltip: 'No languages available',
        onPressed: null,
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language,
        color: ThemeProperties.getAppBarTextColor(context),
        size: ResponsiveSystem.iconSize(context, baseSize: 24),
      ),
      tooltip: 'Select Content Language',
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      color: ThemeProperties.getSurfaceColor(context),
      onSelected: (String value) async {
        // Update language state first
        final language = ContentLanguage.fromCode(value);
        await ref
            .read(contentLanguageServiceProvider.notifier)
            .setContentLanguage(language);
        // Then call the callback
        onLanguageChanged?.call(value);
      },
      itemBuilder: (BuildContext context) {
        return languagesToShow.map((ContentLanguage language) {
          final isSelected = languagePrefs.selectedLanguage == language;
          return PopupMenuItem<String>(
            value: language.code,
            child: Row(
              children: [
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: ThemeProperties.getPrimaryColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  )
                else
                  ResponsiveSystem.sizedBox(
                    context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 20),
                  ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
                Text(
                  language.displayName,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    color: isSelected
                        ? ThemeProperties.getPrimaryColor(context)
                        : ThemeProperties.getPrimaryTextColor(context),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
