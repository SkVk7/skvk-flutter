/// Auspicious Times Panel Widget
///
/// A panel showing auspicious times and muhurta information
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/widgets/common/centralized_widgets.dart';

class AuspiciousTimesPanel extends ConsumerWidget {
  final DateTime selectedDate;

  const AuspiciousTimesPanel({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    return CentralizedInfoCard(
      child: Column(
        children: [
          _buildSunTimes(context, primaryColor, ref),
          ResponsiveSystem.sizedBox(context, height: 16),
          _buildAuspiciousPeriods(context, primaryColor, ref),
          ResponsiveSystem.sizedBox(context, height: 16),
          _buildInauspiciousPeriods(context, primaryColor, ref),
        ],
      ),
    );
  }

  Widget _buildSunTimes(
      BuildContext context, Color primaryColor, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.sun,
              color: primaryColor,
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
            ),
            ResponsiveSystem.sizedBox(context, width: 8),
            Text(
              'Sun Times',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeProperties.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        ResponsiveSystem.sizedBox(context, height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimeCard(
                context,
                'Sunrise',
                '06:30 AM',
                LucideIcons.sunrise,
                primaryColor,
                ref,
              ),
            ),
            ResponsiveSystem.sizedBox(context, width: 12),
            Expanded(
              child: _buildTimeCard(
                context,
                'Sunset',
                '06:15 PM',
                LucideIcons.sunset,
                primaryColor,
                ref,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuspiciousPeriods(
      BuildContext context, Color primaryColor, WidgetRef ref) {
    final auspiciousPeriods = _getAuspiciousPeriods();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.star,
              color: primaryColor,
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
            ),
            ResponsiveSystem.sizedBox(context, width: 8),
            Text(
              'Auspicious Periods',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeProperties.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        ...auspiciousPeriods.map((period) =>
            _buildPeriodItem(context, period, true, primaryColor, ref)),
      ],
    );
  }

  Widget _buildInauspiciousPeriods(
      BuildContext context, Color primaryColor, WidgetRef ref) {
    final inauspiciousPeriods = _getInauspiciousPeriods();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning,
              color: primaryColor.withAlpha((0.7 * 255).round()),
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
            ),
            ResponsiveSystem.sizedBox(context, width: 8),
            Text(
              'Avoid These Times',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeProperties.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        ...inauspiciousPeriods.map((period) =>
            _buildPeriodItem(context, period, false, primaryColor, ref)),
      ],
    );
  }

  Widget _buildTimeCard(
    BuildContext context,
    String label,
    String time,
    IconData icon,
    Color color,
    WidgetRef ref,
  ) {
    return Container(
      padding:
          EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 12)),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: color.withAlpha((0.3 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveSystem.iconSize(context, baseSize: 20),
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ThemeProperties.getSecondaryTextColor(context),
                  fontWeight: FontWeight.w500,
                ),
          ),
          ResponsiveSystem.sizedBox(context, height: 4),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodItem(BuildContext context, Map<String, dynamic> period,
      bool isAuspicious, Color primaryColor, WidgetRef ref) {
    final color = isAuspicious
        ? primaryColor
        : primaryColor.withAlpha((0.7 * 255).round());
    final icon = isAuspicious ? LucideIcons.check : LucideIcons.x;

    return Container(
      margin: EdgeInsets.only(
          bottom: ResponsiveSystem.spacing(context, baseSpacing: 8)),
      padding:
          EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 12)),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: color.withAlpha((0.3 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
          ),
          ResponsiveSystem.sizedBox(context, width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period['name'] ?? 'Period',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ThemeProperties.getPrimaryTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (period['time'] != null) ...[
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    period['time'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
                if (period['description'] != null) ...[
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    period['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeProperties.getSecondaryTextColor(context),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAuspiciousPeriods() {
    // This would typically be calculated based on astrological data
    // For now, returning sample data
    return [
      {
        'name': 'Brahma Muhurta',
        'time': '04:30 AM - 05:30 AM',
        'description': 'Most auspicious time for spiritual practices',
      },
      {
        'name': 'Abhijit Muhurta',
        'time': '11:45 AM - 12:30 PM',
        'description': 'Auspicious for starting new ventures',
      },
      {
        'name': 'Godhuli Muhurta',
        'time': '06:00 PM - 06:30 PM',
        'description': 'Auspicious time during sunset',
      },
    ];
  }

  List<Map<String, dynamic>> _getInauspiciousPeriods() {
    // This would typically be calculated based on astrological data
    // For now, returning sample data
    return [
      {
        'name': 'Rahu Kalam',
        'time': '10:30 AM - 12:00 PM',
        'description': 'Avoid starting new activities',
      },
      {
        'name': 'Yamaganda',
        'time': '03:00 PM - 04:30 PM',
        'description': 'Inauspicious for important decisions',
      },
      {
        'name': 'Gulika Kalam',
        'time': '01:30 PM - 03:00 PM',
        'description': 'Avoid financial transactions',
      },
    ];
  }
}
