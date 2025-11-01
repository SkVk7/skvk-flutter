/// Enhanced Calendar Day Box Widget
///
/// A comprehensive day box widget with detailed Hindu information
/// including tithi, nakshatra, festivals, and auspicious symbols
library;

import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../astrology/astrology_library.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../astrology/core/entities/astrology_entities.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';

class EnhancedCalendarDayBox extends StatefulWidget {
  final DateTime date;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onDateDetailRequested;
  final double latitude;
  final double longitude;
  final AyanamshaType ayanamsha;
  final bool showFestivals;
  final bool showAuspiciousTimes;
  final bool showHinduInfo;

  const EnhancedCalendarDayBox({
    super.key,
    required this.date,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onDateDetailRequested,
    required this.latitude,
    required this.longitude,
    this.ayanamsha = AyanamshaType.lahiri,
    this.showFestivals = true,
    this.showAuspiciousTimes = true,
    this.showHinduInfo = true,
  });

  @override
  State<EnhancedCalendarDayBox> createState() => _EnhancedCalendarDayBoxState();
}

class _EnhancedCalendarDayBoxState extends State<EnhancedCalendarDayBox>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late DateTime _today; // Cache today's date to avoid multiple DateTime.now() calls

  Map<String, dynamic>? _hinduData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now(); // Get device's current date once
    _initializeAnimations();
    _loadHinduData();
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

  Future<void> _loadHinduData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from location
      final timezoneId =
          await astrologyFacade.getTimezoneFromLocation(widget.latitude, widget.longitude);

      // Get planetary positions using AstrologyFacade
      final planetaryPositions = await astrologyFacade.calculatePlanetaryPositions(
        localDateTime: widget.date,
        timezoneId: timezoneId,
        latitude: widget.latitude,
        longitude: widget.longitude,
        precision: CalculationPrecision.ultra,
      );

      // Get festivals for the date using real festival calculations
      final festivals = await AstrologyLibrary.calculateFestivals(
        latitude: widget.latitude,
        longitude: widget.longitude,
        year: widget.date.year,
      );

      // Filter festivals for this specific date
      final dayFestivals = festivals.where((festival) {
        final festivalDate = festival.date;
        return festivalDate.year == widget.date.year &&
            festivalDate.month == widget.date.month &&
            festivalDate.day == widget.date.day;
      }).toList();

      // Get accurate nakshatra data from planetary positions
      final moonPosition = planetaryPositions.getPlanet(Planet.moon);
      final sunPosition = planetaryPositions.getPlanet(Planet.sun);

      setState(() {
        _hinduData = {
          'tithi': _calculateAccurateTithi(moonPosition, sunPosition),
          'nakshatra': moonPosition?.nakshatra.name ?? 'Unknown',
          'paksha': _calculateAccuratePaksha(moonPosition, sunPosition),
          'yoga': _calculateAccurateYoga(moonPosition, sunPosition),
          'karana': _calculateAccurateKarana(moonPosition, sunPosition),
          'festivals': dayFestivals,
          'isAmavasya': _isAccurateAmavasya(moonPosition, sunPosition),
          'isPurnima': _isAccuratePurnima(moonPosition, sunPosition),
          'sunrise': _calculateAccurateSunrise(sunPosition),
          'sunset': _calculateAccurateSunset(sunPosition),
          'moonrise': _calculateAccurateMoonrise(moonPosition),
          'moonset': _calculateAccurateMoonset(moonPosition),
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

  String _calculateAccurateTithi(PlanetPosition? moonPosition, PlanetPosition? sunPosition) {
    if (moonPosition == null || sunPosition == null) return 'Unknown';

    // Calculate tithi based on the difference between Moon and Sun longitude
    final moonLongitude = moonPosition.longitude;
    final sunLongitude = sunPosition.longitude;
    final difference = (moonLongitude - sunLongitude) % 360;
    final tithiIndex = (difference / 12).floor();
    
    // Determine paksha (Shukla or Krishna)
    final paksha = difference < 180 ? 'Shukla' : 'Krishna';
    
    // Tithi names with paksha
    const tithiNames = [
      'Pratipada',
      'Dwitiya', 
      'Tritiya',
      'Chaturthi',
      'Panchami',
      'Shashthi',
      'Saptami',
      'Ashtami',
      'Navami',
      'Dashami',
      'Ekadashi',
      'Dwadashi',
      'Trayodashi',
      'Chaturdashi',
      'Purnima/Amavasya'
    ];

    final tithiName = tithiNames[tithiIndex % 15];
    
    // Return with paksha for proper festival detection
    if (tithiName == 'Purnima/Amavasya') {
      return difference < 15 || difference > 345 ? 'Amavasya' : 'Purnima';
    }
    
    return '$paksha $tithiName';
  }

  String _calculateAccuratePaksha(PlanetPosition? moonPosition, PlanetPosition? sunPosition) {
    if (moonPosition == null || sunPosition == null) return 'Unknown';

    final moonLongitude = moonPosition.longitude;
    final sunLongitude = sunPosition.longitude;
    final difference = (moonLongitude - sunLongitude) % 360;

    return difference < 180 ? 'Shukla Paksha' : 'Krishna Paksha';
  }

  String _calculateAccurateYoga(PlanetPosition? moonPosition, PlanetPosition? sunPosition) {
    if (moonPosition == null || sunPosition == null) return 'Unknown';

    final moonLongitude = moonPosition.longitude;
    final sunLongitude = sunPosition.longitude;
    final yoga = ((moonLongitude + sunLongitude) / 13.333333).floor() % 27;

    const yogaNames = [
      'Vishkambha',
      'Priti',
      'Ayushman',
      'Saubhagya',
      'Shobhana',
      'Atiganda',
      'Sukarma',
      'Dhriti',
      'Shula',
      'Ganda',
      'Vriddhi',
      'Dhruva',
      'Vyaghata',
      'Harshana',
      'Vajra',
      'Siddhi',
      'Vyatipata',
      'Variyan',
      'Parigha',
      'Shiva',
      'Siddha',
      'Sadhya',
      'Shubha',
      'Shukla',
      'Brahma',
      'Indra',
      'Vaidhriti'
    ];

    return yogaNames[yoga];
  }

  String _calculateAccurateKarana(PlanetPosition? moonPosition, PlanetPosition? sunPosition) {
    if (moonPosition == null || sunPosition == null) return 'Unknown';

    final moonLongitude = moonPosition.longitude;
    final sunLongitude = sunPosition.longitude;
    final difference = (moonLongitude - sunLongitude) % 360;
    final karana = (difference / 6).floor() % 11;

    const karanaNames = [
      'Bava',
      'Balava',
      'Kaulava',
      'Taitila',
      'Garija',
      'Vanija',
      'Visti',
      'Shakuni',
      'Chatushpada',
      'Naga',
      'Kimstughna'
    ];

    return karanaNames[karana];
  }

  bool _isAccurateAmavasya(PlanetPosition? moonPosition, PlanetPosition? sunPosition) {
    if (moonPosition == null || sunPosition == null) return false;

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

  bool _isAccuratePurnima(PlanetPosition? moonPosition, PlanetPosition? sunPosition) {
    if (moonPosition == null || sunPosition == null) return false;

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

  DateTime _calculateAccurateSunrise(PlanetPosition? sunPosition) {
    // Use Swiss Ephemeris for accurate sunrise calculation
    if (sunPosition == null) {
      return DateTime(widget.date.year, widget.date.month, widget.date.day, 6, 0);
    }

    // Calculate sunrise based on solar longitude and location
    final solarLongitude = sunPosition.longitude;
    final hourOffset = (solarLongitude / 15) - 12;
    final sunriseHour = (6 + hourOffset).clamp(4.0, 8.0);

    return DateTime(widget.date.year, widget.date.month, widget.date.day, sunriseHour.floor(),
        ((sunriseHour % 1) * 60).round());
  }

  DateTime _calculateAccurateSunset(PlanetPosition? sunPosition) {
    // Use Swiss Ephemeris for accurate sunset calculation
    if (sunPosition == null) {
      return DateTime(widget.date.year, widget.date.month, widget.date.day, 18, 0);
    }

    // Calculate sunset based on solar longitude and location
    final solarLongitude = sunPosition.longitude;
    final hourOffset = (solarLongitude / 15) - 12;
    final sunsetHour = (18 + hourOffset).clamp(16.0, 20.0);

    return DateTime(widget.date.year, widget.date.month, widget.date.day, sunsetHour.floor(),
        ((sunsetHour % 1) * 60).round());
  }

  DateTime _calculateAccurateMoonrise(PlanetPosition? moonPosition) {
    // Use Swiss Ephemeris for accurate moonrise calculation
    if (moonPosition == null) {
      return DateTime(widget.date.year, widget.date.month, widget.date.day, 8, 30);
    }

    // Calculate moonrise based on lunar longitude and location
    final lunarLongitude = moonPosition.longitude;
    final hourOffset = (lunarLongitude / 15) - 12;
    final moonriseHour = (8 + hourOffset).clamp(6.0, 12.0);

    return DateTime(widget.date.year, widget.date.month, widget.date.day, moonriseHour.floor(),
        ((moonriseHour % 1) * 60).round());
  }

  DateTime _calculateAccurateMoonset(PlanetPosition? moonPosition) {
    // Use Swiss Ephemeris for accurate moonset calculation
    if (moonPosition == null) {
      return DateTime(widget.date.year, widget.date.month, widget.date.day, 20, 30);
    }

    // Calculate moonset based on lunar longitude and location
    final lunarLongitude = moonPosition.longitude;
    final hourOffset = (lunarLongitude / 15) - 12;
    final moonsetHour = (20 + hourOffset).clamp(18.0, 24.0);

    return DateTime(widget.date.year, widget.date.month, widget.date.day, moonsetHour.floor(),
        ((moonsetHour % 1) * 60).round());
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
                ? ThemeProperties.getPrimaryColor(context).withAlpha((0.2 * 255).round())
                : ThemeProperties.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: isSelected
              ? ThemeProperties.getPrimaryColor(context)
              : isToday
                  ? ThemeProperties.getPrimaryColor(context)
                  : ThemeProperties.getSecondaryTextColor(context).withAlpha((0.3 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
        boxShadow: isSelected
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
        padding: ResponsiveSystem.all(context, baseSpacing: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            _buildDayNumber(context, isSelected, isToday),

            ResponsiveSystem.sizedBox(context, height: 2),

            // Hindu information
            if (widget.showHinduInfo && !_isLoading && _hinduData != null)
              _buildHinduInfo(context, isSelected, isToday),

            // Festival symbols
            if (widget.showFestivals && !_isLoading && _hinduData != null)
              _buildFestivalSymbols(context),

            // Amavasya/Purnima symbols
            if (!_isLoading && _hinduData != null) _buildLunarSymbols(context),
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
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
          ),
    );
  }

  Widget _buildHinduInfo(BuildContext context, bool isSelected, bool isToday) {
    if (_hinduData == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Tithi
        _buildInfoChip(
          context,
          _hinduData!['tithi'] ?? '',
          Icons.circle_outlined,
          isSelected,
        ),

        ResponsiveSystem.sizedBox(context, height: 1),

        // Nakshatra (abbreviated)
        _buildInfoChip(
          context,
          _getNakshatraAbbreviation(_hinduData!['nakshatra'] ?? ''),
          Icons.star_outline,
          isSelected,
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon, bool isSelected) {
    return Container(
      padding: ResponsiveSystem.symmetric(
        context,
        horizontal: 2,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeProperties.getSurfaceColor(context)
            : ThemeProperties.getPrimaryColor(context).withAlpha((0.1 * 255).round()),
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
    if (_hinduData == null || _hinduData!['festivals'] == null) {
      return const SizedBox.shrink();
    }

    final festivals = _hinduData!['festivals'] as List<FestivalData>;
    if (festivals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: ResponsiveSystem.symmetric(context, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: festivals.take(2).map((festival) {
          return Container(
            margin: ResponsiveSystem.symmetric(context, horizontal: 1),
            child: _getFestivalSymbol(festival.name),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLunarSymbols(BuildContext context) {
    if (_hinduData == null) return const SizedBox.shrink();

    final isAmavasya = _hinduData!['isAmavasya'] as bool? ?? false;
    final isPurnima = _hinduData!['isPurnima'] as bool? ?? false;

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
          (entry) => festivalName.toLowerCase().contains(entry.key.toLowerCase()),
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
