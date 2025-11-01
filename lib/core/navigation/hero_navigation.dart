/// Hero Navigation System
///
/// Provides zoom-out and zoom-in animations for navigation
/// - Zoom-out: Screen expands from a specific widget (like profile icon)
/// - Zoom-in: Screen contracts back to a specific widget (like back button)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '../design_system/responsive/responsive_system.dart';

class HeroNavigation {
  /// Navigate with zoom-out animation from a specific widget
  static Future<T?> pushZoomOut<T extends Object?>(
    BuildContext context,
    Widget destination,
    Offset sourcePosition,
    Size sourceSize, {
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
    String? heroTag,
  }) async {
    return Navigator.push<T>(
      context,
      _ZoomOutPageRoute<T>(
        destination: destination,
        sourcePosition: sourcePosition,
        sourceSize: sourceSize,
        duration: duration,
        curve: curve,
        heroTag: heroTag,
      ),
    );
  }

  /// Navigate with zoom-in animation to a specific widget
  static Future<T?> pushZoomIn<T extends Object?>(
    BuildContext context,
    Widget destination,
    Offset targetPosition,
    Size targetSize, {
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
    String? heroTag,
  }) async {
    return Navigator.push<T>(
      context,
      _ZoomInPageRoute<T>(
        destination: destination,
        targetPosition: targetPosition,
        targetSize: targetSize,
        duration: duration,
        curve: curve,
        heroTag: heroTag,
      ),
    );
  }
}

/// Enhanced Hero Navigation with Ripple Effect
class HeroNavigationWithRipple {
  /// Navigate with zoom-out and ripple effect
  static Future<T?> pushWithRipple<T extends Object?>(
    BuildContext context,
    Widget destination,
    Offset sourcePosition,
    Size sourceSize, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
    Color? rippleColor,
    double? rippleRadius,
  }) async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    return Navigator.push<T>(
      context,
      _RipplePageRoute<T>(
        destination: destination,
        sourcePosition: sourcePosition,
        sourceSize: sourceSize,
        duration: duration,
        curve: curve,
        rippleColor: rippleColor ?? Theme.of(context).colorScheme.primary,
        rippleRadius: rippleRadius ?? ResponsiveSystem.spacing(context, baseSpacing: 100),
      ),
    );
  }
}

/// Custom Page Route for Zoom-Out Animation
class _ZoomOutPageRoute<T> extends PageRoute<T> {
  final Widget destination;
  final Offset sourcePosition;
  final Size sourceSize;
  final Duration duration;
  final Curve curve;
  final String? heroTag;

  _ZoomOutPageRoute({
    required this.destination,
    required this.sourcePosition,
    required this.sourceSize,
    required this.duration,
    required this.curve,
    this.heroTag,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return destination;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return _ZoomOutTransition(
      animation: curvedAnimation,
      sourcePosition: sourcePosition,
      sourceSize: sourceSize,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => duration;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;
}

/// Custom Page Route for Zoom-In Animation
class _ZoomInPageRoute<T> extends PageRoute<T> {
  final Widget destination;
  final Offset targetPosition;
  final Size targetSize;
  final Duration duration;
  final Curve curve;
  final String? heroTag;

  _ZoomInPageRoute({
    required this.destination,
    required this.targetPosition,
    required this.targetSize,
    required this.duration,
    required this.curve,
    this.heroTag,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return destination;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return _ZoomInTransition(
      animation: curvedAnimation,
      targetPosition: targetPosition,
      targetSize: targetSize,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => duration;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;
}

/// Ripple Page Route
class _RipplePageRoute<T> extends PageRoute<T> {
  final Widget destination;
  final Offset sourcePosition;
  final Size sourceSize;
  final Duration duration;
  final Curve curve;
  final Color rippleColor;
  final double rippleRadius;

  _RipplePageRoute({
    required this.destination,
    required this.sourcePosition,
    required this.sourceSize,
    required this.duration,
    required this.curve,
    required this.rippleColor,
    required this.rippleRadius,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return destination;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return _RippleTransition(
      animation: curvedAnimation,
      sourcePosition: sourcePosition,
      rippleColor: rippleColor,
      rippleRadius: rippleRadius,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => duration;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;
}

/// Zoom-Out Transition Widget
class _ZoomOutTransition extends StatelessWidget {
  final Animation<double> animation;
  final Offset sourcePosition;
  final Size sourceSize;
  final Widget child;

  const _ZoomOutTransition({
    required this.animation,
    required this.sourcePosition,
    required this.sourceSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate the scale and position for zoom-out effect
        final scale = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).evaluate(animation);

        final opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).evaluate(animation);

        // Calculate the position offset to create zoom-out from source
        final offsetX = Tween<double>(
          begin: sourcePosition.dx - (screenSize.width / 2),
          end: 0.0,
        ).evaluate(animation);

        final offsetY = Tween<double>(
          begin: sourcePosition.dy - (screenSize.height / 2),
          end: 0.0,
        ).evaluate(animation);

        return Transform(
          transform: Matrix4.identity()
            ..translateByVector3(Vector3(offsetX, offsetY, 0))
            ..scaleByVector3(Vector3(scale, scale, 1)),
          child: Opacity(
            opacity: opacity,
            child: this.child,
          ),
        );
      },
    );
  }
}

/// Zoom-In Transition Widget
class _ZoomInTransition extends StatelessWidget {
  final Animation<double> animation;
  final Offset targetPosition;
  final Size targetSize;
  final Widget child;

  const _ZoomInTransition({
    required this.animation,
    required this.targetPosition,
    required this.targetSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate the scale and position for zoom-in effect
        final scale = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).evaluate(animation);

        final opacity = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).evaluate(animation);

        // Calculate the position offset to create zoom-in to target
        final offsetX = Tween<double>(
          begin: 0.0,
          end: targetPosition.dx - (screenSize.width / 2),
        ).evaluate(animation);

        final offsetY = Tween<double>(
          begin: 0.0,
          end: targetPosition.dy - (screenSize.height / 2),
        ).evaluate(animation);

        return Transform(
          transform: Matrix4.identity()
            ..translateByVector3(Vector3(offsetX, offsetY, 0))
            ..scaleByVector3(Vector3(scale, scale, 1)),
          child: Opacity(
            opacity: opacity,
            child: this.child,
          ),
        );
      },
    );
  }
}

/// Ripple Transition Widget
class _RippleTransition extends StatelessWidget {
  final Animation<double> animation;
  final Offset sourcePosition;
  final Color rippleColor;
  final double rippleRadius;
  final Widget child;

  const _RippleTransition({
    required this.animation,
    required this.sourcePosition,
    required this.rippleColor,
    required this.rippleRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).evaluate(animation);

        final opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).evaluate(animation);

        return Stack(
          children: [
            // Ripple effect
            Positioned.fill(
              child: CustomPaint(
                painter: RipplePainter(
                  animation: animation,
                  rippleColor: rippleColor,
                  rippleRadius: rippleRadius,
                ),
              ),
            ),
            // Main content
            Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: this.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Ripple Painter
class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color rippleColor;
  final double rippleRadius;

  RipplePainter({
    required this.animation,
    required this.rippleColor,
    required this.rippleRadius,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = rippleColor.withValues(
        alpha: ((1.0 - animation.value) * 0.3),
      )
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = rippleRadius * animation.value;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
