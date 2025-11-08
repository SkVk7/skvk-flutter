/// Responsive System - Centralized Responsive Design
///
/// This file provides a comprehensive responsive design system
/// with breakpoints, sizing utilities, and responsive widgets.
library;

import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

/// Screen size categories
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Centralized responsive system
class ResponsiveSystem {
  static ResponsiveSystem? _instance;
  static ResponsiveSystem get instance => _instance ??= ResponsiveSystem._();

  ResponsiveSystem._();

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < ResponsiveBreakpoints.mobile) return ScreenSize.mobile;
    if (width < ResponsiveBreakpoints.tablet) return ScreenSize.tablet;
    if (width < ResponsiveBreakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsive(
        context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
      vertical: responsive(
        context,
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
        largeDesktop: 20.0,
      ),
    );
  }

  /// Get responsive margin
  static EdgeInsets margin(BuildContext context) {
    return EdgeInsets.all(
      responsive(
        context,
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
        largeDesktop: 20.0,
      ),
    );
  }

  /// Get responsive font size
  static double fontSize(
    BuildContext context, {
    required double baseSize,
    double? scaleFactor,
  }) {
    final screenSize = getScreenSize(context);
    final scale = scaleFactor ?? _getScaleFactor(screenSize);
    return baseSize * scale;
  }

  /// Get responsive icon size
  static double iconSize(
    BuildContext context, {
    required double baseSize,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
      largeDesktop: baseSize * 1.3,
    );
  }

  /// Get responsive spacing
  static double spacing(
    BuildContext context, {
    required double baseSpacing,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: baseSpacing,
      tablet: baseSpacing * 1.1,
      desktop: baseSpacing * 1.2,
      largeDesktop: baseSpacing * 1.3,
    );
  }

  /// Get responsive border radius
  static double borderRadius(
    BuildContext context, {
    required double baseRadius,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: baseRadius,
      tablet: baseRadius * 1.1,
      desktop: baseRadius * 1.2,
      largeDesktop: baseRadius * 1.3,
    );
  }

  /// Get responsive border width
  static double borderWidth(
    BuildContext context, {
    required double baseWidth,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: baseWidth,
      tablet: baseWidth * 1.1,
      desktop: baseWidth * 1.2,
      largeDesktop: baseWidth * 1.3,
    );
  }

  /// Get responsive elevation
  static double elevation(
    BuildContext context, {
    required double baseElevation,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: baseElevation,
      tablet: baseElevation * 1.2,
      desktop: baseElevation * 1.4,
      largeDesktop: baseElevation * 1.6,
    );
  }

  /// Get responsive screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get responsive button height
  static double buttonHeight(
    BuildContext context, {
    required double baseHeight,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: baseHeight,
      tablet: baseHeight * 1.1,
      desktop: baseHeight * 1.2,
      largeDesktop: baseHeight * 1.3,
    );
  }

  /// Get responsive line height
  static double lineHeight(
    BuildContext context, {
    required double baseHeight,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: baseHeight,
      tablet: baseHeight * 1.05,
      desktop: baseHeight * 1.1,
      largeDesktop: baseHeight * 1.15,
    );
  }

  /// Get responsive card height
  static double cardHeight(
    BuildContext context, {
    required double baseHeight,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: baseHeight,
      tablet: baseHeight * 1.1,
      desktop: baseHeight * 1.2,
      largeDesktop: baseHeight * 1.3,
    );
  }

  /// Get responsive EdgeInsets.symmetric
  static EdgeInsets symmetric(
    BuildContext context, {
    double? horizontal,
    double? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal:
          horizontal != null ? spacing(context, baseSpacing: horizontal) : 0,
      vertical: vertical != null ? spacing(context, baseSpacing: vertical) : 0,
    );
  }

  /// Get responsive EdgeInsets.all
  static EdgeInsets all(
    BuildContext context, {
    required double baseSpacing,
  }) {
    return EdgeInsets.all(spacing(context, baseSpacing: baseSpacing));
  }

  /// Get responsive EdgeInsets.only
  static EdgeInsets only(
    BuildContext context, {
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null ? spacing(context, baseSpacing: left) : 0,
      top: top != null ? spacing(context, baseSpacing: top) : 0,
      right: right != null ? spacing(context, baseSpacing: right) : 0,
      bottom: bottom != null ? spacing(context, baseSpacing: bottom) : 0,
    );
  }

  /// Get responsive BorderRadius.circular
  static BorderRadius circular(
    BuildContext context, {
    required double baseRadius,
  }) {
    return BorderRadius.circular(borderRadius(context, baseRadius: baseRadius));
  }

  /// Get responsive SizedBox
  static Widget sizedBox(
    BuildContext context, {
    double? width,
    double? height,
    double? baseSpacing,
  }) {
    return SizedBox(
      width: width != null ? spacing(context, baseSpacing: width) : null,
      height: height != null ? spacing(context, baseSpacing: height) : null,
    );
  }

  /// Get responsive SizedBox with baseSpacing
  static Widget sizedBoxWithSpacing(
    BuildContext context, {
    double? width,
    double? height,
    double baseSpacing = 16,
  }) {
    return SizedBox(
      width: width != null ? spacing(context, baseSpacing: width) : null,
      height: height != null ? spacing(context, baseSpacing: height) : null,
    );
  }

  /// Get responsive grid columns
  static int gridColumns(BuildContext context) {
    return ResponsiveSystem.responsive(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }

  /// Get responsive aspect ratio
  static double aspectRatio(BuildContext context) {
    return ResponsiveSystem.responsive(
      context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.4,
      largeDesktop: 1.6,
    );
  }

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  /// Check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  /// Check if screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.largeDesktop;
  }

  /// Get scale factor for screen size
  static double _getScaleFactor(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 1.0;
      case ScreenSize.tablet:
        return 1.1;
      case ScreenSize.desktop:
        return 1.2;
      case ScreenSize.largeDesktop:
        return 1.3;
    }
  }
}

