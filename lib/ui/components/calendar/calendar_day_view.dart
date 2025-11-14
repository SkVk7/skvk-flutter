library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/constants/app_constants.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/utils/validation/error_message_helper.dart';

class CalendarDayView extends StatefulWidget {
  const CalendarDayView({
    required this.selectedDate,
    required this.onDateChanged,
    super.key,
  });
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

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

      // To implement standalone fetching, we would need to:
      // 1. Call getCalendarMonth API for the selected date's month
      // 2. Extract the specific day from the month response
      // The month panchang data is included in getCalendarMonth response.
      setState(() {
        _calendarData = {
          'tithi': 'Not available',
          'paksha': 'Not available',
          'nakshatra': 'Not available',
          'yoga': 'Not available',
          'karana': 'Not available',
          'festival': 'No festival',
          'sunrise': 'Not available',
          'sunset': 'Not available',
        };
        _isLoading = false;
      });
    } on Exception catch (e) {
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      setState(() {
        _errorMessage = userFriendlyMessage;
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
              size: ResponsiveSystem.iconSize(context, baseSize: 48),
              color: ThemeHelpers.getErrorColor(context),
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: ThemeHelpers.getErrorColor(context),
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
                  color: ThemeHelpers.getPrimaryTextColor(context),
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
        color: ThemeHelpers.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: 4),
          Text(
            value,
            style: TextStyle(
              color: ThemeHelpers.getPrimaryTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
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
            child: Text(
              label,
              style: TextStyle(
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}-${d.month}-${d.year}';
  // All calculations now come from the facade month panchang for consistency.
}
