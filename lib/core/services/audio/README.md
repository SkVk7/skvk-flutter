# Audio System Architecture

## Overview

This document describes the architecture of the Queue and Playlist subsystems for the global audio player.

## Data Models

### Track

```dart
class Track {
  final String id;
  final String title;
  final String subtitle;
  final String album;
  final Duration duration;
  final String coverUrl;
  final String sourceUrl;
  final Map<String, dynamic>? metadata;
}
```

### Playlist

```dart
class Playlist {
  final String id;
  final String name;
  final String? description;
  final List<String> trackIds;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### QueueState

```dart
class QueueState {
  final List<Track> queue;
  final int currentIndex;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final List<int>? shuffledIndices; // Mapping for shuffle mode
}
```

## Services

### PlayerQueueService

Manages the audio playback queue with shuffle and repeat support.

**Key Features:**
- Thread-safe operations using mutex
- Shuffle mode maintains original queue order
- Repeat modes: none, one, all
- Stream-based state updates

**Usage:**
```dart
final queueService = ref.read(playerQueueServiceProvider.notifier);

// Load queue
await queueService.loadQueue(tracks, startIndex: 0, autoplay: true);

// Append tracks
await queueService.appendTracks(newTracks);

// Play index
await queueService.playIndex(5);

// Toggle shuffle
await queueService.toggleShuffle();

// Set repeat mode
await queueService.setRepeatMode(RepeatMode.all);
```

### PlaylistService

Manages playlists with local persistence using SharedPreferences.

**Key Features:**
- CRUD operations for playlists
- Local persistence
- Export/import JSON for backup
- Thread-safe operations

**Usage:**
```dart
final playlistService = ref.read(playlistServiceProvider.notifier);

// Create playlist
final playlist = await playlistService.createPlaylist(
  'My Playlist',
  description: 'Description',
  initialTracks: tracks,
);

// Add track to playlist
await playlistService.addToPlaylist(playlistId, track);

// Export playlist
final json = await playlistService.exportPlaylist(playlistId);
```

### Network Connectivity

The audio player requires an active internet connection for streaming. All audio is streamed online as the app requires active internet connectivity.

**Network Check:**
- The `GlobalAudioPlayerController` checks connectivity before loading tracks
- Shows user-friendly message if offline: "Please connect to the internet to stream audio. This app requires an active internet connection for streaming and monetization."
- Uses `NetworkConnectivityService` to check connectivity status

## Integration with GlobalAudioPlayerController

The `GlobalAudioPlayerController` should be updated to use `PlayerQueueService`:

```dart
// In GlobalAudioPlayerController
final queueService = ref.read(playerQueueServiceProvider.notifier);

// Load track from queue
final currentTrack = queueService.currentTrack;
if (currentTrack != null) {
  await loadTrack(currentTrack);
}

// Handle playback completion
void _handlePlaybackComplete() {
  if (queueService.repeatMode == RepeatMode.one) {
    // Repeat current track
    seek(Duration.zero);
  } else if (queueService.repeatMode == RepeatMode.all) {
    // Go to next track
    queueService.next();
    final nextTrack = queueService.currentTrack;
    if (nextTrack != null) {
      loadTrack(nextTrack);
    }
  } else {
    // Go to next track or stop
    if (queueService.canGoNext) {
      queueService.next();
      final nextTrack = queueService.currentTrack;
      if (nextTrack != null) {
        loadTrack(nextTrack);
      }
    } else {
      stop();
    }
  }
}
```

## UI Components

### QueueView

Shows current queue with drag-to-reorder and swipe-to-delete.

**Features:**
- ReorderableListView for drag-to-reorder
- Dismissible for swipe-to-delete
- Highlights currently playing track

### PlaylistList

Shows all playlists with counts and overflow menu.

**Features:**
- List of playlists
- Track count display
- Overflow menu (rename, share, delete)

### PlaylistDetail

Shows tracks in playlist with reorder support and 'play all' button.

**Features:**
- Track list with reorder
- Play all button
- Add/remove tracks


## Persistence

### Queue Persistence

Queue state is persisted every 10 seconds or on major events:
- Current track ID
- Current position
- Repeat mode
- Shuffle enabled

### Playlist Persistence

Playlists are persisted to SharedPreferences as JSON.


## Analytics Hooks

Events are emitted via Riverpod streams:

- `track_play` - Track started playing
- `track_pause` - Track paused
- `track_seek` - Track seeked
- `track_complete` - Track completed
- `playlist_create` - Playlist created
- `playlist_delete` - Playlist deleted

## Testing

### Unit Tests

- `PlayerQueueService` - Test queue operations, shuffle, repeat
- `PlaylistService` - Test CRUD operations, persistence

### Integration Tests

- Restore queue on app restart
- Resume playback position
- Shuffle/repeat behavior correctness

## Migration Guide

### From Local Player to Global Queue

1. Replace local player instances with `PlayerQueueService`
2. Use `queueService.loadQueue()` instead of `loadTrack()`
3. Use `queueService.playIndex()` to play specific tracks
4. Remove local player state management

### Example Migration

**Before:**
```dart
final _audioPlayer = AudioPlayer();
await _audioPlayer.setUrl(audioUrl);
await _audioPlayer.play();
```

**After:**
```dart
final queueService = ref.read(playerQueueServiceProvider.notifier);
final playerController = ref.read(globalAudioPlayerProvider.notifier);

// Load queue
await queueService.loadQueue(tracks, startIndex: 0);

// Play current track
final currentTrack = queueService.currentTrack;
if (currentTrack != null) {
  await playerController.loadTrack(currentTrack);
  await playerController.playPause();
}
```

## License

All packages used:
- `just_audio`: MIT License
- `shared_preferences`: BSD-3-Clause License
- `path_provider`: BSD-3-Clause License
- `http`: BSD-3-Clause License

