/// Player Controls Widget
///
/// Play/pause, next, previous buttons with long-press for seek functionality.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio/audio_controller.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';
import '../../utils/animations.dart';

/// Player controls widget with play/pause, next, prev buttons
class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioControllerProvider);
    final controller = ref.read(audioControllerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        _ControlButton(
          icon: Icons.skip_previous,
          onTap: () {
            // HapticFeedback.lightImpact();
            controller.prev();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            controller.skipBackward();
          },
          size: ResponsiveSystem.iconSize(context, baseSize: 32),
        ),
        ResponsiveSystem.sizedBox(
          context,
          width: ResponsiveSystem.spacing(context, baseSpacing: 24),
        ),
        // Play/Pause button (larger)
        _PlayPauseButton(
          isPlaying: playerState.isPlaying,
          isLoading: playerState.isLoading,
          onTap: () {
            // HapticFeedback.lightImpact();
            controller.togglePlayPause();
          },
          size: ResponsiveSystem.iconSize(context, baseSize: 56),
        ),
        ResponsiveSystem.sizedBox(
          context,
          width: ResponsiveSystem.spacing(context, baseSpacing: 24),
        ),
        // Next button
        _ControlButton(
          icon: Icons.skip_next,
          onTap: () {
            // HapticFeedback.lightImpact();
            controller.next();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            controller.skipForward();
          },
          size: ResponsiveSystem.iconSize(context, baseSize: 32),
        ),
      ],
    );
  }
}

/// Play/Pause button with loading state
class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;
  final double size;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
    required this.size,
  });

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AnimationDurations.quick,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AnimationCurves.standard,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeHelpers.getPrimaryColor(context),
            boxShadow: [
              BoxShadow(
                color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: ResponsiveSystem.responsive(
                        context,
                        mobile: 2.5,
                        tablet: 3.0,
                        desktop: 3.5,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeHelpers.getSurfaceColor(context),
                      ),
                    ),
                  ),
                )
              : Icon(
                  widget.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: ThemeHelpers.getSurfaceColor(context),
                  size: widget.size * 0.5,
                ),
        ),
      ),
    );
  }
}

/// Control button (prev/next) with long-press support
class _ControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.onLongPress,
    required this.size,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AnimationDurations.quick,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AnimationCurves.standard,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeHelpers.getSurfaceColor(context),
            border: Border.all(
              color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.3),
              width: ResponsiveSystem.responsive(
                context,
                mobile: 1.0,
                tablet: 1.5,
                desktop: 2.0,
              ),
            ),
          ),
          child: Icon(
            widget.icon,
            color: ThemeHelpers.getPrimaryTextColor(context),
            size: widget.size * 0.6,
          ),
        ),
      ),
    );
  }
}

