/// Lyrics Language Selector
///
/// Dropdown to select lyrics language with on-demand loading
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../../core/services/content/content_api_service.dart';
import '../../../core/services/content/content_language_service.dart';
import '../../../core/services/audio/global_audio_player_controller.dart';
import '../../../core/logging/logging_helper.dart';

/// Lyrics Language Selector Widget
class LyricsLanguageSelector extends ConsumerStatefulWidget {
  final String trackId;
  final String currentLanguage;
  final Function(String)? onLanguageChanged;

  const LyricsLanguageSelector({
    super.key,
    required this.trackId,
    required this.currentLanguage,
    this.onLanguageChanged,
  });

  @override
  ConsumerState<LyricsLanguageSelector> createState() =>
      _LyricsLanguageSelectorState();
}

class _LyricsLanguageSelectorState
    extends ConsumerState<LyricsLanguageSelector> {
  List<String> _availableLanguages = ['en']; // Default to English
  bool _isLoading = false;
  bool _hasLoadedLanguages = false;

  @override
  void initState() {
    super.initState();
    // Load available languages on demand when dropdown is opened
  }

  Future<void> _loadAvailableLanguages() async {
    if (_hasLoadedLanguages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final languagesData =
          await ContentApiService.instance.getAvailableLanguages(
        contentId: widget.trackId,
        contentType: 'lyrics',
      );
      final availableLangs =
          List<String>.from(languagesData['languages'] ?? ['en']);

      if (mounted) {
        setState(() {
          _availableLanguages = availableLangs;
          _hasLoadedLanguages = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingHelper.logError(
        'Failed to load available languages for lyrics',
        source: 'LyricsLanguageSelector',
        error: e,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Keep default English
        });
      }
    }
  }

  String _getLanguageDisplayName(String code) {
    try {
      final lang = ContentLanguage.fromCode(code);
      return lang.displayName;
    } catch (e) {
      return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onOpened: _loadAvailableLanguages,
      child: Container(
        padding: ResponsiveSystem.symmetric(
          context,
          horizontal: ResponsiveSystem.spacing(context, baseSpacing: 12),
          vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ResponsiveSystem.spacing(context, baseSpacing: 20),
          ),
          color: ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.9),
          border: Border.all(
            color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
              color: ThemeHelpers.getPrimaryColor(context),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 6),
            ),
            Text(
              _getLanguageDisplayName(widget.currentLanguage),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                fontWeight: FontWeight.w500,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 4),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        if (_isLoading) {
          return [
            PopupMenuItem(
              enabled: false,
              child: Center(
                child: Padding(
                  padding: ResponsiveSystem.all(context, baseSpacing: 16),
                  child: SizedBox(
                    width: ResponsiveSystem.iconSize(context, baseSize: 20),
                    height: ResponsiveSystem.iconSize(context, baseSize: 20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeHelpers.getPrimaryColor(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        return _availableLanguages.map((langCode) {
          final isSelected = langCode == widget.currentLanguage;
          return PopupMenuItem<String>(
            value: langCode,
            child: Row(
              children: [
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: ResponsiveSystem.iconSize(context, baseSize: 16),
                    color: ThemeHelpers.getPrimaryColor(context),
                  )
                else
                  SizedBox(
                    width: ResponsiveSystem.iconSize(context, baseSize: 16),
                  ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
                Text(
                  _getLanguageDisplayName(langCode),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? ThemeHelpers.getPrimaryColor(context)
                        : ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (String languageCode) async {
        if (languageCode == widget.currentLanguage) return;

        final playerController = ref.read(globalAudioPlayerProvider.notifier);
        setState(() {
          _isLoading = true;
        });

        try {
          await playerController.loadLyricsForLanguage(
            widget.trackId,
            languageCode,
          );
          // Notify parent of language change
          widget.onLanguageChanged?.call(languageCode);
        } catch (e) {
          LoggingHelper.logError(
            'Failed to load lyrics for language $languageCode',
            source: 'LyricsLanguageSelector',
            error: e,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load lyrics in ${_getLanguageDisplayName(languageCode)}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
    );
  }
}

