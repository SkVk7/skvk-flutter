/// Calendar Month Grid Widget
///
/// A month view widget with calendar information
/// using the day box widgets
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/ui/components/calendar/calendar_day_box.dart';

class CalendarMonthGrid extends StatefulWidget {
  const CalendarMonthGrid({
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onDateDetailRequested,
    required this.latitude,
    required this.longitude,
    super.key,
    this.ayanamsha = 'lahiri',
    this.showFestivals = true,
    this.showAuspiciousTimes = true,
    this.showCalendarInfo = true,
  });
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onDateDetailRequested;
  final double latitude;
  final double longitude;
  final String ayanamsha;
  final bool showFestivals;
  final bool showAuspiciousTimes;
  final bool showCalendarInfo;

  @override
  State<CalendarMonthGrid> createState() => _CalendarMonthGridState();
}

class _CalendarMonthGridState extends State<CalendarMonthGrid>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth =
        DateTime(widget.currentMonth.year, widget.currentMonth.month);
    final lastDayOfMonth =
        DateTime(widget.currentMonth.year, widget.currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final totalCells = firstDayOfWeek - 1 + daysInMonth;
    final weeks = (totalCells / 7).ceil();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: ResponsiveSystem.all(context, baseSpacing: 16),
          child: Column(
            children: [
              // Weekday Headers
              _buildWeekdayHeaders(context),

              ResponsiveSystem.sizedBox(context, height: 8),

              // Calendar Grid
              SizedBox(
                height:
                    weeks * ResponsiveSystem.spacing(context, baseSpacing: 60),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: weeks * 7,
                  itemBuilder: (context, index) {
                    final dayIndex = index - (firstDayOfWeek - 1);
                    if (dayIndex < 0 || dayIndex >= daysInMonth) {
                      return const SizedBox.shrink();
                    }
                    final day = dayIndex + 1;
                    final date = DateTime(
                      widget.currentMonth.year,
                      widget.currentMonth.month,
                      day,
                    );

                    return CalendarDayBox(
                      date: date,
                      selectedDate: widget.selectedDate,
                      onDateSelected: widget.onDateSelected,
                      onDateDetailRequested: widget.onDateDetailRequested,
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      ayanamsha: widget.ayanamsha,
                      showFestivals: widget.showFestivals,
                      showAuspiciousTimes: widget.showAuspiciousTimes,
                      showCalendarInfo: widget.showCalendarInfo,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Container(
            padding: ResponsiveSystem.symmetric(context, vertical: 12),
            decoration: BoxDecoration(
              color:
                  ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.1),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryColor(context),
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
