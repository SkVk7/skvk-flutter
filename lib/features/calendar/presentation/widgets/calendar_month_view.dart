/// Calendar Month View Widget
///
/// A month view showing the calendar grid
/// with current day highlighted and basic calendar information
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/language/translation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'day_view_popup.dart';
import '../../../../core/services/astrology/astrology_service_bridge.dart';
import '../../../../core/services/location/simple_location_service.dart';
import '../../../../core/utils/astrology/timezone_util.dart';
import '../../../../core/services/astrology/astrology_name_service.dart';
import '../../../../core/services/language/language_service.dart';

class CalendarMonthView extends ConsumerStatefulWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final double latitude;
  final double longitude;
  final String ayanamsha;

  const CalendarMonthView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.latitude,
    required this.longitude,
    this.ayanamsha = 'lahiri',
  });

  @override
  ConsumerState<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends ConsumerState<CalendarMonthView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late DateTime
      _today; // Cache today's date to avoid multiple DateTime.now() calls
  late ScrollController _scrollController;
  Map<String, dynamic>? _monthData;
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
    Map<String, dynamic>? dayData;

    print('🔍 DEBUG: _monthData is null: ${_monthData == null}');
    print('🔍 DEBUG: _isMonthDataLoading: $_isMonthDataLoading');

    if (_monthData != null) {
      final daysRaw = _monthData!['days'];
      final days = _convertToListOfMaps(daysRaw);
      print('🔍 DEBUG: Month data has ${days.length} days');
      print('🔍 DEBUG: Looking for day ${date.day} in month ${date.month}');

      try {
        final rawDayData = days.firstWhere(
          (day) {
            final dayDate = _parseDateTime(day['date']);
            return dayDate != null &&
                dayDate.day == date.day &&
                dayDate.month == date.month;
          },
        );
        // Transform nested API response to flat structure expected by DayViewPopup
        dayData = _flattenDayData(rawDayData);
        print('🔍 DEBUG: Found day data: ${dayData['tithiName'] ?? 'N/A'}');
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
      builder: (context) => DayViewPopup(
        selectedDate: date,
        latitude: widget.latitude,
        longitude: widget.longitude,
        ayanamsha: widget.ayanamsha,
        dayData: dayData, // Pass the flattened day data
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefetchMonthAndYear();
  }

  @override
  void didUpdateWidget(CalendarMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if month or ayanamsha changed
    if (oldWidget.currentMonth.year != widget.currentMonth.year ||
        oldWidget.currentMonth.month != widget.currentMonth.month ||
        oldWidget.ayanamsha != widget.ayanamsha) {
      _prefetchMonthAndYear();
    }
  }

  Future<void> _prefetchMonthAndYear() async {
    try {
      setState(() {
        _isMonthDataLoading = true;
      });

      // Get device location with fallback to country-level location
      final locationService = SimpleLocationService();
      final locationResult =
          await locationService.getDeviceLocationWithFallback();

      if (!locationResult.isSuccess ||
          locationResult.latitude == null ||
          locationResult.longitude == null) {
        throw Exception('Failed to get location: ${locationResult.error}');
      }

      final latitude = locationResult.latitude!;
      final longitude = locationResult.longitude!;

      // Get timezone from device or use default
      await TimezoneUtil.initialize();
      final timezoneId = _getTimezoneId(latitude, longitude);

      // Get region from location or use default
      final region = widget.ayanamsha; // Use ayanamsha as region identifier

      // Fetch calendar month data from API through bridge (handles timezone conversions)
      // Ayanamsha is required for accurate nakshatra, tithi, yoga, karana calculations (sidereal zodiac)
      final bridge = AstrologyServiceBridge.instance;
      final monthData = await bridge.getCalendarMonth(
        year: widget.currentMonth.year,
        month: widget.currentMonth.month,
        region: region,
        latitude: latitude,
        longitude: longitude,
        timezoneId: timezoneId,
        ayanamsha: widget.ayanamsha, // Pass ayanamsha for accurate calculations
      );

      if (mounted) {
        setState(() {
          _monthData = monthData;
          _isMonthDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMonthDataLoading = false;
        });
      }
      debugPrint('Error loading month data: $e');
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
    final firstDayOfMonth =
        DateTime(widget.currentMonth.year, widget.currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(widget.currentMonth.year, widget.currentMonth.month + 1, 0);
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
                        final spacing =
                            ResponsiveSystem.spacing(context, baseSpacing: 4);
                        final cellWidth = (availableWidth - (6 * spacing)) / 7;
                        final cellHeight =
                            (availableHeight - ((weeks - 1) * spacing)) / weeks;

                        // Use the smaller dimension to maintain square cells
                        final cellSize =
                            cellWidth < cellHeight ? cellWidth : cellHeight;
                        final aspectRatio = 1.0; // Square cells

                        return GridView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                            final date = DateTime(widget.currentMonth.year,
                                widget.currentMonth.month, day);

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
            final previousMonth = DateTime(
                widget.currentMonth.year, widget.currentMonth.month - 1);
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
            final nextMonth = DateTime(
                widget.currentMonth.year, widget.currentMonth.month + 1);
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

  Widget _buildDayCell(
      BuildContext context, DateTime date, int day, double cellSize) {
    final isSelected = date.day == widget.selectedDate.day &&
        date.month == widget.selectedDate.month &&
        date.year == widget.selectedDate.year;
    final isToday = date.day == _today.day &&
        date.month == _today.month &&
        date.year == _today.year;

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
                    ? ThemeProperties.getPrimaryColor(context)
                        .withAlpha((0.2 * 255).round())
                    : Colors.transparent,
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
            border: isToday && !isSelected
                ? Border.all(
                    color: ThemeProperties.getPrimaryColor(context),
                    width: ResponsiveSystem.borderWidth(context, baseWidth: 2))
                : null,
            boxShadow: [
              BoxShadow(
                color: ThemeProperties.getShadowColor(context)
                    .withAlpha((0.1 * 255).round()),
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
                                  : ThemeProperties.getPrimaryTextColor(
                                      context),
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
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

  Widget _buildHinduInfo(
      BuildContext context, DateTime date, bool isSelected, double cellSize) {
    // Get current language and astrology name service
    final languagePrefs = ref.read(languageServiceProvider);
    final currentLanguage = languagePrefs.contentLanguage;
    final astrologyNameService = ref.read(astrologyNameServiceProvider);

    // Prefer batch data if present; fallback to old per-day future
    final daysRaw = _monthData?['days'];
    final days = _convertToListOfMaps(daysRaw);
    final dayInfo = days.firstWhere(
      (d) {
        final dayDate = _parseDateTime(d['date']);
        return dayDate != null &&
            dayDate.year == date.year &&
            dayDate.month == date.month &&
            dayDate.day == date.day;
      },
      orElse: () => <String, dynamic>{},
    );
    if (dayInfo.isNotEmpty) {
      final chips = <Widget>[];

      // Get raw tithi value and convert to localized name
      String tithiRaw = '';
      if (dayInfo['tithi'] is Map) {
        final tithi = dayInfo['tithi'] as Map<String, dynamic>;
        tithiRaw = tithi['name'] as String? ?? '';
      } else {
        tithiRaw = dayInfo['tithiName'] as String? ?? '';
      }
      if (tithiRaw.isNotEmpty) {
        final tithiName = astrologyNameService.getTithiNameFromString(
            tithiRaw, currentLanguage);
        if (tithiName.isNotEmpty) {
          chips.add(
              _buildInfoChip(context, tithiName, isSelected, false, cellSize));
        }
      }

      // Get raw nakshatra value and convert to localized name
      String nakshatraRaw = '';
      if (dayInfo['nakshatra'] is Map) {
        final nakshatra = dayInfo['nakshatra'] as Map<String, dynamic>;
        nakshatraRaw = nakshatra['name'] as String? ?? '';
      } else {
        nakshatraRaw = dayInfo['nakshatraName'] as String? ?? '';
      }
      if (nakshatraRaw.isNotEmpty) {
        final nakshatraName = astrologyNameService.getNakshatraNameFromString(
            nakshatraRaw, currentLanguage);
        if (nakshatraName.isNotEmpty) {
          chips.add(_buildInfoChip(
              context, nakshatraName, isSelected, false, cellSize));
        }
      }
      final festivals = dayInfo['festivals'] as List<dynamic>? ?? [];
      if (festivals.isNotEmpty) {
        final firstFestival = festivals.first as Map<String, dynamic>?;
        final festivalName = firstFestival?['name'] as String? ?? '';
        if (festivalName.isNotEmpty) {
          chips.add(_buildInfoChip(
              context, festivalName, isSelected, true, cellSize));
        }
      }
      return Column(mainAxisSize: MainAxisSize.min, children: chips);
    }

    // Fallback (rare): compute per day
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCalendarInfo(date),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null)
          return const SizedBox.shrink();
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
            if (tithi.isNotEmpty)
              _buildInfoChip(context, tithi, isSelected, false, cellSize),
            if (nakshatra.isNotEmpty)
              _buildInfoChip(context, nakshatra, isSelected, false, cellSize),
            if (isAmavasya)
              _buildSymbolChip(context, '🌑', _getTranslatedText('new_moon'),
                  isSelected, cellSize),
            if (isPurnima)
              _buildSymbolChip(context, '🌕', _getTranslatedText('full_moon'),
                  isSelected, cellSize),
            if (festivals.isNotEmpty)
              _buildFestivalChip(
                  context, festivals.first['name'] ?? '', isSelected, cellSize),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getCalendarInfo(DateTime date) async {
    try {
      // Get current language and astrology name service
      final languagePrefs = ref.read(languageServiceProvider);
      final currentLanguage = languagePrefs.contentLanguage;
      final astrologyNameService = ref.read(astrologyNameServiceProvider);

      // Use month data if available (from API)
      if (_monthData != null && _monthData!.containsKey('days')) {
        final daysRaw = _monthData!['days'];
        final days = _convertToListOfMaps(daysRaw);
        final dayData = days.firstWhere(
          (day) {
            final dayDate = _parseDateTime(day['date']);
            return dayDate != null &&
                dayDate.year == date.year &&
                dayDate.month == date.month &&
                dayDate.day == date.day;
          },
          orElse: () => <String, dynamic>{},
        );

        if (dayData.isNotEmpty) {
          // Get raw tithi and nakshatra values
          String tithiRaw = '';
          String nakshatraRaw = '';

          // Try to get from nested structure first
          if (dayData['tithi'] is Map) {
            final tithi = dayData['tithi'] as Map<String, dynamic>;
            tithiRaw = tithi['name'] as String? ?? '';
          } else {
            tithiRaw = dayData['tithiName'] as String? ??
                dayData['tithi'] as String? ??
                '';
          }

          if (dayData['nakshatra'] is Map) {
            final nakshatra = dayData['nakshatra'] as Map<String, dynamic>;
            nakshatraRaw = nakshatra['name'] as String? ?? '';
          } else {
            nakshatraRaw = dayData['nakshatraName'] as String? ??
                dayData['nakshatra'] as String? ??
                '';
          }

          // Convert to localized names
          final tithiName = tithiRaw.isNotEmpty
              ? astrologyNameService.getTithiNameFromString(
                  tithiRaw, currentLanguage)
              : '';
          final nakshatraName = nakshatraRaw.isNotEmpty
              ? astrologyNameService.getNakshatraNameFromString(
                  nakshatraRaw, currentLanguage)
              : '';

          return {
            'tithi': tithiName,
            'nakshatra': nakshatraName,
            'festivals': dayData['festivals'] ?? [],
            'isAmavasya': dayData['isAmavasya'] ?? false,
            'isPurnima': dayData['isPurnima'] ?? false,
          };
        }
      }
    } catch (e) {
      debugPrint('Error getting calendar info: $e');
    }

    // Return empty data if not found
    return {
      'tithi': '',
      'nakshatra': '',
      'festivals': [],
      'isAmavasya': false,
      'isPurnima': false,
    };
  }

  // Helper methods for building info chips
  Widget _buildInfoChip(BuildContext context, String text, bool isSelected,
      bool isImportant, double cellSize) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: cellSize * 0.01), // 1% of cell size
      padding: EdgeInsets.symmetric(
        horizontal: cellSize * 0.02, // 2% of cell size
        vertical: cellSize * 0.01, // 1% of cell size
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getSurfaceColor(context)
            : isImportant
                ? ThemeProperties.getPrimaryColor(context)
                    .withAlpha((0.2 * 255).round())
                : ThemeProperties.getPrimaryColor(context)
                    .withAlpha((0.1 * 255).round()),
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

  Widget _buildSymbolChip(BuildContext context, String symbol, String tooltip,
      bool isSelected, double cellSize) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: cellSize * 0.01), // 1% of cell size
      padding: EdgeInsets.symmetric(
        horizontal: cellSize * 0.02, // 2% of cell size
        vertical: cellSize * 0.01, // 1% of cell size
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getSurfaceColor(context)
            : ThemeProperties.getPrimaryColor(context)
                .withAlpha((0.2 * 255).round()),
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

  Widget _buildFestivalChip(BuildContext context, String festivalName,
      bool isSelected, double cellSize) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: cellSize * 0.01), // 1% of cell size
      padding: EdgeInsets.symmetric(
        horizontal: cellSize * 0.02, // 2% of cell size
        vertical: cellSize * 0.01, // 1% of cell size
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getSurfaceColor(context)
            : ThemeProperties.getSecondaryColor(context)
                .withAlpha((0.2 * 255).round()),
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
    final festivalKey =
        'festival_${festivalName.toLowerCase().replaceAll(' ', '_')}';
    final translatedFestival = translationService.translate(festivalKey,
        fallback: festivalName.substring(0, maxLength));

    return translatedFestival;
  }

  // Helper method to get translated text
  String _getTranslatedText(String key) {
    final translationService = ref.read(translationServiceProvider);
    return translationService.translate(key, fallback: key);
  }

  /// Convert List<dynamic> to List<Map<String, dynamic>>
  /// Handles web JavaScript interop where arrays come as List<dynamic>
  List<Map<String, dynamic>> _convertToListOfMaps(dynamic value) {
    if (value == null) return [];
    if (value is List<Map<String, dynamic>>) return value;
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  /// Parse DateTime from various formats (String, DateTime, etc.)
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Flatten nested API response structure to flat structure expected by DayViewPopup
  /// API returns nested objects like { tithi: { name: "..." }, nakshatra: { name: "..." } }
  /// DayViewPopup expects flat fields like { tithiName: "...", nakshatraName: "..." }
  /// Also converts numeric IDs to localized names using AstrologyNameService
  Map<String, dynamic> _flattenDayData(Map<String, dynamic> rawDayData) {
    final flattened = <String, dynamic>{};

    // Get current language and astrology name service
    final languagePrefs = ref.read(languageServiceProvider);
    final currentLanguage = languagePrefs.contentLanguage;
    final astrologyNameService = ref.read(astrologyNameServiceProvider);

    // Copy date as-is
    flattened['date'] = rawDayData['date'];

    // Extract tithi name and convert to localized name
    final tithiValue = rawDayData['tithi'];
    if (tithiValue is Map) {
      final tithi =
          Map<String, dynamic>.from(tithiValue.cast<String, dynamic>());
      final tithiNameRaw = tithi['name'] as String? ?? '';
      // Convert "Tithi 11" or "11" to localized name
      flattened['tithiName'] = astrologyNameService.getTithiNameFromString(
          tithiNameRaw, currentLanguage);
    }

    // Extract nakshatra name and convert to localized name
    final nakshatraValue = rawDayData['nakshatra'];
    if (nakshatraValue is Map) {
      final nakshatra =
          Map<String, dynamic>.from(nakshatraValue.cast<String, dynamic>());
      final nakshatraNameRaw = nakshatra['name'] as String? ?? '';
      // Convert "Nakshatra 11" or "11" to localized name
      flattened['nakshatraName'] = astrologyNameService
          .getNakshatraNameFromString(nakshatraNameRaw, currentLanguage);
    }

    // Extract yoga name and convert to localized name
    final yogaValue = rawDayData['yoga'];
    if (yogaValue is Map) {
      final yoga = Map<String, dynamic>.from(yogaValue.cast<String, dynamic>());
      final yogaNameRaw = yoga['name'] as String? ?? '';
      // Convert "Yoga 11" or "11" to localized name
      flattened['yogaName'] = astrologyNameService.getYogaNameFromString(
          yogaNameRaw, currentLanguage);
    }

    // Extract karana name and convert to localized name
    final karanaValue = rawDayData['karana'];
    if (karanaValue is Map) {
      final karana =
          Map<String, dynamic>.from(karanaValue.cast<String, dynamic>());
      final karanaNameRaw = karana['name'] as String? ?? '';
      // Convert "Karana 11" or "11" to localized name
      flattened['karanaName'] = astrologyNameService.getKaranaNameFromString(
          karanaNameRaw, currentLanguage);
    }

    // Extract paksha (if available, otherwise derive from tithi)
    if (rawDayData.containsKey('paksha')) {
      final pakshaValue = rawDayData['paksha'];
      if (pakshaValue is int) {
        flattened['pakshaName'] =
            astrologyNameService.getPakshaName(pakshaValue, currentLanguage);
      } else {
        flattened['pakshaName'] = pakshaValue.toString();
      }
    } else {
      // Derive paksha from tithi number (1-15 = Shukla, 16-30 = Krishna)
      final tithiNameRaw = flattened['tithiName'] as String? ?? '';
      if (tithiNameRaw.isNotEmpty) {
        final tithiId = astrologyNameService.extractNumericId(tithiNameRaw);
        if (tithiId != null) {
          // Normalize to 1-30 range
          final normalizedId = ((tithiId - 1) % 30) + 1;
          final pakshaId =
              normalizedId <= 15 ? 1 : 2; // 1 = Shukla, 2 = Krishna
          flattened['pakshaName'] =
              astrologyNameService.getPakshaName(pakshaId, currentLanguage);
        }
      }
    }

    // Extract sunrise time
    final sunriseValue = rawDayData['sunrise'];
    if (sunriseValue is Map) {
      final sunrise =
          Map<String, dynamic>.from(sunriseValue.cast<String, dynamic>());
      flattened['sunriseTime'] = sunrise['time'] as String? ?? '';
    }

    // Extract sunset time
    final sunsetValue = rawDayData['sunset'];
    if (sunsetValue is Map) {
      final sunset =
          Map<String, dynamic>.from(sunsetValue.cast<String, dynamic>());
      flattened['sunsetTime'] = sunset['time'] as String? ?? '';
    }

    // Extract moonrise time
    final moonriseValue = rawDayData['moonrise'];
    if (moonriseValue is Map) {
      final moonrise =
          Map<String, dynamic>.from(moonriseValue.cast<String, dynamic>());
      flattened['moonriseTime'] = moonrise['time'] as String? ?? '';
    }

    // Extract moonset time
    final moonsetValue = rawDayData['moonset'];
    if (moonsetValue is Map) {
      final moonset =
          Map<String, dynamic>.from(moonsetValue.cast<String, dynamic>());
      flattened['moonsetTime'] = moonset['time'] as String? ?? '';
    }

    // Extract festivals (already a list, but ensure each has 'name' field)
    if (rawDayData['festivals'] != null) {
      final festivalsRaw = rawDayData['festivals'];
      final festivals = _convertToListOfMaps(festivalsRaw);
      flattened['festivals'] = festivals.map((festival) {
        return {
          'name': festival['name'] as String? ?? 'Festival',
          'description': festival['description'] as String? ?? '',
        };
      }).toList();
    } else {
      flattened['festivals'] = [];
    }

    // Extract panchangam data (rahuKaal, yamaganda, gulikaKaal)
    final panchangamValue = rawDayData['panchangam'];
    if (panchangamValue is Map) {
      final panchangam =
          Map<String, dynamic>.from(panchangamValue.cast<String, dynamic>());

      // Extract rahuKaal
      final rahuKaalValue = panchangam['rahuKaal'];
      if (rahuKaalValue is Map) {
        final rahuKaal =
            Map<String, dynamic>.from(rahuKaalValue.cast<String, dynamic>());
        final start = rahuKaal['start'] as String? ?? '';
        final end = rahuKaal['end'] as String? ?? '';
        flattened['rahuKalam'] =
            start.isNotEmpty && end.isNotEmpty ? '$start - $end' : '';
      }

      // Extract yamaganda
      final yamagandaValue = panchangam['yamaganda'];
      if (yamagandaValue is Map) {
        final yamaganda =
            Map<String, dynamic>.from(yamagandaValue.cast<String, dynamic>());
        final start = yamaganda['start'] as String? ?? '';
        final end = yamaganda['end'] as String? ?? '';
        flattened['yamaGanda'] =
            start.isNotEmpty && end.isNotEmpty ? '$start - $end' : '';
      }

      // Extract gulikaKaal
      final gulikaKaalValue = panchangam['gulikaKaal'];
      if (gulikaKaalValue is Map) {
        final gulikaKaal =
            Map<String, dynamic>.from(gulikaKaalValue.cast<String, dynamic>());
        final start = gulikaKaal['start'] as String? ?? '';
        final end = gulikaKaal['end'] as String? ?? '';
        flattened['gulikaKalam'] =
            start.isNotEmpty && end.isNotEmpty ? '$start - $end' : '';
      }
    }

    return flattened;
  }
}
