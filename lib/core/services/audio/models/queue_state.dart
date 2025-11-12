/// Queue State Model
///
/// Immutable snapshot of queue state
library;

import '../../../models/audio/track.dart';
import 'package:skvk_application/core/services/audio/global_audio_player_controller.dart';

/// Queue state - immutable snapshot
class QueueState {
  final List<Track> queue;
  final int currentIndex;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final List<int>? shuffledIndices; // Mapping for shuffle mode

  const QueueState({
    required this.queue,
    required this.currentIndex,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.none,
    this.shuffledIndices,
  });

  /// Get current track
  Track? get currentTrack {
    if (queue.isEmpty) return null;
    if (shuffleEnabled && shuffledIndices != null) {
      final mappedIndex = shuffledIndices![currentIndex.clamp(0, shuffledIndices!.length - 1)];
      return queue[mappedIndex];
    }
    return queue[currentIndex.clamp(0, queue.length - 1)];
  }

  /// Get next track index
  int? get nextIndex {
    if (queue.isEmpty) return null;
    if (currentIndex >= queue.length - 1) {
      if (repeatMode == RepeatMode.all) return 0;
      return null;
    }
    return currentIndex + 1;
  }

  /// Get previous track index
  int? get previousIndex {
    if (queue.isEmpty) return null;
    if (currentIndex <= 0) {
      if (repeatMode == RepeatMode.all) return queue.length - 1;
      return null;
    }
    return currentIndex - 1;
  }

  /// Check if can go to next
  bool get canGoNext {
    if (queue.isEmpty) return false;
    if (currentIndex < queue.length - 1) return true;
    return repeatMode == RepeatMode.all;
  }

  /// Check if can go to previous
  bool get canGoPrevious {
    if (queue.isEmpty) return false;
    if (currentIndex > 0) return true;
    return repeatMode == RepeatMode.all;
  }

  /// Create a copy with updated fields
  QueueState copyWith({
    List<Track>? queue,
    int? currentIndex,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
    List<int>? shuffledIndices,
  }) {
    return QueueState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffledIndices: shuffledIndices ?? this.shuffledIndices,
    );
  }

  @override
  String toString() =>
      'QueueState(queue: ${queue.length}, currentIndex: $currentIndex, shuffle: $shuffleEnabled, repeat: $repeatMode)';
}

