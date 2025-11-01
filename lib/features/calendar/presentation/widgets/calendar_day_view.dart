library;

import '../../../../core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';

class CalendarDayView extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const CalendarDayView({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<CalendarDayView> createState() => _CalendarDayViewState();
}

class _CalendarDayViewState extends State<CalendarDayView> {
  Map<String, dynamic>? _calendarData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use AstrologyFacade for timezone handling and month panchang
      final facade = AstrologyFacade.instance;

      // TODO: Accept coordinates via widget; currently default to Delhi to avoid breaking API
      const double latitude = 28.6139;
      const double longitude = 77.2090;
      final tz = await facade.getTimezoneFromLocation(latitude, longitude);

      // Fetch month panchang and pick the selected day (names and rise/set provided by facade)
      final monthView = await facade.getMonthPanchang(
        year: widget.selectedDate.year,
        month: widget.selectedDate.month,
        region: RegionalCalendar.universal,
        latitude: latitude,
        longitude: longitude,
        timezoneId: tz,
      );

      final day = monthView.days.firstWhere(
        (d) => d.date.year == widget.selectedDate.year &&
            d.date.month == widget.selectedDate.month &&
            d.date.day == widget.selectedDate.day,
        orElse: () => monthView.days.first,
      );

      setState(() {
        _calendarData = {
          'tithi': day.tithiName,
          'paksha': day.pakshaName,
          'nakshatra': day.nakshatraName,
          'yoga': day.yogaName,
          'karana': day.karanaName,
          'festival': (day.festivals.isNotEmpty ? day.festivals.first : 'No festival'),
          'sunrise': day.sunriseTime,
          'sunset': day.sunsetTime,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading calendar data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: ThemeProperties.getErrorColor(context),
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: ThemeProperties.getErrorColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            ElevatedButton(
              onPressed: _fetchCalendarData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildContent(context, _calendarData);
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic>? info) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(widget.selectedDate),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ThemeProperties.getPrimaryTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
          ),
          ResponsiveSystem.sizedBox(context, height: 12),
          _row('Tithi', info != null ? '${info['tithi']}' : '—'),
          _row('Paksha', info != null ? '${info['paksha']}' : '—'),
          _row('Nakshatra', info != null ? '${info['nakshatra']}' : '—'),
          _row('Yoga', info != null ? '${info['yoga']}' : '—'),
          _row('Karana', info != null ? '${info['karana']}' : '—'),
          _row('Festival', info != null ? '${info['festival']}' : '—'),
          ResponsiveSystem.sizedBox(context, height: 12),
          _sunTimes(info),
        ],
      ),
    );
  }

  Widget _sunTimes(Map<String, dynamic>? info) {
    final sunrise = info?['sunrise'] as String?;
    final sunset = info?['sunset'] as String?;
    return Row(
      children: [
        Expanded(child: _chip('Sunrise', sunrise ?? '—')),
        ResponsiveSystem.sizedBox(context, width: 8),
        Expanded(child: _chip('Sunset', sunset ?? '—')),
      ],
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeProperties.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: ThemeProperties.getSecondaryTextColor(context))),
          ResponsiveSystem.sizedBox(context, height: 4),
          Text(value,
              style: TextStyle(
                  color: ThemeProperties.getPrimaryTextColor(context),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: ResponsiveSystem.symmetric(context, vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: ResponsiveSystem.spacing(context, baseSpacing: 120),
              child: Text(label,
                  style: TextStyle(color: ThemeProperties.getSecondaryTextColor(context)))),
          Expanded(
              child: Text(value,
                  style: TextStyle(color: ThemeProperties.getPrimaryTextColor(context)))),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}-${d.month}-${d.year}';
  // All calculations now come from the facade month panchang for consistency.
}
