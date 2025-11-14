/// Profile Photo Component
///
/// Reusable profile photo with hover effect
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Profile Photo - Profile photo with hover animation
@immutable
class ProfilePhoto extends StatefulWidget {
  const ProfilePhoto({
    required this.onTap,
    super.key,
    this.tooltip,
    this.imageUrl,
    this.fallbackIcon,
  });
  final VoidCallback onTap;
  final String? tooltip;
  final String? imageUrl;
  final IconData? fallbackIcon;

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.1),
      child: Icon(
        widget.fallbackIcon ?? Icons.person,
        color: ThemeHelpers.getPrimaryColor(context),
        size: ResponsiveSystem.iconSize(context, baseSize: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.tooltip ?? 'Profile',
      button: true,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _animationController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _animationController.reverse();
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: ResponsiveSystem.spacing(context, baseSpacing: 40),
                  height: ResponsiveSystem.spacing(context, baseSpacing: 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeHelpers.getPrimaryColor(context),
                      width:
                          ResponsiveSystem.borderWidth(context, baseWidth: 2),
                    ),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: ThemeHelpers.getPrimaryColor(context)
                                  .withValues(alpha: 0.3),
                              blurRadius: ResponsiveSystem.spacing(
                                context,
                                baseSpacing: 8,
                              ),
                              spreadRadius: ResponsiveSystem.spacing(
                                context,
                                baseSpacing: 2,
                              ),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: widget.imageUrl != null
                        ? Image.network(
                            widget.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackIcon(),
                          )
                        : _buildFallbackIcon(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
