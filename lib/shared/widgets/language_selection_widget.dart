/// Language Selection Widget
///
/// A modern, responsive language selection widget with header/content options
/// Follows the application's theme and sizing system
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../core/services/language_service.dart';
import '../../core/services/translation_service.dart';
import '../../core/design_system/design_system.dart';

class LanguageSelectionWidget extends ConsumerStatefulWidget {
  const LanguageSelectionWidget({super.key});

  @override
  ConsumerState<LanguageSelectionWidget> createState() => _LanguageSelectionWidgetState();
}

class _LanguageSelectionWidgetState extends ConsumerState<LanguageSelectionWidget> {
  bool _useSameLanguage = false;
  SupportedLanguage? _tempHeaderLanguage;
  SupportedLanguage? _tempContentLanguage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeTempLanguages();
  }

  void _initializeTempLanguages() {
    final languagePrefs = ref.read(languageServiceProvider);
    _tempHeaderLanguage = languagePrefs.headerLanguage;
    _tempContentLanguage = languagePrefs.contentLanguage;
    _useSameLanguage = languagePrefs.headerLanguage == languagePrefs.contentLanguage;
    _hasChanges = false;
  }

  @override
  Widget build(BuildContext context) {
    final languagePrefs = ref.watch(languageServiceProvider);
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final primaryTextColor = ThemeProperties.getPrimaryTextColor(context);
    final secondaryTextColor = ThemeProperties.getSecondaryTextColor(context);
    final surfaceColor = ThemeProperties.getSurfaceColor(context);
    final cardBackgroundColor = ThemeProperties.getSurfaceColor(context);
    final borderColor = ThemeProperties.getPrimaryColor(context).withAlpha((0.2 * 255).round());
    final shadowColor = ThemeProperties.getPrimaryColor(context).withAlpha((0.1 * 255).round());

    return Container(
      padding: EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 16)),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 16)),
        border: Border.all(
          color: borderColor,
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: ResponsiveSystem.elevation(context, baseElevation: 8),
            offset: Offset(0, ResponsiveSystem.elevation(context, baseElevation: 4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                LucideIcons.globe,
                size: ResponsiveSystem.iconSize(context, baseSize: 24),
                color: primaryColor,
              ),
              SizedBox(width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
              Expanded(
                child: Text(
                  TranslationService()
                      .translate('language_settings', fallback: 'Language Settings'),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ),
              // Toggle Button for Same Language Mode
              _buildSameLanguageToggle(
                primaryColor: primaryColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
              SizedBox(width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  LucideIcons.x,
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 20)),

          // Language Selection based on toggle state
          if (_useSameLanguage) ...[
            // Single Language Selection (when toggle is ON)
            _buildLanguageSelector(
              title: globalTranslationService.translateHeader('language', fallback: 'Language'),
              subtitle: 'For both headers and content',
              currentLanguage: _tempHeaderLanguage ?? languagePrefs.headerLanguage,
              onChanged: (language) {
                setState(() {
                  _tempHeaderLanguage = language;
                  _tempContentLanguage = language;
                  _hasChanges = true;
                });
              },
              primaryColor: primaryColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              surfaceColor: surfaceColor,
            ),
          ] else ...[
            // Header Language Selection (when toggle is OFF)
            _buildLanguageSelector(
              title: globalTranslationService.translateHeader('header_language',
                  fallback: 'Header Language'),
              subtitle: 'For titles and headings',
              currentLanguage: _tempHeaderLanguage ?? languagePrefs.headerLanguage,
              onChanged: (language) {
                setState(() {
                  _tempHeaderLanguage = language;
                  _hasChanges = true;
                });
              },
              primaryColor: primaryColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              surfaceColor: surfaceColor,
            ),

            SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 20)),

            // Content Language Selection (when toggle is OFF)
            _buildLanguageSelector(
              title: globalTranslationService.translateHeader('content_language',
                  fallback: 'Content Language'),
              subtitle: 'For descriptions and content',
              currentLanguage: _tempContentLanguage ?? languagePrefs.contentLanguage,
              onChanged: (language) {
                setState(() {
                  _tempContentLanguage = language;
                  _hasChanges = true;
                });
              },
              primaryColor: primaryColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              surfaceColor: surfaceColor,
            ),
          ],

          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 20)),

          // Save Button
          if (_hasChanges)
            _buildSaveButton(
              primaryColor: primaryColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),

          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

          // Current Selection Info
          _buildCurrentSelectionInfo(
            languagePrefs: languagePrefs,
            primaryColor: primaryColor,
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector({
    required String title,
    required String subtitle,
    required SupportedLanguage currentLanguage,
    required Function(SupportedLanguage) onChanged,
    required Color primaryColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color surfaceColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
            color: secondaryTextColor,
          ),
        ),
        SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 12)),

        // Language Grid
        _buildLanguageGrid(
          currentLanguage: currentLanguage,
          onChanged: onChanged,
          primaryColor: primaryColor,
          primaryTextColor: primaryTextColor,
          surfaceColor: surfaceColor,
        ),
      ],
    );
  }

  Widget _buildLanguageGrid({
    required SupportedLanguage currentLanguage,
    required Function(SupportedLanguage) onChanged,
    required Color primaryColor,
    required Color primaryTextColor,
    required Color surfaceColor,
  }) {
    // Popular languages for Hindu audience
    final popularLanguages = [
      SupportedLanguage.english,
      SupportedLanguage.hindi,
      SupportedLanguage.telugu,
      SupportedLanguage.tamil,
      SupportedLanguage.kannada,
      SupportedLanguage.malayalam,
      SupportedLanguage.bengali,
      SupportedLanguage.gujarati,
      SupportedLanguage.marathi,
      SupportedLanguage.punjabi,
    ];

    return Wrap(
      spacing: ResponsiveSystem.spacing(context, baseSpacing: 8),
      runSpacing: ResponsiveSystem.spacing(context, baseSpacing: 8),
      children: popularLanguages.map((language) {
        final isSelected = currentLanguage == language;

        return GestureDetector(
          onTap: () => onChanged(language),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 12),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : surfaceColor,
              borderRadius:
                  BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 8)),
              border: Border.all(
                color: isSelected ? primaryColor : primaryColor.withAlpha((0.3 * 255).round()),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  language.flag,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  ),
                ),
                SizedBox(width: ResponsiveSystem.spacing(context, baseSpacing: 6)),
                Text(
                  language.nativeName,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                    color: isSelected
                        ? ThemeProperties.getPrimaryTextColor(context)
                        : primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                  Icon(
                    LucideIcons.check,
                    size: ResponsiveSystem.iconSize(context, baseSize: 12),
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentSelectionInfo({
    required LanguagePreferences languagePrefs,
    required Color primaryColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 12)),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 8)),
        border: Border.all(
          color: primaryColor.withAlpha((0.2 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.info,
                size: ResponsiveSystem.iconSize(context, baseSize: 14),
                color: primaryColor,
              ),
              SizedBox(width: ResponsiveSystem.spacing(context, baseSpacing: 6)),
              Text(
                'Current Selection',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Headers',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 10),
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      '${languagePrefs.headerLanguage.flag} ${languagePrefs.headerLanguage.nativeName}',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                        color: primaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 10),
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      '${languagePrefs.contentLanguage.flag} ${languagePrefs.contentLanguage.nativeName}',
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                        color: primaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSameLanguageToggle({
    required Color primaryColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _useSameLanguage
            ? primaryColor.withAlpha((0.1 * 255).round())
            : ThemeProperties.getTransparentColor(context),
        borderRadius: BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 8)),
        border: Border.all(
          color: _useSameLanguage ? primaryColor : primaryColor.withAlpha((0.3 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            _useSameLanguage = !_useSameLanguage;
            if (_useSameLanguage) {
              // When toggling ON, set content language to match header language
              _tempContentLanguage = _tempHeaderLanguage;
            }
            _hasChanges = true;
          });
        },
        icon: Icon(
          _useSameLanguage ? LucideIcons.link : LucideIcons.unlink,
          size: ResponsiveSystem.iconSize(context, baseSize: 16),
          color: _useSameLanguage ? primaryColor : secondaryTextColor,
        ),
        tooltip: _useSameLanguage ? 'Using same language for both' : 'Using different languages',
        padding: EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 8)),
        constraints: BoxConstraints(
          minWidth: ResponsiveSystem.iconSize(context, baseSize: 32),
          minHeight: ResponsiveSystem.iconSize(context, baseSize: 32),
        ),
      ),
    );
  }

  Widget _buildSaveButton({
    required Color primaryColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _hasChanges ? _saveLanguageChanges : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: ThemeProperties.getPrimaryTextColor(context),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSystem.spacing(context, baseSpacing: 24),
            vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 12)),
          ),
          elevation: ResponsiveSystem.elevation(context, baseElevation: 4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.save,
              size: ResponsiveSystem.iconSize(context, baseSize: 18),
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
            SizedBox(width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
            Text(
              globalTranslationService.translateHeader('save_changes', fallback: 'Save Changes'),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                fontWeight: FontWeight.w600,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLanguageChanges() async {
    if (_tempHeaderLanguage == null || _tempContentLanguage == null) return;

    try {
      if (_useSameLanguage) {
        // Set both languages to the same
        await ref.read(languageServiceProvider.notifier).setBothLanguages(_tempHeaderLanguage!);
      } else {
        // Set languages separately
        await ref.read(languageServiceProvider.notifier).setHeaderLanguage(_tempHeaderLanguage!);
        await ref.read(languageServiceProvider.notifier).setContentLanguage(_tempContentLanguage!);
      }

      // Update translation service with new preferences
      final newPrefs = LanguagePreferences(
        headerLanguage: _tempHeaderLanguage!,
        contentLanguage: _tempContentLanguage!,
      );
      globalTranslationService.updatePreferences(newPrefs);

      setState(() {
        _hasChanges = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              globalTranslationService.translateContent('language_saved',
                  fallback: 'Language settings saved successfully!'),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
            backgroundColor: ThemeProperties.getPrimaryColor(context),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 8)),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              globalTranslationService.translateContent('save_error',
                  fallback: 'Failed to save language settings'),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
            backgroundColor: ThemeProperties.getErrorColor(context),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 8)),
            ),
          ),
        );
      }
    }
  }
}

