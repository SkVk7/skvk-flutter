# Audio Player Refactor - Integration Guide

This document describes the new production-grade audio player implementation and how to integrate it with the existing codebase.

## Overview

The new audio player implementation follows MVVM architecture with Riverpod for state management. It provides:

- **Single player instance** shared between mini player and full-screen Now Playing view
- **Smooth animations** with hero transitions
- **Lyrics support** with scrollable view
- **Production-grade UI/UX** matching modern streaming apps

## Architecture

### Components

1. **AudioController** (`lib/core/services/audio/audio_controller.dart`)
   - Wraps existing `GlobalAudioPlayerController` for compatibility
   - Manages all playback logic and state
   - Uses Riverpod `StateNotifier` pattern
   - Located in core/services following the codebase structure

2. **Track Model** (`lib/core/models/audio/track.dart`)
   - Immutable track model with all metadata
   - Supports conversion from API music maps
   - Located in core/models following the codebase structure

3. **MiniPlayer** (`lib/ui/components/audio/mini_player.dart`)
   - Sticky bottom player widget
   - Expands to Now Playing on tap
   - Hero animation for artwork
   - Located in ui/components following the codebase structure

4. **NowPlayingScreen** (`lib/ui/screens/now_playing_screen.dart`)
   - Full-screen player with artwork/lyrics toggle
   - Bottom scrubber and controls
   - Smooth transitions
   - Located in ui/screens following the codebase structure

5. **AudioListScreen** (`lib/ui/screens/audio_list_screen.dart`)
   - Track list with search
   - Proper padding to avoid mini player overlap
   - Located in ui/screens following the codebase structure

## Integration Steps

### 1. Update Main App Builder

The mini player is already integrated in `main.dart` via the `Stack` widget. No changes needed if using the existing setup.

### 2. Using the New AudioController

Replace direct usage of `globalAudioPlayerProvider` with `audioControllerProvider`:

```dart
// Old way
final playerState = ref.watch(globalAudioPlayerProvider);
final controller = ref.read(globalAudioPlayerProvider.notifier);

// New way
final playerState = ref.watch(audioControllerProvider);
final controller = ref.read(audioControllerProvider.notifier);
```

### 3. Playing a Track

```dart
final controller = ref.read(audioControllerProvider.notifier);
final track = Track.fromMusicMap(musicMap);
await controller.playTrack(track);
```

### 4. Navigation to Now Playing

The mini player automatically handles navigation. To manually navigate:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const NowPlayingScreen(),
  ),
);
```

## Compatibility with Existing AudioHandler

The new `AudioController` wraps the existing `GlobalAudioPlayerController`, maintaining full compatibility:

- All existing functionality continues to work
- No breaking changes to existing code
- Gradual migration path available

### Migration Path

1. **Phase 1**: Use new screens (`AudioListScreen`, `NowPlayingScreen`) alongside existing code
2. **Phase 2**: Gradually replace `globalAudioPlayerProvider` with `audioControllerProvider`
3. **Phase 3**: Remove old audio screen implementation once fully migrated

## Hot Reload Notes

The audio player state is managed by Riverpod providers, which persist across hot reloads:

- **Player state**: Maintained during hot reload
- **Current track**: Preserved
- **Playback position**: May reset (expected behavior)
- **UI state**: Resets on hot reload (normal Flutter behavior)

### Best Practices for Hot Reload

1. **State preservation**: Use `ref.watch()` for reactive UI updates
2. **Controller access**: Use `ref.read()` for one-time actions
3. **Testing**: Use `ProviderContainer` in tests for isolated state

## File Structure

Following the codebase structure with `lib/core/` and `lib/ui/`:

```
lib/
├── core/
│   ├── models/
│   │   └── audio/
│   │       └── track.dart                      # Track model
│   └── services/
│       └── audio/
│           ├── audio_controller.dart            # Main controller (MVVM)
│           └── global_audio_player_controller.dart  # Existing controller
└── ui/
    ├── screens/
    │   ├── audio_list_screen.dart              # Track list screen
    │   └── now_playing_screen.dart              # Full-screen player
    ├── components/
    │   └── audio/
    │       ├── mini_player.dart                 # Sticky mini player
    │       ├── lyrics_view.dart                 # Scrollable lyrics
    │       └── player_controls.dart             # Play/pause/next/prev
    └── utils/
        └── animations.dart                     # Animation constants
```

## Testing

Unit tests are located in `test/unit/audio_controller_test.dart`:

```bash
flutter test test/unit/audio_controller_test.dart
```

### Running All Tests

```bash
flutter test
```

## Key Features

### Mini Player
- Height: 72dp (responsive)
- Shows: Artwork, title, subtitle, play/pause, close button
- Behavior: Expands to Now Playing on tap, can be hidden

### Now Playing Screen
- Artwork view with hero animation
- Lyrics toggle (if available)
- Bottom scrubber with time display
- Player controls (prev/play-pause/next)
- Repeat/shuffle controls

### Lyrics Support
- Scrollable lyrics view
- Auto-highlights current line (if timestamps available)
- Graceful fallback when no lyrics available

## Troubleshooting

### Mini Player Not Showing
- Check `playerState.showMiniPlayer` is `true`
- Ensure a track is loaded (`playerState.hasTrack`)
- Verify mini player is in the widget tree

### Playback Not Working
- Verify `GlobalAudioPlayerController` is properly initialized
- Check network connectivity for streaming
- Review error messages in `playerState.errorMessage`

### Hero Animation Not Working
- Ensure artwork `Hero` tag matches: `'artwork-${track.id}'`
- Check both mini player and Now Playing use the same tag
- Verify navigation uses `PageRouteBuilder` for custom transitions

## Future Enhancements

Potential improvements for future iterations:

1. **Queue Management**: Full queue UI with reordering
2. **Offline Support**: Download and play offline tracks
3. **Playback Speed**: UI controls for speed adjustment
4. **Equalizer**: Audio effects and equalizer
5. **Background Playback**: Continue playing when app is backgrounded

## Support

For issues or questions:
1. Check existing tests for usage examples
2. Review `AudioController` documentation
3. Check `GlobalAudioPlayerController` for underlying implementation details

