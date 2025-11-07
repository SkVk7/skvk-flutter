/// Enhanced Calendar Year View Widget
///
/// A comprehensive year view showing all months with festivals,
/// sravanamas, and month-specific information
library;

import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/astrology_service_bridge.dart';
import '../../../../core/services/simple_location_service.dart';
import '../../../../core/utils/timezone_util.dart';

class CalendarYearView extends StatefulWidget {
  final int selectedYear;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthSelected;
  final double latitude;
  final double longitude;
  final String ayanamsha;
  final bool showFestivals;
  final bool showAuspiciousTimes;
  final bool showCalendarInfo;

  const CalendarYearView({
    super.key,
    required this.selectedYear,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthSelected,
    required this.latitude,
    required this.longitude,
    this.ayanamsha = 'lahiri',
    this.showFestivals = true,
    this.showAuspiciousTimes = true,
    this.showCalendarInfo = true,
  });

  @override
  State<CalendarYearView> createState() => _CalendarYearViewState();
}

class _CalendarYearViewState extends State<CalendarYearView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<int, List<String>> _monthFestivals = {};
  Map<int, Map<String, dynamic>> _monthInfo = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadYearData();
  }

  @override
  void didUpdateWidget(CalendarYearView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if year or ayanamsha changed
    if (oldWidget.selectedYear != widget.selectedYear ||
        oldWidget.ayanamsha != widget.ayanamsha) {
      _loadYearData();
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadYearData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get device location with fallback to country-level location
      final locationService = SimpleLocationService();
      final locationResult = await locationService.getDeviceLocationWithFallback();
      
      if (!locationResult.isSuccess || locationResult.latitude == null || locationResult.longitude == null) {
        throw Exception('Failed to get location: ${locationResult.error}');
      }

      final latitude = locationResult.latitude!;
      final longitude = locationResult.longitude!;

      // Get timezone from device or use default
      await TimezoneUtil.initialize();
      final timezoneId = _getTimezoneId(latitude, longitude);

      // Get region from location or use default
      final region = widget.ayanamsha; // Use ayanamsha as region identifier

      // Fetch calendar year data from API through bridge (handles timezone conversions)
      // Ayanamsha is required for accurate nakshatra calculations (sidereal zodiac)
      final bridge = AstrologyServiceBridge.instance;
      final yearData = await bridge.getCalendarYear(
        year: widget.selectedYear,
        region: region,
        latitude: latitude,
        longitude: longitude,
        timezoneId: timezoneId,
        ayanamsha: widget.ayanamsha, // Pass ayanamsha for accurate nakshatra calculations
      );

      // Parse API response
      final monthInfo = <int, Map<String, dynamic>>{};
      final monthFestivals = <int, List<String>>{};

      if (yearData.containsKey('months')) {
        final months = yearData['months'] as Map<String, dynamic>? ?? {};
      for (int month = 1; month <= 12; month++) {
          final monthKey = month.toString();
          if (months.containsKey(monthKey)) {
            final monthData = months[monthKey] as Map<String, dynamic>;
            monthInfo[month] = {
              'monthName': monthData['monthName'] ?? 'Month $month',
              'season': monthData['season'] ?? 'Not available',
              'specialPeriods': monthData['specialPeriods'] ?? [],
              'auspiciousDays': monthData['auspiciousDays'] ?? [],
            };
            
            // Extract festivals
            if (monthData.containsKey('festivals')) {
              final festivals = monthData['festivals'] as List<dynamic>? ?? [];
              monthFestivals[month] = festivals.map((f) => f.toString()).toList();
            }
          } else {
            // Fallback: Use simple defaults if API doesn't have data
            monthInfo[month] = {
              'monthName': 'Month $month',
              'season': 'Not available',
              'specialPeriods': [],
              'auspiciousDays': [],
            };
          }
        }
      } else {
        // Fallback: Use simple defaults if API response format is unexpected
        for (int month = 1; month <= 12; month++) {
          monthInfo[month] = {
            'monthName': 'Month $month',
            'season': 'Not available',
            'specialPeriods': [],
            'auspiciousDays': [],
          };
        }
      }

      setState(() {
        _monthFestivals = monthFestivals;
        _monthInfo = monthInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading year data: $e';
        _isLoading = false;
      });
    }
  }

  /// Get timezone ID from coordinates or use default
  String _getTimezoneId(double latitude, double longitude) {
    try {
      // Try to get timezone from coordinates
      // For simplicity, use a default timezone based on longitude
      // In production, you might want to use a timezone lookup service
      final offsetHours = (longitude / 15.0).round();
      
      // Map common timezones (simplified)
      if (offsetHours >= 5 && offsetHours <= 6) {
        return 'Asia/Kolkata'; // India
      } else if (offsetHours >= -5 && offsetHours <= -4) {
        return 'America/New_York'; // US East
      } else if (offsetHours >= -8 && offsetHours <= -7) {
        return 'America/Los_Angeles'; // US West
      } else if (offsetHours >= 0 && offsetHours <= 1) {
        return 'Europe/London'; // UK
      } else if (offsetHours >= 8 && offsetHours <= 9) {
        return 'Asia/Shanghai'; // China
      } else if (offsetHours >= 9 && offsetHours <= 10) {
        return 'Asia/Tokyo'; // Japan
      }
      
      // Default to India timezone
      return 'Asia/Kolkata';
    } catch (e) {
      return 'Asia/Kolkata'; // Default fallback
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingView(context);
    }

    if (_errorMessage != null) {
      return _buildErrorView(context);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildYearGrid(context),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ThemeProperties.getPrimaryColor(context),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          Text(
            'Loading year information...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveSystem.iconSize(context, baseSize: 48),
            color: ThemeProperties.getErrorColor(context),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeProperties.getErrorColor(context),
                ),
            textAlign: TextAlign.center,
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          ElevatedButton(
            onPressed: _loadYearData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildYearGrid(BuildContext context) {
    return GridView.builder(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final monthDate = DateTime(widget.selectedYear, month);
        final isCurrentMonth =
            month == DateTime.now().month && widget.selectedYear == DateTime.now().year;
        final isSelectedMonth =
            month == widget.selectedDate.month && widget.selectedYear == widget.selectedDate.year;

        return _buildMonthCard(context, month, monthDate, isCurrentMonth, isSelectedMonth);
      },
    );
  }

  Widget _buildMonthCard(BuildContext context, int month, DateTime monthDate, bool isCurrentMonth,
      bool isSelectedMonth) {
    final monthInfo = _monthInfo[month] ?? {};
    final festivals = _monthFestivals[month] ?? [];

    return GestureDetector(
      onTap: () => widget.onMonthSelected(monthDate),
      child: Container(
        decoration: BoxDecoration(
          color: isSelectedMonth
              ? ThemeProperties.getPrimaryColor(context)
              : isCurrentMonth
                  ? ThemeProperties.getPrimaryColor(context).withAlpha((0.2 * 255).round())
                  : ThemeProperties.getSurfaceColor(context),
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
          border: Border.all(
            color: isSelectedMonth
                ? ThemeProperties.getPrimaryColor(context)
                : isCurrentMonth
                    ? ThemeProperties.getPrimaryColor(context)
                    : ThemeProperties.getSecondaryTextColor(context).withAlpha((0.3 * 255).round()),
            width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
          ),
          boxShadow: isSelectedMonth
              ? [
                  BoxShadow(
                    color: ThemeProperties.getPrimaryColor(context).withAlpha((0.3 * 255).round()),
                    blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: ResponsiveSystem.all(context, baseSpacing: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month name and year
              _buildMonthHeader(context, month, isCurrentMonth, isSelectedMonth),

              ResponsiveSystem.sizedBox(context, height: 8),

              // Hindu month name
              _buildHinduMonthName(context, monthInfo, isCurrentMonth, isSelectedMonth),

              ResponsiveSystem.sizedBox(context, height: 8),

              // Season
              _buildSeason(context, monthInfo, isCurrentMonth, isSelectedMonth),

              ResponsiveSystem.sizedBox(context, height: 8),

              // Festivals count
              _buildFestivalsInfo(context, festivals, isCurrentMonth, isSelectedMonth),

              ResponsiveSystem.sizedBox(context, height: 4),

              // Special periods
              _buildSpecialPeriods(context, monthInfo, isCurrentMonth, isSelectedMonth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(
      BuildContext context, int month, bool isCurrentMonth, bool isSelectedMonth) {
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
      'Dec'
    ];

    return Row(
      children: [
        Expanded(
          child: Text(
            monthNames[month - 1],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelectedMonth
                      ? ThemeProperties.getSurfaceColor(context)
                      : isCurrentMonth
                          ? ThemeProperties.getPrimaryColor(context)
                          : ThemeProperties.getPrimaryTextColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                ),
          ),
        ),
        Text(
          '${widget.selectedYear}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelectedMonth
                    ? ThemeProperties.getSurfaceColor(context).withAlpha((0.8 * 255).round())
                    : isCurrentMonth
                        ? ThemeProperties.getPrimaryColor(context).withAlpha((0.8 * 255).round())
                        : ThemeProperties.getSecondaryTextColor(context),
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
              ),
        ),
      ],
    );
  }

  Widget _buildHinduMonthName(BuildContext context, Map<String, dynamic> monthInfo,
      bool isCurrentMonth, bool isSelectedMonth) {
    final hinduMonth = monthInfo['hinduMonth'] as String? ?? '';

    return Text(
      hinduMonth,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelectedMonth
                ? ThemeProperties.getSurfaceColor(context).withAlpha((0.9 * 255).round())
                : isCurrentMonth
                    ? ThemeProperties.getPrimaryColor(context).withAlpha((0.9 * 255).round())
                    : ThemeProperties.getSecondaryTextColor(context),
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildSeason(BuildContext context, Map<String, dynamic> monthInfo, bool isCurrentMonth,
      bool isSelectedMonth) {
    final season = monthInfo['season'] as String? ?? '';

    return Container(
      padding: ResponsiveSystem.symmetric(context, horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelectedMonth
            ? ThemeProperties.getSurfaceColor(context).withAlpha((0.2 * 255).round())
            : ThemeProperties.getPrimaryColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
      ),
      child: Text(
        season,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelectedMonth
                  ? ThemeProperties.getSurfaceColor(context)
                  : isCurrentMonth
                      ? ThemeProperties.getPrimaryColor(context)
                      : ThemeProperties.getPrimaryTextColor(context),
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 10),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildFestivalsInfo(BuildContext context, List<String> festivals,
      bool isCurrentMonth, bool isSelectedMonth) {
    return Row(
      children: [
        Icon(
          Icons.celebration,
          size: ResponsiveSystem.iconSize(context, baseSize: 12),
          color: isSelectedMonth
              ? ThemeProperties.getSurfaceColor(context)
              : isCurrentMonth
                  ? ThemeProperties.getPrimaryColor(context)
                  : ThemeProperties.getSecondaryTextColor(context),
        ),
        ResponsiveSystem.sizedBox(context, width: 4),
        Text(
          '${festivals.length} festivals',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelectedMonth
                    ? ThemeProperties.getSurfaceColor(context)
                    : isCurrentMonth
                        ? ThemeProperties.getPrimaryColor(context)
                        : ThemeProperties.getSecondaryTextColor(context),
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 10),
              ),
        ),
      ],
    );
  }

  Widget _buildSpecialPeriods(BuildContext context, Map<String, dynamic> monthInfo,
      bool isCurrentMonth, bool isSelectedMonth) {
    final specialPeriods = monthInfo['specialPeriods'] as List<String>? ?? [];

    if (specialPeriods.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: specialPeriods.take(2).map((period) {
        return Container(
          padding: ResponsiveSystem.symmetric(context, horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isSelectedMonth
                ? ThemeProperties.getSurfaceColor(context).withAlpha((0.3 * 255).round())
                : ThemeProperties.getPrimaryColor(context).withAlpha((0.2 * 255).round()),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 4),
          ),
          child: Text(
            period,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelectedMonth
                      ? ThemeProperties.getSurfaceColor(context)
                      : isCurrentMonth
                          ? ThemeProperties.getPrimaryColor(context)
                          : ThemeProperties.getPrimaryTextColor(context),
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 8),
                  fontWeight: FontWeight.w500,
                ),
          ),
        );
      }).toList(),
    );
  }
}
