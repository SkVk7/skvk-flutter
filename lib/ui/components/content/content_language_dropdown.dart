/// Content Language Dropdown Widget
///
/// Dropdown widget for selecting content language (books/lyrics)
/// Stores preference across all content screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/content/content_language_service.dart';

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

    // Filter languages to only show available ones from R2
    // If availableLanguages is provided, only show those languages in the dropdown
    // This way users can see exactly which languages are available for the current book
    final languagesToShow =
        availableLanguages != null && availableLanguages!.isNotEmpty
            ? ContentLanguage.values
                .where((lang) => availableLanguages!.contains(lang.code))
                .toList()
            : ContentLanguage.values; // Fallback to all if not specified

    // If no available languages, show disabled icon with tooltip
    if (languagesToShow.isEmpty) {
      return IconButton(
        icon: Icon(
          Icons.language,
          color: ThemeHelpers.getAppBarTextColor(context)
              .withValues(alpha: 0.5),
          size: ResponsiveSystem.iconSize(context, baseSize: 24),
        ),
        tooltip: 'No languages available for this book',
        onPressed: null,
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language,
        color: ThemeHelpers.getAppBarTextColor(context),
        size: ResponsiveSystem.iconSize(context, baseSize: 24),
      ),
      tooltip: 'Select Content Language',
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      color: ThemeHelpers.getSurfaceColor(context),
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
                    color: ThemeHelpers.getPrimaryColor(context),
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
                        ? ThemeHelpers.getPrimaryColor(context)
                        : ThemeHelpers.getPrimaryTextColor(context),
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
