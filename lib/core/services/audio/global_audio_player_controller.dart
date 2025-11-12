/// Global Audio Player Controller
///
/// Single instance audio player controller using Riverpod
/// This is the ONLY audio player used across the entire app
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/content/content_api_service.dart';
import '../../../core/services/analytics/analytics_service.dart';
import '../../../core/services/network/network_connectivity_service.dart';
import '../../../core/logging/logging_helper.dart';
import 'models/lyric_line.dart';
import 'lyrics_parser.dart';
import 'player_queue_service.dart';
import '../../../core/models/audio/track.dart';
import 'models/queue_state.dart';

/// Repeat mode enum
enum RepeatMode {
  none, // No repeat
  one, // Repeat current track
  all, // Repeat all tracks
}

/// Audio Track Model
class AudioTrack {
  final String id;
  final String title;
  final String? artist;
  final String? subtitle;
  final String? coverArtUrl;
  final String? audioUrl;
  final Duration? duration;

  const AudioTrack({
    required this.id,
    required this.title,
    this.artist,
    this.subtitle,
    this.coverArtUrl,
    this.audioUrl,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'subtitle': subtitle,
        'coverArtUrl': coverArtUrl,
        'audioUrl': audioUrl,
        'duration': duration?.inMilliseconds,
      };

  factory AudioTrack.fromJson(Map<String, dynamic> json) => AudioTrack(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String?,
        subtitle: json['subtitle'] as String?,
        coverArtUrl: json['coverArtUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
        duration: json['duration'] != null
            ? Duration(milliseconds: json['duration'] as int)
            : null,
      );

  /// Create AudioTrack from music map (from API)
  factory AudioTrack.fromMusicMap(Map<String, dynamic> music) => AudioTrack(
        id: music['id'] as String? ?? '',
        title: music['title'] as String? ?? music['id'] as String? ?? '',
        artist: music['artist'] as String?,
        subtitle: music['subtitle'] as String?,
        coverArtUrl: music['coverArtUrl'] as String?,
        audioUrl: music['audioUrl'] as String?,
        duration: music['duration'] != null
            ? Duration(milliseconds: music['duration'] as int)
            : null,
      );
}

/// Audio Player State
class AudioPlayerState {
  final AudioTrack? currentTrack;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final RepeatMode repeatMode;
  final double playbackSpeed;
  final String? errorMessage;
  final List<LyricLine> lyrics; // Lyrics for current track

  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.repeatMode = RepeatMode.none,
    this.playbackSpeed = 1.0,
    this.errorMessage,
    this.lyrics = const [],
  });

  AudioPlayerState copyWith({
    AudioTrack? currentTrack,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    RepeatMode? repeatMode,
    double? playbackSpeed,
    String? errorMessage,
    List<LyricLine>? lyrics,
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      errorMessage: errorMessage ?? this.errorMessage,
      lyrics: lyrics ?? this.lyrics,
    );
  }

  bool get hasTrack => currentTrack != null;
}

