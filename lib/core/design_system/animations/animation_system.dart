/// Animation System - Centralized Animation Management
///
/// This file provides a comprehensive animation system with
/// predefined durations, curves, and animation configurations.
library;

import 'package:flutter/material.dart';

/// Centralized animation system for consistent animations across the app
class AnimationSystem {
  static AnimationSystem? _instance;
  static AnimationSystem get instance => _instance ??= AnimationSystem._();

  AnimationSystem._();

  // Animation Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Animation Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // Scale Animation Values
  static const double scaleNormal = 1.0;
  static const double scalePressed = 0.95;
  static const double scaleHover = 1.02;
  static const double scalePulse = 1.1;

  // Rotation Animation Values
  static const double rotationNormal = 0.0;
  static const double rotationPressed = 0.1;

  // Elevation Animation Values
  static const double elevationNormal = 0.0;
  static const double elevationHover = 8.0;
  static const double elevationPressed = 4.0;

  // Opacity Animation Values
  static const double opacityNormal = 1.0;
  static const double opacityDisabled = 0.6;
  static const double opacityHover = 0.8;

  /// Create a scale animation controller
  static AnimationController createScaleController({
    required TickerProvider vsync,
    Duration duration = fast,
    Curve curve = easeInOut,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create a scale animation
  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    double begin = scaleNormal,
    double end = scalePressed,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create a rotation animation
  static Animation<double> createRotationAnimation({
    required AnimationController controller,
    double begin = rotationNormal,
    double end = rotationPressed,
    Curve curve = elasticOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create an elevation animation
  static Animation<double> createElevationAnimation({
    required AnimationController controller,
    double begin = elevationNormal,
    double end = elevationHover,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create an opacity animation
  static Animation<double> createOpacityAnimation({
    required AnimationController controller,
    double begin = opacityNormal,
    double end = opacityDisabled,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create a pulse animation controller
  static AnimationController createPulseController({
    required TickerProvider vsync,
    Duration duration = normal,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create a pulse animation
  static Animation<double> createPulseAnimation({
    required AnimationController controller,
    double begin = scaleNormal,
    double end = scalePulse,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create a ripple animation controller
  static AnimationController createRippleController({
    required TickerProvider vsync,
    Duration duration = slow,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create a ripple animation
  static Animation<double> createRippleAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = easeOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create a stagger animation controller
  static AnimationController createStaggerController({
    required TickerProvider vsync,
    Duration duration = verySlow,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create a stagger animation
  static Animation<double> createStaggerAnimation({
    required AnimationController controller,
    required double delay,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = fastOutSlowIn,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay,
        (delay + 0.3).clamp(0.0, 1.0),
        curve: curve,
      ),
    ));
  }
}

/// Animation utilities for common animation patterns
class AnimationUtils {
  /// Handle button press animation
  static void handleButtonPress({
    required AnimationController scaleController,
    required AnimationController? rippleController,
  }) {
    scaleController.forward();
    rippleController?.forward().then((_) {
      rippleController.reset();
    });
  }

  /// Handle button release animation
  static void handleButtonRelease({
    required AnimationController scaleController,
  }) {
    scaleController.reverse();
  }

  /// Handle button cancel animation
  static void handleButtonCancel({
    required AnimationController scaleController,
  }) {
    scaleController.reverse();
  }

  /// Handle hover enter animation
  static void handleHoverEnter({
    required AnimationController scaleController,
    required AnimationController elevationController,
  }) {
    scaleController.forward();
    elevationController.forward();
  }

  /// Handle hover exit animation
  static void handleHoverExit({
    required AnimationController scaleController,
    required AnimationController elevationController,
  }) {
    scaleController.reverse();
    elevationController.reverse();
  }

  /// Start pulse animation
  static void startPulse({
    required AnimationController pulseController,
  }) {
    pulseController.repeat(reverse: true);
  }

  /// Stop pulse animation
  static void stopPulse({
    required AnimationController pulseController,
  }) {
    pulseController.stop();
    pulseController.reset();
  }

  /// Start stagger animation
  static void startStagger({
    required AnimationController staggerController,
  }) {
    staggerController.forward();
  }

  /// Reset stagger animation
  static void resetStagger({
    required AnimationController staggerController,
  }) {
    staggerController.reset();
  }
}

/// Predefined animation configurations
class AnimationConfigs {
  // Button animations
  static const Map<String, dynamic> buttonPress = {
    'duration': AnimationSystem.fast,
    'curve': AnimationSystem.easeInOut,
    'scale': AnimationSystem.scalePressed,
  };

  static const Map<String, dynamic> buttonHover = {
    'duration': AnimationSystem.fast,
    'curve': AnimationSystem.easeInOut,
    'scale': AnimationSystem.scaleHover,
    'elevation': AnimationSystem.elevationHover,
  };

  // Icon animations
  static const Map<String, dynamic> iconPress = {
    'duration': AnimationSystem.fast,
    'curve': AnimationSystem.elasticOut,
    'scale': AnimationSystem.scalePressed,
    'rotation': AnimationSystem.rotationPressed,
  };

  static const Map<String, dynamic> iconPulse = {
    'duration': AnimationSystem.normal,
    'curve': AnimationSystem.easeInOut,
    'scale': AnimationSystem.scalePulse,
  };

  // Card animations
  static const Map<String, dynamic> cardHover = {
    'duration': AnimationSystem.fast,
    'curve': AnimationSystem.easeInOut,
    'scale': AnimationSystem.scaleHover,
    'elevation': AnimationSystem.elevationHover,
  };

  // Ripple animations
  static const Map<String, dynamic> ripple = {
    'duration': AnimationSystem.slow,
    'curve': AnimationSystem.easeOut,
    'opacity': 0.3,
  };

  // Stagger animations
  static const Map<String, dynamic> stagger = {
    'duration': AnimationSystem.verySlow,
    'curve': AnimationSystem.fastOutSlowIn,
    'delay': 0.1,
  };
}
