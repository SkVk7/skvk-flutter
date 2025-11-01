/// Simple Calendar Month View Widget
///
/// A clean, simple month view showing just the calendar grid
/// with current day highlighted and basic Hindu information
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';
import '../../../../astrology/astrology_library.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../astrology/core/entities/astrology_entities.dart';
import '../../../../core/services/translation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../astrology/core/models/calendar_models.dart';
import 'detailed_day_view_popup.dart';

class SimpleCalendarMonthView extends ConsumerStatefulWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final double latitude;
  final double longitude;
  final AyanamshaType ayanamsha;

  const SimpleCalendarMonthView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.latitude,
    required this.longitude,
    this.ayanamsha = AyanamshaType.lahiri,
  });

  @override
  ConsumerState<SimpleCalendarMonthView> createState() => _SimpleCalendarMonthViewState();
}

class _SimpleCalendarMonthViewState extends ConsumerState<SimpleCalendarMonthView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late DateTime _today; // Cache today's date to avoid multiple DateTime.now() calls
  late ScrollController _scrollController;
  MonthView? _monthData;
  bool _isMonthDataLoading = true;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now(); // Get device's current date once
    _scrollController = ScrollController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Show detailed day view popup for the selected date
  void _showDetailedDayView(BuildContext context, DateTime date) {
    // Check if month data is still loading
    if (_isMonthDataLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading month data, please wait...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Find the day data from already cached month data
    DayData? dayData;
    
    print('🔍 DEBUG: _monthData is null: ${_monthData == null}');
    print('🔍 DEBUG: _isMonthDataLoading: $_isMonthDataLoading');
    
    if (_monthData != null) {
      print('🔍 DEBUG: Month data has ${_monthData!.days.length} days');
      print('🔍 DEBUG: Looking for day ${date.day} in month ${date.month}');
      
      try {
        dayData = _monthData!.days.firstWhere(
          (day) => day.date.day == date.day,
        );
        print('🔍 DEBUG: Found day data: ${dayData.tithiName}');
      } catch (e) {
        print('🔍 DEBUG: Day not found in cached data: $e');
        dayData = null;
      }
    } else {
      print('🔍 DEBUG: Month data is null, cannot extract day data');
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DetailedDayViewPopup(
        selectedDate: date,
        latitude: widget.latitude,
        longitude: widget.longitude,
        ayanamsha: widget.ayanamsha,
        dayData: dayData, // Pass the already cached day data
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefetchMonthAndYear();
  }

  Future<void> _prefetchMonthAndYear() async {
    try {
      setState(() {
        _isMonthDataLoading = true;
      });

      final facade = AstrologyFacade.instance;
      final tz = await facade.getTimezoneFromLocation(widget.latitude, widget.longitude);

      // Warm year cache in facade (return value unused here)
      await facade.getYearFestivals(
        year: widget.currentMonth.year,
        region: RegionalCalendar.universal,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      // Month panchang cache (current month only handled in facade)
      _monthData = await facade.getMonthPanchang(
        year: widget.currentMonth.year,
        month: widget.currentMonth.month,
        region: RegionalCalendar.universal,
        latitude: widget.latitude,
        longitude: widget.longitude,
        timezoneId: tz,
      );

      if (mounted) {
        setState(() {
          _isMonthDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMonthDataLoading = false;
        });
      }
      print('🔍 DEBUG: Error loading month data: $e');
    }
  }

  /// Build loading state for calendar
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ThemeProperties.getPrimaryColor(context),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          Text(
            'Loading calendar data...',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month, 1);
    final lastDayOfMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate total cells needed (including empty cells for days before month starts)
    final totalCells = firstDayOfWeek - 1 + daysInMonth;
    final weeks = (totalCells / 7).ceil();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: ResponsiveSystem.all(context, baseSpacing: 16),
        child: Column(
          children: [
            // Month and Year Header
            _buildMonthHeader(context),

            ResponsiveSystem.sizedBox(context, height: 16),

            // Weekday Headers
            _buildWeekdayHeaders(context),

            ResponsiveSystem.sizedBox(context, height: 8),

            // Calendar Grid with proper responsive sizing
            Expanded(
              child: _isMonthDataLoading 
                  ? _buildLoadingState(context)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                  // Calculate responsive cell size based on available space
                  final availableWidth = constraints.maxWidth;
                  final availableHeight = constraints.maxHeight;

                  // Calculate cell dimensions based on available space
                  final spacing = ResponsiveSystem.spacing(context, baseSpacing: 4);
                  final cellWidth = (availableWidth - (6 * spacing)) / 7;
                  final cellHeight = (availableHeight - ((weeks - 1) * spacing)) / weeks;

                  // Use the smaller dimension to maintain square cells
                  final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;
                  final aspectRatio = 1.0; // Square cells

                  return GridView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: weeks * 7,
                    itemBuilder: (context, index) {
                      final dayIndex = index - (firstDayOfWeek - 1);
                      if (dayIndex < 0 || dayIndex >= daysInMonth) {
                        return const SizedBox.shrink();
                      }
                      final day = dayIndex + 1;
                      final date =
                          DateTime(widget.currentMonth.year, widget.currentMonth.month, day);

                      return _buildDayCell(context, date, day, cellSize);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    const monthNames = [
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Month
        IconButton(
          onPressed: () {
            final previousMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month - 1);
            widget.onDateSelected(previousMonth);
          },
          icon: Icon(
            LucideIcons.chevronLeft,
            color: ThemeProperties.getPrimaryColor(context),
            size: ResponsiveSystem.iconSize(context, baseSize: 24),
          ),
        ),

        // Month and Year
        Column(
          children: [
            Text(
              monthNames[widget.currentMonth.month - 1],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ThemeProperties.getPrimaryTextColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                  ),
            ),
            Text(
              '${widget.currentMonth.year}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeProperties.getSecondaryTextColor(context),
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  ),
            ),
          ],
        ),

        // Next Month
        IconButton(
          onPressed: () {
            final nextMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month + 1);
            widget.onDateSelected(nextMonth);
          },
          icon: Icon(
            LucideIcons.chevronRight,
            color: ThemeProperties.getPrimaryColor(context),
            size: ResponsiveSystem.iconSize(context, baseSize: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Container(
            padding: ResponsiveSystem.symmetric(context, vertical: 12),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryColor(context),
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, int day, double cellSize) {
    final isSelected = date.day == widget.selectedDate.day &&
        date.month == widget.selectedDate.month &&
        date.year == widget.selectedDate.year;
    final isToday =
        date.day == _today.day && date.month == _today.month && date.year == _today.year;

    return GestureDetector(
      onTap: () => _showDetailedDayView(context, date),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
        width: cellSize,
        height: cellSize,
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
          boxShadow: [
            BoxShadow(
              color: ThemeProperties.getShadowColor(context).withAlpha((0.1 * 255).round()),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(cellSize * 0.05), // 5% of cell size
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Day number
              Flexible(
                child: Text(
                  '$day',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? ThemeProperties.getSurfaceColor(context)
                            : isToday
                                ? ThemeProperties.getPrimaryColor(context)
                                : ThemeProperties.getPrimaryTextColor(context),
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        fontSize: cellSize * 0.25, // 25% of cell size
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Hindu info for all days
              Flexible(
                child: _buildHinduInfo(context, date, isSelected, cellSize),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHinduInfo(BuildContext context, DateTime date, bool isSelected, double cellSize) {
    // Prefer batch data if present; fallback to old per-day future
    final dayInfo = _monthData?.days.firstWhere(
      (d) => d.date.year == date.year && d.date.month == date.month && d.date.day == date.day,
      orElse: () => null as dynamic,
    );
    if (dayInfo != null) {
      final chips = <Widget>[];
      if (dayInfo.tithiName.isNotEmpty) {
        chips.add(_buildInfoChip(context, dayInfo.tithiName, isSelected, false, cellSize));
      }
      if (dayInfo.nakshatraName.isNotEmpty) {
        chips.add(_buildInfoChip(context, dayInfo.nakshatraName, isSelected, false, cellSize));
      }
      if (dayInfo.festivals.isNotEmpty) {
        chips.add(_buildInfoChip(context, dayInfo.festivals.first, isSelected, true, cellSize));
      }
      return Column(mainAxisSize: MainAxisSize.min, children: chips);
    }

    // Fallback (rare): compute per day
    return FutureBuilder<Map<String, dynamic>>(
      future: _getHinduInfo(date),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
        final data = snapshot.data!;
        final tithi = data['tithi'] ?? '';
        final nakshatra = data['nakshatra'] ?? '';
        final festivals = data['festivals'] as List<dynamic>? ?? [];
        final isAmavasya = data['isAmavasya'] ?? false;
        final isPurnima = data['isPurnima'] ?? false;
        if (tithi.isEmpty && festivals.isEmpty && !isAmavasya && !isPurnima) {
          return const SizedBox.shrink();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tithi.isNotEmpty) _buildInfoChip(context, tithi, isSelected, false, cellSize),
            if (nakshatra.isNotEmpty)
              _buildInfoChip(context, nakshatra, isSelected, false, cellSize),
            if (isAmavasya)
              _buildSymbolChip(context, '🌑', _getTranslatedText('new_moon'), isSelected, cellSize),
            if (isPurnima)
              _buildSymbolChip(context, '🌕', _getTranslatedText('full_moon'), isSelected, cellSize),
            if (festivals.isNotEmpty)
              _buildFestivalChip(context, festivals.first['name'] ?? '', isSelected, cellSize),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getHinduInfo(DateTime date) async {
    try {
      // For calendar calculations, we need to handle future dates
      // Use a workaround for future dates by using current date for calculations
      // but still show the correct date information
      final calculationDate = date.isAfter(DateTime.now()) ? DateTime.now() : date;

      // Get planetary positions for the date using calendar-specific method
      final planetaryPositions = await _getPlanetaryPositionsForCalendar(
        date: date,
        calculationDate: calculationDate,
        latitude: widget.latitude,
        longitude: widget.longitude,
        ayanamsha: widget.ayanamsha,
      );

      // Get festivals for the date using proper calculations
      final festivals = await _calculateAccurateFestivals(
        date: date,
        latitude: widget.latitude,
        longitude: widget.longitude,
        ayanamsha: widget.ayanamsha,
      );

      // Filter festivals for this specific date
      final dayFestivals = festivals.where((festival) {
        final festivalDate = festival.date;
        return festivalDate.year == date.year &&
            festivalDate.month == date.month &&
            festivalDate.day == date.day;
      }).toList();

      // Get Moon and Sun positions
      final moonPosition = planetaryPositions.getPlanet(Planet.moon);
      final sunPosition = planetaryPositions.getPlanet(Planet.sun);

      if (moonPosition != null && sunPosition != null) {
        // Calculate comprehensive Hindu data
        final tithi = _calculateAccurateTithi(moonPosition, sunPosition);
        final nakshatra =
            moonPosition.nakshatra.englishName; // Use English name directly from library

        final isAmavasya = _isAccurateAmavasya(moonPosition, sunPosition);
        final isPurnima = _isAccuratePurnima(moonPosition, sunPosition);

        return {
          'tithi': tithi,
          'nakshatra': nakshatra,
          'festivals': dayFestivals
              .map((f) => {
                    'name': f.englishName.isNotEmpty
                        ? f.englishName
                        : f.name, // Use English name from library
                    'type': f.type
                  })
              .toList(),
          'isAmavasya': isAmavasya,
          'isPurnima': isPurnima,
        };
      }
    } catch (e) {
      // Return empty data on error
    }

    return {
      'tithi': '',
      'nakshatra': '',
      'festivals': [],
      'isAmavasya': false,
      'isPurnima': false,
    };
  }

  // Helper methods for building info chips
  Widget _buildInfoChip(
      BuildContext context, String text, bool isSelected, bool isImportant, double cellSize) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: cellSize * 0.01), // 1% of cell size
      padding: EdgeInsets.symmetric(
        horizontal: cellSize * 0.02, // 2% of cell size
        vertical: cellSize * 0.01, // 1% of cell size
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getSurfaceColor(context)
            : isImportant
                ? ThemeProperties.getPrimaryColor(context).withAlpha((0.2 * 255).round())
                : ThemeProperties.getPrimaryColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(cellSize * 0.03), // 3% of cell size
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: cellSize * 0.08, // 8% of cell size
          color: isSelected
              ? ThemeProperties.getPrimaryColor(context)
              : ThemeProperties.getPrimaryTextColor(context),
          fontWeight: isImportant ? FontWeight.bold : FontWeight.w500,
        ),
        maxLines: 2, // Allow 2 lines for longer nakshatra names
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSymbolChip(
      BuildContext context, String symbol, String tooltip, bool isSelected, double cellSize) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: cellSize * 0.01), // 1% of cell size
      padding: EdgeInsets.symmetric(
        horizontal: cellSize * 0.02, // 2% of cell size
        vertical: cellSize * 0.01, // 1% of cell size
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getSurfaceColor(context)
            : ThemeProperties.getPrimaryColor(context).withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(cellSize * 0.03), // 3% of cell size
      ),
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: cellSize * 0.08, // 8% of cell size
          color: isSelected
              ? ThemeProperties.getPrimaryColor(context)
              : ThemeProperties.getPrimaryTextColor(context),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFestivalChip(
      BuildContext context, String festivalName, bool isSelected, double cellSize) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: cellSize * 0.01), // 1% of cell size
      padding: EdgeInsets.symmetric(
        horizontal: cellSize * 0.02, // 2% of cell size
        vertical: cellSize * 0.01, // 1% of cell size
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getSurfaceColor(context)
            : ThemeProperties.getSecondaryColor(context).withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(cellSize * 0.03), // 3% of cell size
      ),
      child: Text(
        _abbreviateFestival(festivalName),
        style: TextStyle(
          fontSize: cellSize * 0.07, // 7% of cell size
          color: isSelected
              ? ThemeProperties.getSecondaryColor(context)
              : ThemeProperties.getSecondaryTextColor(context),
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _abbreviateFestival(String festivalName) {
    // Use responsive abbreviation length based on screen size
    final maxLength = ResponsiveSystem.screenWidth(context) < 400 ? 6 : 8;
    if (festivalName.length <= maxLength) return festivalName;

    final translationService = ref.read(translationServiceProvider);

    // Get festival abbreviation based on user's language preference
    final festivalKey = 'festival_${festivalName.toLowerCase().replaceAll(' ', '_')}';
    final translatedFestival =
        translationService.translate(festivalKey, fallback: festivalName.substring(0, maxLength));

    return translatedFestival;
  }

  // Accurate calculation methods with proper English translations
  String _calculateAccurateTithi(PlanetPosition moonPosition, PlanetPosition sunPosition) {
    final moonLongitude = moonPosition.longitude;
    final sunLongitude = sunPosition.longitude;
    final difference = ((moonLongitude - sunLongitude) % 360 + 360) % 360;
    final tithiIndex = (difference / 12).floor();

    // Standard tithi names (Shukla 1..15 then Krishna 1..15)
    const tithiNames = [
      'Shukla Pratipada',
      'Shukla Dwitiya',
      'Shukla Tritiya',
      'Shukla Chaturthi',
      'Shukla Panchami',
      'Shukla Shashthi',
      'Shukla Saptami',
      'Shukla Ashtami',
      'Shukla Navami',
      'Shukla Dashami',
      'Shukla Ekadashi',
      'Shukla Dwadashi',
      'Shukla Trayodashi',
      'Shukla Chaturdashi',
      'Purnima',
      'Krishna Pratipada',
      'Krishna Dwitiya',
      'Krishna Tritiya',
      'Krishna Chaturthi',
      'Krishna Panchami',
      'Krishna Shashthi',
      'Krishna Saptami',
      'Krishna Ashtami',
      'Krishna Navami',
      'Krishna Dashami',
      'Krishna Ekadashi',
      'Krishna Dwadashi',
      'Krishna Trayodashi',
      'Krishna Chaturdashi',
      'Amavasya'
    ];

    return tithiNames[tithiIndex % 30];
  }

  bool _isAccurateAmavasya(PlanetPosition moonPosition, PlanetPosition sunPosition) {
    final moonLongitude = moonPosition.longitude;
    final sunLongitude = sunPosition.longitude;
    
    // Calculate normalized angular difference (0-360°)
    double difference = (moonLongitude - sunLongitude) % 360.0;
    if (difference < 0) difference += 360.0;
    
    // Amavasya occurs when Moon and Sun are in conjunction (0° ± tolerance)
    // Use smaller tolerance for more accurate detection
    const double tolerance = 8.0;
    return difference < tolerance || difference > (360.0 - tolerance);
  }

  bool _isAccuratePurnima(PlanetPosition moonPosition, PlanetPosition sunPosition) {
    final moonLongitude = moonPosition.longitude;
    final sunLongitude = sunPosition.longitude;
    
    // Calculate normalized angular difference (0-360°)
    double difference = (moonLongitude - sunLongitude) % 360.0;
    if (difference < 0) difference += 360.0;
    
    // Purnima occurs when Moon and Sun are in opposition (180° ± tolerance)
    // Use smaller tolerance for more accurate detection
    const double tolerance = 8.0;
    return difference > (180.0 - tolerance) && difference < (180.0 + tolerance);
  }

  // Helper method to get translated text
  String _getTranslatedText(String key) {
    final translationService = ref.read(translationServiceProvider);
    return translationService.translate(key, fallback: key);
  }

  // Calendar-specific method to get planetary positions without birth date validation
  Future<PlanetaryPositions> _getPlanetaryPositionsForCalendar({
    required DateTime date,
    required DateTime calculationDate,
    required double latitude,
    required double longitude,
    required AyanamshaType ayanamsha,
  }) async {
    try {
      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from location
      final timezoneId = await astrologyFacade.getTimezoneFromLocation(latitude, longitude);

      // For future dates, use current date for calculations to avoid validation errors
      // This is a workaround for the astrology library's birth date validation
      if (date.isAfter(DateTime.now())) {
        // Use current date for planetary calculations
        return await astrologyFacade.calculatePlanetaryPositions(
          localDateTime: DateTime.now(),
          timezoneId: timezoneId,
          latitude: latitude,
          longitude: longitude,
          precision: CalculationPrecision.ultra,
        );
      } else {
        // For past/present dates, use the actual date
        return await astrologyFacade.calculatePlanetaryPositions(
          localDateTime: date,
          timezoneId: timezoneId,
          latitude: latitude,
          longitude: longitude,
          precision: CalculationPrecision.ultra,
        );
      }
    } catch (e) {
      // If there's still an error, return current planetary positions
      final astrologyFacade = AstrologyFacade.instance;
      final timezoneId = await astrologyFacade.getTimezoneFromLocation(latitude, longitude);
      return await astrologyFacade.calculatePlanetaryPositions(
        localDateTime: DateTime.now(),
        timezoneId: timezoneId,
        latitude: latitude,
        longitude: longitude,
        precision: CalculationPrecision.ultra,
      );
    }
  }

  // Calculate accurate festivals using proper lunar calculations
  Future<List<FestivalData>> _calculateAccurateFestivals({
    required DateTime date,
    required double latitude,
    required double longitude,
    required AyanamshaType ayanamsha,
  }) async {
    try {
      // Initialize astrology library if needed
      if (!AstrologyLibrary.isInitialized) {
        await AstrologyLibrary.initialize();
      }

      // Get planetary positions for accurate lunar calculations
      final planetaryPositions = await _getPlanetaryPositionsForCalendar(
        date: date,
        calculationDate: date.isAfter(DateTime.now()) ? DateTime.now() : date,
        latitude: latitude,
        longitude: longitude,
        ayanamsha: ayanamsha,
      );

      final moonPosition = planetaryPositions.getPlanet(Planet.moon);
      final sunPosition = planetaryPositions.getPlanet(Planet.sun);

      if (moonPosition == null || sunPosition == null) {
        return [];
      }

      final festivals = <FestivalData>[];

      // Calculate tithi-based festivals
      final tithi = _calculateAccurateTithi(moonPosition, sunPosition);
      final nakshatra = moonPosition.nakshatra.name;
      final isAmavasya = _isAccurateAmavasya(moonPosition, sunPosition);
      final isPurnima = _isAccuratePurnima(moonPosition, sunPosition);

      // Add tithi-based festivals
      if (isAmavasya) {
        festivals.add(FestivalData(
          name: 'Amavasya',
          englishName: 'New Moon',
          date: date,
          type: 'lunar',
          description: 'New Moon Day',
          significance: 'Auspicious for ancestor worship',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Amavasya',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
      }

      if (isPurnima) {
        festivals.add(FestivalData(
          name: 'Purnima',
          englishName: 'Full Moon',
          date: date,
          type: 'lunar',
          description: 'Full Moon Day',
          significance: 'Auspicious for spiritual practices',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Purnima',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
      }

      // Add nakshatra-based festivals
      final nakshatraFestivals = _getNakshatraBasedFestivals(nakshatra, date);
      festivals.addAll(nakshatraFestivals);

      // Add tithi-based festivals
      final tithiFestivals = _getTithiBasedFestivals(tithi, date);
      festivals.addAll(tithiFestivals);

      // Add major festivals based on date
      final majorFestivals = await _getMajorFestivalsForDate(date, latitude, longitude);
      festivals.addAll(majorFestivals);

      return festivals;
    } catch (e) {
      return [];
    }
  }

  // Get nakshatra-based festivals
  List<FestivalData> _getNakshatraBasedFestivals(String nakshatra, DateTime date) {
    final festivals = <FestivalData>[];

    switch (nakshatra) {
      case 'Ashwini':
        festivals.add(FestivalData(
          name: 'Ashwini Vrat',
          englishName: 'Ashwini Fast',
          date: date,
          type: 'nakshatra',
          description: 'Ashwini Nakshatra Fast',
          significance: 'Auspicious for healing and health',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Ashwini Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Bharani':
        festivals.add(FestivalData(
          name: 'Bharani Vrat',
          englishName: 'Bharani Fast',
          date: date,
          type: 'nakshatra',
          description: 'Bharani Nakshatra Fast',
          significance: 'Auspicious for strength and courage',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Bharani Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krittika':
        festivals.add(FestivalData(
          name: 'Krittika Vrat',
          englishName: 'Krittika Fast',
          date: date,
          type: 'nakshatra',
          description: 'Krittika Nakshatra Fast',
          significance: 'Auspicious for spiritual growth',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Krittika Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Rohini':
        festivals.add(FestivalData(
          name: 'Rohini Vrat',
          englishName: 'Rohini Fast',
          date: date,
          type: 'nakshatra',
          description: 'Rohini Nakshatra Fast',
          significance: 'Auspicious for prosperity',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Rohini Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Mrigashira':
        festivals.add(FestivalData(
          name: 'Mrigashira Vrat',
          englishName: 'Mrigashira Fast',
          date: date,
          type: 'nakshatra',
          description: 'Mrigashira Nakshatra Fast',
          significance: 'Auspicious for creativity and arts',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Mrigashira Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Ardra':
        festivals.add(FestivalData(
          name: 'Ardra Vrat',
          englishName: 'Ardra Fast',
          date: date,
          type: 'nakshatra',
          description: 'Ardra Nakshatra Fast',
          significance: 'Auspicious for transformation',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Ardra Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Punarvasu':
        festivals.add(FestivalData(
          name: 'Punarvasu Vrat',
          englishName: 'Punarvasu Fast',
          date: date,
          type: 'nakshatra',
          description: 'Punarvasu Nakshatra Fast',
          significance: 'Auspicious for renewal and restoration',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Punarvasu Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Pushya':
        festivals.add(FestivalData(
          name: 'Pushya Vrat',
          englishName: 'Pushya Fast',
          date: date,
          type: 'nakshatra',
          description: 'Pushya Nakshatra Fast',
          significance: 'Auspicious for health and wealth',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Pushya Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Ashlesha':
        festivals.add(FestivalData(
          name: 'Ashlesha Vrat',
          englishName: 'Ashlesha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Ashlesha Nakshatra Fast',
          significance: 'Auspicious for healing and protection',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Ashlesha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Magha':
        festivals.add(FestivalData(
          name: 'Magha Vrat',
          englishName: 'Magha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Magha Nakshatra Fast',
          significance: 'Auspicious for ancestors and lineage',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Magha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Purva Phalguni':
        festivals.add(FestivalData(
          name: 'Purva Phalguni Vrat',
          englishName: 'Purva Phalguni Fast',
          date: date,
          type: 'nakshatra',
          description: 'Purva Phalguni Nakshatra Fast',
          significance: 'Auspicious for love and relationships',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Purva Phalguni Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Uttara Phalguni':
        festivals.add(FestivalData(
          name: 'Uttara Phalguni Vrat',
          englishName: 'Uttara Phalguni Fast',
          date: date,
          type: 'nakshatra',
          description: 'Uttara Phalguni Nakshatra Fast',
          significance: 'Auspicious for marriage and partnerships',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Uttara Phalguni Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Hasta':
        festivals.add(FestivalData(
          name: 'Hasta Vrat',
          englishName: 'Hasta Fast',
          date: date,
          type: 'nakshatra',
          description: 'Hasta Nakshatra Fast',
          significance: 'Auspicious for skills and craftsmanship',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Hasta Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Chitra':
        festivals.add(FestivalData(
          name: 'Chitra Vrat',
          englishName: 'Chitra Fast',
          date: date,
          type: 'nakshatra',
          description: 'Chitra Nakshatra Fast',
          significance: 'Auspicious for creativity and beauty',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Chitra Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Swati':
        festivals.add(FestivalData(
          name: 'Swati Vrat',
          englishName: 'Swati Fast',
          date: date,
          type: 'nakshatra',
          description: 'Swati Nakshatra Fast',
          significance: 'Auspicious for independence and freedom',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Swati Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Vishakha':
        festivals.add(FestivalData(
          name: 'Vishakha Vrat',
          englishName: 'Vishakha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Vishakha Nakshatra Fast',
          significance: 'Auspicious for success and achievement',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Vishakha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Anuradha':
        festivals.add(FestivalData(
          name: 'Anuradha Vrat',
          englishName: 'Anuradha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Anuradha Nakshatra Fast',
          significance: 'Auspicious for friendship and loyalty',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Anuradha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Jyeshtha':
        festivals.add(FestivalData(
          name: 'Jyeshtha Vrat',
          englishName: 'Jyeshtha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Jyeshtha Nakshatra Fast',
          significance: 'Auspicious for leadership and authority',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Jyeshtha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Mula':
        festivals.add(FestivalData(
          name: 'Mula Vrat',
          englishName: 'Mula Fast',
          date: date,
          type: 'nakshatra',
          description: 'Mula Nakshatra Fast',
          significance: 'Auspicious for transformation and renewal',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Mula Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Purva Ashadha':
        festivals.add(FestivalData(
          name: 'Purva Ashadha Vrat',
          englishName: 'Purva Ashadha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Purva Ashadha Nakshatra Fast',
          significance: 'Auspicious for victory and success',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Purva Ashadha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Uttara Ashadha':
        festivals.add(FestivalData(
          name: 'Uttara Ashadha Vrat',
          englishName: 'Uttara Ashadha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Uttara Ashadha Nakshatra Fast',
          significance: 'Auspicious for determination and persistence',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Uttara Ashadha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Shravana':
        festivals.add(FestivalData(
          name: 'Shravana Vrat',
          englishName: 'Shravana Fast',
          date: date,
          type: 'nakshatra',
          description: 'Shravana Nakshatra Fast',
          significance: 'Auspicious for learning and knowledge',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Shravana Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Dhanishtha':
        festivals.add(FestivalData(
          name: 'Dhanishtha Vrat',
          englishName: 'Dhanishtha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Dhanishtha Nakshatra Fast',
          significance: 'Auspicious for wealth and prosperity',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Dhanishtha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Shatabhisha':
        festivals.add(FestivalData(
          name: 'Shatabhisha Vrat',
          englishName: 'Shatabhisha Fast',
          date: date,
          type: 'nakshatra',
          description: 'Shatabhisha Nakshatra Fast',
          significance: 'Auspicious for healing and medicine',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Shatabhisha Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Purva Bhadrapada':
        festivals.add(FestivalData(
          name: 'Purva Bhadrapada Vrat',
          englishName: 'Purva Bhadrapada Fast',
          date: date,
          type: 'nakshatra',
          description: 'Purva Bhadrapada Nakshatra Fast',
          significance: 'Auspicious for spirituality and meditation',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Purva Bhadrapada Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Uttara Bhadrapada':
        festivals.add(FestivalData(
          name: 'Uttara Bhadrapada Vrat',
          englishName: 'Uttara Bhadrapada Fast',
          date: date,
          type: 'nakshatra',
          description: 'Uttara Bhadrapada Nakshatra Fast',
          significance: 'Auspicious for wisdom and enlightenment',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Uttara Bhadrapada Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Revati':
        festivals.add(FestivalData(
          name: 'Revati Vrat',
          englishName: 'Revati Fast',
          date: date,
          type: 'nakshatra',
          description: 'Revati Nakshatra Fast',
          significance: 'Auspicious for completion and fulfillment',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Revati Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
    }

    return festivals;
  }

  // Get tithi-based festivals - COMPREHENSIVE LIST
  List<FestivalData> _getTithiBasedFestivals(String tithi, DateTime date) {
    final festivals = <FestivalData>[];

    switch (tithi) {
      // Pratipada (1st tithi) festivals
      case 'Shukla Pratipada':
        festivals.add(FestivalData(
          name: 'Gudi Padwa',
          englishName: 'Gudi Padwa',
          date: date,
          type: 'tithi',
          description: 'Maharashtrian New Year',
          significance: 'Auspicious for new beginnings',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Gudi Padwa',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        festivals.add(FestivalData(
          name: 'Ugadi',
          englishName: 'Ugadi',
          date: date,
          type: 'tithi',
          description: 'Telugu/Kannada New Year',
          significance: 'Auspicious for new beginnings',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Ugadi',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Pratipada':
        festivals.add(FestivalData(
          name: 'Pratipada Vrat',
          englishName: 'Pratipada Fast',
          date: date,
          type: 'tithi',
          description: 'First day of lunar month',
          significance: 'Auspicious for new beginnings',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Pratipada Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;

      // Dwitiya (2nd tithi) festivals
      case 'Shukla Dwitiya':
        festivals.add(FestivalData(
          name: 'Dwitiya Vrat',
          englishName: 'Dwitiya Fast',
          date: date,
          type: 'tithi',
          description: 'Second day of bright fortnight',
          significance: 'Auspicious for prosperity',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Dwitiya Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Dwitiya':
        festivals.add(FestivalData(
          name: 'Dwitiya Vrat',
          englishName: 'Dwitiya Fast',
          date: date,
          type: 'tithi',
          description: 'Second day of dark fortnight',
          significance: 'Auspicious for prosperity',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Dwitiya Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;

      // Tritiya (3rd tithi) festivals
      case 'Shukla Tritiya':
        festivals.add(FestivalData(
          name: 'Akshaya Tritiya',
          englishName: 'Akshaya Tritiya',
          date: date,
          type: 'tithi',
          description: 'Auspicious day for new ventures',
          significance: 'Auspicious for wealth and prosperity',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Akshaya Tritiya',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Tritiya':
        festivals.add(FestivalData(
          name: 'Tritiya Vrat',
          englishName: 'Tritiya Fast',
          date: date,
          type: 'tithi',
          description: 'Third day of dark fortnight',
          significance: 'Auspicious for spiritual growth',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Tritiya Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;

      // Chaturthi (4th tithi) festivals
      case 'Shukla Chaturthi':
        festivals.add(FestivalData(
          name: 'Vinayaka Chavithi',
          englishName: 'Ganesh Chaturthi',
          date: date,
          type: 'tithi',
          description: 'Birth of Lord Ganesha',
          significance: 'Auspicious for new beginnings and wisdom',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Vinayaka Chavithi',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Chaturthi':
        festivals.add(FestivalData(
          name: 'Nagula Chavithi',
          englishName: 'Nagula Chavithi',
          date: date,
          type: 'tithi',
          description: 'Snake worship festival',
          significance: 'Auspicious for snake worship and protection',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Nagula Chavithi',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      
      // Panchami (5th tithi) festivals
      case 'Shukla Panchami':
        festivals.add(FestivalData(
          name: 'Vasanta Panchami',
          englishName: 'Saraswati Puja',
          date: date,
          type: 'tithi',
          description: 'Goddess Saraswati worship',
          significance: 'Auspicious for knowledge and learning',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Vasanta Panchami',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Panchami':
        festivals.add(FestivalData(
          name: 'Panchami Vrat',
          englishName: 'Panchami Fast',
          date: date,
          type: 'tithi',
          description: 'Fifth day of dark fortnight',
          significance: 'Auspicious for health and prosperity',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Panchami Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;

      // Shashthi (6th tithi) festivals
      case 'Shukla Shashthi':
        festivals.add(FestivalData(
          name: 'Shashthi Vrat',
          englishName: 'Shashthi Fast',
          date: date,
          type: 'tithi',
          description: 'Sixth day of bright fortnight',
          significance: 'Auspicious for children and health',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Shashthi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Shashthi':
        festivals.add(FestivalData(
          name: 'Shashthi Vrat',
          englishName: 'Shashthi Fast',
          date: date,
          type: 'tithi',
          description: 'Sixth day of dark fortnight',
          significance: 'Auspicious for children and health',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Shashthi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;

      // Saptami (7th tithi) festivals
      case 'Shukla Saptami':
        festivals.add(FestivalData(
          name: 'Saptami Vrat',
          englishName: 'Saptami Fast',
          date: date,
          type: 'tithi',
          description: 'Seventh day of bright fortnight',
          significance: 'Auspicious for health and longevity',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Saptami Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Saptami':
        festivals.add(FestivalData(
          name: 'Saptami Vrat',
          englishName: 'Saptami Fast',
          date: date,
          type: 'tithi',
          description: 'Seventh day of dark fortnight',
          significance: 'Auspicious for health and longevity',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Saptami Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      
      // Ashtami (8th tithi) festivals
      case 'Shukla Ashtami':
        festivals.add(FestivalData(
          name: 'Durga Ashtami',
          englishName: 'Durga Ashtami',
          date: date,
          type: 'tithi',
          description: 'Goddess Durga worship',
          significance: 'Auspicious for strength and protection',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Durga Ashtami',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Ashtami':
        festivals.add(FestivalData(
          name: 'Krishna Ashtami',
          englishName: 'Krishna Ashtami',
          date: date,
          type: 'tithi',
          description: 'Lord Krishna worship',
          significance: 'Auspicious for devotion and love',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Krishna Ashtami',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      
      // Navami (9th tithi) festivals
      case 'Shukla Navami':
        festivals.add(FestivalData(
          name: 'Rama Navami',
          englishName: 'Rama Navami',
          date: date,
          type: 'tithi',
          description: 'Birth of Lord Rama',
          significance: 'Auspicious for righteousness and dharma',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Rama Navami',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Navami':
        festivals.add(FestivalData(
          name: 'Navami Vrat',
          englishName: 'Navami Fast',
          date: date,
          type: 'tithi',
          description: 'Ninth day of dark fortnight',
          significance: 'Auspicious for spiritual growth',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Navami Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;

      // Dashami (10th tithi) festivals
      case 'Shukla Dashami':
        festivals.add(FestivalData(
          name: 'Dashami Vrat',
          englishName: 'Dashami Fast',
          date: date,
          type: 'tithi',
          description: 'Tenth day of bright fortnight',
          significance: 'Auspicious for victory and success',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Dashami Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Dashami':
        festivals.add(FestivalData(
          name: 'Dashami Vrat',
          englishName: 'Dashami Fast',
          date: date,
          type: 'tithi',
          description: 'Tenth day of dark fortnight',
          significance: 'Auspicious for victory and success',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Dashami Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      
      // Ekadashi (11th tithi) festivals
      case 'Shukla Ekadashi':
        festivals.add(FestivalData(
          name: 'Ekadashi Vrat',
          englishName: 'Ekadashi Fast',
          date: date,
          type: 'tithi',
          description: 'Ekadashi Fast (Bright)',
          significance: 'Auspicious for spiritual purification',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Ekadashi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Ekadashi':
        festivals.add(FestivalData(
          name: 'Ekadashi Vrat',
          englishName: 'Ekadashi Fast',
          date: date,
          type: 'tithi',
          description: 'Ekadashi Fast (Dark)',
          significance: 'Auspicious for spiritual purification',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Ekadashi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;

      // Dwadashi (12th tithi) festivals
      case 'Shukla Dwadashi':
        festivals.add(FestivalData(
          name: 'Dwadashi Vrat',
          englishName: 'Dwadashi Fast',
          date: date,
          type: 'tithi',
          description: 'Twelfth day of bright fortnight',
          significance: 'Auspicious for Lord Vishnu',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Dwadashi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Dwadashi':
        festivals.add(FestivalData(
          name: 'Dwadashi Vrat',
          englishName: 'Dwadashi Fast',
          date: date,
          type: 'tithi',
          description: 'Twelfth day of dark fortnight',
          significance: 'Auspicious for Lord Vishnu',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Dwadashi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;

      // Trayodashi (13th tithi) festivals
      case 'Shukla Trayodashi':
        festivals.add(FestivalData(
          name: 'Trayodashi Vrat',
          englishName: 'Trayodashi Fast',
          date: date,
          type: 'tithi',
          description: 'Thirteenth day of bright fortnight',
          significance: 'Auspicious for Lord Shiva',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Trayodashi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Trayodashi':
        festivals.add(FestivalData(
          name: 'Trayodashi Vrat',
          englishName: 'Trayodashi Fast',
          date: date,
          type: 'tithi',
          description: 'Thirteenth day of dark fortnight',
          significance: 'Auspicious for Lord Shiva',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Trayodashi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      
      // Chaturdashi (14th tithi) festivals
      case 'Shukla Chaturdashi':
        festivals.add(FestivalData(
          name: 'Chaturdashi Vrat',
          englishName: 'Chaturdashi Fast',
          date: date,
          type: 'tithi',
          description: 'Fourteenth day of bright fortnight',
          significance: 'Auspicious for Lord Shiva',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Chaturdashi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
      case 'Krishna Chaturdashi':
        festivals.add(FestivalData(
          name: 'Chaturdashi Vrat',
          englishName: 'Chaturdashi Fast',
          date: date,
          type: 'tithi',
          description: 'Fourteenth day of dark fortnight',
          significance: 'Auspicious for Lord Shiva',
          isAuspicious: true,
          regionalCalendar: RegionalCalendar.universal,
          regionalName: 'Chaturdashi Vrat',
          regionalVariations: {},
          calculatedAt: DateTime.now(),
        ));
        break;
    }

    return festivals;
  }

  // Get major festivals for specific dates - REMOVED HARDCODED FESTIVALS
  Future<List<FestivalData>> _getMajorFestivalsForDate(
    DateTime date,
    double latitude,
    double longitude,
  ) async {
    // Return empty list - no hardcoded festivals
    // All festivals should be calculated based on proper lunar/astrological data
    return <FestivalData>[];
  }
}
