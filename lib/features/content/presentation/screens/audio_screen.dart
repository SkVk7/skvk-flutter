/// Audio Screen
///
/// Screen for playing devotional audio with synchronized lyrics highlighting
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/content/content_api_service.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/content/content_language_service.dart';
import '../../../../core/services/language/translation_service.dart';
import '../../../../core/logging/logging_helper.dart';
import '../../../../core/utils/validation/error_message_helper.dart';
import '../../../../core/design_system/theme/theme_provider.dart';
import '../../../../shared/widgets/common/centralized_widgets.dart';
import '../widgets/content_language_dropdown.dart';

/// LRC line model
class LrcLine {
  final Duration timestamp;
  final String text;

  LrcLine({required this.timestamp, required this.text});
}

/// Audio screen
class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});

  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _musicList = [];
  Map<String, dynamic>? _selectedMusic;
  List<LrcLine> _lyrics = [];
  int _currentLyricIndex = -1;
  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _positionTimer;
  String? _errorMessage;
  List<String> _availableLanguages =
      []; // Available languages for selected music
  String? _loadingMusicId; // Track which music is currently being loaded

  @override
  void initState() {
    super.initState();
    _loadMusicList();
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _updateCurrentLyric(position);
        });
      }
    });
    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMusicList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final musicList = await ContentApiService.instance.getMusicList();
      if (mounted) {
        setState(() {
          _musicList =
              List<Map<String, dynamic>>.from(musicList['music'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load music list',
          source: 'AudioScreen', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load music. Please try again.';
        });
      }
    }
  }

  Future<void> _loadAudio(String musicId) async {
    // Prevent loading the same audio multiple times
    if (_loadingMusicId == musicId && _isLoading) {
      LoggingHelper.logInfo('Audio already loading: $musicId',
          source: 'AudioScreen');
      return;
    }

    // If already selected and loaded, just play it
    if (_selectedMusic?['id'] == musicId && !_isLoading) {
      if (!_isPlaying) {
        await _playPause();
      }
      return;
    }

    try {
      _loadingMusicId = musicId;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _availableLanguages = [];
      });

      // Stop current audio (non-blocking for UI)
      _audioPlayer.stop();

      // Update selected music immediately for better UX
      if (mounted) {
        setState(() {
          _selectedMusic = _musicList.firstWhere((m) => m['id'] == musicId);
        });
      }

      // CRITICAL PATH: Get audio URL and load audio immediately (this is what user is waiting for)
      final audioUrl = await ContentApiService.instance.getMusicUrl(musicId);

      // Validate audio URL
      if (audioUrl.isEmpty) {
        throw Exception('Invalid audio URL');
      }

      // Load audio with timeout to prevent hanging
      await _audioPlayer.setUrl(audioUrl).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Audio loading timeout. Please check your connection and try again.');
        },
      );

      // Audio is loaded! Clear loading state and allow playback
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMusicId = null;
        });
      }

      // NON-BLOCKING: Load languages, lyrics, and analytics in parallel (don't block playback)
      unawaited(_loadLanguagesAndLyrics(musicId));
      unawaited(_trackAudioPlay(musicId));
    } catch (e) {
      LoggingHelper.logError('Failed to load audio',
          source: 'AudioScreen', error: e);
      if (mounted) {
        // Convert technical error to user-friendly message
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(e);
        setState(() {
          _isLoading = false;
          _errorMessage = userFriendlyMessage;
          _loadingMusicId = null;
        });
      }
    }
  }

  /// Load languages and lyrics in background (non-blocking)
  Future<void> _loadLanguagesAndLyrics(String musicId) async {
    try {
      // Fetch available languages for this music item
      try {
        final languagesData =
            await ContentApiService.instance.getAvailableLanguages(
          contentId: musicId,
          contentType: 'lyrics',
        );
        final availableLangs =
            List<String>.from(languagesData['languages'] ?? []);
        if (mounted) {
          setState(() {
            _availableLanguages = availableLangs;
          });
        }

        // If current language is not available, switch to first available or default
        final currentLang =
            ref.read(contentLanguageServiceProvider).selectedLanguage.code;
        if (_availableLanguages.isNotEmpty &&
            !_availableLanguages.contains(currentLang)) {
          final defaultLang = _availableLanguages.contains('en')
              ? 'en'
              : _availableLanguages.first;
          final lang = ContentLanguage.fromCode(defaultLang);
          await ref
              .read(contentLanguageServiceProvider.notifier)
              .setContentLanguage(lang);
        }
      } catch (e) {
        LoggingHelper.logError('Failed to fetch available languages',
            source: 'AudioScreen', error: e);
        // Continue with default behavior if language fetch fails
      }

      // Load lyrics with current language (non-blocking)
      await _loadLyrics(musicId);
    } catch (e) {
      LoggingHelper.logError('Failed to load languages/lyrics',
          source: 'AudioScreen', error: e);
      // Don't show error to user - this is background loading
    }
  }

  /// Track audio play analytics (non-blocking, fire and forget)
  Future<void> _trackAudioPlay(String musicId) async {
    try {
      await AnalyticsService.instance.trackAudioPlay(musicId);
    } catch (e) {
      LoggingHelper.logError('Failed to track audio play',
          source: 'AudioScreen', error: e);
      // Silently fail - analytics shouldn't block user experience
    }
  }

  Future<void> _loadLyrics(String musicId) async {
    try {
      // Get current language from service - read directly to ensure we get the latest value
      final languagePrefs = ref.read(contentLanguageServiceProvider);
      final languageCode = languagePrefs.selectedLanguage.code;

      LoggingHelper.logInfo(
          'Loading lyrics for $musicId in language: $languageCode',
          source: 'AudioScreen');

      // Fetch lyrics with current language (force refresh to get correct language)
      final lyricsText = await ContentApiService.instance
          .getLyrics(musicId, language: languageCode, forceRefresh: true);

      LoggingHelper.logInfo('Lyrics received, length: ${lyricsText.length}',
          source: 'AudioScreen');

      // Parse LRC format
      final parsedLyrics = _parseLrc(lyricsText);

      LoggingHelper.logInfo('Parsed ${parsedLyrics.length} lyric lines',
          source: 'AudioScreen');

      if (mounted) {
        setState(() {
          _lyrics = parsedLyrics;
          _currentLyricIndex = -1;
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load lyrics',
          source: 'AudioScreen', error: e);
      if (mounted) {
        setState(() {
          _lyrics = [];
          _errorMessage =
              'Failed to load lyrics. ${ErrorMessageHelper.getUserFriendlyMessage(e)}';
        });
      }
    }
  }

  List<LrcLine> _parseLrc(String lrcText) {
    final lines = <LrcLine>[];

    if (lrcText.isEmpty) {
      LoggingHelper.logInfo('Empty lyrics text', source: 'AudioScreen');
      return lines;
    }

    final lrcLines = lrcText.split('\n');
    int lineNumber = 0;

    for (final line in lrcLines) {
      lineNumber++;
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Match [mm:ss.ff] or [mm:ss:ff] format
      final regex = RegExp(r'\[(\d{2}):(\d{2})[\.:](\d{2,3})\]');
      final matches = regex.allMatches(trimmedLine);

      if (matches.isNotEmpty) {
        // Get text after last timestamp
        final lastMatch = matches.last;
        final text = trimmedLine.substring(lastMatch.end).trim();

        if (text.isNotEmpty) {
          try {
            // Parse timestamp
            final minutes = int.parse(lastMatch.group(1)!);
            final seconds = int.parse(lastMatch.group(2)!);
            final millisecondsStr = lastMatch.group(3)!;
            final milliseconds =
                int.parse(millisecondsStr.padRight(3, '0').substring(0, 3));

            final timestamp = Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            );

            lines.add(LrcLine(timestamp: timestamp, text: text));
          } catch (e) {
            LoggingHelper.logError(
                'Failed to parse timestamp on line $lineNumber: $trimmedLine',
                source: 'AudioScreen',
                error: e);
            // Fallback: add line without timestamp at the end
            if (lines.isNotEmpty) {
              final lastTimestamp = lines.last.timestamp;
              lines.add(LrcLine(
                  timestamp: lastTimestamp + const Duration(seconds: 1),
                  text: trimmedLine));
            } else {
              lines.add(LrcLine(
                  timestamp: Duration(seconds: lineNumber), text: trimmedLine));
            }
          }
        }
      } else {
        // No timestamp found - add as plain text with sequential timestamp
        if (lines.isNotEmpty) {
          final lastTimestamp = lines.last.timestamp;
          lines.add(LrcLine(
              timestamp: lastTimestamp + const Duration(seconds: 1),
              text: trimmedLine));
        } else {
          lines.add(LrcLine(
              timestamp: Duration(seconds: lineNumber), text: trimmedLine));
        }
      }
    }

    LoggingHelper.logInfo(
        'Parsed ${lines.length} lines from ${lrcLines.length} input lines',
        source: 'AudioScreen');
    return lines;
  }

  void _updateCurrentLyric(Duration position) {
    if (_lyrics.isEmpty) return;

    int newIndex = -1;
    for (int i = 0; i < _lyrics.length; i++) {
      if (position >= _lyrics[i].timestamp) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != _currentLyricIndex) {
      setState(() {
        _currentLyricIndex = newIndex;
      });

      // Auto-scroll to current lyric
      if (newIndex >= 0 && _scrollController.hasClients) {
        final itemHeight = 60.0; // Approximate height of each lyric line
        final scrollPosition = newIndex * itemHeight;

        _scrollController.animateTo(
          scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _playPause() async {
    try {
      // Check if audio is loaded before trying to play
      if (_selectedMusic == null || _isLoading) {
        LoggingHelper.logInfo('Cannot play: audio not loaded yet',
            source: 'AudioScreen');
        return;
      }

      // Check if audio player has a source loaded
      final playerState = _audioPlayer.playerState;
      if (playerState.processingState == ProcessingState.idle && !_isPlaying) {
        LoggingHelper.logInfo('Cannot play: no audio source loaded',
            source: 'AudioScreen');
        return;
      }

      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      LoggingHelper.logError('Failed to play/pause audio',
          source: 'AudioScreen', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to play audio. Please try again.';
        });
      }
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      LoggingHelper.logError('Failed to seek audio',
          source: 'AudioScreen', error: e);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final translationService = ref.watch(translationServiceProvider);
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
      isEvening: false,
      useSacredFire: false,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight:
                    ResponsiveSystem.spacing(context, baseSpacing: 120),
                floating: true,
                pinned: true,
                backgroundColor: ThemeProperties.getTransparentColor(context),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    LucideIcons.arrowLeft,
                    color: ThemeProperties.getAppBarTextColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  // Language Dropdown Widget
                  CentralizedLanguageDropdown(
                    onLanguageChanged: (value) {
                      LoggingHelper.logInfo('Language changed to: $value');
                    },
                  ),
                  // Theme Dropdown Widget
                  CentralizedThemeDropdown(
                    onThemeChanged: (value) {
                      LoggingHelper.logInfo('Theme changed to: $value');
                      _handleThemeChange(ref, value);
                    },
                  ),
                  // Profile Photo with Hover Effect
                  Padding(
                    padding: ResponsiveSystem.only(
                      context,
                      right: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    child: CentralizedProfilePhotoWithHover(
                      key: const ValueKey('profile_icon'),
                      onTap: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      tooltip: translationService.translateContent(
                        'my_profile',
                        fallback: 'My Profile',
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    translationService.translateHeader('devotional_audio',
                        fallback: 'Devotional Audio'),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 18),
                      fontWeight: FontWeight.bold,
                      color: ThemeProperties.getAppBarTextColor(context),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: ThemeProperties.getPrimaryGradient(context),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveSystem.all(context, baseSpacing: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Music List
                      if (_musicList.isNotEmpty)
                        ..._musicList.map(
                            (music) => _buildMusicCard(context, music, isDark)),

                      // Selected Music Player
                      if (_selectedMusic != null) ...[
                        ResponsiveSystem.sizedBox(
                          context,
                          height: ResponsiveSystem.spacing(context,
                              baseSpacing: 24),
                        ),
                        _buildPlayer(context, isDark),
                      ],

                      // Lyrics Display
                      if (_selectedMusic != null && _lyrics.isNotEmpty) ...[
                        ResponsiveSystem.sizedBox(
                          context,
                          height: ResponsiveSystem.spacing(context,
                              baseSpacing: 24),
                        ),
                        _buildLyricsDisplay(context, isDark),
                      ],

                      // Error Message
                      if (_errorMessage != null)
                        _buildErrorMessage(context, isDark),

                      // Loading Indicator
                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding:
                                ResponsiveSystem.all(context, baseSpacing: 24),
                            child: CircularProgressIndicator(
                              color: ThemeProperties.getPrimaryColor(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicCard(
      BuildContext context, Map<String, dynamic> music, bool isDark) {
    final isSelected = _selectedMusic?['id'] == music['id'];

    return Card(
      margin: ResponsiveSystem.only(
        context,
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 12),
      ),
      elevation: ResponsiveSystem.elevation(context, baseElevation: 2),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      color: isSelected
          ? ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.1)
          : ThemeProperties.getSurfaceColor(context),
      child: ListTile(
        leading: Icon(
          Icons.music_note,
          color: isSelected
              ? ThemeProperties.getPrimaryColor(context)
              : ThemeProperties.getSecondaryTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 28),
        ),
        title: Text(
          music['title'] ?? music['id'],
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            fontWeight: FontWeight.bold,
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        subtitle: Text(
          'Tap to play',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
            color: ThemeProperties.getSecondaryTextColor(context),
          ),
        ),
        trailing: isSelected && _isPlaying
            ? Icon(
                Icons.equalizer,
                color: ThemeProperties.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 24),
              )
            : null,
        onTap: () => _loadAudio(music['id']),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, bool isDark) {
    return Card(
      elevation: ResponsiveSystem.elevation(context, baseElevation: 4),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
      ),
      color: ThemeProperties.getSurfaceColor(context),
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 20),
        child: Column(
          children: [
            // Back button and Title row
            Row(
              children: [
                // Back button
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  ),
                  color: ThemeProperties.getPrimaryColor(context),
                  onPressed: () {
                    // Stop audio and return to list
                    _audioPlayer.stop();
                    setState(() {
                      _selectedMusic = null;
                      _lyrics = [];
                      _currentLyricIndex = -1;
                      _currentPosition = Duration.zero;
                      _totalDuration = Duration.zero;
                    });
                  },
                ),
                // Title (expanded to take remaining space)
                Expanded(
                  child: Text(
                    _selectedMusic!['title'] ?? _selectedMusic!['id'],
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 20),
                      fontWeight: FontWeight.bold,
                      color: ThemeProperties.getPrimaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Spacer to balance the back button
                SizedBox(
                    width:
                        ResponsiveSystem.iconSize(context, baseSize: 24) + 16),
              ],
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 20),
            ),

            // Progress Bar
            Slider(
              value: _currentPosition.inMilliseconds.toDouble().clamp(
                    0.0,
                    _totalDuration.inMilliseconds.toDouble(),
                  ),
              min: 0.0,
              max: _totalDuration.inMilliseconds.toDouble(),
              onChanged: (value) {
                _seek(Duration(milliseconds: value.toInt()));
              },
              activeColor: ThemeProperties.getPrimaryColor(context),
              inactiveColor: ThemeProperties.getSecondaryTextColor(context)
                  .withValues(alpha: 0.3),
            ),

            // Time Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                    color: ThemeProperties.getSecondaryTextColor(context),
                  ),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                    color: ThemeProperties.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.replay_10,
                    size: ResponsiveSystem.iconSize(context, baseSize: 32),
                  ),
                  color: ThemeProperties.getPrimaryColor(context),
                  onPressed: () {
                    final newPosition =
                        _currentPosition - const Duration(seconds: 10);
                    _seek(newPosition < Duration.zero
                        ? Duration.zero
                        : (newPosition > _totalDuration
                            ? _totalDuration
                            : newPosition));
                  },
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeProperties.getPrimaryColor(context),
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? SizedBox(
                            width: ResponsiveSystem.iconSize(context,
                                baseSize: 40),
                            height: ResponsiveSystem.iconSize(context,
                                baseSize: 40),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: ResponsiveSystem.iconSize(context,
                                baseSize: 40),
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    onPressed: _isLoading ? null : _playPause,
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                IconButton(
                  icon: Icon(
                    Icons.forward_10,
                    size: ResponsiveSystem.iconSize(context, baseSize: 32),
                  ),
                  color: ThemeProperties.getPrimaryColor(context),
                  onPressed: () {
                    final newPosition =
                        _currentPosition + const Duration(seconds: 10);
                    _seek(newPosition < Duration.zero
                        ? Duration.zero
                        : (newPosition > _totalDuration
                            ? _totalDuration
                            : newPosition));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Handle theme change
  void _handleThemeChange(WidgetRef ref, String themeValue) {
    AppThemeMode themeMode;
    switch (themeValue) {
      case 'light':
        themeMode = AppThemeMode.light;
        break;
      case 'dark':
        themeMode = AppThemeMode.dark;
        break;
      case 'system':
        themeMode = AppThemeMode.system;
        break;
      default:
        themeMode = AppThemeMode.system;
    }

    ref.read(themeNotifierProvider.notifier).setThemeMode(themeMode);
  }

  Widget _buildLyricsDisplay(BuildContext context, bool isDark) {
    return Card(
      elevation: ResponsiveSystem.elevation(context, baseElevation: 4),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
      ),
      color: ThemeProperties.getSurfaceColor(context),
      child: Column(
        children: [
          // Content Language Dropdown near lyrics widget
          if (_availableLanguages.isNotEmpty)
            Padding(
              padding: ResponsiveSystem.all(context, baseSpacing: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ContentLanguageDropdown(
                    availableLanguages: _availableLanguages,
                    onLanguageChanged: (value) async {
                      if (_selectedMusic != null) {
                        // Wait a bit to ensure state is updated
                        await Future.delayed(const Duration(milliseconds: 100));
                        // Reload lyrics with new language
                        await _loadLyrics(_selectedMusic!['id']);
                        // Reset current lyric index
                        if (mounted) {
                          setState(() {
                            _currentLyricIndex = -1;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          // Lyrics List
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.5, // 50% of screen height
            ),
            child: Container(
              padding: ResponsiveSystem.all(context, baseSpacing: 16),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: _lyrics.length,
                itemBuilder: (context, index) {
                  final line = _lyrics[index];
                  final isCurrent = index == _currentLyricIndex;

                  return Padding(
                    padding: ResponsiveSystem.only(
                      context,
                      bottom:
                          ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: ResponsiveSystem.all(context, baseSpacing: 12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? ThemeProperties.getPrimaryColor(context)
                                .withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius:
                            ResponsiveSystem.circular(context, baseRadius: 8),
                      ),
                      child: Text(
                        line.text,
                        style: TextStyle(
                          fontSize: ResponsiveSystem.fontSize(
                            context,
                            baseSize: isCurrent ? 18 : 16,
                          ),
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? ThemeProperties.getPrimaryColor(context)
                              : ThemeProperties.getPrimaryTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, bool isDark) {
    return Card(
      margin: ResponsiveSystem.all(context, baseSpacing: 16),
      color: ThemeProperties.getErrorColor(context).withValues(alpha: 0.1),
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: ThemeProperties.getErrorColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  color: ThemeProperties.getErrorColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
