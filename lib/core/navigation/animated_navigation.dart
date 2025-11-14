/// Animated Navigation System
///
/// This file provides enhanced navigation with smooth transitions
/// and animations throughout the application.
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/design_system/design_system.dart';

/// Slide direction enum for navigation animations
enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// Animated page route with slide transitions
class AnimatedPageRoute<T> extends PageRoute<T> {
  AnimatedPageRoute({
    required this.child,
    required this.direction,
    required this.duration,
  });
  final Widget child;
  final SlideDirection direction;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => true;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Offset begin;
    switch (direction) {
      case SlideDirection.leftToRight:
        begin = const Offset(-1, 0);
        break;
      case SlideDirection.rightToLeft:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.topToBottom:
        begin = const Offset(0, -1);
        break;
      case SlideDirection.bottomToTop:
        begin = const Offset(0, 1);
        break;
    }

    const end = Offset.zero;
    const curve = Curves.easeInOut;

    final tween = Tween(begin: begin, end: end);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }
}

/// Enhanced navigation service with animations
class AnimatedNavigation {
  /// Navigate with slide transition
  static Future<T?> pushSlide<T extends Object?>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.rightToLeft,
    Duration duration = AnimationSystem.normal,
  }) {
    return Navigator.push<T>(
      context,
      AnimatedPageRoute<T>(
        child: page,
        direction: direction,
        duration: duration,
      ),
    );
  }

  /// Navigate with fade transition
  static Future<T?> pushFade<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = AnimationSystem.normal,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate with scale transition
  static Future<T?> pushScale<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = AnimationSystem.normal,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(
              begin: beginScale,
              end: endScale,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate with hero transition
  static Future<T?> pushHero<T extends Object?>(
    BuildContext context,
    Widget page, {
    required String heroTag,
    Duration duration = AnimationSystem.normal,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Hero(
            tag: heroTag,
            child: child,
            flightShuttleBuilder: (
              flightContext,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) {
              return Transform.scale(
                scale: animation.value,
                child: child,
              );
            },
          );
        },
      ),
    );
  }

  /// Replace with slide transition
  static Future<T?> pushReplacementSlide<T extends Object?>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.rightToLeft,
    Duration duration = AnimationSystem.normal,
  }) {
    return Navigator.pushReplacement<T, dynamic>(
      context,
      AnimatedPageRoute<T>(
        child: page,
        direction: direction,
        duration: duration,
      ),
    );
  }

  /// Replace with fade transition
  static Future<T?> pushReplacementFade<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = AnimationSystem.normal,
  }) {
    return Navigator.pushReplacement<T, dynamic>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  /// Pop with animation
  static void popAnimated<T extends Object?>(
    BuildContext context, {
    T? result,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    Navigator.of(context).pop<T>(result);
  }

  /// Show animated dialog
  static Future<T?> showAnimatedDialog<T extends Object?>(
    BuildContext context,
    Widget dialog, {
    Duration duration = AnimationSystem.normal,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AnimatedDialog(
        duration: duration,
        child: dialog,
      ),
    );
  }

  /// Show animated bottom sheet
  static Future<T?> showAnimatedBottomSheet<T extends Object?>(
    BuildContext context,
    Widget bottomSheet, {
    Duration duration = AnimationSystem.normal,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedBottomSheet(
        duration: duration,
        child: bottomSheet,
      ),
    );
  }

  /// Show animated snackbar
  static void showAnimatedSnackBar(
    BuildContext context,
    String message, {
    Duration duration = AnimationSystem.normal,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AnimatedSnackBarContent(
          message: message,
          icon: icon,
          textColor: textColor,
        ),
        backgroundColor: backgroundColor,
        duration: Duration(milliseconds: duration.inMilliseconds + 2000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Animated dialog widget
class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 300),
  });
  final Widget child;
  final Duration duration;

  @override
  State<AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Animated bottom sheet widget
class AnimatedBottomSheet extends StatefulWidget {
  const AnimatedBottomSheet({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 300),
  });
  final Widget child;
  final Duration duration;

  @override
  State<AnimatedBottomSheet> createState() => _AnimatedBottomSheetState();
}

class _AnimatedBottomSheetState extends State<AnimatedBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Animated snackbar content
class AnimatedSnackBarContent extends StatefulWidget {
  const AnimatedSnackBarContent({
    required this.message,
    super.key,
    this.icon,
    this.textColor,
  });
  final String message;
  final IconData? icon;
  final Color? textColor;

  @override
  State<AnimatedSnackBarContent> createState() =>
      _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * 100, 0),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.textColor,
                    size: ResponsiveSystem.iconSize(
                      context,
                      baseSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: ResponsiveSystem.fontSize(
                        context,
                        baseSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Navigation extensions for easy access
extension NavigationExtensions on BuildContext {
  /// Navigate with slide transition
  Future<T?> pushSlide<T extends Object?>(
    Widget page, {
    SlideDirection direction = SlideDirection.rightToLeft,
    Duration duration = AnimationSystem.normal,
  }) {
    return AnimatedNavigation.pushSlide<T>(
      this,
      page,
      direction: direction,
      duration: duration,
    );
  }

  /// Navigate with fade transition
  Future<T?> pushFade<T extends Object?>(
    Widget page, {
    Duration duration = AnimationSystem.normal,
  }) {
    return AnimatedNavigation.pushFade<T>(
      this,
      page,
      duration: duration,
    );
  }

  /// Navigate with scale transition
  Future<T?> pushScale<T extends Object?>(
    Widget page, {
    Duration duration = AnimationSystem.normal,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return AnimatedNavigation.pushScale<T>(
      this,
      page,
      duration: duration,
      beginScale: beginScale,
      endScale: endScale,
    );
  }

  /// Navigate with hero transition
  Future<T?> pushHero<T extends Object?>(
    Widget page, {
    required String heroTag,
    Duration duration = AnimationSystem.normal,
  }) {
    return AnimatedNavigation.pushHero<T>(
      this,
      page,
      heroTag: heroTag,
      duration: duration,
    );
  }

  /// Show animated dialog
  Future<T?> showAnimatedDialog<T extends Object?>(
    Widget dialog, {
    Duration duration = AnimationSystem.normal,
    bool barrierDismissible = true,
  }) {
    return AnimatedNavigation.showAnimatedDialog<T>(
      this,
      dialog,
      duration: duration,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Show animated bottom sheet
  Future<T?> showAnimatedBottomSheet<T extends Object?>(
    Widget bottomSheet, {
    Duration duration = AnimationSystem.normal,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return AnimatedNavigation.showAnimatedBottomSheet<T>(
      this,
      bottomSheet,
      duration: duration,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Show animated snackbar
  void showAnimatedSnackBar(
    String message, {
    Duration duration = AnimationSystem.normal,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    AnimatedNavigation.showAnimatedSnackBar(
      this,
      message,
      duration: duration,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
    );
  }
}
