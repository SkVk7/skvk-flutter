/// Calendar Month View Widget
///
/// A month view widget for the calendar with Hindu traditional styling
library;

import '../../../../core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class CalendarMonthView extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarMonthView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate total cells needed (including empty cells for days before month starts)
    final totalCells = firstDayOfWeek - 1 + daysInMonth;
    final weeks = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Weekday Headers
          _buildWeekdayHeaders(context),

          ResponsiveSystem.sizedBox(context, height: 8),

          // Calendar Grid
          SizedBox(
            height: weeks *
                ResponsiveSystem.spacing(context,
                    baseSpacing: 50), // Responsive height based on number of weeks
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: weeks * 7,
              itemBuilder: (context, index) {
                final dayIndex = index - (firstDayOfWeek - 1);
                if (dayIndex < 0 || dayIndex >= daysInMonth) {
                  return const SizedBox.shrink();
                }
                final day = dayIndex + 1;
                final date = DateTime(currentMonth.year, currentMonth.month, day);
                final isSelected = date.day == selectedDate.day &&
                    date.month == selectedDate.month &&
                    date.year == selectedDate.year;
                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;
                return _buildDayCell(context, date, day, isSelected, isToday);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Container(
            padding: ResponsiveSystem.symmetric(context, vertical: 8),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryColor(context),
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(
      BuildContext context, DateTime date, int day, bool isSelected, bool isToday) {
    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeProperties.getPrimaryColor(context)
              : isToday
                  ? ThemeProperties.getPrimaryColor(context).withAlpha((0.2 * 255).round())
                  : Colors.transparent,
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
          border: isToday && !isSelected
              ? Border.all(
                  color: ThemeProperties.getPrimaryColor(context),
                  width: ResponsiveSystem.borderWidth(context, baseWidth: 2))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? ThemeProperties.getSurfaceColor(context)
                        : isToday
                            ? ThemeProperties.getPrimaryColor(context)
                            : ThemeProperties.getPrimaryTextColor(context),
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            ResponsiveSystem.sizedBox(context, height: 2),
            _buildHinduInfo(context, date),
          ],
        ),
      ),
    );
  }

  Widget _buildHinduInfo(BuildContext context, DateTime date) {
    // For now, show basic day info without detailed Hindu calculations
    // This can be enhanced later with actual astrology library integration
    final dayOfWeek = date.weekday;
    final isWeekend = dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday;

    return Column(
      children: [
        if (isWeekend)
          Container(
            width: ResponsiveSystem.spacing(context, baseSpacing: 4),
            height: ResponsiveSystem.spacing(context, baseSpacing: 4),
            decoration: BoxDecoration(
              color: ThemeProperties.getPrimaryColor(context),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  // Removed hardcoded helpers; using computed monthly data
}
