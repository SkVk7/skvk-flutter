import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'reusable_buttons.dart';
import 'reusable_form_fields.dart';
import 'reusable_cards.dart';

/// Centralized widgets that use reactive sizing and themed coloring
class CentralizedWidgets {
  static CentralizedWidgets get instance => _instance ??= CentralizedWidgets._();
  static CentralizedWidgets? _instance;
  CentralizedWidgets._();
}

/// Centralized Info Card (alias for ReusableInfoCard)
class CentralizedInfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool enableAnimation;

  const CentralizedInfoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.enableAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableInfoCard(
      title: '', // CentralizedInfoCard doesn't have title, but ReusableInfoCard requires it
      padding: padding as EdgeInsets?,
      margin: margin as EdgeInsets?,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}

/// Centralized Info Row for displaying key-value pairs
class CentralizedInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const CentralizedInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
      child: Padding(
        padding: ResponsiveSystem.symmetric(context, horizontal: 8, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
                color: iconColor ?? ThemeProperties.getPrimaryColor(context),
              ),
              ResponsiveSystem.sizedBox(context, width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                      fontWeight: FontWeight.w500,
                      color: ThemeProperties.getSecondaryTextColor(context),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w600,
                      color: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centralized Section Title
class CentralizedSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const CentralizedSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? ResponsiveSystem.only(context, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                ),
                if (subtitle != null) ...[
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeProperties.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Centralized Modern Button (alias for ReusablePrimaryButton)
class CentralizedModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const CentralizedModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ReusablePrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: height,
      icon: icon,
      padding: padding as EdgeInsets?,
    );
  }
}

/// Centralized Modern Text Field (alias for ReusableTextInput)
class CentralizedModernTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;

  const CentralizedModernTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTextInput(
      controller: controller ?? TextEditingController(),
      hintText: hint ?? '',
      onChanged: onChanged,
      keyboardType: keyboardType ?? TextInputType.text,
      prefixIcon: prefixIcon is Icon ? (prefixIcon as Icon).icon : null,
    );
  }
}

/// Centralized Location Suggestion Item
class CentralizedLocationSuggestionItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const CentralizedLocationSuggestionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: ResponsiveSystem.symmetric(context, horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
              color: ThemeProperties.getPrimaryColor(context),
            ),
            ResponsiveSystem.sizedBox(context, width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w500,
                      color: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                  if (subtitle != null) ...[
                    ResponsiveSystem.sizedBox(context, height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                        color: ThemeProperties.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centralized Error Message
class CentralizedErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CentralizedErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: ResponsiveSystem.iconSize(context, baseSize: 48),
              color: ThemeProperties.getErrorColor(context),
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeProperties.getErrorColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              ResponsiveSystem.sizedBox(context, height: 16),
              CentralizedModernButton(
                text: 'Retry',
                onPressed: onRetry,
                width: ResponsiveSystem.screenWidth(context) * 0.5,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centralized Loading Widget
class CentralizedLoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const CentralizedLoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size ?? ResponsiveSystem.iconSize(context, baseSize: 48),
              height: size ?? ResponsiveSystem.iconSize(context, baseSize: 48),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeProperties.getPrimaryColor(context),
                ),
              ),
            ),
            if (message != null) ...[
              ResponsiveSystem.sizedBox(context, height: 16),
              Text(
                message!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centralized Empty State Widget
class CentralizedEmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const CentralizedEmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: ResponsiveSystem.iconSize(context, baseSize: 64),
              color: ThemeProperties.getSecondaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                fontWeight: FontWeight.w600,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              ResponsiveSystem.sizedBox(context, height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              ResponsiveSystem.sizedBox(context, height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Centralized Date Picker (alias for ReusableDatePicker)
class CentralizedDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateChanged;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CentralizedDatePicker({
    super.key,
    this.selectedDate,
    this.onDateChanged,
    this.label,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableDatePicker(
      selectedDate: selectedDate ?? DateTime.now(),
      onDateChanged: onDateChanged ?? (date) {},
    );
  }
}

/// Centralized Time Picker (alias for ReusableTimePicker)
class CentralizedTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final String? label;

  const CentralizedTimePicker({
    super.key,
    this.selectedTime,
    this.onTimeChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableTimePicker(
      selectedTime: selectedTime ?? TimeOfDay.now(),
      onTimeChanged: onTimeChanged ?? (time) {},
    );
  }
}

/// Centralized Profile Completion Popup
class CentralizedProfileCompletionPopup extends StatelessWidget {
  final VoidCallback? onCompleteProfile;
  final VoidCallback? onSkip;

  const CentralizedProfileCompletionPopup({
    super.key,
    this.onCompleteProfile,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
      ),
      title: Text(
        'Complete Your Profile',
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
          fontWeight: FontWeight.bold,
          color: ThemeProperties.getPrimaryTextColor(context),
        ),
      ),
      content: Text(
        'To access all features, please complete your profile with your birth details.',
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
          color: ThemeProperties.getSecondaryTextColor(context),
        ),
      ),
      actions: [
        if (onSkip != null)
          CentralizedModernButton(
            text: 'Skip',
            onPressed: onSkip,
            width: ResponsiveSystem.screenWidth(context) * 0.25,
            backgroundColor: ThemeProperties.getTransparentColor(context),
            textColor: ThemeProperties.getSecondaryTextColor(context),
          ),
        CentralizedModernButton(
          text: 'Complete Profile',
          onPressed: onCompleteProfile,
          width: ResponsiveSystem.screenWidth(context) * 0.3,
        ),
      ],
    );
  }
}

/// Centralized Gradient App Bar
class CentralizedGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Gradient? gradient;

  const CentralizedGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
          fontWeight: FontWeight.bold,
          color: ThemeProperties.getTextColor(context),
        ),
      ),
      leading: leading,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient ??
              LinearGradient(
                colors: [
                  ThemeProperties.getPrimaryColor(context),
                  ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        ),
      ),
      elevation: ResponsiveSystem.elevation(context, baseElevation: 4),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// Centralized Modern Info Card (alias for CentralizedInfoCard)
