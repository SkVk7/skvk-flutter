/// Calendar Navigation Widget
///
/// Navigation controls for the calendar with Hindu traditional styling
library;

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/calendar_enums.dart';
import '../../../../core/design_system/design_system.dart';

class CalendarNavigationWidget extends StatelessWidget {
  final DateTime currentMonth;
  final CalendarView currentView;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const CalendarNavigationWidget({
    super.key,
    required this.currentMonth,
    required this.currentView,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          _buildNavButton(
            context,
            icon: Icons.chevron_left,
            onTap: onPrevious,
          ),

          // Current Period Display
          Expanded(
            child: Center(
              child: _buildCurrentPeriodDisplay(context),
            ),
          ),

          // Next Button
          _buildNavButton(
            context,
            icon: Icons.chevron_right,
            onTap: onNext,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeProperties.getPrimaryColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: ThemeProperties.getPrimaryColor(context),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPeriodDisplay(BuildContext context) {
    return Column(
      children: [
        Text(
          _getCurrentPeriodTitle(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          _getCurrentPeriodSubtitle(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
        ),
      ],
    );
  }

  String _getCurrentPeriodTitle() {
    switch (currentView) {
      case CalendarView.year:
        return '${currentMonth.year}';
      case CalendarView.month:
        return _getMonthName(currentMonth.month);
      case CalendarView.week:
        return 'Week ${_getWeekOfMonth(currentMonth)}';
      case CalendarView.day:
        return '${currentMonth.day}';
    }
  }

  String _getCurrentPeriodSubtitle() {
    switch (currentView) {
      case CalendarView.year:
        return 'Year View';
      case CalendarView.month:
        return '${currentMonth.year}';
      case CalendarView.week:
        return '${_getMonthName(currentMonth.month)} ${currentMonth.year}';
      case CalendarView.day:
        return '${_getMonthName(currentMonth.month)} ${currentMonth.year}';
    }
  }

  int _getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final daysDifference = date.difference(firstDayOfMonth).inDays;
    return (daysDifference / 7).floor() + 1;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
