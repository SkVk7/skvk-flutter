/// Player Queue Service
///
/// Manages the audio playback queue with shuffle and repeat support
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/track.dart';
import 'models/queue_state.dart';
import 'global_audio_player_controller.dart';
import '../../../core/logging/logging_helper.dart';

/// Player Queue Service - Manages queue state and operations
class PlayerQueueService extends StateNotifier<QueueState> {
  Completer<void> _mutex = Completer<void>()..complete();
  List<Track> _originalQueue = []; // Original queue order (for shuffle)
  List<int>? _shuffledIndices; // Shuffled index mapping
  
  // Storage keys
  static const String _queueKey = 'audio_queue';
  static const String _queueIndexKey = 'audio_queue_index';
  static const String _shuffleKey = 'audio_queue_shuffle';
  static const String _repeatKey = 'audio_queue_repeat';

  PlayerQueueService() : super(const QueueState(queue: [], currentIndex: 0)) {
    _loadPersistedState();
  }
  
  /// Load persisted queue state
  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      final queueIndex = prefs.getInt(_queueIndexKey) ?? 0;
      final shuffleEnabled = prefs.getBool(_shuffleKey) ?? false;
      final repeatModeIndex = prefs.getInt(_repeatKey) ?? 0;
      final repeatMode = RepeatMode.values[repeatModeIndex.clamp(0, RepeatMode.values.length - 1)];
      