class ModernInfoCard extends CentralizedInfoCard {
  const ModernInfoCard({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.backgroundColor,
    super.elevation,
    super.borderRadius,
    super.enableAnimation,
  });
}

/// Centralized Info Row (alias for CentralizedInfoRow)
class InfoRow extends CentralizedInfoRow {
  const InfoRow({
    super.key,
    required super.label,
    required super.value,
    super.icon,
    super.iconColor,
    super.onTap,
  });
}

/// Centralized Astrology Info Row
class AstrologyInfoRow extends CentralizedInfoRow {
  const AstrologyInfoRow({
    super.key,
    required super.label,
    required super.value,
    super.icon,
    super.iconColor,
    super.onTap,
  });
}

/// Centralized Modern Loading Widget
class ModernLoadingWidget extends CentralizedLoadingWidget {
  const ModernLoadingWidget({
    super.key,
    super.message,
    super.size,
  });
}

/// Centralized Modern Error Widget
class ModernErrorWidget extends CentralizedErrorMessage {
  const ModernErrorWidget({
    super.key,
    required super.message,
    super.onRetry,
    super.icon,
  });
}

/// Centralized Welcome Section Widget
class CentralizedWelcomeSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String? badgeText;
  final VoidCallback? onBadgeTap;

  const CentralizedWelcomeSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.badgeText,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 20),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: ResponsiveSystem.iconSize(context, baseSize: 28),
          ),
          ResponsiveSystem.sizedBox(context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                    color: ThemeProperties.getSecondaryTextColor(context),
                    height: ResponsiveSystem.lineHeight(context, baseHeight: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Centralized Quick Actions Section Widget
class CentralizedQuickActionsSection extends StatelessWidget {
  final String title;
  final List<CentralizedQuickActionCard> actions;

  const CentralizedQuickActionsSection({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveSystem.symmetric(context, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
              fontWeight: FontWeight.bold,
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 32)),
          Row(
            children: actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < actions.length - 1
                        ? ResponsiveSystem.spacing(context, baseSpacing: 16)
                        : 0,
                  ),
                  child: action,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Centralized Quick Action Card Widget
class CentralizedQuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const CentralizedQuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: ResponsiveSystem.cardHeight(context, baseHeight: 160),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveSystem.iconSize(context, baseSize: 32),
              color: color,
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                fontWeight: FontWeight.w600,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centralized Features Grid Section Widget
class CentralizedFeaturesGridSection extends StatelessWidget {
  final String title;
  final List<CentralizedFeatureCard> features;

  const CentralizedFeaturesGridSection({
    super.key,
    required this.title,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveSystem.all(context, baseSpacing: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
              fontWeight: FontWeight.bold,
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 32)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: ResponsiveSystem.spacing(context, baseSpacing: 12),
            mainAxisSpacing: ResponsiveSystem.spacing(context, baseSpacing: 12),
            childAspectRatio: 1.4,
            children: features,
          ),
        ],
      ),
    );
  }
}

/// Centralized Feature Card Widget
class CentralizedFeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const CentralizedFeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveSystem.iconSize(context, baseSize: 32),
              color: color,
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                fontWeight: FontWeight.w600,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centralized Daily Insights Section Widget
class CentralizedDailyInsightsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonTap;
  final bool isDark;

  const CentralizedDailyInsightsSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveSystem.symmetric(context, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
              fontWeight: FontWeight.bold,
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 32)),
          Container(
            padding: ResponsiveSystem.all(context, baseSpacing: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.1),
                  ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
              border: Border.all(
                color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.2),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                    color: ThemeProperties.getPrimaryTextColor(context),
                    height: ResponsiveSystem.lineHeight(context, baseHeight: 1.5),
                  ),
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                CentralizedModernButton(
                  text: buttonText,
                  onPressed: onButtonTap,
                  width: ResponsiveSystem.screenWidth(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Centralized Profile Photo with Hover Widget
class CentralizedProfilePhotoWithHover extends StatefulWidget {
  final VoidCallback onTap;
  final String? tooltip;
  final String? imageUrl;
  final IconData? fallbackIcon;

  const CentralizedProfilePhotoWithHover({
    super.key,
    required this.onTap,
    this.tooltip,
    this.imageUrl,
    this.fallbackIcon,
  });

  @override
  State<CentralizedProfilePhotoWithHover> createState() => _CentralizedProfilePhotoWithHoverState();
}

class _CentralizedProfilePhotoWithHoverState extends State<CentralizedProfilePhotoWithHover>
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
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
                    color: ThemeProperties.getPrimaryColor(context),
                    width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.3),
                            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
                            spreadRadius: ResponsiveSystem.spacing(context, baseSpacing: 2),
                          ),
                        ]
                      : null,
                ),
                child: ClipOval(
                  child: widget.imageUrl != null
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
                        )
                      : _buildFallbackIcon(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.1),
      ),
      child: Icon(
        widget.fallbackIcon ?? Icons.person,
        color: ThemeProperties.getAppBarTextColor(context),
        size: ResponsiveSystem.iconSize(context, baseSize: 24),
      ),
    );
  }
}

