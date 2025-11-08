/// Profile Info Card Widget
///
/// A reusable card widget for displaying profile information
/// with Hindu traditional styling
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';

class ProfileInfoCard extends ConsumerWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final VoidCallback? onTap;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize responsive sizing
    // ResponsiveSystem.init(context); // Removed - not needed

    return Card(
      elevation: ResponsiveSystem.elevation(context, baseElevation: 4),
      color: ThemeProperties.getSurfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        child: Container(
          padding: EdgeInsets.all(
              ResponsiveSystem.spacing(context, baseSpacing: 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        ResponsiveSystem.spacing(context, baseSpacing: 8)),
                    decoration: BoxDecoration(
                      color: ThemeProperties.getPrimaryColor(context)
                          .withAlpha((0.1 * 255).round()),
                      borderRadius: ResponsiveSystem.circular(context,
                          baseRadius: 8),
                    ),
                    child: Icon(
                      icon,
                      color: ThemeProperties.getPrimaryColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 20),
                    ),
                  ),
                  SizedBox(
                      width:
                          ResponsiveSystem.spacing(context, baseSpacing: 12)),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 19),
                        fontWeight: FontWeight.bold,
                        color: ThemeProperties.getPrimaryTextColor(context),
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: ThemeProperties.getSecondaryTextColor(context),
                      size: ResponsiveSystem.iconSize(context, baseSize: 16),
                    ),
                ],
              ),

              SizedBox(
                  height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

              // Content
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
