/// Calendar Header Widget
///
/// A header widget for the calendar screen with view selection
/// and Hindu traditional styling
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/features/calendar/calendar_enums.dart';

class CalendarHeaderWidget extends StatelessWidget {
  const CalendarHeaderWidget({
    required this.selectedDate,
    required this.currentView,
    required this.onViewChanged,
    super.key,
  });
  final DateTime selectedDate;
  final CalendarView currentView;
  final Function(CalendarView) onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: ThemeHelpers.getPrimaryGradient(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelpers.getPrimaryColor(context)
                .withValues(alpha: 76 / 255),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: ThemeHelpers.getPrimaryColor(context)
                .withValues(alpha: 51 / 255),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      padding:
          EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 24)),
      child: Column(
        children: [
          // Title and View Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hindu Calendar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ThemeHelpers.getPrimaryTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _buildViewSelector(context),
            ],
          ),

          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 20)),

          // Current Date Display
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            decoration: BoxDecoration(
              color:
                  ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.2),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 16),
                ),
                SizedBox(
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
                Text(
                  _formatDate(selectedDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ThemeHelpers.getPrimaryTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ThemeHelpers.getSurfaceColor(context).withValues(alpha: 0.2),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CalendarView.values.map((view) {
          final isSelected = currentView == view;
          return GestureDetector(
            onTap: () => onViewChanged(view),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? ThemeHelpers.getSurfaceColor(context)
                    : Colors.transparent,
                borderRadius:
                    ResponsiveSystem.circular(context, baseRadius: 16),
              ),
              child: Text(
                _getViewName(view),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? ThemeHelpers.getPrimaryColor(context)
                          : ThemeHelpers.getPrimaryTextColor(context),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getViewName(CalendarView view) {
    switch (view) {
      case CalendarView.year:
        return 'Year';
      case CalendarView.month:
        return 'Month';
      case CalendarView.week:
        return 'Week';
      case CalendarView.day:
        return 'Day';
    }
  }

  String _formatDate(DateTime date) {
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

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