/// Responsive widget that adapts to screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveSystem.responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

/// Responsive container with adaptive sizing
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? ResponsiveSystem.padding(context),
      margin: margin ?? ResponsiveSystem.margin(context),
      decoration: decoration,
      child: child,
    );
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.baseFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveSystem.fontSize(
          context,
          baseSize: baseFontSize,
        ),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive icon widget
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double baseSize;
  final Color? color;

  const ResponsiveIcon(
    this.icon, {
    super.key,
    required this.baseSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: ResponsiveSystem.iconSize(
        context,
        baseSize: baseSize,
      ),
      color: color,
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final double baseSpacing;
  final bool isVertical;

  const ResponsiveSpacing({
    super.key,
    required this.baseSpacing,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveSystem.spacing(
      context,
      baseSpacing: baseSpacing,
    );

    return SizedBox(
      height: isVertical ? spacing : 0,
      width: isVertical ? 0 : spacing,
    );
  }
}

/// Additional methods to match old ResponsiveSizing API
extension ResponsiveSystemExtensions on ResponsiveSystem {
  /// Get responsive text style (matches old ResponsiveSizing API)
  static TextStyle textStyle(
    BuildContext context, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    final responsiveFontSize =
        ResponsiveSystem.fontSize(context, baseSize: baseFontSize);

    return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  /// Get responsive padding with named parameters (matches old API)
  static EdgeInsets padding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      final responsiveAll = ResponsiveSystem.spacing(context, baseSpacing: all);
      return EdgeInsets.all(responsiveAll);
    }

    return EdgeInsets.only(
      left: left != null
          ? ResponsiveSystem.spacing(context, baseSpacing: left)
          : (horizontal ?? 0),
      top: top != null
          ? ResponsiveSystem.spacing(context, baseSpacing: top)
          : (vertical ?? 0),
      right: right != null
          ? ResponsiveSystem.spacing(context, baseSpacing: right)
          : (horizontal ?? 0),
      bottom: bottom != null
          ? ResponsiveSystem.spacing(context, baseSpacing: bottom)
          : (vertical ?? 0),
    );
  }

  /// Get responsive margin with named parameters (matches old API)
  static EdgeInsets margin(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      final responsiveAll = ResponsiveSystem.spacing(context, baseSpacing: all);
      return EdgeInsets.all(responsiveAll);
    }

    return EdgeInsets.only(
      left: left != null
          ? ResponsiveSystem.spacing(context, baseSpacing: left)
          : (horizontal ?? 0),
      top: top != null
          ? ResponsiveSystem.spacing(context, baseSpacing: top)
          : (vertical ?? 0),
      right: right != null
          ? ResponsiveSystem.spacing(context, baseSpacing: right)
          : (horizontal ?? 0),
      bottom: bottom != null
          ? ResponsiveSystem.spacing(context, baseSpacing: bottom)
          : (vertical ?? 0),
    );
  }

  /// Get responsive toolbar height for SliverAppBar
  static double toolbarHeight(BuildContext context, {double baseHeight = 60}) {
    return ResponsiveSystem.spacing(context, baseSpacing: baseHeight);
  }

  /// Get responsive expanded height for SliverAppBar
  static double expandedHeight(BuildContext context,
      {double baseHeight = 120}) {
    return ResponsiveSystem.spacing(context, baseSpacing: baseHeight);
  }

  /// Get responsive content top padding to prevent overlap with SliverAppBar
  static double contentTopPadding(BuildContext context,
      {double basePadding = 20}) {
    return ResponsiveSystem.spacing(context, baseSpacing: basePadding);
  }

  /// Get responsive section spacing
  static double sectionSpacing(BuildContext context,
      {double baseSpacing = 40}) {
    return ResponsiveSystem.spacing(context, baseSpacing: baseSpacing);
  }

  /// Get responsive screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive screen size
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get responsive device pixel ratio
  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Get responsive safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive safe area insets
  static EdgeInsets safeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  /// Get responsive viewport width
  static double viewportWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get responsive viewport height
  static double viewportHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive text scale factor
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Get responsive brightness
  static Brightness brightness(BuildContext context) {
    return MediaQuery.of(context).platformBrightness;
  }

  /// Get responsive orientation
  static Orientation orientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Get responsive aspect ratio
  static double aspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  /// Get responsive diagonal size
  static double diagonalSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return (size.width * size.width + size.height * size.height) / 2;
  }

  /// Get responsive width percentage
  static double widthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  /// Get responsive height percentage
  static double heightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  /// Get responsive min dimension
  static double minDimension(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < size.height ? size.width : size.height;
  }

  /// Get responsive max dimension
  static double maxDimension(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height ? size.width : size.height;
  }

  /// Get responsive breakpoint value
  static double breakpointValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Get responsive breakpoint int value
  static int breakpointIntValue(
    BuildContext context, {
    required int mobile,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Get responsive breakpoint bool value
  static bool breakpointBoolValue(
    BuildContext context, {
    required bool mobile,
    bool? tablet,
    bool? desktop,
    bool? largeDesktop,
  }) {
    return ResponsiveSystem.responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}
