/// Responsive System - Centralized Responsive Design
///
/// This file provides a comprehensive responsive design system
/// with breakpoints, sizing utilities, and responsive widgets.
///
/// **Automatic Screen Size Adaptation:**
/// - All methods use MediaQuery.of(context) which automatically rebuilds
///   when screen size changes (browser resize, split screen, orientation change)
/// - No manual listeners needed - Flutter handles this automatically
/// - All UI elements scale proportionally based on actual screen dimensions
/// - Aspect ratio is calculated in real-time for accurate scaling
///
/// **Supported Scenarios:**
/// - Browser window resizing (Chrome, desktop)
/// - Split screen mode (mobile/tablet)
/// - Device orientation changes
/// - Foldable device unfolding
/// - Any dynamic screen size changes
///
/// **Usage:**
/// ```dart
/// // All methods automatically respond to screen size changes
/// ResponsiveSystem.fontSize(context, baseSize: 16)
/// ResponsiveSystem.spacing(context, baseSpacing: 20)
/// ResponsiveSystem.iconSize(context, baseSize: 24)
/// ```
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
  /// Considers both width and aspect ratio for better responsiveness
  static ScreenSize getScreenSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final aspectRatio = width / height;
    
    // Consider aspect ratio: wider screens (landscape) get adjusted categories
    // Tall screens (portrait) use standard categories
    final isLandscape = aspectRatio > 1.0;
    final isVeryWide = aspectRatio > 2.0; // Ultra-wide or foldable devices
    
    if (width < ResponsiveBreakpoints.mobile) {
      // For very wide mobile screens in landscape, treat as tablet
      if (isVeryWide && isLandscape) return ScreenSize.tablet;
      return ScreenSize.mobile;
    }
    if (width < ResponsiveBreakpoints.tablet) {
      // For wide tablets in landscape, treat as desktop
      if (isVeryWide && isLandscape) return ScreenSize.desktop;
      return ScreenSize.tablet;
    }
    if (width < ResponsiveBreakpoints.desktop) {
      // For wide desktops, treat as large desktop
      if (isVeryWide && isLandscape) return ScreenSize.largeDesktop;
      return ScreenSize.desktop;
    }
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
  /// Considers both screen size and aspect ratio
  static double fontSize(
    BuildContext context, {
    required double baseSize,
    double? scaleFactor,
  }) {
    final screenSize = getScreenSize(context);
    final scale = scaleFactor ?? _getScaleFactor(screenSize, context);
    return baseSize * scale;
  }

  /// Get responsive icon size
  /// Dynamically scales based on screen size and aspect ratio
  static double iconSize(
    BuildContext context, {
    required double baseSize,
  }) {
    final screenSize = getScreenSize(context);
    final scale = _getScaleFactor(screenSize, context);
    return baseSize * scale;
  }

  /// Get responsive spacing
  /// Dynamically scales based on screen size and aspect ratio
  static double spacing(
    BuildContext context, {
    required double baseSpacing,
  }) {
    final screenSize = getScreenSize(context);
    final scale = _getScaleFactor(screenSize, context);
    return baseSpacing * scale;
  }

  /// Get responsive border radius
  /// Dynamically scales based on screen size and aspect ratio
  static double borderRadius(
    BuildContext context, {
    required double baseRadius,
  }) {
    final screenSize = getScreenSize(context);
    final scale = _getScaleFactor(screenSize, context);
    return baseRadius * scale;
  }

  /// Get responsive border width
  /// Dynamically scales based on screen size and aspect ratio
  static double borderWidth(
    BuildContext context, {
    required double baseWidth,
  }) {
    final screenSize = getScreenSize(context);
    final scale = _getScaleFactor(screenSize, context);
    return baseWidth * scale;
  }

  /// Get responsive elevation
  /// Dynamically scales based on screen size and aspect ratio
  static double elevation(
    BuildContext context, {
    required double baseElevation,
  }) {
    final screenSize = getScreenSize(context);
    final scale = _getScaleFactor(screenSize, context);
    // Elevation scales more aggressively for better depth perception
    return baseElevation * (scale * 1.2);
  }

  /// Get responsive screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get responsive button height
  /// Dynamically scales based on screen size and aspect ratio
  static double buttonHeight(
    BuildContext context, {
    required double baseHeight,
  }) {
    final screenSize = getScreenSize(context);
    final scale = _getScaleFactor(screenSize, context);
    return baseHeight * scale;
  }

  /// Get responsive line height
  /// Dynamically scales based on screen size and aspect ratio
  static double lineHeight(
    BuildContext context, {
    required double baseHeight,
  }) {
    final screenSize = getScreenSize(context);
    final scale = _getScaleFactor(screenSize, context);
    // Line height scales more conservatively for readability
    return baseHeight * (scale * 0.9);
  }

  /// Get responsive card height
  /// Dynamically scales based on screen size and aspect ratio
  static double cardHeight(
    BuildContext context, {
    required double baseHeight,
  }) {
    final screenSize = getScreenSize(context);
    final scale = _getScaleFactor(screenSize, context);
    return baseHeight * scale;
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
  /// Dynamically calculates based on screen size AND aspect ratio
  /// This ensures all UI elements scale proportionally to the actual screen dimensions
  static double _getScaleFactor(ScreenSize screenSize, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final aspectRatio = width / height;
    
    // Get base scale from screen size category
    final baseScale = _getBaseScaleFactor(screenSize);
    
    // Calculate dynamic scale adjustment based on aspect ratio
    // This makes the UI adapt to the actual screen shape, not just width
    double aspectRatioAdjustment = 1.0;
    
    if (aspectRatio < 0.6) {
      // Very tall screens (portrait phones, aspectRatio < 0.6)
      // Reduce scale slightly to fit more content vertically
      aspectRatioAdjustment = 0.92;
    } else if (aspectRatio < 0.8) {
      // Tall screens (portrait, aspectRatio 0.6-0.8)
      aspectRatioAdjustment = 0.96;
    } else if (aspectRatio < 1.0) {
      // Slightly tall (portrait, aspectRatio 0.8-1.0)
      aspectRatioAdjustment = 0.98;
    } else if (aspectRatio > 2.5) {
      // Very wide screens (ultra-wide, foldables unfolded, aspectRatio > 2.5)
      // Increase scale significantly for better use of horizontal space
      aspectRatioAdjustment = 1.15;
    } else if (aspectRatio > 2.0) {
      // Wide screens (landscape tablets, foldables, aspectRatio 2.0-2.5)
      aspectRatioAdjustment = 1.12;
    } else if (aspectRatio > 1.6) {
      // Wide landscape (aspectRatio 1.6-2.0)
      aspectRatioAdjustment = 1.08;
    } else if (aspectRatio > 1.3) {
      // Normal landscape (aspectRatio 1.3-1.6)
      aspectRatioAdjustment = 1.04;
    }
    // For aspectRatio 1.0-1.3 (square to slightly wide), use 1.0 (no adjustment)
    
    // Also consider screen density for better scaling
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final densityAdjustment = pixelRatio > 3.0 ? 1.05 : (pixelRatio > 2.0 ? 1.02 : 1.0);
    
    // Combine all factors: base scale × aspect ratio adjustment × density adjustment
    return baseScale * aspectRatioAdjustment * densityAdjustment;
  }
  
  /// Get base scale factor for screen size category
  static double _getBaseScaleFactor(ScreenSize screenSize) {
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

  /// Get responsive dialog width based on screen dimensions and aspect ratio
  /// Calculates width as: screen_width - (outer_padding * 2)
  /// Outer padding is calculated based on screen size and aspect ratio
  static double dialogWidth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final aspectRatio = width / height;
    
    // Calculate outer padding based on screen dimensions and aspect ratio
    // For wider screens, use more padding; for taller screens, use less
    double outerPadding;
    if (aspectRatio > 2.0) {
      // Very wide screens - use larger padding
      outerPadding = width * 0.15; // 15% of width
    } else if (aspectRatio > 1.5) {
      // Wide screens - use medium padding
      outerPadding = width * 0.12; // 12% of width
    } else if (aspectRatio > 1.0) {
      // Normal landscape - use standard padding
      outerPadding = width * 0.10; // 10% of width
    } else {
      // Portrait or square - use smaller padding
      outerPadding = width * 0.08; // 8% of width
    }
    
    // Ensure minimum padding
    final minPadding = responsive(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      largeDesktop: 48.0,
    );
    outerPadding = outerPadding < minPadding ? minPadding : outerPadding;
    
    // Calculate dialog width: screen width - (padding * 2)
    final dialogWidth = width - (outerPadding * 2);
    
    // Ensure minimum and maximum dialog widths
    final minWidth = responsive(
      context,
      mobile: 280.0,
      tablet: 320.0,
      desktop: 400.0,
      largeDesktop: 480.0,
    );
    final maxWidth = responsive(
      context,
      mobile: width * 0.9,
      tablet: width * 0.85,
      desktop: width * 0.75,
      largeDesktop: width * 0.65,
    );
    
    if (dialogWidth < minWidth) return minWidth;
    if (dialogWidth > maxWidth) return maxWidth;
    return dialogWidth;
  }

  /// Get responsive dialog padding based on screen dimensions
  /// Inner padding is calculated as a percentage of dialog width
  static EdgeInsets dialogPadding(BuildContext context) {
    final dialogWidth = ResponsiveSystem.dialogWidth(context);
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;
    
    // Calculate inner padding as percentage of dialog width
    // Adjust based on aspect ratio
    double paddingPercentage;
    if (aspectRatio > 2.0) {
      paddingPercentage = 0.08; // 8% for very wide screens
    } else if (aspectRatio > 1.5) {
      paddingPercentage = 0.06; // 6% for wide screens
    } else {
      paddingPercentage = 0.05; // 5% for normal/portrait screens
    }
    
    final horizontalPadding = dialogWidth * paddingPercentage;
    final verticalPadding = horizontalPadding * 0.8; // Slightly less vertical padding
    
    // Ensure minimum padding
    final minPadding = responsive(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
      largeDesktop: 28.0,
    );
    
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding < minPadding ? minPadding : horizontalPadding,
      vertical: verticalPadding < minPadding * 0.8 ? minPadding * 0.8 : verticalPadding,
    );
  }

  /// Get responsive button width for dialogs
  /// Calculates button width based on available dialog space and aspect ratio
  /// Accounts for button internal padding to prevent overflow
  static double dialogButtonWidth(
    BuildContext context, {
    required int buttonCount,
    double? spacingBetween,
  }) {
    final dialogWidth = ResponsiveSystem.dialogWidth(context);
    final padding = ResponsiveSystem.dialogPadding(context);
    final spacing = spacingBetween ?? ResponsiveSystem.spacing(context, baseSpacing: 12);
    
    // Available width = dialog width - (horizontal padding * 2) - (spacing between buttons * (buttonCount - 1))
    // Subtract a small buffer (4px per button) to account for rounding errors and ensure buttons fit
    final buffer = buttonCount * 4.0;
    final availableWidth = dialogWidth - 
        (padding.horizontal * 2) - 
        (spacing * (buttonCount - 1)) - 
        buffer;
    
    // Button width = available width / button count
    // This width will be used for the SizedBox, and the button's internal padding is inside this width
    final buttonWidth = availableWidth / buttonCount;
    
    // Ensure minimum button width
    final minButtonWidth = responsive(
      context,
      mobile: 100.0,
      tablet: 120.0,
      desktop: 140.0,
      largeDesktop: 160.0,
    );
    
    return buttonWidth < minButtonWidth ? minButtonWidth : buttonWidth;
  }

  /// Get responsive action button constraints for dialogs
  /// Returns constraints that prevent overflow
  static BoxConstraints dialogActionConstraints(
    BuildContext context, {
    required int buttonCount,
    double? spacingBetween,
  }) {
    final buttonWidth = ResponsiveSystem.dialogButtonWidth(
      context,
      buttonCount: buttonCount,
      spacingBetween: spacingBetween,
    );
    
    return BoxConstraints(
      minWidth: buttonWidth,
      maxWidth: buttonWidth,
    );
  }
}

