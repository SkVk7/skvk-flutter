/// Calendar Week View Widget
///
/// A week view widget for the calendar with Hindu traditional styling
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/design_system/design_system.dart';

class CalendarWeekView extends StatelessWidget {
  const CalendarWeekView({
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
    this.showFestivals = true,
    this.showAuspiciousTimes = true,
  });
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool showFestivals;
  final bool showAuspiciousTimes;

  @override
  Widget build(BuildContext context) {
    final startOfWeek = _getStartOfWeek(selectedDate);
    final weekDays =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      child: Column(
        children: [
          // Week Header
          _buildWeekHeader(context, weekDays),

          ResponsiveSystem.sizedBox(context, height: 16),

          // Week Days
          Expanded(
            child: ListView.builder(
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                // Use astrology library for calendar data
                const dayData = null;
                final isSelected = day.day == selectedDate.day &&
                    day.month == selectedDate.month &&
                    day.year == selectedDate.year;
                final isToday = day.day == DateTime.now().day &&
                    day.month == DateTime.now().month &&
                    day.year == DateTime.now().year;

                return _buildWeekDayCard(
                  context,
                  day,
                  dayData,
                  isSelected,
                  isToday,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(BuildContext context, List<DateTime> weekDays) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ThemeHelpers.getPrimaryGradient(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Column(
              children: [
                Text(
                  _getDayName(day.weekday),
                  style: TextStyle(
                    color: ThemeHelpers.getPrimaryTextColor(context),
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ResponsiveSystem.sizedBox(context, height: 4),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: ThemeHelpers.getPrimaryTextColor(context),
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeekDayCard(
    BuildContext context,
    DateTime day,
    Map<String, dynamic>? dayData,
    bool isSelected,
    bool isToday,
  ) {
    return GestureDetector(
      onTap: () => onDateSelected(day),
      child: Container(
        margin: ResponsiveSystem.only(context, bottom: 8),
        padding: ResponsiveSystem.all(context, baseSpacing: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.1)
              : ThemeHelpers.getSurfaceColor(context),
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
          border: Border.all(
            color: isSelected
                ? ThemeHelpers.getPrimaryColor(context)
                : (isToday
                    ? ThemeHelpers.getPrimaryColor(context)
                        .withValues(alpha: 0.5)
                    : ThemeHelpers.getPrimaryColor(context)
                        .withValues(alpha: 0.1)),
            width: isSelected
                ? ResponsiveSystem.borderWidth(context, baseWidth: 2)
                : ResponsiveSystem.borderWidth(context, baseWidth: 1),
          ),
        ),
        child: Row(
          children: [
            // Date Column
            SizedBox(
              width: ResponsiveSystem.spacing(context, baseSpacing: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: isSelected
                              ? ThemeHelpers.getPrimaryColor(context)
                              : ThemeHelpers.getPrimaryTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _getMonthName(day.month),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeHelpers.getSecondaryTextColor(context),
                        ),
                  ),
                ],
              ),
            ),

            ResponsiveSystem.sizedBox(context, width: 16),

            // Hindu Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dayData != null) ...[
                    _buildInfoRow(context, 'Tithi', '${dayData['tithi']}'),
                    _buildInfoRow(
                      context,
                      'Nakshatra',
                      '${dayData['nakshatra']}',
                    ),
                    if (showFestivals && dayData['festival'] != null)
                      _buildInfoRow(
                        context,
                        'Festival',
                        '${dayData['festival']}',
                      ),
                    if (showAuspiciousTimes && dayData['auspicious'] != null)
                      _buildInfoRow(
                        context,
                        'Auspicious',
                        '${dayData['auspicious']}',
                      ),
                  ] else ...[
                    Text(
                      'No data available',
                      style: TextStyle(
                        color: ThemeHelpers.getSecondaryTextColor(context),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Status Indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isToday
                    ? ThemeHelpers.getPrimaryColor(context)
                    : (isSelected
                        ? ThemeHelpers.getPrimaryColor(context)
                            .withValues(alpha: 0.7)
                        : Colors.transparent),
                shape: BoxShape.circle,
                border: isToday || isSelected
                    ? null
                    : Border.all(
                        color: ThemeHelpers.getSecondaryTextColor(context)
                            .withValues(alpha: 0.3),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: ResponsiveSystem.symmetric(context, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: ResponsiveSystem.spacing(context, baseSpacing: 80),
            child: Text(
              label,
              style: TextStyle(
                color: ThemeHelpers.getSecondaryTextColor(context),
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: ThemeHelpers.getPrimaryTextColor(context),
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  String _getDayName(int weekday) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[weekday - 1];
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }
}
