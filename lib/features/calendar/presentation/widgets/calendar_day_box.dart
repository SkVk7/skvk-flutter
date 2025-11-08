/// Enhanced Calendar Day Box Widget
///
/// A comprehensive day box widget with detailed Hindu information
/// including tithi, nakshatra, festivals, and auspicious symbols
library;

import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

class CalendarDayBox extends StatefulWidget {
  final DateTime date;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onDateDetailRequested;
  final double latitude;
  final double longitude;
  final String ayanamsha;
  final bool showFestivals;
  final bool showAuspiciousTimes;
  final bool showCalendarInfo;

  const CalendarDayBox({
    super.key,
    required this.date,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onDateDetailRequested,
    required this.latitude,
    required this.longitude,
    this.ayanamsha = 'lahiri',
    this.showFestivals = true,
    this.showAuspiciousTimes = true,
    this.showCalendarInfo = true,
  });

  @override
  State<CalendarDayBox> createState() => _CalendarDayBoxState();
}

class _CalendarDayBoxState extends State<CalendarDayBox>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late DateTime
      _today; // Cache today's date to avoid multiple DateTime.now() calls

  Map<String, dynamic>? _calendarData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now(); // Get device's current date once
    _initializeAnimations();
    _loadCalendarData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadCalendarData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Note: There is no standalone getCalendarDay API endpoint.
      // Only getCalendarMonth and getCalendarYear exist.
      // This widget is used in calendar grids where month data is already loaded.
      // To implement standalone fetching, we would need to:
      // 1. Call getCalendarMonth API for the date's month
      // 2. Extract the specific day from the month response
      // This is inefficient for individual day boxes in a grid, so it's not implemented.
      // The parent calendar_month_view already loads month data and extracts day info.
      setState(() {
        _calendarData = {
          'tithi': 'Not available',
          'nakshatra': 'Not available',
          'paksha': 'Not available',
          'yoga': 'Not available',
          'karana': 'Not available',
          'festivals': <Map<String, dynamic>>[],
          'isAmavasya': false,
          'isPurnima': false,
          'sunrise': null,
          'sunset': null,
          'moonrise': null,
          'moonset': null,
        };
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.date.day == widget.selectedDate.day &&
        widget.date.month == widget.selectedDate.month &&
        widget.date.year == widget.selectedDate.year;
    final isToday = widget.date.day == _today.day &&
        widget.date.month == _today.month &&
        widget.date.year == _today.year;

    return GestureDetector(
      onTap: () => widget.onDateSelected(widget.date),
      onLongPress: () => widget.onDateDetailRequested(widget.date),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildDayBox(context, isSelected, isToday),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayBox(BuildContext context, bool isSelected, bool isToday) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getPrimaryColor(context)
            : isToday
                ? ThemeProperties.getPrimaryColor(context)
                    .withAlpha((0.2 * 255).round())
                : ThemeProperties.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: isSelected
              ? ThemeProperties.getPrimaryColor(context)
              : isToday
                  ? ThemeProperties.getPrimaryColor(context)
                  : ThemeProperties.getSecondaryTextColor(context)
                      .withAlpha((0.3 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: ThemeProperties.getPrimaryColor(context)
                      .withAlpha((0.3 * 255).round()),
                  blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  offset: Offset(
                      0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            _buildDayNumber(context, isSelected, isToday),

            ResponsiveSystem.sizedBox(context, height: 2),

            // Calendar information
            if (widget.showCalendarInfo && !_isLoading && _calendarData != null)
              _buildCalendarInfo(context, isSelected, isToday),

            // Festival symbols
            if (widget.showFestivals && !_isLoading && _calendarData != null)
              _buildFestivalSymbols(context),

            // Amavasya/Purnima symbols
            if (!_isLoading && _calendarData != null)
              _buildLunarSymbols(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDayNumber(BuildContext context, bool isSelected, bool isToday) {
    return Text(
      '${widget.date.day}',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? ThemeProperties.getSurfaceColor(context)
                : isToday
                    ? ThemeProperties.getPrimaryColor(context)
                    : ThemeProperties.getPrimaryTextColor(context),
            fontWeight:
                isSelected || isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
          ),
    );
  }

  Widget _buildCalendarInfo(
      BuildContext context, bool isSelected, bool isToday) {
    if (_calendarData == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Tithi
        _buildInfoChip(
          context,
          _calendarData!['tithi'] ?? '',
          Icons.circle_outlined,
          isSelected,
        ),

        ResponsiveSystem.sizedBox(context, height: 1),

        // Nakshatra (abbreviated)
        _buildInfoChip(
          context,
          _getNakshatraAbbreviation(_calendarData!['nakshatra'] ?? ''),
          Icons.star_outline,
          isSelected,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
      BuildContext context, String text, IconData icon, bool isSelected) {
    return Container(
      padding: ResponsiveSystem.symmetric(
        context,
        horizontal: 2,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getSurfaceColor(context)
            : ThemeProperties.getPrimaryColor(context)
                .withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveSystem.iconSize(context, baseSize: 8),
            color: isSelected
                ? ThemeProperties.getPrimaryColor(context)
                : ThemeProperties.getPrimaryTextColor(context),
          ),
          ResponsiveSystem.sizedBox(context, width: 2),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 8),
                color: isSelected
                    ? ThemeProperties.getPrimaryColor(context)
                    : ThemeProperties.getPrimaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalSymbols(BuildContext context) {
    if (_calendarData == null || _calendarData!['festivals'] == null) {
      return const SizedBox.shrink();
    }

    final festivals =
        _calendarData!['festivals'] as List<Map<String, dynamic>>? ?? [];
    if (festivals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: ResponsiveSystem.symmetric(context, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: festivals.take(2).map((festival) {
          final festivalName = festival['name'] as String? ?? 'Festival';
          return Container(
            margin: ResponsiveSystem.symmetric(context, horizontal: 1),
            child: _getFestivalSymbol(festivalName),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLunarSymbols(BuildContext context) {
    if (_calendarData == null) return const SizedBox.shrink();

    final isAmavasya = _calendarData!['isAmavasya'] as bool? ?? false;
    final isPurnima = _calendarData!['isPurnima'] as bool? ?? false;

    if (!isAmavasya && !isPurnima) return const SizedBox.shrink();

    return Container(
      margin: ResponsiveSystem.symmetric(context, vertical: 1),
      child: Icon(
        isAmavasya ? Icons.dark_mode : Icons.light_mode,
        size: ResponsiveSystem.iconSize(context, baseSize: 10),
        color: isAmavasya
            ? ThemeProperties.getSecondaryTextColor(context)
            : ThemeProperties.getPrimaryColor(context),
      ),
    );
  }

  Widget _getFestivalSymbol(String festivalName) {
    // Map festival names to appropriate symbols
    final symbolMap = {
      'Diwali': Icons.lightbulb,
      'Holi': Icons.color_lens,
      'Dussehra': Icons.sports_martial_arts,
      'Janmashtami': Icons.music_note,
      'Navratri': Icons.star,
      'Karva Chauth': Icons.favorite,
      'Raksha Bandhan': Icons.volunteer_activism,
      'Ganesh Chaturthi': Icons.pets,
      'Ram Navami': Icons.temple_hindu,
      'Hanuman Jayanti': Icons.pets,
      'Maha Shivratri': Icons.temple_hindu,
    };

    final symbol = symbolMap.entries
        .firstWhere(
          (entry) =>
              festivalName.toLowerCase().contains(entry.key.toLowerCase()),
          orElse: () => const MapEntry('default', Icons.celebration),
        )
        .value;

    return Icon(
      symbol,
      size: ResponsiveSystem.iconSize(context, baseSize: 8),
      color: ThemeProperties.getPrimaryColor(context),
    );
  }

  String _getNakshatraAbbreviation(String nakshatra) {
    // Return first 3 characters of nakshatra name
    if (nakshatra.length <= 3) return nakshatra;
    return nakshatra.substring(0, 3);
  }
}
