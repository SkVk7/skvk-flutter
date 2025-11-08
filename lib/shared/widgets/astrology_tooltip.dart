/// Astrology Symbol Tooltip Widget
///
/// Provides beautiful, informative tooltips for astrological symbols
/// with auto-close functionality and elegant animations
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';

/// Tooltip data for astrological symbols
class AstrologyTooltipData {
  final String symbol;
  final String name;
  final String meaning;
  final String type; // 'rashi', 'nakshatra', 'planet'
  final String? additionalInfo;

  const AstrologyTooltipData({
    required this.symbol,
    required this.name,
    required this.meaning,
    required this.type,
    this.additionalInfo,
  });
}

/// Beautiful tooltip widget for astrological symbols
class AstrologyTooltip extends StatefulWidget {
  final Widget child;
  final AstrologyTooltipData tooltipData;
  final Duration autoCloseDuration;
  final bool showTooltip;

  const AstrologyTooltip({
    super.key,
    required this.child,
    required this.tooltipData,
    this.autoCloseDuration = const Duration(seconds: 4),
    this.showTooltip = true,
  });

  @override
  State<AstrologyTooltip> createState() => _AstrologyTooltipState();
}

class _AstrologyTooltipState extends State<AstrologyTooltip>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoCloseTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _showTooltip() {
    if (!widget.showTooltip || _overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        tooltipData: widget.tooltipData,
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
        onClose: _hideTooltip,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();

    // Auto-close after specified duration
    _autoCloseTimer = Timer(widget.autoCloseDuration, _hideTooltip);
  }

  void _hideTooltip() {
    _autoCloseTimer?.cancel();
    if (_overlayEntry != null) {
      _animationController.reverse().then((_) {
        _removeOverlay();
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTooltip,
      onLongPress: _showTooltip,
      child: widget.child,
    );
  }
}

/// Overlay widget for the tooltip
class _TooltipOverlay extends StatelessWidget {
  final AstrologyTooltipData tooltipData;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback onClose;

  const _TooltipOverlay({
    required this.tooltipData,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = ThemeProperties.getPrimaryColor(context);
        final backgroundColor = ThemeProperties.getBackgroundColor(context);
        final surfaceColor = ThemeProperties.getSurfaceColor(context);
        final primaryTextColor = ThemeProperties.getPrimaryTextColor(context);
        final secondaryTextColor =
            ThemeProperties.getSecondaryTextColor(context);
        final tertiaryTextColor =
            ThemeProperties.getSecondaryTextColor(context);

        return AnimatedBuilder(
          animation: Listenable.merge([fadeAnimation, scaleAnimation]),
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Material(
                  color: ThemeProperties.getTransparentColor(context),
                  child: Stack(
                    children: [
                      // Backdrop
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          color: isDarkMode
                              ? ThemeProperties.getTextColor(context)
                                  .withAlpha((0.3 * 255).round())
                              : ThemeProperties.getTextColor(context)
                                  .withAlpha((0.1 * 255).round()),
                          width: ResponsiveSystem.screenWidth(context),
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                      // Tooltip content
                      Center(
                        child: Container(
                          margin: ResponsiveSystem.symmetric(
                            context,
                            horizontal: ResponsiveSystem.spacing(context,
                                baseSpacing: 20),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          child: _TooltipContent(
                            tooltipData: tooltipData,
                            isDarkMode: isDarkMode,
                            primaryColor: primaryColor,
                            backgroundColor: backgroundColor,
                            surfaceColor: surfaceColor,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            tertiaryTextColor: tertiaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Tooltip content widget
class _TooltipContent extends StatelessWidget {
  final AstrologyTooltipData tooltipData;
  final bool isDarkMode;
  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color tertiaryTextColor;

  const _TooltipContent({
    required this.tooltipData,
    required this.isDarkMode,
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.tertiaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.symmetric(
        context,
        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 20),
        vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? ThemeProperties.getTextColor(context)
                    .withAlpha((0.4 * 255).round())
                : ThemeProperties.getTextColor(context)
                    .withAlpha((0.15 * 255).round()),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 20),
            offset:
                Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 8)),
          ),
        ],
        border: Border.all(
          color: primaryColor.withAlpha((0.2 * 255).round()),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Symbol and name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tooltipData.symbol,
                style: TextStyle(
                  fontSize: ResponsiveSystem.iconSize(context, baseSize: 32),
                ),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
              Flexible(
                child: Text(
                  tooltipData.name,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          ResponsiveSystem.sizedBox(context, height: 12),

          // Type badge
          Container(
            padding: ResponsiveSystem.symmetric(
              context,
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 8),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 4),
            ),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha((0.15 * 255).round()),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
              border: Border.all(
                color: primaryColor.withAlpha((0.3 * 255).round()),
                width: 0.5,
              ),
            ),
            child: Text(
              _getTypeLabel(tooltipData.type),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
          ),

          ResponsiveSystem.sizedBox(context, height: 12),

          // Meaning
          Text(
            tooltipData.meaning,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),

          if (tooltipData.additionalInfo != null) ...[
            SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
            Text(
              tooltipData.additionalInfo!,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: tertiaryTextColor,
              ).copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],

          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

          // Close hint
          Text(
            'Tap anywhere to close',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
              color: tertiaryTextColor.withAlpha((0.7 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'rashi':
        return 'Zodiac Sign (Rashi)';
      case 'nakshatra':
        return 'Birth Star (Nakshatra)';
      case 'planet':
        return 'Planet';
      default:
        return 'Astrological';
    }
  }
}

/// Helper class to create tooltip data for different astrological elements
class AstrologyTooltipHelper {
  static AstrologyTooltipData createRashiTooltip({
    required String symbol,
    required String name,
    required String meaning,
    String? additionalInfo,
  }) {
    return AstrologyTooltipData(
      symbol: symbol,
      name: name,
      meaning: meaning,
      type: 'rashi',
      additionalInfo: additionalInfo,
    );
  }

  static AstrologyTooltipData createNakshatraTooltip({
    required String symbol,
    required String name,
    required String meaning,
    String? additionalInfo,
  }) {
    return AstrologyTooltipData(
      symbol: symbol,
      name: name,
      meaning: meaning,
      type: 'nakshatra',
      additionalInfo: additionalInfo,
    );
  }

  static AstrologyTooltipData createPlanetTooltip({
    required String symbol,
    required String name,
    required String meaning,
    String? additionalInfo,
  }) {
    return AstrologyTooltipData(
      symbol: symbol,
      name: name,
      meaning: meaning,
      type: 'planet',
      additionalInfo: additionalInfo,
    );
  }
}
