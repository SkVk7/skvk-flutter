/// Hindu Festivals Panel Widget
///
/// A panel showing Hindu festivals and important dates
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../shared/widgets/centralized_widgets.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../astrology/astrology_library.dart';

class HinduFestivalsPanel extends StatefulWidget {
  final DateTime selectedDate;
  final double latitude;
  final double longitude;

  const HinduFestivalsPanel({
    super.key,
    required this.selectedDate,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<HinduFestivalsPanel> createState() => _HinduFestivalsPanelState();
}

class _HinduFestivalsPanelState extends State<HinduFestivalsPanel> {
  List<Map<String, dynamic>> _festivals = [];
  List<Map<String, dynamic>> _upcomingFestivals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFestivals();
  }

  Future<void> _loadFestivals() async {
    final festivals = await _getFestivalsForDate(widget.selectedDate);
    final upcoming = await _getUpcomingFestivals();

    setState(() {
      _festivals = festivals;
      _upcomingFestivals = upcoming;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CentralizedInfoCard(
        child: Center(
          child: CircularProgressIndicator(
            color: ThemeProperties.getPrimaryColor(context),
          ),
        ),
      );
    }

    return CentralizedInfoCard(
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
              color: ThemeProperties.getPrimaryColor(context),
              size: 16,
            ),
            ResponsiveSystem.sizedBox(context, width: 8),
            Text(
              'Today\'s Festivals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeProperties.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        if (todayFestivals.isNotEmpty)
          ...todayFestivals.map((festival) => _buildFestivalItem(context, festival))
        else
          Text(
            'No festivals today',
            style: TextStyle(
              color: ThemeProperties.getSecondaryTextColor(context),
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
              color: ThemeProperties.getPrimaryColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 16),
            ),
            ResponsiveSystem.sizedBox(context, width: 8),
            Text(
              'Upcoming Festivals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeProperties.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        if (upcomingFestivals.isNotEmpty)
          ...upcomingFestivals.take(3).map((festival) => _buildFestivalItem(context, festival))
        else
          Text(
            'No upcoming festivals',
            style: TextStyle(
              color: ThemeProperties.getSecondaryTextColor(context),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildFestivalItem(BuildContext context, Map<String, dynamic> festival) {
    return Container(
      margin: ResponsiveSystem.only(context, bottom: 8),
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeProperties.getPrimaryColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: ThemeProperties.getPrimaryColor(context).withAlpha((0.3 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveSystem.spacing(context, baseSpacing: 4),
            height: ResponsiveSystem.spacing(context, baseSpacing: 40),
            decoration: BoxDecoration(
              color: ThemeProperties.getPrimaryColor(context),
              borderRadius:
                  BorderRadius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 2)),
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
                        color: ThemeProperties.getPrimaryTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (festival['date'] != null) ...[
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    festival['date'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeProperties.getSecondaryTextColor(context),
                        ),
                  ),
                ],
                if (festival['description'] != null) ...[
                  ResponsiveSystem.sizedBox(context, height: 4),
                  Text(
                    festival['description'],
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
          Icon(
            _getFestivalIcon(festival['type']),
            color: ThemeProperties.getPrimaryColor(context),
            size: 20,
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

  Future<List<Map<String, dynamic>>> _getFestivalsForDate(DateTime date) async {
    try {
      // Initialize astrology library if needed
      if (!AstrologyLibrary.isInitialized) {
        await AstrologyLibrary.initialize();
      }

      // Get festivals for the specific date using real astrology calculations
      final festivals = await AstrologyLibrary.calculateFestivals(
        latitude: widget.latitude,
        longitude: widget.longitude,
        year: date.year,
      );

      // Filter festivals for this specific date
      final dayFestivals = festivals.where((festival) {
        final festivalDate = festival.date;
        return festivalDate.year == date.year &&
            festivalDate.month == date.month &&
            festivalDate.day == date.day;
      }).toList();

      // Convert to the expected format
      return dayFestivals
          .map((festival) => {
                'name': festival.name,
                'type': festival.type,
                'description': festival.description,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getUpcomingFestivals() async {
    try {
      // Initialize astrology library if needed
      if (!AstrologyLibrary.isInitialized) {
        await AstrologyLibrary.initialize();
      }

      final now = DateTime.now();

      // Get festivals for the current year
      final festivals = await AstrologyLibrary.calculateFestivals(
        latitude: widget.latitude,
        longitude: widget.longitude,
        year: now.year,
      );

      // Filter upcoming festivals (from today onwards)
      final upcomingFestivals = festivals.where((festival) {
        return festival.date.isAfter(now) || festival.date.isAtSameMomentAs(now);
      }).toList();

      // Sort by date and take next 10 festivals
      upcomingFestivals.sort((a, b) => a.date.compareTo(b.date));
      final nextFestivals = upcomingFestivals.take(10).toList();

      // Convert to the expected format
      return nextFestivals
          .map((festival) => {
                'name': festival.name,
                'date': '${festival.date.day}/${festival.date.month}/${festival.date.year}',
                'type': festival.type,
                'description': festival.description,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }
}
