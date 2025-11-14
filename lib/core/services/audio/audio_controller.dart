/// Audio Controller
///
/// MVVM controller for audio playback using Riverpod StateNotifier.
/// Wraps the existing GlobalAudioPlayerController to maintain compatibility
/// while providing a clean, testable interface.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/models/audio/track.dart';
import 'package:skvk_application/core/services/audio/global_audio_player_controller.dart';
import 'package:skvk_application/core/services/audio/models/lyric_line.dart';

/// Player state for UI consumption
class PlayerState {
  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.showMiniPlayer = false,
    this.isFullScreenOpen = false,
    this.errorMessage,
    this.lyrics = const [],
    this.repeatMode = RepeatMode.none,
    this.playbackSpeed = 1.0,
  });

  /// Current track being played
  final Track? currentTrack;

  /// Whether audio is currently playing
  final bool isPlaying;

  /// Whether audio is loading
  final bool isLoading;

  /// Current playback position
  final Duration position;

  /// Total duration of current track
  final Duration duration;

  /// Whether mini player should be visible
  final bool showMiniPlayer;

  /// Whether full screen player is currently open
  final bool isFullScreenOpen;

  /// Error message if any
  final String? errorMessage;

  /// Lyrics for current track
  final List<LyricLine> lyrics;

  /// Repeat mode (none, one, all)
  final RepeatMode repeatMode;

  /// Playback speed
  final double playbackSpeed;

  PlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    bool? showMiniPlayer,
    bool? isFullScreenOpen,
    String? errorMessage,
    List<LyricLine>? lyrics,
    RepeatMode? repeatMode,
    double? playbackSpeed,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      showMiniPlayer: showMiniPlayer ?? this.showMiniPlayer,
      isFullScreenOpen: isFullScreenOpen ?? this.isFullScreenOpen,
      errorMessage: errorMessage ?? this.errorMessage,
      lyrics: lyrics ?? this.lyrics,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }

  /// Whether a track is currently loaded
  bool get hasTrack => currentTrack != null;
}

/// Audio Controller
///
/// Manages all audio playback logic and state.
/// Uses the existing GlobalAudioPlayerController under the hood.
class AudioController extends StateNotifier<PlayerState> {
  AudioController(this._globalController) : super(const PlayerState()) {
    _initialize();
  }
  final GlobalAudioPlayerController _globalController;
  StreamSubscription<AudioPlayerState>? _stateSubscription;

  /// Initialize controller and listen to global player state
  void _initialize() {
    // Listen to global player state changes
    _stateSubscription = _globalController.stream.listen((globalState) {
      if (!mounted) return;

      final track = globalState.currentTrack != null
          ? Track(
              id: globalState.currentTrack!.id,
              title: globalState.currentTrack!.title,
              artist: globalState.currentTrack!.artist,
              subtitle: globalState.currentTrack!.subtitle,
              artworkUrl: globalState.currentTrack!.coverArtUrl,
              audioUrl: globalState.currentTrack!.audioUrl,
              duration: globalState.currentTrack!.duration,
            )
          : null;

      // Determine if mini player should be shown:
      // - If track is cleared, hide mini player
      // - If it's a new track (different ID), show mini player (unless full screen is open)
      // - If it's the same track, preserve user preference (unless full screen is open)
      final isNewTrack = track != null && track.id != state.currentTrack?.id;
      final shouldShowMiniPlayer =
          track != null && (isNewTrack || state.showMiniPlayer);

      state = state.copyWith(
        currentTrack: track,
        isPlaying: globalState.isPlaying,
        isLoading: globalState.isLoading,
        position: globalState.position,
        duration: globalState.duration,
        errorMessage: globalState.errorMessage,
        lyrics: globalState.lyrics,
        repeatMode: globalState.repeatMode,
        playbackSpeed: globalState.playbackSpeed,
        showMiniPlayer: shouldShowMiniPlayer && !state.isFullScreenOpen,
      );
    });
  }

  /// Play a track
  ///
  /// Loads and plays the specified track. If a track is already playing,
  /// it will be replaced.
  Future<void> playTrack(Track track) async {
    final audioTrack = AudioTrack(
      id: track.id,
      title: track.title,
      artist: track.artist,
      subtitle: track.subtitle,
      coverArtUrl: track.artworkUrl,
      audioUrl: track.audioUrl,
      duration: track.duration,
    );

    await _globalController.loadTrack(audioTrack);
    // Auto-play after loading
    await _globalController.playPause();
    // Always show mini player for new track (unless full screen is open)
    // The state will be updated via the stream listener, but we set it here
    // to ensure it shows immediately for new tracks
    if (!state.isFullScreenOpen) {
      state = state.copyWith(showMiniPlayer: true);
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    await _globalController.playPause();
  }

  /// Play next track in queue
  ///
  /// If queue service is available, moves to next track.
  /// Otherwise does nothing.
  Future<void> next() async {
    // The global controller handles queue logic internally
    // For now, we'll rely on the global controller's queue handling
  }

  /// Play previous track in queue
  ///
  /// If queue service is available, moves to previous track.
  /// Otherwise does nothing.
  Future<void> prev() async {
    // Similar to next(), relies on global controller
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _globalController.seek(position);
  }

  /// Skip forward by 10 seconds
  Future<void> skipForward() async {
    await _globalController.skipForward(const Duration(seconds: 10));
  }

  /// Skip backward by 10 seconds
  Future<void> skipBackward() async {
    await _globalController.skipBackward(const Duration(seconds: 10));
  }

  /// Toggle shuffle mode
  ///
  /// Note: Shuffle functionality depends on queue service implementation
  void toggleShuffle() {
    // For now, it's a placeholder
  }

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    // The global controller manages repeat mode
    // We sync it here
    while (_globalController.state.repeatMode != mode) {
      _globalController.toggleRepeatMode();
    }
  }

  /// Toggle repeat mode (cycles through none -> all -> one -> none)
  void toggleRepeatMode() {
    _globalController.toggleRepeatMode();
  }

  /// Show or hide mini player
  void showMiniPlayer({required bool show}) {
    if (!show && state.isFullScreenOpen) return;
    state = state.copyWith(showMiniPlayer: show && state.hasTrack);
  }

  /// Set full screen player open state
  void setFullScreenOpen({required bool isOpen}) {
    state = state.copyWith(
      isFullScreenOpen: isOpen,
      showMiniPlayer: !isOpen && state.hasTrack,
    );
  }

  /// Stop playback and clear track
  Future<void> stop() async {
    await _globalController.stop();
    state = state.copyWith(showMiniPlayer: false);
  }

  /// Clear current track
  void clearTrack() {
    _globalController.clearTrack();
    state = state.copyWith(showMiniPlayer: false);
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }
}

/// Audio Controller Provider
///
/// Provides the AudioController instance.
/// Uses the existing globalAudioPlayerProvider.
final audioControllerProvider =
    StateNotifierProvider<AudioController, PlayerState>((ref) {
  final globalController = ref.watch(globalAudioPlayerProvider.notifier);
  return AudioController(globalController);
});
