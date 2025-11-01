/// Profile Photo Widget
///
/// A widget that displays the user's profile photo or default avatar
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/profile_photo_provider.dart';

class ProfilePhotoWidget extends ConsumerWidget {
  final double? size;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final BoxShadow? shadow;
  final Widget? fallbackWidget;

  const ProfilePhotoWidget({
    super.key,
    this.size,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shadow,
    this.fallbackWidget,
  });

  /// Safe fallback widget that never fails
  static Widget safeFallback(BuildContext context, {double? size}) {
    final safeSize = size ?? 40.0;
    return Container(
      width: safeSize,
      height: safeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeProperties.getSurfaceColor(context),
      ),
      child: Icon(
        Icons.person,
        size: safeSize * 0.6,
        color: ThemeProperties.getTextColor(context),
      ),
    );
  }

  /// Ultra-safe widget that never uses Image.file() - for web compatibility
  static Widget ultraSafeFallback(BuildContext context, {double? size}) {
    final safeSize = size ?? 40.0;
    return Container(
      width: safeSize,
      height: safeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.1),
        border: Border.all(color: ThemeProperties.getPrimaryColor(context), width: 2),
      ),
      child: Icon(
        Icons.person,
        size: safeSize * 0.6,
        color: ThemeProperties.getPrimaryColor(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final profilePhotoAsync = ref.watch(profilePhotoNotifierProvider);
      final double size = this.size ?? ResponsiveSystem.spacing(context, baseSpacing: 40);
      final Color backgroundColor =
          this.backgroundColor ?? ThemeProperties.getSurfaceColor(context);
      final Color borderColor = this.borderColor ?? ThemeProperties.getPrimaryColor(context);
      final double borderWidth =
          this.borderWidth ?? ResponsiveSystem.borderWidth(context, baseWidth: 2);

      // Debug logging
      if (profilePhotoAsync.hasValue && profilePhotoAsync.value != null) {
        print('ProfilePhotoWidget: Photo path = ${profilePhotoAsync.value}');
        print('ProfilePhotoWidget: Is data URL = ${profilePhotoAsync.value!.startsWith('data:')}');
        print('ProfilePhotoWidget: Platform = ${kIsWeb ? 'Web' : 'Mobile'}');
      } else if (profilePhotoAsync.hasError) {
        print('ProfilePhotoWidget: Error loading photo: ${profilePhotoAsync.error}');
      } else {
        print('ProfilePhotoWidget: No photo available');
      }

      if (profilePhotoAsync.isLoading) {
        return _buildLoadingWidget(context, size, backgroundColor, borderColor, borderWidth);
      }

      if (profilePhotoAsync.hasError) {
        print('ProfilePhotoWidget: Provider error: ${profilePhotoAsync.error}');
        return _buildDefaultAvatar(context, size);
      }

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: shadow != null
              ? [shadow!]
              : [
                  BoxShadow(
                    color: ThemeProperties.getShadowColor(context),
                    blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
                  ),
                ],
        ),
        child: profilePhotoAsync.hasValue && profilePhotoAsync.value != null
            ? _buildCrossPlatformImage(context, profilePhotoAsync.value!, size)
            : fallbackWidget ?? _buildDefaultAvatar(context, size),
      );
    } catch (e) {
      print('ProfilePhotoWidget: Critical error in build method: $e');
      return _buildDefaultAvatar(context, ResponsiveSystem.spacing(context, baseSpacing: 40));
    }
  }

  Widget _buildLoadingWidget(BuildContext context, double size, Color backgroundColor,
      Color borderColor, double borderWidth) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeProperties.getPrimaryColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrossPlatformImage(BuildContext context, String imagePath, double size) {
    try {
      print('ProfilePhotoWidget: Building cross-platform image for: $imagePath');
      print('ProfilePhotoWidget: Platform check - kIsWeb: $kIsWeb');

      // ALWAYS check platform first to avoid any Image.file calls on web
      if (kIsWeb) {
        // On web, only handle data URLs
        if (imagePath.startsWith('data:')) {
          print('ProfilePhotoWidget: Using web image (data URL)');
          return _buildWebImage(context, imagePath, size);
        } else {
          print('ProfilePhotoWidget: Web platform cannot display file path: $imagePath');
          return _buildDefaultAvatar(context, size);
        }
      } else {
        // On mobile, handle file paths
        if (imagePath.startsWith('data:')) {
          print('ProfilePhotoWidget: Mobile platform with data URL, using network image');
          return _buildWebImage(context, imagePath, size);
        } else {
          print('ProfilePhotoWidget: Using file image (mobile)');
          return _buildFileImage(context, imagePath, size);
        }
      }
    } catch (e) {
      print('ProfilePhotoWidget: Error in cross-platform image building: $e');
      return _buildDefaultAvatar(context, size);
    }
  }

  Widget _buildFileImage(BuildContext context, String filePath, double size) {
    // Double-check platform to prevent any Image.file calls on web
    if (kIsWeb) {
      print('ProfilePhotoWidget: CRITICAL ERROR - _buildFileImage called on web!');
      return _buildDefaultAvatar(context, size);
    }

    try {
      print('ProfilePhotoWidget: Building file image for: $filePath');
      return ClipOval(
        child: Image.file(
          File(filePath),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('ProfilePhotoWidget: Error loading file image: $error');
            return _buildDefaultAvatar(context, size);
          },
        ),
      );
    } catch (e) {
      print('ProfilePhotoWidget: Exception loading file image: $e');
      return _buildDefaultAvatar(context, size);
    }
  }

  Widget _buildWebImage(BuildContext context, String dataUrl, double size) {
    try {
      return ClipOval(
        child: Image.network(
          dataUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('ProfilePhotoWidget: Error loading web image: $error');
            return _buildDefaultAvatar(context, size);
          },
        ),
      );
    } catch (e) {
      print('ProfilePhotoWidget: Exception loading web image: $e');
      return _buildDefaultAvatar(context, size);
    }
  }

  Widget _buildDefaultAvatar(BuildContext context, double size) {
    try {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ThemeProperties.getPrimaryGradient(context),
        ),
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: ThemeProperties.getSurfaceColor(context),
        ),
      );
    } catch (e) {
      print('ProfilePhotoWidget: Error building default avatar: $e');
      // Ultimate fallback - simple container with icon
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeProperties.getSurfaceColor(context),
        ),
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: ThemeProperties.getTextColor(context),
        ),
      );
    }
  }
}