/// Language Icon Widget for App Bar
class LanguageIconWidget extends ConsumerWidget {
  const LanguageIconWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ThemeProperties.getPrimaryColor(context);

    return SizedBox(
      width: ResponsiveSystem.responsive(
        context,
        mobile: ResponsiveSystem.spacing(context, baseSpacing: 36),
        tablet: ResponsiveSystem.spacing(context, baseSpacing: 40),
        desktop: ResponsiveSystem.spacing(context, baseSpacing: 44),
        largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 48),
      ), // Reactive width based on screen size
      height: ResponsiveSystem.responsive(
        context,
        mobile: ResponsiveSystem.spacing(context, baseSpacing: 36),
        tablet: ResponsiveSystem.spacing(context, baseSpacing: 40),
        desktop: ResponsiveSystem.spacing(context, baseSpacing: 44),
        largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 48),
      ), // Reactive height based on screen size
      child: IconButton(
        onPressed: () => _showLanguageSelectionDialog(context),
        icon: Stack(
          children: [
            Icon(
              LucideIcons.globe,
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
            // Small indicator showing current language
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                height: ResponsiveSystem.spacing(context, baseSpacing: 8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeProperties.getSurfaceColor(context),
                    width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: ThemeProperties.getTransparentColor(context),
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveSystem.spacing(context, baseSpacing: 20),
          vertical: ResponsiveSystem.spacing(context, baseSpacing: 40),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: const LanguageSelectionWidget(),
          ),
        ),
      ),
    );
  }
}
