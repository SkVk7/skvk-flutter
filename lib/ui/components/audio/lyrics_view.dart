/// Lyrics View Widget
///
/// Scrollable, interactive lyrics display with auto-scroll to current line.
/// Similar to production streaming apps like Spotify, Apple Music.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/services/audio/audio_controller.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

/// Scrollable lyrics view widget with auto-scroll
class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({super.key});

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  final ScrollController _scrollController = ScrollController();
  int _lastActiveIndex = -1;
  bool _userScrolling = false;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    // Detect user scrolling - disable auto-scroll when user manually scrolls
    _scrollController.addListener(() {
      if (_scrollController.position.isScrollingNotifier.value) {
        if (!_userScrolling) {
          setState(() {
            _userScrolling = true;
          });
        }
        // Reset user scrolling flag after user stops scrolling for 2 seconds
        _scrollTimer?.cancel();
        _scrollTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _userScrolling = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _scrollToActiveLine(int activeIndex, int totalLines) {
    if (!_scrollController.hasClients || _userScrolling) return;
    if (activeIndex < 0 || activeIndex >= totalLines) return;

    // Calculate the position to scroll to (center the active line)
    final itemHeight = ResponsiveSystem.spacing(context, baseSpacing: 80);
    final screenHeight = MediaQuery.of(context).size.height;
    final targetOffset = (activeIndex * itemHeight) - (screenHeight / 2) + (itemHeight / 2);

    // Smooth scroll to the active line
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioControllerProvider);
    final lyrics = playerState.lyrics;
    final currentPosition = playerState.position;

    if (lyrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: ResponsiveSystem.iconSize(context, baseSize: 64),
              color: ThemeHelpers.getSecondaryTextColor(context).withValues(alpha: 0.5),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 24),
            ),
            Text(
              'No lyrics available',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                color: ThemeHelpers.getSecondaryTextColor(context).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Find current lyric index based on position
    int currentIndex = -1;
    for (int i = 0; i < lyrics.length; i++) {
      if (lyrics[i].timestamp <= currentPosition) {
        currentIndex = i;
      } else {
        break;
      }
    }

    // Auto-scroll to active line when it changes (only if user isn't scrolling)
    if (currentIndex != _lastActiveIndex && !_userScrolling) {
      _lastActiveIndex = currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveLine(currentIndex, lyrics.length);
      });
    }

    return ListView.builder(
      controller: _scrollController,
      padding: ResponsiveSystem.symmetric(
        context,
        horizontal: ResponsiveSystem.spacing(context, baseSpacing: 32),
        vertical: ResponsiveSystem.spacing(context, baseSpacing: 24),
      ),
      itemCount: lyrics.length,
      itemBuilder: (context, index) {
        final lyric = lyrics[index];
        final isActive = index == currentIndex;
        final isPast = index < currentIndex;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
            horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(
                context,
                baseSize: isActive ? 22 : isPast ? 16 : 17,
              ),
              fontWeight: isActive ? FontWeight.bold : (isPast ? FontWeight.normal : FontWeight.w500),
              color: isActive
                  ? ThemeHelpers.getPrimaryColor(context)
                  : isPast
                      ? ThemeHelpers.getSecondaryTextColor(context).withValues(alpha: 0.6)
                      : ThemeHelpers.getPrimaryTextColor(context).withValues(alpha: 0.8),
              height: 1.8,
              letterSpacing: isActive ? 0.5 : 0.0,
            ),
            child: Text(
              lyric.text,
              textAlign: TextAlign.center,
              maxLines: null,
            ),
          ),
        );
      },
    );
  }
}

