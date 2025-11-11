import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// UI Utils - Use only these for consistency
import '../utils/theme_helpers.dart';
import '../utils/responsive_system.dart';
// Core imports
import '../../core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import '../../core/navigation/hero_navigation.dart'; // For HeroNavigationWithRipple
import '../utils/screen_handlers.dart';
// UI Components - Reusable components
import '../components/common/index.dart';
import '../components/app_bar/index.dart';
import '../components/dialogs/index.dart';
// Core imports
import '../../core/services/language/translation_service.dart';
import '../../core/features/user/providers/user_provider.dart' as user_providers;
import '../../core/utils/validation/profile_completion_checker.dart';
import '../../core/utils/either.dart';
import '../../core/models/user/user_model.dart';
import '../../core/logging/logging_helper.dart';
import 'user_edit_screen.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class HoroscopeScreen extends ConsumerStatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen> {
  bool _isLoading = true;
  bool _isProfileComplete = false;
  UserModel? _user;
  Map<String, dynamic>? _birthChart;
  Map<String, dynamic>? _fixedBirthData;
  String? _errorMessage;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Clean up any resources
    super.dispose();
  }

  Future<void> _checkProfileCompletion() async {
    try {
      final userService = ref.read(user_providers.userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      final user =
          ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

      if (mounted && !_isDisposed) {
        setState(() {
          _user = user;
          _isProfileComplete =
              user != null && ProfileCompletionChecker.isProfileComplete(user);
          _isLoading = false;
        });

        // If profile is complete, generate horoscope
        if (_isProfileComplete && user != null && !_isDisposed) {
          await _generateHoroscope(user);
        }
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isProfileComplete = false;
          _isLoading = false;
          _errorMessage = 'Error loading profile: $e';
        });
      }
    }
  }

  Future<void> _generateHoroscope(UserModel user) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // First, try to get cached user birth chart data (from when user saved profile)
      final userService = ref.read(user_providers.userServiceProvider.notifier);
      Map<String, dynamic>? birthData =
          await userService.getFormattedAstrologyData();

      if (mounted && !_isDisposed) {
        setState(() {
          // Use camelCase only
          _birthChart = birthData!['birthChart'] as Map<String, dynamic>?;
          _fixedBirthData = birthData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error generating horoscope: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationService = ref.watch(translationServiceProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Ensure proper cleanup when navigating back
        if (!_isDisposed) {
          _isDisposed = true;
        }
      },
      child: _buildHoroscopeContent(translationService),
    );
  }

  Widget _buildHoroscopeContent(TranslationService translationService) {
    if (_isLoading) {
      return Scaffold(
        appBar: StandardAppBar(
          title: translationService.translateHeader('horoscope_title',
              fallback: 'Horoscope'),
          showBackButton: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: BackgroundGradients.getBackgroundGradient(
              isDark: Theme.of(context).brightness == Brightness.dark,
              isEvening: false,
              useSacredFire: false,
            ),
          ),
          child: const Center(
            child: LoadingWidget(),
          ),
        ),
      );
    }

    if (!_isProfileComplete) {
      return Scaffold(
        appBar: StandardAppBar(
          title: translationService.translateHeader('horoscope_title',
              fallback: 'Horoscope'),
          showBackButton: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: BackgroundGradients.getBackgroundGradient(
              isDark: Theme.of(context).brightness == Brightness.dark,
              isEvening: false,
              useSacredFire: false,
            ),
          ),
          child: Center(
            child: Padding(
              padding: ResponsiveSystem.all(context, baseSpacing: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add,
                    size: ResponsiveSystem.iconSize(context, baseSize: 64),
                    color: ThemeHelpers.getSecondaryTextColor(context),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 24),
                  Text(
                    translationService.translateHeader('horoscope_title',
                        fallback: 'Your Horoscope'),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 24),
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 16),
                  Text(
                    translationService.translateContent('horoscope_message',
                        fallback:
                            'Please complete your profile to view your personalized horoscope.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 24),
                  ModernButton(
                    text: translationService.translateContent(
                        'complete_profile',
                        fallback: 'Complete Profile'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
            isEvening: false,
            useSacredFire: false,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Collapsible Hero Section using SliverAppBar
            SliverAppBar(
              expandedHeight:
                  ResponsiveSystem.spacing(context, baseSpacing: 250),
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: ThemeHelpers.getTransparentColor(context),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  LucideIcons.house,
                  color: ThemeHelpers.getAppBarTextColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                // Language Dropdown Widget
                LanguageDropdown(
                  onLanguageChanged: (value) {
                    LoggingHelper.logInfo('Language changed to: $value');
                    ScreenHandlers.handleLanguageChange(ref, value);
                  },
                ),
                // Theme Dropdown Widget
                ThemeDropdown(
                  onThemeChanged: (value) {
                    LoggingHelper.logInfo('Theme changed to: $value');
                    ScreenHandlers.handleThemeChange(ref, value);
                  },
                ),
                // Profile Photo with Hover Effect
                Padding(
                  padding: ResponsiveSystem.only(
                    context,
                    right: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  ),
                  child: ProfilePhoto(
                    key: const ValueKey('profile_icon'),
                    onTap: () =>
                        _handleProfileTap(context, ref, translationService),
                    tooltip: translationService.translateContent(
                      'my_profile',
                      fallback: 'My Profile',
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  translationService.translateHeader('horoscope_title',
                      fallback: 'Horoscope'),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                background: _buildHeroSection(),
                collapseMode: CollapseMode.parallax,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveSystem.all(context, baseSpacing: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Birth Chart Information
                    if (_birthChart != null) ...[
                      _buildBirthChartInfo(),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildRasiNakshatraInfo(),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildPlanetaryPositions(),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildHousePositions(),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildAscendantInfo(),
                    ] else if (_errorMessage != null) ...[
                      ErrorDisplayWidget(
                        message: 'Error Loading Horoscope: $_errorMessage',
                        onRetry: () {
                          if (_user != null) {
                            _generateHoroscope(_user!);
                          }
                        },
                        icon: Icons.error_outline,
                      ),
                    ] else ...[
                      // Show loading state when data is being fetched
                      _buildBirthChartInfo(),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildRasiNakshatraInfo(),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildPlanetaryPositions(),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildHousePositions(),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildAscendantInfo(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthChartInfo() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Birth Chart Information',
            baseFontSize: 18,
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          Text(
            'Your birth details for accurate calculations',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          InfoRow(
            label: 'Birth Date',
            value:
                '${_user!.dateOfBirth.day}/${_user!.dateOfBirth.month}/${_user!.dateOfBirth.year}',
            icon: Icons.calendar_today,
          ),
          InfoRow(
            label: 'Birth Time',
            value:
                '${_user!.timeOfBirth.hour.toString().padLeft(2, '0')}:${_user!.timeOfBirth.minute.toString().padLeft(2, '0')}',
            icon: Icons.access_time,
          ),
          InfoRow(
            label: 'Birth Place',
            value: _user!.placeOfBirth,
            icon: Icons.location_on,
          ),
          InfoRow(
            label: 'Coordinates',
            value:
                '${_user!.latitude.toStringAsFixed(4)}°N, ${_user!.longitude.toStringAsFixed(4)}°E',
            icon: Icons.my_location,
          ),
        ],
      ),
    );
  }

  Widget _buildRasiNakshatraInfo() {
    if (_fixedBirthData == null) {
      return InfoCard(
        child: Column(
          children: [
            SectionTitle(
              title: 'Rasi & Nakshatra Information',
              baseFontSize: 18,
            ),
            ResponsiveSystem.sizedBox(context, height: 8),
            Text(
              'Your Moon sign and birth star details',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            const LoadingWidget(),
          ],
        ),
      );
    }

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Rasi & Nakshatra Information',
            baseFontSize: 18,
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          Text(
            'Your Moon sign and birth star details',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          InfoRow(
            label: 'Rasi (Moon Sign)',
            value: _getRashiOrNakshatraName(
                (_fixedBirthData!['rashi'] as Map<String, dynamic>?)),
            icon: Icons.nightlight_round,
          ),
          InfoRow(
            label: 'Nakshatra (Birth Star)',
            value: _getRashiOrNakshatraName(
                (_fixedBirthData!['nakshatra'] as Map<String, dynamic>?)),
            icon: Icons.star,
          ),
          InfoRow(
            label: 'Pada (Quarter)',
            value:
                '${(_fixedBirthData!['pada'] as Map<String, dynamic>?)?['number'] ?? 'Unknown'}',
            icon: Icons.grid_view,
          ),
          InfoRow(
            label: 'Rasi Lord',
            value: _getPlanetDisplayName((_fixedBirthData!['rashi']
                as Map<String, dynamic>?)?['lord'] as String?),
            icon: Icons.king_bed,
          ),
          InfoRow(
            label: 'Nakshatra Lord',
            value: _getPlanetDisplayName((_fixedBirthData!['nakshatra']
                as Map<String, dynamic>?)?['lord'] as String?),
            icon: Icons.star_border,
          ),
          InfoRow(
            label: 'Element',
            value: _getElementDisplayName((_fixedBirthData!['rashi']
                as Map<String, dynamic>?)?['element'] as String?),
            icon: Icons.water_drop,
          ),
          InfoRow(
            label: 'Quality',
            value: _getQualityDisplayName((_fixedBirthData!['rashi']
                as Map<String, dynamic>?)?['quality'] as String?),
            icon: Icons.speed,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetaryPositions() {
    final planetaryPositions =
        _birthChart?['planetaryPositions'] as Map<String, dynamic>?;
    if (planetaryPositions == null || planetaryPositions.isEmpty) {
      return InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  color: ThemeHelpers.getPrimaryColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Text(
                  'Your Personality & Traits',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(context, height: 12),
            Text(
              'Analyzing your personality traits...',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Your Personality & Traits',
            baseFontSize: 18,
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          Text(
            'Based on your planetary positions',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          _buildPersonalityInsight('Core Identity', _getSunInsight()),
          _buildPersonalityInsight('Emotional Nature', _getMoonInsight()),
          _buildPersonalityInsight('Energy & Drive', _getMarsInsight()),
          _buildPersonalityInsight('Wisdom & Growth', _getJupiterInsight()),
          _buildPersonalityInsight('Love & Relationships', _getVenusInsight()),
        ],
      ),
    );
  }

  Widget _buildHousePositions() {
    final houseLords = _birthChart?['houseLords'] as Map<String, dynamic>?;
    if (houseLords == null || houseLords.isEmpty) {
      return InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  color: ThemeHelpers.getPrimaryColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Text(
                  'Life Insights & Guidance',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(context, height: 12),
            Text(
              'Analyzing your life areas and current influences...',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Life Insights & Guidance',
            baseFontSize: 18,
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          Text(
            'Based on your house lords and life areas',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          _buildLifeInsight('Career & Success', _getCareerInsight()),
          _buildLifeInsight('Relationships & Love', _getMarriageInsight()),
          _buildLifeInsight('Wealth & Resources', _getWealthInsight()),
          _buildLifeInsight('Health & Wellbeing', _getHealthInsight()),
        ],
      ),
    );
  }

  Widget _buildAscendantInfo() {
    final houseLords = _birthChart?['houseLords'] as Map<String, dynamic>?;
    final ascendantLord = houseLords?['House 1'] as String?;
    if (ascendantLord == null) {
      return InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  color: ThemeHelpers.getPrimaryColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Text(
                  'Current Influences',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(context, height: 12),
            Text(
              'Analyzing current planetary influences...',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Current Influences',
            baseFontSize: 18,
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          Text(
            'Based on your rising sign and current focus',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          _buildCurrentInsight('Rising Sign', _getAscendantInsight()),
          _buildCurrentInsight('Current Focus', _getCurrentFocusInsight()),
          _buildCurrentInsight('Best Time for Action', _getBestTimeInsight()),
        ],
      ),
    );
  }

  Widget _buildPersonalityInsight(String aspect, String insight) {
    return InfoRow(
      label: aspect,
      value: insight,
      icon: Icons.psychology,
    );
  }

  Widget _buildLifeInsight(String area, String insight) {
    return InfoRow(
      label: area,
      value: insight,
      icon: Icons.trending_up,
    );
  }

  Widget _buildCurrentInsight(String aspect, String insight) {
    return InfoRow(
      label: aspect,
      value: insight,
      icon: Icons.wb_sunny,
    );
  }

  // Helper method to get planet data from planetaryPositions (camelCase)
  Map<String, dynamic>? _getPlanetData(String planetName) {
    final planetaryPositions =
        _birthChart?['planetaryPositions'] as Map<String, dynamic>?;
    return planetaryPositions?[planetName] as Map<String, dynamic>?;
  }

  // Dynamic personality insights based on actual birth chart analysis
  String _getSunInsight() {
    final sunData = _getPlanetData('Sun');
    if (sunData == null) return 'Your core identity is being calculated...';

    final sunRashi = sunData['rashi'] as String?;
    final sunHouse = sunData['house'] as int?;
    final sunNakshatra = sunData['nakshatra'] as String?;

    final sunStrength = _calculatePlanetaryStrength('sun');
    final sunAspects = _calculatePlanetaryAspects('sun');

    // Build dynamic interpretation based on actual chart data
    final sunRashiName = sunRashi ?? 'Unknown';
    String baseInterpretation = _getSunSignInterpretation(sunRashiName);
    String houseInfluence = _getHouseInfluence(sunHouse?.toString());
    String nakshatraInfluence = _getNakshatraInfluence(sunNakshatra);
    String strengthInfluence = _getStrengthInfluence(sunStrength);
    String aspectInfluence = _getAspectInfluence(sunAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  String _getMoonInsight() {
    final moonData = _getPlanetData('Moon');
    if (moonData == null) return 'Your emotional nature is being analyzed...';

    final moonRashi = moonData['rashi'] as String?;
    final moonHouse = moonData['house'] as int?;
    final moonNakshatra = moonData['nakshatra'] as String?;
    final moonStrength = _calculatePlanetaryStrength('moon');
    final moonAspects = _calculatePlanetaryAspects('moon');

    final moonRashiName = moonRashi ?? 'Unknown';
    String baseInterpretation = _getMoonSignInterpretation(moonRashiName);
    String houseInfluence = _getHouseInfluence(moonHouse?.toString());
    String nakshatraInfluence = _getNakshatraInfluence(moonNakshatra);
    String strengthInfluence = _getStrengthInfluence(moonStrength);
    String aspectInfluence = _getAspectInfluence(moonAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  String _getMarsInsight() {
    final marsData = _getPlanetData('Mars');
    if (marsData == null) return 'Your energy and drive are being assessed...';

    final marsRashi = marsData['rashi'] as String?;
    final marsHouse = marsData['house'] as int?;
    final marsNakshatra = marsData['nakshatra'] as String?;
    final marsStrength = _calculatePlanetaryStrength('mars');
    final marsAspects = _calculatePlanetaryAspects('mars');

    final marsRashiName = marsRashi ?? 'Unknown';
    String baseInterpretation = _getMarsSignInterpretation(marsRashiName);
    String houseInfluence = _getHouseInfluence(marsHouse?.toString());
    String nakshatraInfluence = _getNakshatraInfluence(marsNakshatra);
    String strengthInfluence = _getStrengthInfluence(marsStrength);
    String aspectInfluence = _getAspectInfluence(marsAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  String _getJupiterInsight() {
    final jupiterData = _getPlanetData('Jupiter');
    if (jupiterData == null)
      return 'Your wisdom and growth potential are being evaluated...';

    final jupiterRashi = jupiterData['rashi'] as String?;
    final jupiterHouse = jupiterData['house'] as int?;
    final jupiterNakshatra = jupiterData['nakshatra'] as String?;
    final jupiterStrength = _calculatePlanetaryStrength('jupiter');
    final jupiterAspects = _calculatePlanetaryAspects('jupiter');

    final jupiterRashiName = jupiterRashi ?? 'Unknown';
    String baseInterpretation = _getJupiterSignInterpretation(jupiterRashiName);
    String houseInfluence = _getHouseInfluence(jupiterHouse?.toString());
    String nakshatraInfluence = _getNakshatraInfluence(jupiterNakshatra);
    String strengthInfluence = _getStrengthInfluence(jupiterStrength);
    String aspectInfluence = _getAspectInfluence(jupiterAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  String _getVenusInsight() {
    final venusData = _getPlanetData('Venus');
    if (venusData == null)
      return 'Your love and relationship style is being analyzed...';

    final venusRashi = venusData['rashi'] as String?;
    final venusHouse = venusData['house'] as int?;
    final venusNakshatra = venusData['nakshatra'] as String?;
    final venusStrength = _calculatePlanetaryStrength('venus');
    final venusAspects = _calculatePlanetaryAspects('venus');

    final venusRashiName = venusRashi ?? 'Unknown';
    String baseInterpretation = _getVenusSignInterpretation(venusRashiName);
    String houseInfluence = _getHouseInfluence(venusHouse?.toString());
    String nakshatraInfluence = _getNakshatraInfluence(venusNakshatra);
    String strengthInfluence = _getStrengthInfluence(venusStrength);
    String aspectInfluence = _getAspectInfluence(venusAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  // Helper method to get house lord planet name
  String? _getHouseLord(int houseNumber) {
    final houseLords = _birthChart?['houseLords'] as Map<String, dynamic>?;
    final houseLord = houseLords?['House $houseNumber'] as String?;
    
    // Check if it's a valid planet name
    if (houseLord != null && _isValidPlanetName(houseLord)) {
      return houseLord;
    }
    
    // Calculate house lord from ascendant sign
    final ascendantData = _birthChart?['ascendant'] as Map<String, dynamic>?;
    final ascendantRashi = ascendantData?['rashi'] as String?;
    if (ascendantRashi != null) {
      return _calculateHouseLordFromAscendant(houseNumber, ascendantRashi);
    }
    
    return null;
  }

  // Check if string is a valid planet name
  bool _isValidPlanetName(String name) {
    const validPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];
    return validPlanets.contains(name);
  }

  // Calculate house lord from ascendant sign
  String? _calculateHouseLordFromAscendant(int houseNumber, String ascendantRashi) {
    // Map of rashi names to their lords
    const rashiLords = {
      'Aries': 'Mars',
      'Taurus': 'Venus',
      'Gemini': 'Mercury',
      'Cancer': 'Moon',
      'Leo': 'Sun',
      'Virgo': 'Mercury',
      'Libra': 'Venus',
      'Scorpio': 'Mars',
      'Sagittarius': 'Jupiter',
      'Capricorn': 'Saturn',
      'Aquarius': 'Saturn',
      'Pisces': 'Jupiter',
    };
    
    // Find the ascendant rashi index (0-11)
    const rashiNames = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 
                        'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    final ascendantIndex = rashiNames.indexWhere((r) => r.toLowerCase() == ascendantRashi.toLowerCase());
    if (ascendantIndex == -1) return null;
    
    // Calculate which sign the house cusp is in (house 1 = ascendant sign, house 2 = next sign, etc.)
    final houseSignIndex = (ascendantIndex + houseNumber - 1) % 12;
    final houseSignName = rashiNames[houseSignIndex];
    
    // Return the lord of that sign
    return rashiLords[houseSignName];
  }

  // Life area insights based on house lords
  String _getCareerInsight() {
    final careerLord = _getHouseLord(10);
    if (careerLord == null) {
      // Fallback to Sun's position for career
      final sunData = _getPlanetData('Sun');
      if (sunData != null) {
        final sunRashi = sunData['rashi'] as String? ?? 'Unknown';
        return _getCareerInsightByRashi(sunRashi);
      }
      return 'Your career potential is being analyzed...';
    }

    final careerData = _getPlanetData(careerLord);
    if (careerData == null) {
      // Fallback to Sun's position for career
      final sunData = _getPlanetData('Sun');
      if (sunData != null) {
        final sunRashi = sunData['rashi'] as String? ?? 'Unknown';
        return _getCareerInsightByRashi(sunRashi);
      }
      return 'Your career potential is being analyzed...';
    }

    final careerRashiName = careerData['rashi'] as String? ?? 'Unknown';
    return _getCareerInsightByRashi(careerRashiName);
  }

  String _getCareerInsightByRashi(String rashiName) {
    switch (rashiName.toLowerCase()) {
      case 'aries':
        return 'You excel in leadership roles and pioneering new ventures. Consider careers in management, entrepreneurship, or any field requiring initiative.';
      case 'taurus':
        return 'You thrive in stable, practical careers with tangible results. Consider finance, real estate, agriculture, or any field requiring persistence.';
      case 'gemini':
        return 'You excel in communication and information-based careers. Consider writing, teaching, sales, or any field requiring versatility.';
      case 'cancer':
        return 'You succeed in nurturing and protective careers. Consider healthcare, hospitality, real estate, or any field serving families.';
      case 'leo':
        return 'You excel in creative and leadership roles. Consider entertainment, management, or any field where you can inspire others.';
      case 'virgo':
        return 'You thrive in service and detail-oriented careers. Consider healthcare, research, or any field requiring precision and analysis.';
      case 'libra':
        return 'You succeed in partnership and harmony-focused careers. Consider law, diplomacy, or any field requiring balance and fairness.';
      case 'scorpio':
        return 'You excel in transformative and investigative careers. Consider psychology, research, or any field requiring deep understanding.';
      case 'sagittarius':
        return 'You thrive in expansive and educational careers. Consider teaching, travel, or any field requiring philosophical understanding.';
      case 'capricorn':
        return 'You excel in structured and ambitious careers. Consider management, government, or any field requiring discipline and long-term planning.';
      case 'aquarius':
        return 'You succeed in innovative and humanitarian careers. Consider technology, social work, or any field requiring originality and progress.';
      case 'pisces':
        return 'You excel in compassionate and service-oriented careers. Consider healthcare, arts, or any field requiring empathy and spiritual understanding.';
      default:
        return 'Your career potential reflects your natural abilities and the type of work that will bring you fulfillment and success.';
    }
  }

  String _getMarriageInsight() {
    final marriageLord = _getHouseLord(7);
    if (marriageLord == null) {
      // Fallback to Venus's position for relationships
      final venusData = _getPlanetData('Venus');
      if (venusData != null) {
        final venusRashi = venusData['rashi'] as String? ?? 'Unknown';
        return _getMarriageInsightByRashi(venusRashi);
      }
      return 'Your relationship potential is being analyzed...';
    }

    final marriageData = _getPlanetData(marriageLord);
    if (marriageData == null) {
      // Fallback to Venus's position for relationships
      final venusData = _getPlanetData('Venus');
      if (venusData != null) {
        final venusRashi = venusData['rashi'] as String? ?? 'Unknown';
        return _getMarriageInsightByRashi(venusRashi);
      }
      return 'Your relationship potential is being analyzed...';
    }

    final marriageRashiName = marriageData['rashi'] as String? ?? 'Unknown';
    return _getMarriageInsightByRashi(marriageRashiName);
  }

  String _getMarriageInsightByRashi(String rashiName) {
    switch (rashiName.toLowerCase()) {
      case 'aries':
        return 'You need a partner who is independent and exciting. Your relationships may be passionate but require mutual respect for freedom.';
      case 'taurus':
        return 'You need a stable, loyal partner who values commitment. Your relationships are built on trust, security, and shared values.';
      case 'gemini':
        return 'You need a mentally stimulating partner who can communicate well. Your relationships thrive on intellectual connection and variety.';
      case 'cancer':
        return 'You need a nurturing, emotionally supportive partner. Your relationships are built on emotional security and family values.';
      case 'leo':
        return 'You need a partner who admires and appreciates you. Your relationships thrive on mutual respect and shared creative interests.';
      case 'virgo':
        return 'You need a practical, service-oriented partner. Your relationships are built on mutual support and helping each other improve.';
      case 'libra':
        return 'You need a harmonious, diplomatic partner. Your relationships thrive on balance, fairness, and shared aesthetic interests.';
      case 'scorpio':
        return 'You need a deeply committed, transformative partner. Your relationships require trust, intimacy, and mutual growth.';
      case 'sagittarius':
        return 'You need an adventurous, philosophical partner. Your relationships thrive on shared beliefs, travel, and intellectual exploration.';
      case 'capricorn':
        return 'You need a responsible, ambitious partner. Your relationships are built on mutual respect, shared goals, and long-term commitment.';
      case 'aquarius':
        return 'You need an independent, humanitarian partner. Your relationships thrive on friendship, shared ideals, and mutual freedom.';
      case 'pisces':
        return 'You need a compassionate, spiritually-minded partner. Your relationships are built on empathy, understanding, and mutual support.';
      default:
        return 'Your relationship potential reflects the type of partner who will complement your nature and support your growth.';
    }
  }

  String _getWealthInsight() {
    final wealthLord = _getHouseLord(2);
    if (wealthLord == null) {
      // Fallback to Jupiter's position for wealth
      final jupiterData = _getPlanetData('Jupiter');
      if (jupiterData != null) {
        final jupiterRashi = jupiterData['rashi'] as String? ?? 'Unknown';
        return _getWealthInsightByRashi(jupiterRashi);
      }
      return 'Your wealth potential is being analyzed...';
    }

    final wealthData = _getPlanetData(wealthLord);
    if (wealthData == null) {
      // Fallback to Jupiter's position for wealth
      final jupiterData = _getPlanetData('Jupiter');
      if (jupiterData != null) {
        final jupiterRashi = jupiterData['rashi'] as String? ?? 'Unknown';
        return _getWealthInsightByRashi(jupiterRashi);
      }
      return 'Your wealth potential is being analyzed...';
    }

    final wealthRashiName = wealthData['rashi'] as String? ?? 'Unknown';
    return _getWealthInsightByRashi(wealthRashiName);
  }

  String _getWealthInsightByRashi(String rashiName) {
    switch (rashiName.toLowerCase()) {
      case 'aries':
        return 'You build wealth through leadership and new ventures. Your energy and initiative help you create opportunities for financial growth.';
      case 'taurus':
        return 'You build wealth through steady, practical means. Your persistence and appreciation for quality help you accumulate resources over time.';
      case 'gemini':
        return 'You build wealth through communication and versatility. Your ability to adapt and learn helps you create multiple income streams.';
      case 'cancer':
        return 'You build wealth through nurturing and protecting resources. Your emotional intelligence helps you make wise financial decisions.';
      case 'leo':
        return 'You build wealth through creative expression and leadership. Your confidence and charisma help you attract financial opportunities.';
      case 'virgo':
        return 'You build wealth through service and attention to detail. Your analytical skills help you make practical financial decisions.';
      case 'libra':
        return 'You build wealth through partnerships and balance. Your diplomatic skills help you create mutually beneficial financial relationships.';
      case 'scorpio':
        return 'You build wealth through transformation and deep understanding. Your intensity helps you uncover hidden financial opportunities.';
      case 'sagittarius':
        return 'You build wealth through expansion and philosophy. Your optimism and love of learning help you create opportunities for growth.';
      case 'capricorn':
        return 'You build wealth through discipline and long-term planning. Your ambition and practical approach help you achieve financial security.';
      case 'aquarius':
        return 'You build wealth through innovation and humanitarian service. Your originality helps you create unique financial opportunities.';
      case 'pisces':
        return 'You build wealth through compassion and intuition. Your sensitivity helps you understand others\' needs and create value.';
      default:
        return 'Your wealth potential reflects your natural abilities and the best ways for you to create and manage financial resources.';
    }
  }

  String _getHealthInsight() {
    final healthLord = _getHouseLord(6);
    if (healthLord == null) {
      // Fallback to Mars's position for health
      final marsData = _getPlanetData('Mars');
      if (marsData != null) {
        final marsRashi = marsData['rashi'] as String? ?? 'Unknown';
        return _getHealthInsightByRashi(marsRashi);
      }
      return 'Your health patterns are being analyzed...';
    }

    final healthData = _getPlanetData(healthLord);
    if (healthData == null) {
      // Fallback to Mars's position for health
      final marsData = _getPlanetData('Mars');
      if (marsData != null) {
        final marsRashi = marsData['rashi'] as String? ?? 'Unknown';
        return _getHealthInsightByRashi(marsRashi);
      }
      return 'Your health patterns are being analyzed...';
    }

    final healthRashiName = healthData['rashi'] as String? ?? 'Unknown';
    return _getHealthInsightByRashi(healthRashiName);
  }

  String _getHealthInsightByRashi(String rashiName) {
    switch (rashiName.toLowerCase()) {
      case 'aries':
        return 'You have strong vitality but may need to manage stress and anger. Regular exercise and competitive activities help maintain your health.';
      case 'taurus':
        return 'You have good endurance but may need to watch your diet and exercise routine. Regular physical activity and healthy eating are essential.';
      case 'gemini':
        return 'You may experience stress-related health issues. Mental stimulation and regular communication help maintain your well-being.';
      case 'cancer':
        return 'Your health is closely tied to your emotional state. A nurturing environment and emotional security are important for your well-being.';
      case 'leo':
        return 'You have strong vitality but may need to manage your heart and blood pressure. Regular exercise and creative expression support your health.';
      case 'virgo':
        return 'You may be prone to stress-related digestive issues. A healthy diet, regular routine, and attention to details support your well-being.';
      case 'libra':
        return 'Your health is affected by relationship stress. Balance in all areas of life and harmonious relationships support your well-being.';
      case 'scorpio':
        return 'You have strong regenerative abilities but may need to manage intense emotions. Regular detoxification and emotional release support your health.';
      case 'sagittarius':
        return 'You have good overall health but may need to watch your liver and avoid overindulgence. Regular exercise and philosophical pursuits support your well-being.';
      case 'capricorn':
        return 'You may experience stress-related bone and joint issues. Regular exercise, proper nutrition, and stress management support your health.';
      case 'aquarius':
        return 'Your health may be affected by nervous system stress. Regular exercise, social connection, and innovative activities support your well-being.';
      case 'pisces':
        return 'You may be sensitive to environmental factors and emotions. Regular spiritual practices, boundaries, and emotional support are essential for your health.';
      default:
        return 'Your health patterns reflect your natural constitution and the areas where you need to pay special attention to maintain well-being.';
    }
  }

  // Current influences and timing insights
  String _getAscendantInsight() {
    final ascendantData = _birthChart?['ascendant'] as Map<String, dynamic>?;
    if (ascendantData == null)
      return 'Your rising sign influence is being analyzed...';

    final ascendantRashiName = ascendantData['rashi'] as String? ?? 'Unknown';
    return 'Your rising sign in $ascendantRashiName influences how others perceive you and your first impressions. This energy affects your approach to new situations and relationships.';
  }

  String _getCurrentFocusInsight() {
    final sunData = _getPlanetData('Sun');
    if (sunData == null) return 'Your current focus is being determined...';

    final sunRashiName = sunData['rashi'] as String? ?? 'Unknown';
    return 'Your current focus is on developing your $sunRashiName qualities and expressing your authentic self. This is a time for personal growth and self-discovery.';
  }

  String _getBestTimeInsight() {
    final moonData = _getPlanetData('Moon');
    if (moonData == null) return 'Your best timing is being analyzed...';

    final moonRashiName = moonData['rashi'] as String? ?? 'Unknown';
    return 'Your best time for action is when you feel emotionally secure and connected to your $moonRashiName nature. Trust your intuition and act from your heart.';
  }

  double _calculatePlanetaryStrength(String planet) {
    // Convert lowercase planet name to capitalized (e.g., 'sun' -> 'Sun')
    final planetName = planet[0].toUpperCase() + planet.substring(1);
    final planetData = _getPlanetData(planetName);

    if (planetData == null) return 0.5;

    final signName = planetData['rashi'] as String? ?? 'Unknown';
    final planetHouse = planetData['house'] as int?;
    final planetNakshatra = planetData['nakshatra'] as String?;

    if (signName == 'Unknown' || planetHouse == null || planetNakshatra == null)
      return 0.5;

    double strength = 0.0;

    strength += _getSignStrength(planet, signName);
    strength += _getHouseStrength(planetHouse.toString());
    strength += _getNakshatraStrength(planetNakshatra);
    strength += _getAspectStrength(planet);

    return (strength / 4.0).clamp(0.0, 1.0);
  }

  List<String> _calculatePlanetaryAspects(String planet) {
    final aspects = <String>[];
    // Convert lowercase planet name to capitalized (e.g., 'sun' -> 'Sun')
    final planetName = planet[0].toUpperCase() + planet.substring(1);
    final planetData = _getPlanetData(planetName);
    if (planetData == null) return aspects;

    final planetNames = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu'
    ];
    for (final otherPlanetName in planetNames) {
      if (otherPlanetName == planetName) continue;

      final otherPlanetData = _getPlanetData(otherPlanetName);
      if (otherPlanetData == null) continue;

      final aspect = _calculateAspect(planetData, otherPlanetData);
      if (aspect.isNotEmpty) {
        aspects
            .add('${_getPlanetName(otherPlanetName.toLowerCase())}: $aspect');
      }
    }

    return aspects;
  }

  double _getSignStrength(String planet, String signName) {
    switch (planet.toLowerCase()) {
      case 'sun':
        return signName.toLowerCase() == 'leo' ? 1.0 : 0.5;
      case 'moon':
        return signName.toLowerCase() == 'cancer' ? 1.0 : 0.5;
      case 'mars':
        return signName.toLowerCase() == 'aries' ? 1.0 : 0.5;
      case 'mercury':
        return (signName.toLowerCase() == 'gemini' ||
                signName.toLowerCase() == 'virgo')
            ? 1.0
            : 0.5;
      case 'jupiter':
        return (signName.toLowerCase() == 'sagittarius' ||
                signName.toLowerCase() == 'pisces')
            ? 1.0
            : 0.5;
      case 'venus':
        return (signName.toLowerCase() == 'taurus' ||
                signName.toLowerCase() == 'libra')
            ? 1.0
            : 0.5;
      case 'saturn':
        return (signName.toLowerCase() == 'capricorn' ||
                signName.toLowerCase() == 'aquarius')
            ? 1.0
            : 0.5;
      default:
        return 0.5;
    }
  }

  double _getHouseStrength(String? house) {
    if (house == null) return 0.4;
    switch (house.toLowerCase()) {
      case 'first':
      case 'fourth':
      case 'seventh':
      case 'tenth':
        return 1.0;
      case 'second':
      case 'fifth':
      case 'eighth':
      case 'eleventh':
        return 0.7;
      default:
        return 0.4;
    }
  }

  double _getNakshatraStrength(String? nakshatra) {
    if (nakshatra == null || nakshatra.isEmpty) return 0.5;
    // Simple strength calculation based on nakshatra name length
    return (nakshatra.length % 3 == 0) ? 1.0 : 0.7;
  }

  double _getAspectStrength(String planet) {
    return 0.6;
  }

  String _calculateAspect(
      Map<String, dynamic> planet1, Map<String, dynamic> planet2) {
    final longitude1 = planet1['longitude'] as double? ?? 0.0;
    final longitude2 = planet2['longitude'] as double? ?? 0.0;
    final diff = (longitude2 - longitude1).abs() % 360.0;
    final aspect = (diff / 30.0).floor() % 12;

    switch (aspect) {
      case 0:
        return 'Conjunction';
      case 2:
      case 10:
        return 'Sextile';
      case 3:
      case 9:
        return 'Square';
      case 4:
      case 8:
        return 'Trine';
      case 6:
        return 'Opposition';
      default:
        return '';
    }
  }

  String _getPlanetName(String planet) {
    switch (planet.toLowerCase()) {
      case 'sun':
        return 'Sun';
      case 'moon':
        return 'Moon';
      case 'mars':
        return 'Mars';
      case 'mercury':
        return 'Mercury';
      case 'jupiter':
        return 'Jupiter';
      case 'venus':
        return 'Venus';
      case 'saturn':
        return 'Saturn';
      case 'rahu':
        return 'Rahu';
      case 'ketu':
        return 'Ketu';
      default:
        return planet.toUpperCase();
    }
  }

  // Dynamic interpretation components
  String _getSunSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your core identity is marked by natural leadership and pioneering spirit.';
      case 'taurus':
        return 'Your core identity is grounded in stability and practical wisdom.';
      case 'gemini':
        return 'Your core identity thrives on communication and intellectual curiosity.';
      case 'cancer':
        return 'Your core identity is deeply connected to nurturing and emotional intelligence.';
      case 'leo':
        return 'Your core identity shines through creativity and natural charisma.';
      case 'virgo':
        return 'Your core identity is defined by analytical precision and service to others.';
      case 'libra':
        return 'Your core identity seeks harmony and balance in all relationships.';
      case 'scorpio':
        return 'Your core identity is marked by intensity and transformative power.';
      case 'sagittarius':
        return 'Your core identity is driven by adventure and philosophical exploration.';
      case 'capricorn':
        return 'Your core identity is built on discipline and ambitious achievement.';
      case 'aquarius':
        return 'Your core identity is innovative and humanitarian in nature.';
      case 'pisces':
        return 'Your core identity is compassionate and spiritually attuned.';
      default:
        return 'Your core identity reflects your unique personality blend.';
    }
  }

  String _getHouseInfluence(String? house) {
    if (house == null) return '';

    // Handle both numeric strings ("1", "2") and word strings ("first", "second")
    final houseNum = int.tryParse(house) ?? 0;
    if (houseNum > 0 && houseNum <= 12) {
      switch (houseNum) {
        case 1:
          return 'This placement emphasizes your personality and first impressions.';
        case 2:
          return 'This placement influences your values and material resources.';
        case 3:
          return 'This placement affects your communication and immediate environment.';
        case 4:
          return 'This placement emphasizes your home life and emotional foundation.';
        case 5:
          return 'This placement influences your creativity and self-expression.';
        case 6:
          return 'This placement affects your daily routines and service to others.';
        case 7:
          return 'This placement emphasizes your partnerships and relationships.';
        case 8:
          return 'This placement influences transformation and shared resources.';
        case 9:
          return 'This placement affects your higher learning and philosophical outlook.';
        case 10:
          return 'This placement emphasizes your career and public reputation.';
        case 11:
          return 'This placement influences your hopes, dreams, and social connections.';
        case 12:
          return 'This placement affects your spirituality and subconscious mind.';
        default:
          return '';
      }
    }

    // Fallback for word-based house names
    switch (house.toLowerCase()) {
      case 'first':
        return 'This placement emphasizes your personality and first impressions.';
      case 'second':
        return 'This placement influences your values and material resources.';
      case 'third':
        return 'This placement affects your communication and immediate environment.';
      case 'fourth':
        return 'This placement emphasizes your home life and emotional foundation.';
      case 'fifth':
        return 'This placement influences your creativity and self-expression.';
      case 'sixth':
        return 'This placement affects your daily routines and service to others.';
      case 'seventh':
        return 'This placement emphasizes your partnerships and relationships.';
      case 'eighth':
        return 'This placement influences transformation and shared resources.';
      case 'ninth':
        return 'This placement affects your higher learning and philosophical outlook.';
      case 'tenth':
        return 'This placement emphasizes your career and public reputation.';
      case 'eleventh':
        return 'This placement influences your hopes, dreams, and social connections.';
      case 'twelfth':
        return 'This placement affects your spirituality and subconscious mind.';
      default:
        return '';
    }
  }

  String _getNakshatraInfluence(String? nakshatra) {
    if (nakshatra == null || nakshatra.isEmpty) return '';
    return 'The $nakshatra nakshatra influences your personality and life path.';
  }

  String _getStrengthInfluence(double strength) {
    if (strength > 0.8) {
      return 'This planet is very strong in your chart, giving you exceptional abilities in this area.';
    } else if (strength > 0.6) {
      return 'This planet is well-placed in your chart, providing good support for your endeavors.';
    } else if (strength > 0.4) {
      return 'This planet has moderate strength, requiring some effort to manifest its qualities.';
    } else {
      return 'This planet may need extra attention and conscious development to reach its potential.';
    }
  }

  String _getAspectInfluence(List<String> aspects) {
    if (aspects.isEmpty) return '';

    return 'The planetary aspects in your chart create unique dynamics: ${aspects.join(', ')}.';
  }

  // Additional interpretation methods for dynamic insights
  String _getMoonSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your emotional nature responds quickly and needs excitement.';
      case 'taurus':
        return 'Your emotional nature seeks security through stability and comfort.';
      case 'gemini':
        return 'Your emotional nature processes feelings through communication.';
      case 'cancer':
        return 'Your emotional nature is deeply intuitive and nurturing.';
      case 'leo':
        return 'Your emotional nature expresses itself dramatically and needs recognition.';
      case 'virgo':
        return 'Your emotional nature processes feelings through analysis and service.';
      case 'libra':
        return 'Your emotional nature seeks harmony and balance in relationships.';
      case 'scorpio':
        return 'Your emotional nature experiences feelings intensely and needs transformation.';
      case 'sagittarius':
        return 'Your emotional nature needs freedom and philosophical understanding.';
      case 'capricorn':
        return 'Your emotional nature may suppress feelings to maintain control.';
      case 'aquarius':
        return 'Your emotional nature processes feelings through detachment and humanitarian concerns.';
      case 'pisces':
        return 'Your emotional nature is highly sensitive and spiritually attuned.';
      default:
        return 'Your emotional nature reflects your inner needs and feelings.';
    }
  }

  String _getMarsSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your energy and drive are marked by tremendous initiative and leadership.';
      case 'taurus':
        return 'Your energy and drive are steady and persistent, preferring your own pace.';
      case 'gemini':
        return 'Your energy and drive are quick and versatile, excelling at multitasking.';
      case 'cancer':
        return 'Your energy and drive are emotional and protective, fighting for family.';
      case 'leo':
        return 'Your energy and drive are dramatic and confident, inspiring others.';
      case 'virgo':
        return 'Your energy and drive are precise and analytical, working through detailed planning.';
      case 'libra':
        return 'Your energy and drive prefer cooperation over confrontation.';
      case 'scorpio':
        return 'Your energy and drive are intense and transformative, requiring deep investigation.';
      case 'sagittarius':
        return 'Your energy and drive are enthusiastic and adventurous, exploring new territories.';
      case 'capricorn':
        return 'Your energy and drive are disciplined and ambitious, working toward long-term goals.';
      case 'aquarius':
        return 'Your energy and drive are innovative and independent, pursuing original ideas.';
      case 'pisces':
        return 'Your energy and drive are sensitive and intuitive, working best in service to others.';
      default:
        return 'Your energy and drive reflect how you take action and pursue goals.';
    }
  }

  String _getJupiterSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your wisdom and growth expand through leadership and new initiatives.';
      case 'taurus':
        return 'Your wisdom and growth come from building solid foundations and appreciating life\'s pleasures.';
      case 'gemini':
        return 'Your wisdom and growth expand through learning and communication.';
      case 'cancer':
        return 'Your wisdom and growth come from nurturing others and creating emotional security.';
      case 'leo':
        return 'Your wisdom and growth expand through creative expression and leadership.';
      case 'virgo':
        return 'Your wisdom and growth come from service and attention to detail.';
      case 'libra':
        return 'Your wisdom and growth expand through relationships and creating harmony.';
      case 'scorpio':
        return 'Your wisdom and growth come from transformation and deep understanding.';
      case 'sagittarius':
        return 'Your wisdom and growth expand through philosophy and adventure.';
      case 'capricorn':
        return 'Your wisdom and growth come from discipline and achievement.';
      case 'aquarius':
        return 'Your wisdom and growth expand through innovation and humanitarian service.';
      case 'pisces':
        return 'Your wisdom and growth come from compassion and spiritual understanding.';
      default:
        return 'Your wisdom and growth reflect your highest aspirations.';
    }
  }

  String _getVenusSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your love and relationship style is passionate and direct.';
      case 'taurus':
        return 'Your love and relationship style values stability and sensuality.';
      case 'gemini':
        return 'Your love and relationship style needs mental stimulation and communication.';
      case 'cancer':
        return 'Your love and relationship style is nurturing and protective.';
      case 'leo':
        return 'Your love and relationship style is generous and dramatic.';
      case 'virgo':
        return 'Your love and relationship style shows love through service and attention to detail.';
      case 'libra':
        return 'Your love and relationship style needs harmony and partnership.';
      case 'scorpio':
        return 'Your love and relationship style experiences love intensely and needs deep connections.';
      case 'sagittarius':
        return 'Your love and relationship style needs freedom and adventure.';
      case 'capricorn':
        return 'Your love and relationship style is serious and responsible.';
      case 'aquarius':
        return 'Your love and relationship style needs independence and intellectual connection.';
      case 'pisces':
        return 'Your love and relationship style is compassionate and idealistic.';
      default:
        return 'Your love and relationship style reflects how you give and receive affection.';
    }
  }

  // Helper methods for displaying astrological information
  String _getRashiOrNakshatraName(Map<String, dynamic>? data) {
    if (data == null) return 'Unknown';
    // Check for both 'englishName' and 'name' fields for backward compatibility
    if (data.containsKey('englishName')) {
      return data['englishName'] as String? ?? 'Unknown';
    } else if (data.containsKey('name')) {
      return data['name'] as String? ?? 'Unknown';
    }
    return 'Unknown';
  }

  String _getPlanetDisplayName(String? planet) {
    if (planet == null) return 'Unknown';
    switch (planet.toLowerCase()) {
      case 'sun':
        return 'Sun';
      case 'moon':
        return 'Moon';
      case 'mars':
        return 'Mars';
      case 'mercury':
        return 'Mercury';
      case 'jupiter':
        return 'Jupiter';
      case 'venus':
        return 'Venus';
      case 'saturn':
        return 'Saturn';
      case 'rahu':
        return 'Rahu';
      case 'ketu':
        return 'Ketu';
      default:
        return planet.toUpperCase();
    }
  }

  String _getElementDisplayName(String? element) {
    if (element == null) return 'Unknown';
    switch (element.toLowerCase()) {
      case 'fire':
        return 'Fire';
      case 'earth':
        return 'Earth';
      case 'air':
        return 'Air';
      case 'water':
        return 'Water';
      default:
        return element;
    }
  }

  String _getQualityDisplayName(String? quality) {
    if (quality == null) return 'Unknown';
    switch (quality.toLowerCase()) {
      case 'cardinal':
        return 'Cardinal';
      case 'fixed':
        return 'Fixed';
      case 'mutable':
        return 'Mutable';
      default:
        return quality;
    }
  }


  /// Handle profile icon tap - show popup if profile incomplete, otherwise navigate to profile
  Future<void> _handleProfileTap(BuildContext context, WidgetRef ref,
      TranslationService translationService) async {
    final currentContext = context;
    try {
      final userService = ref.read(user_providers.userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      final user =
          ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

      // Use ProfileCompletionChecker to determine if user has real profile data
      if (user == null || !ProfileCompletionChecker.isProfileComplete(user)) {
        // Show "Complete Your Profile" popup instead of directly navigating
        _showProfileCompletionPopup(currentContext, translationService);
      } else {
        // Navigate to profile view screen
        _navigateToProfile(currentContext);
      }
    } catch (e) {
      // On error, show profile completion popup
      _showProfileCompletionPopup(currentContext, translationService);
    }
  }

  /// Show profile completion popup
  void _showProfileCompletionPopup(
      BuildContext context, TranslationService translationService) {
    showDialog(
      context: context,
      builder: (context) => ProfileCompletionDialog(
        translationService: translationService,
        onCompleteProfile: () {
          Navigator.of(context).pop(); // Close dialog
          _navigateToUser(context); // Navigate to edit screen
        },
        onSkip: () {
          Navigator.of(context).pop(); // Close dialog
        },
      ),
    );
  }

  /// Navigate to user edit screen with hero animation
  void _navigateToUser(BuildContext context) {
    // Get the screen size for positioning
    final screenSize = MediaQuery.of(context).size;

    // Calculate approximate position of profile icon (top right)
    final sourcePosition = Offset(
      screenSize.width -
          ResponsiveSystem.spacing(context,
              baseSpacing: 60), // Approximate position of profile icon
      ResponsiveSystem.spacing(context,
          baseSpacing: 60), // Approximate Y position
    );
    final sourceSize = Size(
        ResponsiveSystem.spacing(context, baseSpacing: 40),
        ResponsiveSystem.spacing(context,
            baseSpacing: 40)); // Approximate size of profile icon

    // Use hero navigation with zoom-out effect from profile icon
    HeroNavigationWithRipple.pushWithRipple(
      context,
      const UserEditScreen(),
      sourcePosition,
      sourceSize,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      rippleColor: ThemeHelpers.getPrimaryColor(context),
      rippleRadius: 100.0,
    );
  }

  /// Navigate to profile with slide animation
  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  Widget _buildHeroSection() {
    final primaryGradient = ThemeHelpers.getPrimaryGradient(context);
    return Container(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
              ResponsiveSystem.borderRadius(context, baseRadius: 30)),
          bottomRight: Radius.circular(
              ResponsiveSystem.borderRadius(context, baseRadius: 30)),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              60, // Adjusted for better collapse behavior
          bottom: ResponsiveSystem.spacing(context, baseSpacing: 20),
          left: ResponsiveSystem.spacing(context, baseSpacing: 20),
          right: ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Horoscope Icon
            Icon(
              LucideIcons.star,
              size: ResponsiveSystem.iconSize(context, baseSize: 40),
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),

            // Subtitle only (title is handled by SliverAppBar)
            Text(
              'Discover your cosmic blueprint and life path',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getPrimaryTextColor(context)
                    .withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