/// Centralized Fade Animation Widget
class CentralizedFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool autoStart;

  const CentralizedFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    this.autoStart = true,
  });

  @override
  State<CentralizedFadeAnimation> createState() => _CentralizedFadeAnimationState();
}

class _CentralizedFadeAnimationState extends State<CentralizedFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Centralized Slide Animation Widget
class CentralizedSlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;
  final Offset endOffset;
  final bool autoStart;

  const CentralizedSlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    this.beginOffset = const Offset(0.0, 0.3),
    this.endOffset = Offset.zero,
    this.autoStart = true,
  });

  @override
  State<CentralizedSlideAnimation> createState() => _CentralizedSlideAnimationState();
}

class _CentralizedSlideAnimationState extends State<CentralizedSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Centralized Stagger Animation Widget
class CentralizedStaggerAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Curve curve;
  final double staggerDelay;
  final bool autoStart;

  const CentralizedStaggerAnimation({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutCubic,
    this.staggerDelay = 0.2,
    this.autoStart = true,
  });

  @override
  State<CentralizedStaggerAnimation> createState() => _CentralizedStaggerAnimationState();
}

class _CentralizedStaggerAnimationState extends State<CentralizedStaggerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animations = List.generate(widget.children.length, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * widget.staggerDelay,
          (index * widget.staggerDelay) + 0.6,
          curve: widget.curve,
        ),
      ));
    });

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _animations[index].value)),
              child: Opacity(
                opacity: _animations[index].value,
                child: child,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

/// Centralized Animated Card Widget
class CentralizedAnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Curve curve;
  final double staggerDelay;

  const CentralizedAnimatedCard({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutCubic,
    this.staggerDelay = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return CentralizedStaggerAnimation(
      duration: duration,
      curve: curve,
      staggerDelay: staggerDelay,
      children: [child],
    );
  }
}

/// Centralized App Bar Widget
class CentralizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? leadingIcon;
  final List<Widget> actions;
  final Color? backgroundColor;
  final double? elevation;

  const CentralizedAppBar({
    super.key,
    required this.title,
    this.leadingIcon,
    this.actions = const [],
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? ThemeProperties.getPrimaryColor(context),
      elevation: ResponsiveSystem.elevation(context, baseElevation: elevation ?? 4),
      toolbarHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
      title: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              color: ThemeProperties.getAppBarTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
            ResponsiveSystem.sizedBox(context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          ],
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeProperties.getAppBarTextColor(context),
              ),
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

/// Centralized App Bar Action Button
class CentralizedAppBarActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const CentralizedAppBarActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: ThemeProperties.getAppBarTextColor(context),
        size: ResponsiveSystem.iconSize(context, baseSize: 24),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

/// Centralized Text Widget
class CentralizedText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CentralizedText({
    super.key,
    required this.text,
    this.fontSize,
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
        fontSize: fontSize ?? ResponsiveSystem.fontSize(context, baseSize: 16),
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? ThemeProperties.getPrimaryTextColor(context),
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Centralized Dropdown Menu Widget
class CentralizedDropdownMenu extends StatelessWidget {
  final String title;
  final List<CentralizedDropdownItem> items;
  final Function(String)? onSelected;
  final String? tooltip;

  const CentralizedDropdownMenu({
    super.key,
    required this.title,
    required this.items,
    this.onSelected,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: tooltip,
      icon: Icon(
        Icons.more_vert,
        color: ThemeProperties.getAppBarTextColor(context),
        size: ResponsiveSystem.iconSize(context, baseSize: 24),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => items.map((item) => item.build(context)).toList(),
    );
  }
}

/// Centralized Dropdown Item Widget
class CentralizedDropdownItem {
  final String value;
  final String label;
  final IconData? icon;

  const CentralizedDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });

  PopupMenuItem<String> build(BuildContext context) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: ThemeProperties.getPrimaryColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
            ResponsiveSystem.sizedBox(context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centralized Theme Dropdown Widget
class CentralizedThemeDropdown extends StatelessWidget {
  final Function(String)? onThemeChanged;

  const CentralizedThemeDropdown({
    super.key,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Theme',
      icon: Container(
        padding: EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 4)),
        decoration: BoxDecoration(
          color: ThemeProperties.getAppBarTextColor(context).withValues(alpha: 0.1),
          borderRadius:
              BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 4)),
        ),
        child: Icon(
          Icons.palette,
          color: ThemeProperties.getAppBarTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 24),
        ),
      ),
      onSelected: onThemeChanged,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'light',
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                color: ThemeProperties.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
              Text(
                'Light',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'dark',
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: ThemeProperties.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
              Text(
                'Dark',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'system',
          child: Row(
            children: [
              Icon(
                Icons.settings_system_daydream,
                color: ThemeProperties.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
              Text(
                'System',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Centralized Language Dropdown Widget
class CentralizedLanguageDropdown extends StatelessWidget {
  final Function(String)? onLanguageChanged;

  const CentralizedLanguageDropdown({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Language',
      icon: Container(
        padding: EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 4)),
        decoration: BoxDecoration(
          color: ThemeProperties.getAppBarTextColor(context).withValues(alpha: 0.1),
          borderRadius:
              BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 4)),
        ),
        child: Icon(
          Icons.public,
          color: ThemeProperties.getAppBarTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 24),
        ),
      ),
      onSelected: onLanguageChanged,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Icon(
                Icons.public,
                color: ThemeProperties.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
              Text(
                'English',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'hi',
          child: Row(
            children: [
              Icon(
                Icons.public,
                color: ThemeProperties.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
              Text(
                'हिन्दी',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'te',
          child: Row(
            children: [
              Icon(
                Icons.public,
                color: ThemeProperties.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
              Text(
                'తెలుగు',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
