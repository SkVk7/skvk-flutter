/// Audio Hero Section Component
///
/// Reusable hero section for featured track display
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Audio Hero Section - Featured track with parallax effect
class AudioHeroSection extends StatelessWidget {
  const AudioHeroSection({
    required this.featuredTrack,
    super.key,
  });

  final Map<String, dynamic> featuredTrack;

  @override
  Widget build(BuildContext context) {
    final coverArtUrl = featuredTrack['coverArtUrl'] as String?;
    final title = featuredTrack['title'] as String? ?? '';
    final subtitle = featuredTrack['subtitle'] as String? ??
        featuredTrack['artist'] as String? ??
        '';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: child,
          ),
        );
      },
      child: Container(
        margin: ResponsiveSystem.all(context, baseSpacing: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ResponsiveSystem.spacing(context, baseSpacing: 20),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  ThemeHelpers.getShadowColor(context).withValues(alpha: 0.3),
              blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 30),
              offset: Offset(
                0,
                ResponsiveSystem.spacing(context, baseSpacing: 10),
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            ResponsiveSystem.spacing(context, baseSpacing: 20),
          ),
          child: Stack(
            children: [
              // Background Image or Gradient
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeHelpers.getPrimaryColor(context)
                          .withValues(alpha: 0.8),
                      ThemeHelpers.getPrimaryColor(context)
                          .withValues(alpha: 0.4),
                    ],
                  ),
                  image: coverArtUrl != null
                      ? DecorationImage(
                          image: NetworkImage(coverArtUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            ThemeHelpers.getShadowColor(context)
                                .withValues(alpha: 0.3),
                            BlendMode.darken,
                          ),
                          onError: (_, __) {},
                        )
                      : null,
                ),
              ),
              // Content Overlay
              Container(
                width: double.infinity,
                height: ResponsiveSystem.responsive(
                  context,
                  mobile: MediaQuery.of(context).size.height * 0.35,
                  tablet: MediaQuery.of(context).size.height * 0.30,
                  desktop: MediaQuery.of(context).size.height * 0.25,
                  largeDesktop: MediaQuery.of(context).size.height * 0.25,
                ),
                padding: ResponsiveSystem.all(context, baseSpacing: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ThemeHelpers.getShadowColor(context)
                          .withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 12),
                        fontWeight: FontWeight.w600,
                        color: ThemeHelpers.getAppBarTextColor(context)
                            .withValues(alpha: 0.9),
                        letterSpacing: 1.2,
                      ),
                    ),
                    ResponsiveSystem.sizedBox(
                      context,
                      height: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    ),
                    Tooltip(
                      message: title,
                      preferBelow: false,
                      waitDuration: const Duration(milliseconds: 500),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 28),
                          fontWeight: FontWeight.bold,
                          color: ThemeHelpers.getAppBarTextColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      ResponsiveSystem.sizedBox(
                        context,
                        height:
                            ResponsiveSystem.spacing(context, baseSpacing: 4),
                      ),
                      Tooltip(
                        message: subtitle,
                        preferBelow: false,
                        waitDuration: const Duration(milliseconds: 500),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context,
                                baseSize: 16,),
                            fontWeight: FontWeight.w500,
                            color: ThemeHelpers.getAppBarTextColor(context)
                                .withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