/// Global Audio Player Controller
class GlobalAudioPlayerController extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _positionTimer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<QueueState>? _queueSubscription;
  PlayerQueueService? _queueService;

  // Storage keys
  static const String _lastTrackKey = 'audio_last_track';
  static const String _lastPositionKey = 'audio_last_position';
  static const String _repeatModeKey = 'audio_repeat_mode';
  static const String _playbackSpeedKey = 'audio_playback_speed';
  static const String _queueKey = 'audio_queue';
  static const String _queueIndexKey = 'audio_queue_index';

  GlobalAudioPlayerController() : super(const AudioPlayerState()) {
    _initializePlayer();
    _loadPersistedState();
  }

  /// Set queue service reference (called from outside)
  void setQueueService(PlayerQueueService queueService) {
    _queueService = queueService;
    // Listen to queue changes
    _queueSubscription?.cancel();
    _queueSubscription = queueService.queueStream.listen(_onQueueStateChanged);
    // Restore queue state
    _restoreQueueState();
  }

  /// Handle queue state changes
  void _onQueueStateChanged(QueueState queueState) {
    if (!mounted) return;
    
    // If queue has a current track, load it
    final currentTrack = queueState.currentTrack;
    if (currentTrack != null && state.currentTrack?.id != currentTrack.id) {
      // Convert Track to AudioTrack
      final audioTrack = AudioTrack(
        id: currentTrack.id,
        title: currentTrack.title,
        artist: currentTrack.subtitle,
        subtitle: currentTrack.subtitle,
        coverArtUrl: currentTrack.coverUrl,
        audioUrl: currentTrack.sourceUrl,
        duration: currentTrack.duration,
      );
      loadTrack(audioTrack);
    }
    
    // Sync repeat mode with queue
    if (state.repeatMode != queueState.repeatMode) {
      state = state.copyWith(repeatMode: queueState.repeatMode);
      _applyRepeatMode();
    }
  }

  void _initializePlayer() {
    // Listen to position updates
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        state = state.copyWith(position: position);
      }
    });

    // Listen to duration updates
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        state = state.copyWith(duration: duration);
        // Update track duration if available
        if (state.currentTrack != null && state.currentTrack!.duration == null) {
          final updatedTrack = AudioTrack(
            id: state.currentTrack!.id,
            title: state.currentTrack!.title,
            artist: state.currentTrack!.artist,
            subtitle: state.currentTrack!.subtitle,
            coverArtUrl: state.currentTrack!.coverArtUrl,
            audioUrl: state.currentTrack!.audioUrl,
            duration: duration,
          );
          state = state.copyWith(currentTrack: updatedTrack);
        }
      }
    });

    // Listen to player state updates
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        state = state.copyWith(
          isPlaying: playerState.playing,
          isLoading: playerState.processingState == ProcessingState.loading ||
              playerState.processingState == ProcessingState.buffering,
        );
      }
    });

    // Handle playback completion
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _handlePlaybackComplete();
      }
    });
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load repeat mode
      final repeatModeIndex = prefs.getInt(_repeatModeKey) ?? 0;
      final repeatMode = RepeatMode.values[repeatModeIndex.clamp(0, RepeatMode.values.length - 1)];
      
      // Load playback speed
      final playbackSpeed = prefs.getDouble(_playbackSpeedKey) ?? 1.0;
      
      state = state.copyWith(
        repeatMode: repeatMode,
        playbackSpeed: playbackSpeed,
      );
      
      // Apply repeat mode and speed
      _applyRepeatMode();
      await _audioPlayer.setSpeed(playbackSpeed);
    } catch (e) {
      LoggingHelper.logError('Failed to load persisted audio state', source: 'GlobalAudioPlayer', error: e);
    }
  }

  Future<void> _savePersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (state.currentTrack != null) {
        // Save last track ID (we'll reload track details when needed)
        await prefs.setString(_lastTrackKey, state.currentTrack!.id);
        await prefs.setInt(_lastPositionKey, state.position.inMilliseconds);
      }
      
      await prefs.setInt(_repeatModeKey, state.repeatMode.index);
      await prefs.setDouble(_playbackSpeedKey, state.playbackSpeed);
      
      // Save queue state if available
      if (_queueService != null) {
        final queueState = _queueService!.state;
        if (queueState.queue.isNotEmpty) {
          // Save queue as JSON
          final queueJson = jsonEncode(queueState.queue.map((t) => t.toJson()).toList());
          await prefs.setString(_queueKey, queueJson);
          await prefs.setInt(_queueIndexKey, queueState.currentIndex);
        }
      }
    } catch (e) {
      LoggingHelper.logError('Failed to save persisted audio state', source: 'GlobalAudioPlayer', error: e);
    }
  }

  /// Restore queue state from persistence
  Future<void> _restoreQueueState() async {
    if (_queueService == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      final queueIndex = prefs.getInt(_queueIndexKey) ?? 0;
      
      if (queueJson != null && queueJson.isNotEmpty) {
        final queueList = jsonDecode(queueJson) as List<dynamic>;
        final tracks = queueList.map((json) => Track.fromJson(json as Map<String, dynamic>)).toList();
        
        if (tracks.isNotEmpty) {
          await _queueService!.loadQueue(tracks, startIndex: queueIndex, autoplay: false);
        }
      }
    } catch (e) {
      LoggingHelper.logError('Failed to restore queue state', source: 'GlobalAudioPlayer', error: e);
    }
  }

  /// Load and play a track
  Future<void> loadTrack(AudioTrack track) async {
    try {
      // Check network connectivity first
      final hasInternet = await NetworkConnectivityService.instance.hasInternetConnection();
      if (!hasInternet) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: NetworkConnectivityService.instance.getOfflineMessage(),
        );
        return;
      }

      state = state.copyWith(isLoading: true, errorMessage: null);

      // Get audio URL if not provided
      String audioUrl = track.audioUrl ?? '';
      if (audioUrl.isEmpty) {
        audioUrl = await ContentApiService.instance.getMusicUrl(track.id);
      }

      if (audioUrl.isEmpty) {
        throw Exception('Invalid audio URL');
      }

      // Stop current playback
      await _audioPlayer.stop();

      // Load new audio
      await _audioPlayer.setUrl(audioUrl).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Audio loading timeout');
        },
      );

      // Update state
      state = state.copyWith(
        currentTrack: track.copyWith(audioUrl: audioUrl),
        isLoading: false,
        lyrics: [], // Clear lyrics - will be loaded separately
      );

      // Load lyrics in background (non-blocking)
      // Will use content language preference, fallback to English
      _loadLyrics(track.id);

      // Save state
      await _savePersistedState();

      // Track analytics (non-blocking)
      Future.microtask(() {
        AnalyticsService.instance.trackAudioPlay(track.id).catchError((e) {
          LoggingHelper.logError('Failed to track audio play', source: 'GlobalAudioPlayer', error: e);
        });
      });

      // Auto-resume from last position if same track
      final prefs = await SharedPreferences.getInstance();
      final lastTrackId = prefs.getString(_lastTrackKey);
      if (lastTrackId == track.id) {
        final lastPositionMs = prefs.getInt(_lastPositionKey) ?? 0;
        if (lastPositionMs > 0) {
          await seek(Duration(milliseconds: lastPositionMs));
        }
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load track', source: 'GlobalAudioPlayer', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load audio. Please try again.',
      );
    }
  }

  /// Load and play a track from music map (from API)
  Future<void> loadTrackFromMusicMap(Map<String, dynamic> music) async {
    final track = AudioTrack.fromMusicMap(music);
    await loadTrack(track);
  }

  /// Play/Pause toggle
  Future<void> playPause() async {
    try {
      if (state.currentTrack == null) return;

      if (state.isPlaying) {
        // Save current position before pausing
        await _savePersistedState();
        await _audioPlayer.pause();
        // Track analytics (non-blocking)
        Future.microtask(() {
          AnalyticsService.instance.trackAudioPause(state.currentTrack!.id).catchError((e) {
            LoggingHelper.logError('Failed to track audio pause', source: 'GlobalAudioPlayer', error: e);
          });
        });
      } else {
        // When resuming, ensure we're at the correct position
        // Get the current position from the audio player to verify it matches our state
        final currentPosition = _audioPlayer.position;
        final statePosition = state.position;
        
        // If positions don't match, seek to the state position before playing
        if ((currentPosition - statePosition).abs() > const Duration(milliseconds: 500)) {
          await _audioPlayer.seek(statePosition);
        }
        
        await _audioPlayer.play();
        // Track analytics (non-blocking)
        Future.microtask(() {
          AnalyticsService.instance.trackAudioPlay(state.currentTrack!.id).catchError((e) {
            LoggingHelper.logError('Failed to track audio play', source: 'GlobalAudioPlayer', error: e);
          });
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to play/pause', source: 'GlobalAudioPlayer', error: e);
      state = state.copyWith(errorMessage: 'Failed to play audio. Please try again.');
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      state = state.copyWith(position: position);
      await _savePersistedState();
      
      // Track analytics (non-blocking)
      if (state.currentTrack != null) {
        Future.microtask(() {
          AnalyticsService.instance.trackAudioSeek(
            state.currentTrack!.id,
            position.inSeconds,
          ).catchError((e) {
            LoggingHelper.logError('Failed to track audio seek', source: 'GlobalAudioPlayer', error: e);
          });
        });
      }
    } catch (e) {
      LoggingHelper.logError('Failed to seek', source: 'GlobalAudioPlayer', error: e);
    }
  }

  /// Skip forward by duration
  Future<void> skipForward(Duration duration) async {
    final newPosition = state.position + duration;
    final maxPosition = state.duration;
    await seek(newPosition > maxPosition ? maxPosition : newPosition);
  }

  /// Skip backward by duration
  Future<void> skipBackward(Duration duration) async {
    final newPosition = state.position - duration;
    await seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  /// Toggle repeat mode
  void toggleRepeatMode() {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.none => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.none,
    };
    state = state.copyWith(repeatMode: nextMode);
    _applyRepeatMode();
    _savePersistedState();
  }

  void _applyRepeatMode() {
    switch (state.repeatMode) {
      case RepeatMode.none:
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.one:
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      state = state.copyWith(playbackSpeed: speed);
      await _savePersistedState();
    } catch (e) {
      LoggingHelper.logError('Failed to set playback speed', source: 'GlobalAudioPlayer', error: e);
    }
  }

  /// Handle playback completion
  void _handlePlaybackComplete() {
    // Track analytics (non-blocking)
    if (state.currentTrack != null) {
      Future.microtask(() {
        AnalyticsService.instance.trackAudioComplete(state.currentTrack!.id).catchError((e) {
          LoggingHelper.logError('Failed to track audio complete', source: 'GlobalAudioPlayer', error: e);
        });
      });
    }
    
    // Handle queue-based playback
    if (_queueService != null) {
      final queueState = _queueService!.state;
      if (queueState.canGoNext) {
        // Move to next track in queue
        _queueService!.next().then((_) {
          // Track will be loaded via _onQueueStateChanged
        });
      } else {
        // No more tracks - stop playback
        _audioPlayer.stop();
        state = state.copyWith(isPlaying: false);
      }
    } else {
      // Fallback to old behavior if queue not integrated
      switch (state.repeatMode) {
        case RepeatMode.none:
          // Stop playback
          _audioPlayer.stop();
          state = state.copyWith(isPlaying: false);
          break;
        case RepeatMode.one:
          // Already handled by LoopMode.one
          break;
        case RepeatMode.all:
          // Already handled by LoopMode.all
          break;
      }
    }
  }

  /// Stop playback and clear track
  Future<void> stop() async {
    await _audioPlayer.stop();
    state = state.copyWith(
      isPlaying: false,
      position: Duration.zero,
    );
    await _savePersistedState();
  }

  /// Clear current track
  void clearTrack() {
    _audioPlayer.stop();
    state = const AudioPlayerState();
  }

  /// Set lyrics for current track
  void setLyrics(List<LyricLine> lyrics) {
    state = state.copyWith(lyrics: lyrics);
  }

  /// Check if current track has lyrics
  bool get hasLyrics => state.lyrics.isNotEmpty;

  /// Get position stream
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Get current track stream
  Stream<AudioTrack?> get currentTrackStream => stream.map((s) => s.currentTrack);

  /// Seek to position (alias for seek method)
  Future<void> seekTo(Duration position) => seek(position);

  /// Parse lyrics from Cloudflare R2 (LRC format only)
  /// Maps LRC format to LyricLine objects
  /// LRC format: [00:12.00]Line 1
  List<LyricLine> _parseLyrics(String lyricsText, String trackId) {
    try {
      // Parse LRC format from Cloudflare R2
      return LyricsParser.parseLrc(lyricsText);
    } catch (e) {
      LoggingHelper.logError(
        'Failed to parse LRC lyrics for $trackId',
        source: 'GlobalAudioPlayer',
        error: e,
      );
      return [];
    }
  }

  /// Load lyrics for track (non-blocking)
  /// Loads lyrics from Cloudflare R2 for the selected content language first, falls back to English if not available
  /// Gets the preferred language from SharedPreferences (content language service)
  Future<void> _loadLyrics(String trackId, {String? preferredLanguage}) async {
    try {
      // Get preferred language from SharedPreferences if not provided
      String language = preferredLanguage ?? 'en';
      if (preferredLanguage == null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final languageCode = prefs.getString('content_language_preference') ?? 'en';
          language = languageCode;
        } catch (e) {
          // If error reading preference, default to English
          language = 'en';
        }
      }
      
      // Try to load lyrics for the preferred language first
      String? lyricsText;
      try {
        lyricsText = await ContentApiService.instance.getLyrics(
          trackId,
          language: language,
          forceRefresh: false,
        );
      } catch (e) {
        // If preferred language fails, try English
        if (language != 'en') {
          LoggingHelper.logInfo(
            'Failed to load lyrics for $trackId in language $language, trying English',
            source: 'GlobalAudioPlayer',
          );
          lyricsText = await ContentApiService.instance.getLyrics(
            trackId,
            language: 'en',
            forceRefresh: false,
          );
          language = 'en'; // Update to English since that's what we loaded
        } else {
          rethrow; // If English also fails, rethrow
        }
      }

      if (lyricsText.isNotEmpty) {
        // Parse LRC format from Cloudflare R2
        List<LyricLine> lyrics = _parseLyrics(lyricsText, trackId);
        if (mounted && state.currentTrack?.id == trackId) {
          state = state.copyWith(lyrics: lyrics);
          LoggingHelper.logInfo(
            'Loaded ${lyrics.length} lyric lines for $trackId in language $language from Cloudflare R2',
            source: 'GlobalAudioPlayer',
          );
        }
      } else {
        // If preferred language returned empty, try English as fallback
        if (language != 'en') {
          try {
            lyricsText = await ContentApiService.instance.getLyrics(
              trackId,
              language: 'en',
              forceRefresh: false,
            );
            if (lyricsText.isNotEmpty) {
              List<LyricLine> lyrics = _parseLyrics(lyricsText, trackId);
              if (mounted && state.currentTrack?.id == trackId) {
                state = state.copyWith(lyrics: lyrics);
                LoggingHelper.logInfo(
                  'Loaded ${lyrics.length} lyric lines for $trackId in English (fallback) from Cloudflare R2',
                  source: 'GlobalAudioPlayer',
                );
              }
            }
          } catch (e) {
            LoggingHelper.logError(
              'Failed to load English lyrics as fallback for $trackId',
              source: 'GlobalAudioPlayer',
              error: e,
            );
          }
        }
      }
    } catch (e) {
      LoggingHelper.logError(
        'Failed to load lyrics for $trackId',
        source: 'GlobalAudioPlayer',
        error: e,
      );
      // Don't update state on error - keep empty lyrics
    }
  }

  /// Load lyrics for a specific language (on demand)
  /// Call this when user requests a different language
  /// Falls back to English if the requested language is not available
  Future<void> loadLyricsForLanguage(String trackId, String language) async {
    try {
      // Get lyrics from API for the requested language
      String? lyricsText;
      try {
        lyricsText = await ContentApiService.instance.getLyrics(
          trackId,
          language: language,
          forceRefresh: false,
        );
      } catch (e) {
        // If requested language fails, try English as fallback
        if (language != 'en') {
          LoggingHelper.logInfo(
            'Failed to load lyrics for $trackId in language $language, trying English',
            source: 'GlobalAudioPlayer',
          );
          lyricsText = await ContentApiService.instance.getLyrics(
            trackId,
            language: 'en',
            forceRefresh: false,
          );
        } else {
          rethrow; // If English also fails, rethrow
        }
      }

      if (lyricsText.isNotEmpty) {
        // Parse LRC format from Cloudflare R2
        List<LyricLine> lyrics = _parseLyrics(lyricsText, trackId);
        if (mounted && state.currentTrack?.id == trackId) {
          state = state.copyWith(lyrics: lyrics);
          LoggingHelper.logInfo(
            'Loaded ${lyrics.length} lyric lines for $trackId in language $language from Cloudflare R2',
            source: 'GlobalAudioPlayer',
          );
        }
      } else {
        // If requested language returned empty, try English as fallback
        if (language != 'en') {
          try {
            lyricsText = await ContentApiService.instance.getLyrics(
              trackId,
              language: 'en',
              forceRefresh: false,
            );
            if (lyricsText.isNotEmpty) {
              List<LyricLine> lyrics = _parseLyrics(lyricsText, trackId);
              if (mounted && state.currentTrack?.id == trackId) {
                state = state.copyWith(lyrics: lyrics);
                LoggingHelper.logInfo(
                  'Loaded ${lyrics.length} lyric lines for $trackId in English (fallback) from Cloudflare R2',
                  source: 'GlobalAudioPlayer',
                );
              }
            }
          } catch (e) {
            LoggingHelper.logError(
              'Failed to load English lyrics as fallback for $trackId',
              source: 'GlobalAudioPlayer',
              error: e,
            );
          }
        }
      }
    } catch (e) {
      LoggingHelper.logError(
        'Failed to load lyrics for $trackId in language $language',
        source: 'GlobalAudioPlayer',
        error: e,
      );
      // If error loading requested language, try English as fallback
      if (language != 'en') {
        try {
          final lyricsText = await ContentApiService.instance.getLyrics(
            trackId,
            language: 'en',
            forceRefresh: false,
          );
          if (lyricsText.isNotEmpty) {
            List<LyricLine> lyrics = _parseLyrics(lyricsText, trackId);
            if (mounted && state.currentTrack?.id == trackId) {
              state = state.copyWith(lyrics: lyrics);
              LoggingHelper.logInfo(
                'Loaded ${lyrics.length} lyric lines for $trackId in English (fallback) from Cloudflare R2',
                source: 'GlobalAudioPlayer',
              );
            }
          }
        } catch (e) {
          LoggingHelper.logError(
            'Failed to load English lyrics as fallback for $trackId',
            source: 'GlobalAudioPlayer',
            error: e,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _queueSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Extension to add copyWith to AudioTrack
extension AudioTrackCopyWith on AudioTrack {
  AudioTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? subtitle,
    String? coverArtUrl,
    String? audioUrl,
    Duration? duration,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      subtitle: subtitle ?? this.subtitle,
      coverArtUrl: coverArtUrl ?? this.coverArtUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
    );
  }
}

/// Global Audio Player Provider
final globalAudioPlayerProvider =
    StateNotifierProvider<GlobalAudioPlayerController, AudioPlayerState>(
  (ref) => GlobalAudioPlayerController(),
);

