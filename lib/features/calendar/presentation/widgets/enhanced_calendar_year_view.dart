/// Enhanced Calendar Year View Widget
///
/// A comprehensive year view showing all months with festivals,
/// sravanamas, and month-specific information
library;

import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../astrology/core/entities/astrology_entities.dart';

class EnhancedCalendarYearView extends StatefulWidget {
  final int selectedYear;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthSelected;
  final double latitude;
  final double longitude;
  final AyanamshaType ayanamsha;
  final bool showFestivals;
  final bool showAuspiciousTimes;
  final bool showHinduInfo;

  const EnhancedCalendarYearView({
    super.key,
    required this.selectedYear,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthSelected,
    required this.latitude,
    required this.longitude,
    this.ayanamsha = AyanamshaType.lahiri,
    this.showFestivals = true,
    this.showAuspiciousTimes = true,
    this.showHinduInfo = true,
  });

  @override
  State<EnhancedCalendarYearView> createState() => _EnhancedCalendarYearViewState();
}

class _EnhancedCalendarYearViewState extends State<EnhancedCalendarYearView>
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

      // Fetch batch year festivals from facade (names only, cached in facade)
      final facade = AstrologyFacade.instance;
      final yearView = await facade.getYearFestivals(
        year: widget.selectedYear,
        region: RegionalCalendar.universal,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      // Get month-specific information
      final monthInfo = <int, Map<String, dynamic>>{};
      for (int month = 1; month <= 12; month++) {
        final hinduMonth = await _getHinduMonthName(month);
        final season = await _getSeason(month);

        monthInfo[month] = {
          'hinduMonth': hinduMonth,
          'season': season,
          'specialPeriods': _getSpecialPeriods(month, const []),
          'auspiciousDays': _getAuspiciousDays(month, const []),
        };
      }

      setState(() {
        _monthFestivals = yearView.festivalsByMonth;
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

  Future<String> _getHinduMonthName(int month) async {
    try {
      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from location
      final timezoneId =
          await astrologyFacade.getTimezoneFromLocation(widget.latitude, widget.longitude);

      // Get planetary positions for the middle of the month
      final monthDate = DateTime(widget.selectedYear, month, 15);
      final planetaryPositions = await astrologyFacade.calculatePlanetaryPositions(
        localDateTime: monthDate,
        timezoneId: timezoneId,
        latitude: widget.latitude,
        longitude: widget.longitude,
        precision: CalculationPrecision.ultra,
      );

      // Calculate Hindu month based on solar position
      final sunPosition = planetaryPositions.getPlanet(Planet.sun);
      if (sunPosition != null) {
        final solarLongitude = sunPosition.longitude;
        final hinduMonth = ((solarLongitude / 30).floor() + 1) % 12;

        const hinduMonths = [
          'Chaitra',
          'Vaishakha',
          'Jyeshtha',
          'Ashadha',
          'Shravana',
          'Bhadrapada',
          'Ashwin',
          'Kartika',
          'Margashirsha',
          'Pausha',
          'Magha',
          'Phalguna'
        ];
        return hinduMonths[hinduMonth];
      }
    } catch (e) {
      // Fallback to static names if calculation fails
    }

    const hinduMonths = [
      'Chaitra',
      'Vaishakha',
      'Jyeshtha',
      'Ashadha',
      'Shravana',
      'Bhadrapada',
      'Ashwin',
      'Kartika',
      'Margashirsha',
      'Pausha',
      'Magha',
      'Phalguna'
    ];
    return hinduMonths[month - 1];
  }

  Future<String> _getSeason(int month) async {
    try {
      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from location
      final timezoneId =
          await astrologyFacade.getTimezoneFromLocation(widget.latitude, widget.longitude);

      // Get planetary positions for the middle of the month
      final monthDate = DateTime(widget.selectedYear, month, 15);
      final planetaryPositions = await astrologyFacade.calculatePlanetaryPositions(
        localDateTime: monthDate,
        timezoneId: timezoneId,
        latitude: widget.latitude,
        longitude: widget.longitude,
        precision: CalculationPrecision.ultra,
      );

      // Calculate season based on solar position
      final sunPosition = planetaryPositions.getPlanet(Planet.sun);
      if (sunPosition != null) {
        final solarLongitude = sunPosition.longitude;

        if (solarLongitude >= 0 && solarLongitude < 90) return 'Spring (Vasant)';
        if (solarLongitude >= 90 && solarLongitude < 180) return 'Summer (Grishma)';
        if (solarLongitude >= 180 && solarLongitude < 270) return 'Monsoon (Varsha)';
        return 'Winter (Shishira)';
      }
    } catch (e) {
      // Fallback to static seasons if calculation fails
    }

    if (month >= 3 && month <= 5) return 'Spring (Vasant)';
    if (month >= 6 && month <= 8) return 'Summer (Grishma)';
    if (month >= 9 && month <= 11) return 'Monsoon (Varsha)';
    return 'Winter (Shishira)';
  }

  List<String> _getSpecialPeriods(int month, List<FestivalData> festivals) {
    final specialPeriods = <String>[];

    // Check for Sravanamas (July-August)
    if (month == 7 || month == 8) {
      specialPeriods.add('Sravanamas Period');
    }

    // Check for Navratri (September-October)
    if (month == 9 || month == 10) {
      specialPeriods.add('Navratri Season');
    }

    // Check for major festivals
    final monthFestivals = festivals.where((f) => f.date.month == month).toList();
    if (monthFestivals.any((f) => f.name.toLowerCase().contains('diwali'))) {
      specialPeriods.add('Diwali Season');
    }
    if (monthFestivals.any((f) => f.name.toLowerCase().contains('holi'))) {
      specialPeriods.add('Holi Season');
    }

    return specialPeriods;
  }

  List<String> _getAuspiciousDays(int month, List<FestivalData> festivals) {
    final auspiciousDays = <String>[];
    final monthFestivals = festivals.where((f) => f.date.month == month).toList();

    for (final festival in monthFestivals) {
      if (festival.name.toLowerCase().contains('ekadashi') ||
          festival.name.toLowerCase().contains('purnima') ||
          festival.name.toLowerCase().contains('amavasya')) {
        auspiciousDays.add('${festival.date.day} - ${festival.name}');
      }
    }

    return auspiciousDays.take(3).toList(); // Limit to 3 most important
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
