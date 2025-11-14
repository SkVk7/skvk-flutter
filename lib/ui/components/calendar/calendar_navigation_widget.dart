/// Calendar Navigation Widget
///
/// Navigation controls for the calendar with Hindu traditional styling
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/constants/app_constants.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/features/calendar/calendar_enums.dart';

class CalendarNavigationWidget extends StatelessWidget {
  const CalendarNavigationWidget({
    required this.currentMonth,
    required this.currentView,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    super.key,
  });
  final DateTime currentMonth;
  final CalendarView currentView;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.1),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
          child: Padding(
            padding: ResponsiveSystem.all(context, baseSpacing: 8),
            child: Icon(
              icon,
              color: ThemeHelpers.getPrimaryColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
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
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
        ),
        ResponsiveSystem.sizedBox(context, height: 4),
        Text(
          _getCurrentPeriodSubtitle(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ThemeHelpers.getSecondaryTextColor(context),
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
    final firstDayOfMonth = DateTime(date.year, date.month);
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
      'December',
    ];
    return months[month - 1];
  }
}
