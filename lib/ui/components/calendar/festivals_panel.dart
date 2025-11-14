/// Festivals Panel Widget
///
/// A panel showing festivals and important dates
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/services/astrology/astrology_service_bridge.dart';
import 'package:skvk_application/core/services/location/simple_location_service.dart';
import 'package:skvk_application/core/utils/astrology/timezone_util.dart';
import 'package:skvk_application/ui/components/common/index.dart';

class FestivalsPanel extends StatefulWidget {
  const FestivalsPanel({
    required this.selectedDate,
    required this.latitude,
    required this.longitude,
    super.key,
  });
  final DateTime selectedDate;
  final double latitude;
  final double longitude;

  @override
  State<FestivalsPanel> createState() => _FestivalsPanelState();
}

class _FestivalsPanelState extends State<FestivalsPanel> {
  List<Map<String, dynamic>> _festivals = [];
  List<Map<String, dynamic>> _upcomingFestivals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFestivals();
  }

  Future<void> _loadFestivals() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final locationService = SimpleLocationService();
      final locationResult =
          await locationService.getDeviceLocationWithFallback();

      if (!locationResult.isSuccess ||
          locationResult.latitude == null ||
          locationResult.longitude == null) {
        throw Exception('Failed to get location: ${locationResult.error}');
      }

      final latitude = locationResult.latitude!;
      final longitude = locationResult.longitude!;

      await TimezoneUtil.initialize();
      final timezoneId =
          AstrologyServiceBridge.getTimezoneFromLocation(latitude, longitude);

      // Fetch calendar month data from API to extract festivals
      final bridge = AstrologyServiceBridge.instance();
      final monthData = await bridge.getCalendarMonth(
        year: widget.selectedDate.year,
        month: widget.selectedDate.month,
        region: 'lahiri', // Default ayanamsha
        latitude: latitude,
        longitude: longitude,
        timezoneId: timezoneId,
      );

      // Extract festivals from month data
      final festivals = <Map<String, dynamic>>[];
      final upcoming = <Map<String, dynamic>>[];

      if (monthData.containsKey('days')) {
        final days = monthData['days'] as Map<String, dynamic>? ?? {};
        final selectedDayKey = widget.selectedDate.day.toString();

        if (days.containsKey(selectedDayKey)) {
          final dayData = days[selectedDayKey] as Map<String, dynamic>? ?? {};
          final dayFestivals = dayData['festivals'] as List<dynamic>? ?? [];

          for (final festival in dayFestivals) {
            if (festival is Map<String, dynamic>) {
              festivals.add({
                'name': festival['name'] ?? 'Festival',
                'description': festival['description'] ?? '',
                'date': widget.selectedDate.toString().split(' ')[0],
                'type': festival['type'] ?? 'religious',
              });
            }
          }
        }

        final today = DateTime.now();
        for (int i = 1; i <= 7; i++) {
          final futureDate = today.add(Duration(days: i));
          if (futureDate.year == widget.selectedDate.year &&
              futureDate.month == widget.selectedDate.month) {
            final dayKey = futureDate.day.toString();
            if (days.containsKey(dayKey)) {
              final dayData = days[dayKey] as Map<String, dynamic>? ?? {};
              final dayFestivals = dayData['festivals'] as List<dynamic>? ?? [];

              for (final festival in dayFestivals) {
                if (festival is Map<String, dynamic>) {
                  upcoming.add({
                    'name': festival['name'] ?? 'Festival',
                    'description': festival['description'] ?? '',
                    'date': futureDate.toString().split(' ')[0],
                    'type': festival['type'] ?? 'religious',
                  });
                }
              }
            }
          }
        }
      }

      setState(() {
        _festivals = festivals;
        _upcomingFestivals = upcoming;
        _isLoading = false;
      });
    } on Exception {
      setState(() {
        _festivals = [];
        _upcomingFestivals = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return InfoCard(
        child: Center(
          child: CircularProgressIndicator(
            color: ThemeHelpers.getPrimaryColor(context),
          ),
        ),
      );
    }

    return InfoCard(
      child: Column(
        children: [
          _buildTodayFestivals(context),
          ResponsiveSystem.sizedBox(context, height: 16),
          _buildUpcomingFestivals(context),
        ],
      ),
    );
  }

  Widget _buildTodayFestivals(BuildContext context) {
    final todayFestivals = _festivals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.calendar,
              color: ThemeHelpers.getPrimaryColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
            ),
            ResponsiveSystem.sizedBox(context, width: 8),
            Text(
              "Today's Festivals",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeHelpers.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        if (todayFestivals.isNotEmpty)
          ...todayFestivals
              .map((festival) => _buildFestivalItem(context, festival))
        else
          Text(
            'No festivals today',
            style: TextStyle(
              color: ThemeHelpers.getSecondaryTextColor(context),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildUpcomingFestivals(BuildContext context) {
    final upcomingFestivals = _upcomingFestivals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.calendarClock,
              color: ThemeHelpers.getPrimaryColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
            ),
            ResponsiveSystem.sizedBox(context, width: 8),
            Text(
              'Upcoming Festivals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeHelpers.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        if (upcomingFestivals.isNotEmpty)
          ...upcomingFestivals
              .take(3)
              .map((festival) => _buildFestivalItem(context, festival))
        else
          Text(
            'No upcoming festivals',
            style: TextStyle(
              color: ThemeHelpers.getSecondaryTextColor(context),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildFestivalItem(
    BuildContext context,
    Map<String, dynamic> festival,
  ) {
    return Container(
      margin: ResponsiveSystem.only(context, bottom: 8),
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.1),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.3),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveSystem.spacing(context, baseSpacing: 4),
            height: ResponsiveSystem.spacing(context, baseSpacing: 40),
            decoration: BoxDecoration(
              color: ThemeHelpers.getPrimaryColor(context),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 2),
            ),
          ),
          ResponsiveSystem.sizedBox(context, width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  festival['name'] ?? 'Festival',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ThemeHelpers.getPrimaryTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (festival['date'] != null) ...[
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    festival['date'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                  ),
                ],
                if (festival['description'] != null) ...[
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    festival['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Icon(
            _getFestivalIcon(festival['type']),
            color: ThemeHelpers.getPrimaryColor(context),
            size: ResponsiveSystem.iconSize(context, baseSize: 20),
          ),
        ],
      ),
    );
  }

  IconData _getFestivalIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'major':
        return LucideIcons.star;
      case 'religious':
        return LucideIcons.church;
      case 'seasonal':
        return LucideIcons.leaf;
      case 'regional':
        return LucideIcons.mapPin;
      default:
        return LucideIcons.calendarHeart;
    }
  }
}