      if (queueJson != null && queueJson.isNotEmpty) {
        final queueList = jsonDecode(queueJson) as List<dynamic>;
        final tracks = queueList.map((json) => Track.fromJson(json as Map<String, dynamic>)).toList();
        
        if (tracks.isNotEmpty) {
          _originalQueue = List.from(tracks);
          _shuffledIndices = shuffleEnabled ? _generateShuffledIndices(tracks.length) : null;
          
          state = QueueState(
            queue: tracks,
            currentIndex: queueIndex.clamp(0, tracks.length - 1),
            shuffleEnabled: shuffleEnabled,
            repeatMode: repeatMode,
            shuffledIndices: _shuffledIndices,
          );
        }
      }
    } catch (e) {
      LoggingHelper.logError('Failed to load persisted queue state', source: 'PlayerQueueService', error: e);
    }
  }
  
  /// Save queue state to persistence
  Future<void> _savePersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (state.queue.isNotEmpty) {
        final queueJson = jsonEncode(state.queue.map((t) => t.toJson()).toList());
        await prefs.setString(_queueKey, queueJson);
        await prefs.setInt(_queueIndexKey, state.currentIndex);
        await prefs.setBool(_shuffleKey, state.shuffleEnabled);
        await prefs.setInt(_repeatKey, state.repeatMode.index);
      } else {
        // Clear persisted state if queue is empty
        await prefs.remove(_queueKey);
        await prefs.remove(_queueIndexKey);
        await prefs.remove(_shuffleKey);
        await prefs.remove(_repeatKey);
      }
    } catch (e) {
      LoggingHelper.logError('Failed to save persisted queue state', source: 'PlayerQueueService', error: e);
    }
  }

  /// Get current track
  Track? get currentTrack => state.currentTrack;

  /// Get queue
  List<Track> get queue => state.queue;

  /// Get current index
  int get currentIndex => state.currentIndex;

  /// Get shuffle enabled
  bool get shuffleEnabled => state.shuffleEnabled;

  /// Get repeat mode
  RepeatMode get repeatMode => state.repeatMode;

  /// Queue stream
  Stream<QueueState> get queueStream => stream;

  /// Acquire mutex for thread-safe operations
  Future<void> _acquireMutex() async {
    await _mutex.future;
    _mutex = Completer<void>();
  }

  /// Release mutex
  void _releaseMutex() {
    if (!_mutex.isCompleted) {
      _mutex.complete();
    }
  }

  /// Generate shuffled indices
  List<int> _generateShuffledIndices(int length) {
    final indices = List.generate(length, (i) => i);
    indices.shuffle(Random());
    return indices;
  }


  /// Load queue
  Future<void> loadQueue(
    List<Track> tracks, {
    int startIndex = 0,
    bool autoplay = true,
  }) async {
    await _acquireMutex();
    try {
      _originalQueue = List.from(tracks);
      _shuffledIndices = state.shuffleEnabled
          ? _generateShuffledIndices(tracks.length)
          : null;

      state = state.copyWith(
        queue: tracks,
        currentIndex: startIndex.clamp(0, tracks.length - 1),
        shuffledIndices: _shuffledIndices,
      );
    } finally {
      _releaseMutex();
    }
  }

  /// Append tracks to queue
  Future<void> appendTracks(List<Track> tracks) async {
    await _acquireMutex();
    try {
      final newQueue = [...state.queue, ...tracks];
      _originalQueue = [..._originalQueue, ...tracks];

      if (state.shuffleEnabled) {
        _shuffledIndices = _generateShuffledIndices(newQueue.length);
      }

      state = state.copyWith(
        queue: newQueue,
        shuffledIndices: _shuffledIndices,
      );
      
      // Save to persistence
      await _savePersistedState();
    } finally {
      _releaseMutex();
    }
  }

  /// Insert track at index
  Future<void> insertTrack(Track track, {int? index}) async {
    await _acquireMutex();
    try {
      final insertIndex = index ?? state.queue.length;
      final newQueue = List<Track>.from(state.queue);
      newQueue.insert(insertIndex.clamp(0, newQueue.length), track);

      _originalQueue = List.from(newQueue);

      if (state.shuffleEnabled) {
        _shuffledIndices = _generateShuffledIndices(newQueue.length);
      }

      // Adjust current index if needed
      int newCurrentIndex = state.currentIndex;
      if (insertIndex <= state.currentIndex) {
        newCurrentIndex++;
      }

      state = state.copyWith(
        queue: newQueue,
        currentIndex: newCurrentIndex,
        shuffledIndices: _shuffledIndices,
      );
    } finally {
      _releaseMutex();
    }
  }

  /// Remove track at index
  Future<void> removeAt(int index) async {
    await _acquireMutex();
    try {
      if (index < 0 || index >= state.queue.length) return;

      final newQueue = List<Track>.from(state.queue);
      newQueue.removeAt(index);
      _originalQueue = List.from(newQueue);

      if (state.shuffleEnabled) {
        _shuffledIndices = _generateShuffledIndices(newQueue.length);
      }

      // Adjust current index
      int newCurrentIndex = state.currentIndex;
      if (index < state.currentIndex) {
        newCurrentIndex--;
      } else if (index == state.currentIndex && newCurrentIndex >= newQueue.length) {
        newCurrentIndex = newQueue.isNotEmpty ? newCurrentIndex - 1 : 0;
      }
      newCurrentIndex = newCurrentIndex.clamp(0, newQueue.length - 1);

      state = state.copyWith(
        queue: newQueue,
        currentIndex: newCurrentIndex,
        shuffledIndices: _shuffledIndices,
      );
      
      // Save to persistence
      await _savePersistedState();
    } finally {
      _releaseMutex();
    }
  }

  /// Move track from one index to another
  Future<void> move(int fromIndex, int toIndex) async {
    await _acquireMutex();
    try {
      if (fromIndex < 0 ||
          fromIndex >= state.queue.length ||
          toIndex < 0 ||
          toIndex >= state.queue.length) {
        return;
      }

      final newQueue = List<Track>.from(state.queue);
      final track = newQueue.removeAt(fromIndex);
      newQueue.insert(toIndex, track);
      _originalQueue = List.from(newQueue);

      if (state.shuffleEnabled) {
        _shuffledIndices = _generateShuffledIndices(newQueue.length);
      }

      // Adjust current index
      int newCurrentIndex = state.currentIndex;
      if (fromIndex == state.currentIndex) {
        newCurrentIndex = toIndex;
      } else if (fromIndex < state.currentIndex && toIndex >= state.currentIndex) {
        newCurrentIndex--;
      } else if (fromIndex > state.currentIndex && toIndex <= state.currentIndex) {
        newCurrentIndex++;
      }

      state = state.copyWith(
        queue: newQueue,
        currentIndex: newCurrentIndex,
        shuffledIndices: _shuffledIndices,
      );
      
      // Save to persistence
      await _savePersistedState();
    } finally {
      _releaseMutex();
    }
  }

  /// Clear queue
  Future<void> clearQueue() async {
    await _acquireMutex();
    try {
      _originalQueue = [];
      _shuffledIndices = null;
      state = const QueueState(queue: [], currentIndex: 0);
      
      // Save to persistence (clear)
      await _savePersistedState();
    } finally {
      _releaseMutex();
    }
  }

  /// Play track at index
  Future<void> playIndex(int index) async {
    await _acquireMutex();
    try {
      if (index < 0 || index >= state.queue.length) return;

      state = state.copyWith(
        currentIndex: index,
      );
      
      // Save to persistence
      await _savePersistedState();
    } finally {
      _releaseMutex();
    }
  }

  /// Toggle shuffle
  Future<void> toggleShuffle() async {
    await _acquireMutex();
    try {
      final newShuffleEnabled = !state.shuffleEnabled;
      List<int>? newShuffledIndices;

      if (newShuffleEnabled) {
        newShuffledIndices = _generateShuffledIndices(state.queue.length);
        // Find current track's position in shuffled order
        final currentTrack = state.currentTrack;
        if (currentTrack != null) {
          final originalIndex = state.queue.indexOf(currentTrack);
          final shuffledIndex = newShuffledIndices.indexOf(originalIndex);
          if (shuffledIndex >= 0) {
            state = state.copyWith(
              shuffleEnabled: newShuffleEnabled,
              shuffledIndices: newShuffledIndices,
              currentIndex: shuffledIndex,
            );
            await _savePersistedState();
            _releaseMutex();
            return;
          }
        }
      } else {
        // Restore original order - find current track's original position
        final currentTrack = state.currentTrack;
        if (currentTrack != null) {
          final originalIndex = _originalQueue.indexOf(currentTrack);
          if (originalIndex >= 0) {
            state = state.copyWith(
              shuffleEnabled: newShuffleEnabled,
              shuffledIndices: null,
              currentIndex: originalIndex,
            );
            await _savePersistedState();
            _releaseMutex();
            return;
          }
        }
      }

      state = state.copyWith(
        shuffleEnabled: newShuffleEnabled,
        shuffledIndices: newShuffledIndices,
      );
      
      // Save to persistence
      await _savePersistedState();
    } finally {
      _releaseMutex();
    }
  }

  /// Set repeat mode
  Future<void> setRepeatMode(RepeatMode mode) async {
    await _acquireMutex();
    try {
      state = state.copyWith(repeatMode: mode);
      
      // Save to persistence
      await _savePersistedState();
    } finally {
      _releaseMutex();
    }
  }

  /// Go to next track
  Future<void> next() async {
    await _acquireMutex();
    try {
      if (!state.canGoNext) return;

      final nextIndex = state.nextIndex;
      if (nextIndex != null) {
        state = state.copyWith(currentIndex: nextIndex);
        // Save to persistence
        await _savePersistedState();
      }
    } finally {
      _releaseMutex();
    }
  }

  /// Go to previous track
  Future<void> previous() async {
    await _acquireMutex();
    try {
      if (!state.canGoPrevious) return;

      final prevIndex = state.previousIndex;
      if (prevIndex != null) {
        state = state.copyWith(currentIndex: prevIndex);
        // Save to persistence
        await _savePersistedState();
      }
    } finally {
      _releaseMutex();
    }
  }
}

/// Player Queue Service Provider
final playerQueueServiceProvider =
    StateNotifierProvider<PlayerQueueService, QueueState>(
  (ref) => PlayerQueueService(),
);

