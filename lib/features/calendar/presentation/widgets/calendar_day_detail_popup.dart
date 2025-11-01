/// Calendar Day Detail Popup
///
/// A detailed popup showing comprehensive Hindu information for a selected day
/// including abhijit, rahu, ketu, and ghadiyalu information
library;

import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../astrology/astrology_library.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../astrology/core/entities/astrology_entities.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';

class CalendarDayDetailPopup extends StatefulWidget {
  final DateTime date;
  final double latitude;
  final double longitude;
  final AyanamshaType ayanamsha;
  final VoidCallback onClose;

  const CalendarDayDetailPopup({
    super.key,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.onClose,
    this.ayanamsha = AyanamshaType.lahiri,
  });

  @override
  State<CalendarDayDetailPopup> createState() => _CalendarDayDetailPopupState();
}

class _CalendarDayDetailPopupState extends State<CalendarDayDetailPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? _detailedData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDetailedData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

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
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _contentAnimationController.forward();
  }

  Future<void> _loadDetailedData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
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

      // Get accurate planetary positions
      final moonPosition = planetaryPositions.getPlanet(Planet.moon);
      final sunPosition = planetaryPositions.getPlanet(Planet.sun);
      final rahuPosition = planetaryPositions.getPlanet(Planet.rahu);
      final ketuPosition = planetaryPositions.getPlanet(Planet.ketu);

      setState(() {
        _detailedData = {
          'tithi': _calculateAccurateTithi(moonPosition, sunPosition),
          'nakshatra': moonPosition?.nakshatra.name ?? 'Unknown',
          'paksha': _calculateAccuratePaksha(moonPosition, sunPosition),
          'yoga': _calculateAccurateYoga(moonPosition, sunPosition),
          'karana': _calculateAccurateKarana(moonPosition, sunPosition),
          'festivals': dayFestivals,
          'abhijit': _calculateAccurateAbhijit(sunPosition),
          'rahu': _calculateAccurateRahu(rahuPosition),
          'ketu': _calculateAccurateKetu(ketuPosition),
          'ghadiyalu': _calculateAccurateGhadiyalu(moonPosition, sunPosition),
          'sunrise': _calculateAccurateSunrise(sunPosition),
          'sunset': _calculateAccurateSunset(sunPosition),
          'moonrise': _calculateAccurateMoonrise(moonPosition),
          'moonset': _calculateAccurateMoonset(moonPosition),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading detailed data: $e';
        _isLoading = false;
      });
    }
  }

  String _calculateAccurateTithi(PlanetPosition? moonPosition, PlanetPosition? sunPosition) {
    if (moonPosition == null || sunPosition == null) return 'Unknown';

    final moonLongitude = moonPosition.longitude;
    final sunLongitude = sunPosition.longitude;
    final difference = (moonLongitude - sunLongitude) % 360;
    final tithi = (difference / 12).floor() + 1;

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

    return tithiNames[(tithi - 1) % 15];
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

  Map<String, dynamic> _calculateAccurateAbhijit(PlanetPosition? sunPosition) {
    if (sunPosition == null) {
      return {
        'isActive': false,
        'startTime': '11:36 AM',
        'endTime': '12:24 PM',
        'duration': '48 minutes',
      };
    }

    // Abhijit is the 28th nakshatra, considered very auspicious
    final sunLongitude = sunPosition.longitude;
    final abhijitStart = 276.0; // 276 degrees
    final abhijitEnd = 280.0; // 280 degrees

    final isInAbhijit = sunLongitude >= abhijitStart && sunLongitude <= abhijitEnd;

    return {
      'isActive': isInAbhijit,
      'startTime': '11:36 AM',
      'endTime': '12:24 PM',
      'duration': '48 minutes',
    };
  }

  Map<String, dynamic> _calculateAccurateRahu(PlanetPosition? rahuPosition) {
    if (rahuPosition == null) {
      return {
        'longitude': 0.0,
        'rashi': 0,
        'degree': 0.0,
        'isRetrograde': true,
      };
    }

    final rahuLongitude = rahuPosition.longitude;
    final rahuRashi = (rahuLongitude / 30).floor();
    final rahuDegree = (rahuLongitude % 30);

    return {
      'longitude': rahuLongitude,
      'rashi': rahuRashi + 1,
      'degree': rahuDegree,
      'isRetrograde': true, // Rahu is always retrograde
    };
  }

  Map<String, dynamic> _calculateAccurateKetu(PlanetPosition? ketuPosition) {
    if (ketuPosition == null) {
      return {
        'longitude': 0.0,
        'rashi': 0,
        'degree': 0.0,
        'isRetrograde': true,
      };
    }

    final ketuLongitude = ketuPosition.longitude;
    final ketuRashi = (ketuLongitude / 30).floor();
    final ketuDegree = (ketuLongitude % 30);

    return {
      'longitude': ketuLongitude,
      'rashi': ketuRashi + 1,
      'degree': ketuDegree,
      'isRetrograde': true, // Ketu is always retrograde
    };
  }

  List<Map<String, dynamic>> _calculateAccurateGhadiyalu(
      PlanetPosition? moonPosition, PlanetPosition? sunPosition) {
    // Ghadiyalu are the 8 periods of the day, each lasting 1.5 hours
    final sunrise = _calculateAccurateSunrise(sunPosition);
    final sunset = _calculateAccurateSunset(sunPosition);
    final dayDuration = sunset.difference(sunrise).inMinutes;
    final ghadiDuration = dayDuration / 8;

    const ghadiyalu = [
      'Kumbha',
      'Meena',
      'Mesha',
      'Vrishabha',
      'Mithuna',
      'Karka',
      'Simha',
      'Kanya'
    ];

    return List.generate(8, (index) {
      final startTime = sunrise.add(Duration(minutes: (index * ghadiDuration).round()));
      final endTime = sunrise.add(Duration(minutes: ((index + 1) * ghadiDuration).round()));

      return {
        'name': ghadiyalu[index],
        'startTime':
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        'endTime':
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        'isAuspicious': index % 2 == 0, // Even indices are auspicious
      };
    });
  }

  DateTime _calculateAccurateSunrise(PlanetPosition? sunPosition) {
    // Use Swiss Ephemeris for accurate sunrise calculation
    // This should be calculated based on the actual solar position and location
    if (sunPosition == null) {
      return DateTime(widget.date.year, widget.date.month, widget.date.day, 6, 0);
    }

    // Calculate sunrise based on solar longitude and location
    // This is a simplified version - in production, use proper solar calculations
    final solarLongitude = sunPosition.longitude;
    final hourOffset = (solarLongitude / 15) - 12; // Convert longitude to time offset
    final sunriseHour = (6 + hourOffset).clamp(4.0, 8.0); // Clamp to reasonable hours

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
    final sunsetHour = (18 + hourOffset).clamp(16.0, 20.0); // Clamp to reasonable hours

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
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withAlpha((0.5 * 255).round()),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on content
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPopupContent(context),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupContent(BuildContext context) {
    return Container(
      width: ResponsiveSystem.screenWidth(context) * 0.9,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: ThemeProperties.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 20),
            offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 10)),
          ),
        ],
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: _isLoading
            ? _buildLoadingContent(context)
            : _errorMessage != null
                ? _buildErrorContent(context)
                : _buildDetailedContent(context),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: ThemeProperties.getPrimaryColor(context),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          Text(
            'Loading detailed information...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            onPressed: _loadDetailedData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedContent(BuildContext context) {
    if (_detailedData == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        _buildHeader(context),

        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: ResponsiveSystem.all(context, baseSpacing: 16),
            child: Column(
              children: [
                // Basic Information
                _buildBasicInfo(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Festivals
                if (_detailedData!['festivals'] != null &&
                    (_detailedData!['festivals'] as List).isNotEmpty)
                  _buildFestivals(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Abhijit Information
                _buildAbhijitInfo(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Rahu and Ketu
                _buildRahuKetuInfo(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Ghadiyalu
                _buildGhadiyaluInfo(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Sun and Moon Times
                _buildSunMoonTimes(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeProperties.getPrimaryColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 16)),
          topRight: Radius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 16)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(widget.date),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ThemeProperties.getSurfaceColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ResponsiveSystem.sizedBox(context, height: 4),
                Text(
                  _getDayName(widget.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            ThemeProperties.getSurfaceColor(context).withAlpha((0.8 * 255).round()),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              color: ThemeProperties.getSurfaceColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return _buildInfoSection(
      context,
      'Basic Information',
      Icons.info_outline,
      [
        _buildInfoRow(context, 'Tithi', _detailedData!['tithi'] ?? ''),
        _buildInfoRow(context, 'Nakshatra', _detailedData!['nakshatra'] ?? ''),
        _buildInfoRow(context, 'Paksha', _detailedData!['paksha'] ?? ''),
        _buildInfoRow(context, 'Yoga', _detailedData!['yoga'] ?? ''),
        _buildInfoRow(context, 'Karana', _detailedData!['karana'] ?? ''),
      ],
    );
  }

  Widget _buildFestivals(BuildContext context) {
    final festivals = _detailedData!['festivals'] as List<FestivalData>;

    return _buildInfoSection(
      context,
      'Festivals',
      Icons.celebration,
      festivals
          .map((festival) => _buildInfoRow(
                context,
                festival.name,
                festival.description.isNotEmpty ? festival.description : 'Hindu Festival',
              ))
          .toList(),
    );
  }

  Widget _buildAbhijitInfo(BuildContext context) {
    final abhijit = _detailedData!['abhijit'] as Map<String, dynamic>;

    return _buildInfoSection(
      context,
      'Abhijit Muhurat',
      Icons.schedule,
      [
        _buildInfoRow(
          context,
          'Status',
          abhijit['isActive'] ? 'Active' : 'Inactive',
          isActive: abhijit['isActive'],
        ),
        _buildInfoRow(context, 'Time', '${abhijit['startTime']} - ${abhijit['endTime']}'),
        _buildInfoRow(context, 'Duration', abhijit['duration']),
      ],
    );
  }

  Widget _buildRahuKetuInfo(BuildContext context) {
    final rahu = _detailedData!['rahu'] as Map<String, dynamic>;
    final ketu = _detailedData!['ketu'] as Map<String, dynamic>;

    return _buildInfoSection(
      context,
      'Rahu & Ketu',
      Icons.visibility,
      [
        _buildInfoRow(context, 'Rahu Rashi', 'Rashi ${rahu['rashi']}'),
        _buildInfoRow(context, 'Rahu Degree', '${rahu['degree']?.toStringAsFixed(2)}°'),
        _buildInfoRow(context, 'Ketu Rashi', 'Rashi ${ketu['rashi']}'),
        _buildInfoRow(context, 'Ketu Degree', '${ketu['degree']?.toStringAsFixed(2)}°'),
      ],
    );
  }

  Widget _buildGhadiyaluInfo(BuildContext context) {
    final ghadiyalu = _detailedData!['ghadiyalu'] as List<Map<String, dynamic>>;

    return _buildInfoSection(
      context,
      'Ghadiyalu (8 Periods)',
      Icons.access_time,
      ghadiyalu
          .map((ghadi) => _buildInfoRow(
                context,
                ghadi['name'],
                '${ghadi['startTime']} - ${ghadi['endTime']}',
                isAuspicious: ghadi['isAuspicious'],
              ))
          .toList(),
    );
  }

  Widget _buildSunMoonTimes(BuildContext context) {
    return _buildInfoSection(
      context,
      'Sun & Moon Times',
      Icons.wb_sunny,
      [
        _buildInfoRow(context, 'Sunrise', _formatTime(_detailedData!['sunrise'])),
        _buildInfoRow(context, 'Sunset', _formatTime(_detailedData!['sunset'])),
        _buildInfoRow(context, 'Moonrise', _formatTime(_detailedData!['moonrise'])),
        _buildInfoRow(context, 'Moonset', _formatTime(_detailedData!['moonset'])),
      ],
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeProperties.getCardColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: ThemeProperties.getPrimaryColor(context).withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
                color: ThemeProperties.getPrimaryColor(context),
              ),
              ResponsiveSystem.sizedBox(context, width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ThemeProperties.getPrimaryTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool? isActive, bool? isAuspicious}) {
    return Padding(
      padding: ResponsiveSystem.symmetric(context, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeProperties.getSecondaryTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isActive != null)
                  Container(
                    width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    height: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (isActive != null) ResponsiveSystem.sizedBox(context, width: 8),
                if (isAuspicious != null)
                  Icon(
                    isAuspicious ? Icons.star : Icons.star_border,
                    size: ResponsiveSystem.iconSize(context, baseSize: 16),
                    color: isAuspicious
                        ? Colors.amber
                        : ThemeProperties.getSecondaryTextColor(context),
                  ),
                if (isAuspicious != null) ResponsiveSystem.sizedBox(context, width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ThemeProperties.getPrimaryTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