/// Responsive widget that adapts to screen size
/// Automatically rebuilds when screen size changes (browser resize, split screen, etc.)
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
    // MediaQuery.of(context) automatically triggers rebuilds when screen size changes
    // This ensures seamless readjustment during browser resize, split screen, etc.
    return ResponsiveSystem.responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

/// Responsive builder that rebuilds automatically when screen size changes
/// Use this for widgets that need to respond to dynamic screen size changes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize, Size screenDimensions, double aspectRatio) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // MediaQuery.of(context) automatically triggers rebuilds when screen size changes
    final size = MediaQuery.of(context).size;
    final screenSize = ResponsiveSystem.getScreenSize(context);
    final aspectRatio = size.width / size.height;
    
    // This widget rebuilds automatically when screen dimensions change
    // Perfect for browser resize, split screen, orientation changes, etc.
    return builder(context, screenSize, size, aspectRatio);
  }
}

/// Layout builder that responds to screen size changes in real-time
/// Provides smooth transitions during resize operations
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize, Size screenDimensions, double aspectRatio, Orientation orientation) builder;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder + MediaQuery ensures real-time updates during resize
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get current screen dimensions (updates in real-time)
        final size = MediaQuery.of(context).size;
        final screenSize = ResponsiveSystem.getScreenSize(context);
        final aspectRatio = size.width / size.height;
        final orientation = MediaQuery.of(context).orientation;
        
        // Rebuilds automatically when:
        // - Browser window is resized
        // - Split screen mode is activated/deactivated
        // - Device orientation changes
        // - Screen size changes for any reason
        return builder(context, screenSize, size, aspectRatio, orientation);
      },
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
