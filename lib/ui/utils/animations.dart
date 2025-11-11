/// Animation Utilities
///
/// Shared animation durations, curves, and constants for consistent
/// animations across the audio player UI.
library;

import 'package:flutter/material.dart';

/// Animation durations used throughout the player
class AnimationDurations {
  /// Quick animation (button presses, small transitions)
  static const quick = Duration(milliseconds: 150);

  /// Standard animation (most UI transitions)
  static const standard = Duration(milliseconds: 300);

  /// Extended animation (page transitions, hero animations)
  static const extended = Duration(milliseconds: 400);

  /// Long animation (complex transitions)
  static const long = Duration(milliseconds: 500);

  /// Mini player expand/collapse
  static const playerExpand = Duration(milliseconds: 350);
}

/// Animation curves for consistent feel
class AnimationCurves {
  /// Standard easing curve
  static const standard = Curves.easeOut;

  /// Smooth cubic easing (for player transitions)
  static const smooth = Curves.easeOutCubic;

  /// Sharp cubic easing (for quick interactions)
  static const sharp = Curves.easeInOutCubic;

  /// Bounce effect (for playful interactions)
  static const bounce = Curves.elasticOut;
}

/// Mini player height constant
const double kMiniPlayerHeight = 72.0;

/// Extended mini player height (when showing more info)
const double kMiniPlayerHeightExtended = 84.0;

