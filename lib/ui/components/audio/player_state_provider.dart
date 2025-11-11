/// Player State Provider
///
/// Tracks whether the player is maximized or minimized
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Player view state
enum PlayerViewState {
  minimized,
  maximized,
}

/// Player state notifier
class PlayerStateNotifier extends StateNotifier<PlayerViewState> {
  PlayerStateNotifier() : super(PlayerViewState.minimized);

  void maximize() {
    state = PlayerViewState.maximized;
  }

  void minimize() {
    state = PlayerViewState.minimized;
  }

  void toggle() {
    state = state == PlayerViewState.maximized
        ? PlayerViewState.minimized
        : PlayerViewState.maximized;
  }
}

/// Player state provider
final playerViewStateProvider =
    StateNotifierProvider<PlayerStateNotifier, PlayerViewState>((ref) {
  return PlayerStateNotifier();
});

