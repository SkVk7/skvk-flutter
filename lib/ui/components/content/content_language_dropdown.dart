/// Content Language Dropdown Widget
///
/// Dropdown widget for selecting content language (books/lyrics)
/// Stores preference across all content screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/services/content/content_language_service.dart';

/// Content language dropdown widget
class ContentLanguageDropdown extends ConsumerWidget {
  // Filter to only show available languages

  const ContentLanguageDropdown({
    super.key,
    this.onLanguageChanged,
    this.availableLanguages,
  });
  final Function(String)? onLanguageChanged;
  final List<String>? availableLanguages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languagePrefs = ref.watch(contentLanguageServiceProvider);

    // Filter languages to only show available ones from R2
    final languagesToShow =
        availableLanguages != null && availableLanguages!.isNotEmpty
            ? ContentLanguage.values
                .where((lang) => availableLanguages!.contains(lang.code))
                .toList()
            : ContentLanguage.values; // Fallback to all if not specified

    if (languagesToShow.isEmpty) {
      return IconButton(
        icon: Icon(
          Icons.language,
          color:
              ThemeHelpers.getAppBarTextColor(context).withValues(alpha: 0.5),
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
      onSelected: (value) async {
        final language = ContentLanguage.fromCode(value);
        await ref
            .read(contentLanguageServiceProvider.notifier)
            .setContentLanguage(language);
        onLanguageChanged?.call(value);
      },
      itemBuilder: (context) {
        return languagesToShow.map((language) {
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
