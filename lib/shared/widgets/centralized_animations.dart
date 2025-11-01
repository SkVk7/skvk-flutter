import 'package:flutter/material.dart';

/// Centralized animation controller factory
class CentralizedAnimationController {
  static AnimationController createStandard(
    TickerProvider vsync, {
    Duration? duration,
  }) {
    return AnimationController(
      duration: duration ?? const Duration(milliseconds: 300),
      vsync: vsync,
    );
  }

  static AnimationController createSlow(
    TickerProvider vsync, {
    Duration? duration,
  }) {
    return AnimationController(
      duration: duration ?? const Duration(milliseconds: 600),
      vsync: vsync,
    );
  }

  static AnimationController createFast(
    TickerProvider vsync, {
    Duration? duration,
  }) {
    return AnimationController(
      duration: duration ?? const Duration(milliseconds: 150),
      vsync: vsync,
    );
  }
}

/// Centralized Animated Opacity
class CentralizedAnimatedOpacity extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedOpacity({
    super.key,
    required this.child,
    required this.opacity,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Centralized Animated Scale
class CentralizedAnimatedScale extends StatelessWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  const CentralizedAnimatedScale({
    super.key,
    required this.child,
    required this.scale,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: child,
    );
  }
}

/// Centralized Animated Slide
class CentralizedAnimatedSlide extends StatelessWidget {
  final Widget child;
  final Offset offset;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedSlide({
    super.key,
    required this.child,
    required this.offset,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: offset,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: curve,
      )),
      child: child,
    );
  }
}

/// Centralized Animated Container
class CentralizedAnimatedContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

/// Centralized Animated Positioned
class CentralizedAnimatedPositioned extends StatelessWidget {
  final Widget child;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedPositioned({
    super.key,
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Centralized Animated Cross Fade
class CentralizedAnimatedCrossFade extends StatelessWidget {
  final Widget firstChild;
  final Widget secondChild;
  final CrossFadeState crossFadeState;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedCrossFade({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.crossFadeState,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState: crossFadeState,
      duration: duration,
    );
  }
}

/// Centralized Animated Switcher
class CentralizedAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  const CentralizedAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.transitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: transitionBuilder ?? (child, animation) => child,
      child: child,
    );
  }
}

/// Centralized Animated List
class CentralizedAnimatedList extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final Curve curve;
  final Axis scrollDirection;
  final ScrollController? controller;

  const CentralizedAnimatedList({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.scrollDirection = Axis.vertical,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: duration,
          curve: curve,
          child: children[index],
        );
      },
    );
  }
}

/// Centralized Animated Rotation
class CentralizedAnimatedRotation extends StatelessWidget {
  final Widget child;
  final double turns;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedRotation({
    super.key,
    required this.child,
    required this.turns,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turns,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Centralized Animated Align
class CentralizedAnimatedAlign extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedAlign({
    super.key,
    required this.child,
    required this.alignment,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: alignment,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Centralized Animated Padding
class CentralizedAnimatedPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedPadding({
    super.key,
    required this.child,
    required this.padding,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: padding,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Centralized Animated Size
class CentralizedAnimatedSize extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  const CentralizedAnimatedSize({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: child,
    );
  }
}

/// Centralized Animated Default Text Style
class CentralizedAnimatedDefaultTextStyle extends StatelessWidget {
  final Widget child;
  final TextStyle style;
  final Duration duration;
  final Curve curve;
  final TextAlign? textAlign;

  const CentralizedAnimatedDefaultTextStyle({
    super.key,
    required this.child,
    required this.style,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      style: style,
      duration: duration,
      curve: curve,
      textAlign: textAlign,
      child: child,
    );
  }
}

/// Centralized Animated Theme
class CentralizedAnimatedTheme extends StatelessWidget {
  final Widget child;
  final ThemeData data;
  final Duration duration;
  final Curve curve;

  const CentralizedAnimatedTheme({
    super.key,
    required this.child,
    required this.data,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: data,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Centralized Animated Builder
class CentralizedAnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const CentralizedAnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

/// Centralized Animated Widget
class CentralizedAnimatedWidget extends AnimatedWidget {
  final Widget child;
  final Widget Function(BuildContext, Widget?, Animation<double>) builder;

  const CentralizedAnimatedWidget({
    super.key,
    required this.child,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child, listenable as Animation<double>);
  }
}

/// Centralized Animated Opacity (alias)
class CentralizedAnimatedOpacityAlias extends AnimatedOpacity {
  const CentralizedAnimatedOpacityAlias({
    super.key,
    required super.opacity,
    required super.child,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.easeInOut,
  });
}

/// Centralized Animated Scale (alias)
class CentralizedAnimatedScaleAlias extends AnimatedScale {
  const CentralizedAnimatedScaleAlias({
    super.key,
    required super.scale,
    required super.child,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.easeInOut,
    super.alignment = Alignment.center,
  });
}

/// Centralized Animated Slide (alias)
class CentralizedAnimatedSlideAlias extends AnimatedSlide {
  const CentralizedAnimatedSlideAlias({
    super.key,
    required super.offset,
    required super.child,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.easeInOut,
  });
}
