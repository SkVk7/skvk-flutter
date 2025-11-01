import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/widgets/centralized_widgets.dart';
import '../../../../core/services/translation_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/utils/profile_completion_checker.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/models/user_model.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import '../../../../astrology/core/entities/astrology_entities.dart';
import '../../../../astrology/core/enums/astrology_enums.dart' as astrology_enums;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/logging/logging_helper.dart';
import '../../../../features/user/presentation/screens/user_edit_screen.dart';
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
  BirthChart? _birthChart;
  FixedBirthData? _fixedBirthData;
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
      final userService = ref.read(userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      final user = ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

      if (mounted && !_isDisposed) {
        setState(() {
          _user = user;
          _isProfileComplete = user != null && ProfileCompletionChecker.isProfileComplete(user);
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

      // Use AstrologyFacade for timezone handling
      final astrologyFacade = AstrologyFacade.instance;

      // Get timezone from user's location
      final timezoneId =
          await astrologyFacade.getTimezoneFromLocation(user.latitude, user.longitude);

      // Generate birth chart using AstrologyFacade (handles timezone conversion)
      final fixedBirthData = await astrologyFacade.getFixedBirthData(
        localBirthDateTime: user.localBirthDateTime,
        timezoneId: timezoneId,
        latitude: user.latitude,
        longitude: user.longitude,
        ayanamsha: user.ayanamsha,
        isUserData: true,
      );

      if (mounted && !_isDisposed) {
        setState(() {
          _birthChart = fixedBirthData.birthChart;
          _fixedBirthData = fixedBirthData;
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
        appBar: CentralizedGradientAppBar(
          title: translationService.translateHeader('horoscope_title', fallback: 'Horoscope'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
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
            child: CentralizedLoadingWidget(),
          ),
        ),
      );
    }

    if (!_isProfileComplete) {
      return Scaffold(
        appBar: CentralizedGradientAppBar(
          title: translationService.translateHeader('horoscope_title', fallback: 'Horoscope'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
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
                    color: ThemeProperties.getSecondaryTextColor(context),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 24),
                  Text(
                    translationService.translateHeader('horoscope_title',
                        fallback: 'Your Horoscope'),
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                      fontWeight: FontWeight.bold,
                      color: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 16),
                  Text(
                    translationService.translateContent('horoscope_message',
                        fallback:
                            'Please complete your profile to view your personalized horoscope.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeProperties.getSecondaryTextColor(context),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 24),
                  CentralizedModernButton(
                    text: translationService.translateContent('complete_profile',
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
              expandedHeight: ResponsiveSystem.spacing(context, baseSpacing: 250),
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: ThemeProperties.getTransparentColor(context),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  LucideIcons.house,
                  color: ThemeProperties.getAppBarTextColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                // Language Dropdown Widget
                CentralizedLanguageDropdown(
                  onLanguageChanged: (value) {
                    LoggingHelper.logInfo('Language changed to: $value');
                    _handleLanguageChange(ref, value);
                  },
                ),
                // Theme Dropdown Widget
                CentralizedThemeDropdown(
                  onThemeChanged: (value) {
                    LoggingHelper.logInfo('Theme changed to: $value');
                    _handleThemeChange(ref, value);
                  },
                ),
                // Profile Photo with Hover Effect
                Padding(
                  padding: ResponsiveSystem.only(
                    context,
                    right: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  ),
                  child: CentralizedProfilePhotoWithHover(
                    key: const ValueKey('profile_icon'),
                    onTap: () => _handleProfileTap(context, ref, translationService),
                    tooltip: translationService.translateContent(
                      'my_profile',
                      fallback: 'My Profile',
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  translationService.translateHeader('horoscope_title', fallback: 'Horoscope'),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryTextColor(context),
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
                      CentralizedAnimatedCard(
                        index: 0,
                        child: _buildBirthChartInfo(),
                      ),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      CentralizedAnimatedCard(
                        index: 1,
                        child: _buildRasiNakshatraInfo(),
                      ),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      CentralizedAnimatedCard(
                        index: 2,
                        child: _buildPlanetaryPositions(),
                      ),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      CentralizedAnimatedCard(
                        index: 3,
                        child: _buildHousePositions(),
                      ),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      CentralizedAnimatedCard(
                        index: 4,
                        child: _buildAscendantInfo(),
                      ),
                    ] else if (_errorMessage != null) ...[
                      CentralizedErrorMessage(
                        message: 'Error Loading Horoscope: $_errorMessage',
                        onRetry: () {
                          if (_user != null) {
                            _generateHoroscope(_user!);
                          }
                        },
                        icon: Icons.error_outline,
                      ),
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
    return CentralizedInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CentralizedSectionTitle(
            title: 'Birth Chart Information',
            subtitle: 'Your birth details for accurate calculations',
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          CentralizedInfoRow(
            label: 'Birth Date',
            value:
                '${_user!.dateOfBirth.day}/${_user!.dateOfBirth.month}/${_user!.dateOfBirth.year}',
            icon: Icons.calendar_today,
          ),
          CentralizedInfoRow(
            label: 'Birth Time',
            value:
                '${_user!.timeOfBirth.hour.toString().padLeft(2, '0')}:${_user!.timeOfBirth.minute.toString().padLeft(2, '0')}',
            icon: Icons.access_time,
          ),
          CentralizedInfoRow(
            label: 'Birth Place',
            value: _user!.placeOfBirth,
            icon: Icons.location_on,
          ),
          CentralizedInfoRow(
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
      return CentralizedInfoCard(
        child: Column(
          children: [
            CentralizedSectionTitle(
              title: 'Rasi & Nakshatra Information',
              subtitle: 'Your Moon sign and birth star details',
            ),
            ResponsiveSystem.sizedBox(context, height: 16),
            const CentralizedLoadingWidget(),
          ],
        ),
      );
    }

    return CentralizedInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CentralizedSectionTitle(
            title: 'Rasi & Nakshatra Information',
            subtitle: 'Your Moon sign and birth star details',
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          CentralizedInfoRow(
            label: 'Rasi (Moon Sign)',
            value: _fixedBirthData!.rashi.englishName,
            icon: Icons.nightlight_round,
          ),
          CentralizedInfoRow(
            label: 'Nakshatra (Birth Star)',
            value: _fixedBirthData!.nakshatra.englishName,
            icon: Icons.star,
          ),
          CentralizedInfoRow(
            label: 'Pada (Quarter)',
            value: '${_fixedBirthData!.pada.number}',
            icon: Icons.grid_view,
          ),
          CentralizedInfoRow(
            label: 'Rasi Lord',
            value: _getPlanetDisplayName(_fixedBirthData!.rashi.lord),
            icon: Icons.king_bed,
          ),
          CentralizedInfoRow(
            label: 'Nakshatra Lord',
            value: _getPlanetDisplayName(_fixedBirthData!.nakshatra.lord),
            icon: Icons.star_border,
          ),
          CentralizedInfoRow(
            label: 'Element',
            value: _getElementDisplayName(_fixedBirthData!.rashi.element),
            icon: Icons.water_drop,
          ),
          CentralizedInfoRow(
            label: 'Quality',
            value: _getQualityDisplayName(_fixedBirthData!.rashi.quality),
            icon: Icons.speed,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetaryPositions() {
    if (_birthChart?.planetRashis == null || _birthChart!.planetRashis.isEmpty) {
      return CentralizedInfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  color: ThemeProperties.getPrimaryColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Text(
                  'Your Personality & Traits',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(context, height: 12),
            Text(
              'Analyzing your personality traits...',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return CentralizedInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CentralizedSectionTitle(
            title: 'Your Personality & Traits',
            subtitle: 'Based on your planetary positions',
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
    if (_birthChart?.houseLords == null || _birthChart!.houseLords.isEmpty) {
      return CentralizedInfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  color: ThemeProperties.getPrimaryColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Text(
                  'Life Insights & Guidance',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(context, height: 12),
            Text(
              'Analyzing your life areas and current influences...',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return CentralizedInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CentralizedSectionTitle(
            title: 'Life Insights & Guidance',
            subtitle: 'Based on your house lords and life areas',
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
    // Get ascendant from house 1 lord
    final ascendantLord = _birthChart?.houseLords[astrology_enums.House.first];
    if (ascendantLord == null) {
      return CentralizedInfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                  color: ThemeProperties.getPrimaryColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Text(
                  'Current Influences',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(context, height: 12),
            Text(
              'Analyzing current planetary influences...',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return CentralizedInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CentralizedSectionTitle(
            title: 'Current Influences',
            subtitle: 'Based on your rising sign and current focus',
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
    return CentralizedInfoRow(
      label: aspect,
      value: insight,
      icon: Icons.psychology,
    );
  }

  Widget _buildLifeInsight(String area, String insight) {
    return CentralizedInfoRow(
      label: area,
      value: insight,
      icon: Icons.trending_up,
    );
  }

  Widget _buildCurrentInsight(String aspect, String insight) {
    return CentralizedInfoRow(
      label: aspect,
      value: insight,
      icon: Icons.wb_sunny,
    );
  }

  // Dynamic personality insights based on actual birth chart analysis
  String _getSunInsight() {
    final sunRashi = _birthChart?.planetRashis[astrology_enums.Planet.sun];
    if (sunRashi == null) return 'Your core identity is being calculated...';

    // Get Sun's house position for dynamic analysis
    final sunHouse = _birthChart?.planetHouses[astrology_enums.Planet.sun];
    final sunNakshatra = _birthChart?.planetNakshatras[astrology_enums.Planet.sun];

    // Calculate Sun's strength and influence
    final sunStrength = _calculatePlanetaryStrength(astrology_enums.Planet.sun);
    final sunAspects = _calculatePlanetaryAspects(astrology_enums.Planet.sun);

    // Build dynamic interpretation based on actual chart data
    String baseInterpretation = _getSunSignInterpretation(sunRashi.englishName);
    String houseInfluence = _getHouseInfluence(sunHouse);
    String nakshatraInfluence = _getNakshatraInfluence(sunNakshatra);
    String strengthInfluence = _getStrengthInfluence(sunStrength);
    String aspectInfluence = _getAspectInfluence(sunAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  String _getMoonInsight() {
    final moonRashi = _birthChart?.planetRashis[astrology_enums.Planet.moon];
    if (moonRashi == null) return 'Your emotional nature is being analyzed...';

    // Get Moon's house position and nakshatra for dynamic analysis
    final moonHouse = _birthChart?.planetHouses[astrology_enums.Planet.moon];
    final moonNakshatra = _birthChart?.planetNakshatras[astrology_enums.Planet.moon];
    final moonStrength = _calculatePlanetaryStrength(astrology_enums.Planet.moon);
    final moonAspects = _calculatePlanetaryAspects(astrology_enums.Planet.moon);

    // Build dynamic interpretation
    String baseInterpretation = _getMoonSignInterpretation(moonRashi.englishName);
    String houseInfluence = _getHouseInfluence(moonHouse);
    String nakshatraInfluence = _getNakshatraInfluence(moonNakshatra);
    String strengthInfluence = _getStrengthInfluence(moonStrength);
    String aspectInfluence = _getAspectInfluence(moonAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  String _getMarsInsight() {
    final marsRashi = _birthChart?.planetRashis[astrology_enums.Planet.mars];
    if (marsRashi == null) return 'Your energy and drive are being assessed...';

    // Get Mars's house position and nakshatra for dynamic analysis
    final marsHouse = _birthChart?.planetHouses[astrology_enums.Planet.mars];
    final marsNakshatra = _birthChart?.planetNakshatras[astrology_enums.Planet.mars];
    final marsStrength = _calculatePlanetaryStrength(astrology_enums.Planet.mars);
    final marsAspects = _calculatePlanetaryAspects(astrology_enums.Planet.mars);

    // Build dynamic interpretation
    String baseInterpretation = _getMarsSignInterpretation(marsRashi.englishName);
    String houseInfluence = _getHouseInfluence(marsHouse);
    String nakshatraInfluence = _getNakshatraInfluence(marsNakshatra);
    String strengthInfluence = _getStrengthInfluence(marsStrength);
    String aspectInfluence = _getAspectInfluence(marsAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  String _getJupiterInsight() {
    final jupiterRashi = _birthChart?.planetRashis[astrology_enums.Planet.jupiter];
    if (jupiterRashi == null) return 'Your wisdom and growth potential are being evaluated...';

    // Get Jupiter's house position and nakshatra for dynamic analysis
    final jupiterHouse = _birthChart?.planetHouses[astrology_enums.Planet.jupiter];
    final jupiterNakshatra = _birthChart?.planetNakshatras[astrology_enums.Planet.jupiter];
    final jupiterStrength = _calculatePlanetaryStrength(astrology_enums.Planet.jupiter);
    final jupiterAspects = _calculatePlanetaryAspects(astrology_enums.Planet.jupiter);

    // Build dynamic interpretation
    String baseInterpretation = _getJupiterSignInterpretation(jupiterRashi.englishName);
    String houseInfluence = _getHouseInfluence(jupiterHouse);
    String nakshatraInfluence = _getNakshatraInfluence(jupiterNakshatra);
    String strengthInfluence = _getStrengthInfluence(jupiterStrength);
    String aspectInfluence = _getAspectInfluence(jupiterAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  String _getVenusInsight() {
    final venusRashi = _birthChart?.planetRashis[astrology_enums.Planet.venus];
    if (venusRashi == null) return 'Your love and relationship style is being analyzed...';

    // Get Venus's house position and nakshatra for dynamic analysis
    final venusHouse = _birthChart?.planetHouses[astrology_enums.Planet.venus];
    final venusNakshatra = _birthChart?.planetNakshatras[astrology_enums.Planet.venus];
    final venusStrength = _calculatePlanetaryStrength(astrology_enums.Planet.venus);
    final venusAspects = _calculatePlanetaryAspects(astrology_enums.Planet.venus);

    // Build dynamic interpretation
    String baseInterpretation = _getVenusSignInterpretation(venusRashi.englishName);
    String houseInfluence = _getHouseInfluence(venusHouse);
    String nakshatraInfluence = _getNakshatraInfluence(venusNakshatra);
    String strengthInfluence = _getStrengthInfluence(venusStrength);
    String aspectInfluence = _getAspectInfluence(venusAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  // Life area insights based on house lords
  String _getCareerInsight() {
    final careerLord = _birthChart?.houseLords[astrology_enums.House.tenth];
    if (careerLord == null) return 'Your career potential is being analyzed...';

    final careerRashi = _birthChart?.planetRashis[careerLord];
    if (careerRashi == null) return 'Your career potential is being analyzed...';

    switch (careerRashi.englishName.toLowerCase()) {
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
    final marriageLord = _birthChart?.houseLords[astrology_enums.House.seventh];
    if (marriageLord == null) return 'Your relationship potential is being analyzed...';

    final marriageRashi = _birthChart?.planetRashis[marriageLord];
    if (marriageRashi == null) return 'Your relationship potential is being analyzed...';

    switch (marriageRashi.englishName.toLowerCase()) {
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
    final wealthLord = _birthChart?.houseLords[astrology_enums.House.second];
    if (wealthLord == null) return 'Your wealth potential is being analyzed...';

    final wealthRashi = _birthChart?.planetRashis[wealthLord];
    if (wealthRashi == null) return 'Your wealth potential is being analyzed...';

    switch (wealthRashi.englishName.toLowerCase()) {
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
    final healthLord = _birthChart?.houseLords[astrology_enums.House.sixth];
    if (healthLord == null) return 'Your health patterns are being analyzed...';

    final healthRashi = _birthChart?.planetRashis[healthLord];
    if (healthRashi == null) return 'Your health patterns are being analyzed...';

    switch (healthRashi.englishName.toLowerCase()) {
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
    final ascendantLord = _birthChart?.houseLords[astrology_enums.House.first];
    if (ascendantLord == null) return 'Your rising sign influence is being analyzed...';

    final ascendantRashi = _birthChart?.planetRashis[ascendantLord];
    if (ascendantRashi == null) return 'Your rising sign influence is being analyzed...';

    return 'Your rising sign in ${ascendantRashi.englishName} influences how others perceive you and your first impressions. This energy affects your approach to new situations and relationships.';
  }

  String _getCurrentFocusInsight() {
    // This would ideally be calculated based on current planetary transits
    // For now, providing a general insight based on the birth chart
    final sunRashi = _birthChart?.planetRashis[astrology_enums.Planet.sun];
    if (sunRashi == null) return 'Your current focus is being determined...';

    return 'Your current focus is on developing your ${sunRashi.englishName} qualities and expressing your authentic self. This is a time for personal growth and self-discovery.';
  }

  String _getBestTimeInsight() {
    // This would ideally be calculated based on current planetary transits and dasha periods
    // For now, providing a general insight based on the birth chart
    final moonRashi = _birthChart?.planetRashis[astrology_enums.Planet.moon];
    if (moonRashi == null) return 'Your best timing is being analyzed...';

    return 'Your best time for action is when you feel emotionally secure and connected to your ${moonRashi.englishName} nature. Trust your intuition and act from your heart.';
  }

  // Dynamic calculation methods for truly personalized interpretations
  double _calculatePlanetaryStrength(astrology_enums.Planet planet) {
    final planetRashi = _birthChart?.planetRashis[planet];
    final planetHouse = _birthChart?.planetHouses[planet];
    final planetNakshatra = _birthChart?.planetNakshatras[planet];

    if (planetRashi == null || planetHouse == null || planetNakshatra == null) return 0.5;

    double strength = 0.0;

    // Sign strength (exaltation, debilitation, own sign)
    strength += _getSignStrength(planet, planetRashi.englishName);

    // House strength (angular, succedent, cadent)
    strength += _getHouseStrength(planetHouse);

    // Nakshatra strength
    strength += _getNakshatraStrength(planetNakshatra);

    // Aspects from other planets
    strength += _getAspectStrength(planet);

    return (strength / 4.0).clamp(0.0, 1.0);
  }

  List<String> _calculatePlanetaryAspects(astrology_enums.Planet planet) {
    final aspects = <String>[];
    final planetRashi = _birthChart?.planetRashis[planet];
    if (planetRashi == null) return aspects;

    // Check aspects with other planets
    for (final otherPlanet in astrology_enums.Planet.values) {
      if (otherPlanet == planet) continue;

      final otherRashi = _birthChart?.planetRashis[otherPlanet];
      if (otherRashi == null) continue;

      final aspect = _calculateAspect(planetRashi, otherRashi);
      if (aspect.isNotEmpty) {
        aspects.add('${_getPlanetName(otherPlanet)}: $aspect');
      }
    }

    return aspects;
  }

  double _getSignStrength(astrology_enums.Planet planet, String signName) {
    // This would contain the actual Vedic astrology rules for planetary strength
    // For now, providing a simplified version
    switch (planet) {
      case astrology_enums.Planet.sun:
        return signName.toLowerCase() == 'leo' ? 1.0 : 0.5;
      case astrology_enums.Planet.moon:
        return signName.toLowerCase() == 'cancer' ? 1.0 : 0.5;
      case astrology_enums.Planet.mars:
        return signName.toLowerCase() == 'aries' ? 1.0 : 0.5;
      case astrology_enums.Planet.mercury:
        return (signName.toLowerCase() == 'gemini' || signName.toLowerCase() == 'virgo')
            ? 1.0
            : 0.5;
      case astrology_enums.Planet.jupiter:
        return (signName.toLowerCase() == 'sagittarius' || signName.toLowerCase() == 'pisces')
            ? 1.0
            : 0.5;
      case astrology_enums.Planet.venus:
        return (signName.toLowerCase() == 'taurus' || signName.toLowerCase() == 'libra')
            ? 1.0
            : 0.5;
      case astrology_enums.Planet.saturn:
        return (signName.toLowerCase() == 'capricorn' || signName.toLowerCase() == 'aquarius')
            ? 1.0
            : 0.5;
      default:
        return 0.5;
    }
  }

  double _getHouseStrength(astrology_enums.House house) {
    // Angular houses (1, 4, 7, 10) are strongest
    switch (house) {
      case astrology_enums.House.first:
      case astrology_enums.House.fourth:
      case astrology_enums.House.seventh:
      case astrology_enums.House.tenth:
        return 1.0;
      // Succedent houses (2, 5, 8, 11) are moderate
      case astrology_enums.House.second:
      case astrology_enums.House.fifth:
      case astrology_enums.House.eighth:
      case astrology_enums.House.eleventh:
        return 0.7;
      // Cadent houses (3, 6, 9, 12) are weakest
      default:
        return 0.4;
    }
  }

  double _getNakshatraStrength(NakshatraData nakshatra) {
    // This would contain the actual nakshatra strength calculations
    // For now, providing a simplified version based on nakshatra number
    return (nakshatra.number % 3 == 0) ? 1.0 : 0.7;
  }

  double _getAspectStrength(astrology_enums.Planet planet) {
    // This would calculate the strength of aspects from other planets
    // For now, providing a simplified version
    return 0.6;
  }

  String _calculateAspect(RashiData planet1, RashiData planet2) {
    final diff = (planet2.number - planet1.number).abs();
    final aspect = diff % 12;

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

  String _getPlanetName(astrology_enums.Planet planet) {
    switch (planet) {
      case astrology_enums.Planet.sun:
        return 'Sun';
      case astrology_enums.Planet.moon:
        return 'Moon';
      case astrology_enums.Planet.mars:
        return 'Mars';
      case astrology_enums.Planet.mercury:
        return 'Mercury';
      case astrology_enums.Planet.jupiter:
        return 'Jupiter';
      case astrology_enums.Planet.venus:
        return 'Venus';
      case astrology_enums.Planet.saturn:
        return 'Saturn';
      case astrology_enums.Planet.rahu:
        return 'Rahu';
      case astrology_enums.Planet.ketu:
        return 'Ketu';
      default:
        return planet.name;
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

  String _getHouseInfluence(astrology_enums.House? house) {
    if (house == null) return '';

    switch (house) {
      case astrology_enums.House.first:
        return 'This placement emphasizes your personality and first impressions.';
      case astrology_enums.House.second:
        return 'This placement influences your values and material resources.';
      case astrology_enums.House.third:
        return 'This placement affects your communication and immediate environment.';
      case astrology_enums.House.fourth:
        return 'This placement emphasizes your home life and emotional foundation.';
      case astrology_enums.House.fifth:
        return 'This placement influences your creativity and self-expression.';
      case astrology_enums.House.sixth:
        return 'This placement affects your daily routines and service to others.';
      case astrology_enums.House.seventh:
        return 'This placement emphasizes your partnerships and relationships.';
      case astrology_enums.House.eighth:
        return 'This placement influences transformation and shared resources.';
      case astrology_enums.House.ninth:
        return 'This placement affects your higher learning and philosophical outlook.';
      case astrology_enums.House.tenth:
        return 'This placement emphasizes your career and public reputation.';
      case astrology_enums.House.eleventh:
        return 'This placement influences your hopes, dreams, and social connections.';
      case astrology_enums.House.twelfth:
        return 'This placement affects your spirituality and subconscious mind.';
    }
  }

  String _getNakshatraInfluence(NakshatraData? nakshatra) {
    if (nakshatra == null) return '';

    return 'The ${nakshatra.englishName} nakshatra adds ${nakshatra.guna} qualities and ${nakshatra.yoni} characteristics to your nature.';
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
  String _getPlanetDisplayName(astrology_enums.Planet planet) {
    switch (planet) {
      case astrology_enums.Planet.sun:
        return 'Sun';
      case astrology_enums.Planet.moon:
        return 'Moon';
      case astrology_enums.Planet.mars:
        return 'Mars';
      case astrology_enums.Planet.mercury:
        return 'Mercury';
      case astrology_enums.Planet.jupiter:
        return 'Jupiter';
      case astrology_enums.Planet.venus:
        return 'Venus';
      case astrology_enums.Planet.saturn:
        return 'Saturn';
      case astrology_enums.Planet.rahu:
        return 'Rahu';
      case astrology_enums.Planet.ketu:
        return 'Ketu';
      default:
        return planet.name.toUpperCase();
    }
  }

  String _getElementDisplayName(astrology_enums.Element element) {
    switch (element) {
      case astrology_enums.Element.fire:
        return 'Fire';
      case astrology_enums.Element.earth:
        return 'Earth';
      case astrology_enums.Element.air:
        return 'Air';
      case astrology_enums.Element.water:
        return 'Water';
    }
  }

  String _getQualityDisplayName(astrology_enums.Quality quality) {
    switch (quality) {
      case astrology_enums.Quality.cardinal:
        return 'Cardinal';
      case astrology_enums.Quality.fixed:
        return 'Fixed';
      case astrology_enums.Quality.mutable:
        return 'Mutable';
    }
  }

  /// Handle language change
  void _handleLanguageChange(WidgetRef ref, String languageValue) {
    SupportedLanguage language;
    switch (languageValue) {
      case 'en':
        language = SupportedLanguage.english;
        break;
      case 'hi':
        language = SupportedLanguage.hindi;
        break;
      default:
        language = SupportedLanguage.english;
    }

    // Change both header and content language
    ref.read(languageServiceProvider.notifier).setHeaderLanguage(language);
    ref.read(languageServiceProvider.notifier).setContentLanguage(language);
  }

  /// Handle theme change
  void _handleThemeChange(WidgetRef ref, String themeValue) {
    AppThemeMode themeMode;
    switch (themeValue) {
      case 'light':
        themeMode = AppThemeMode.light;
        break;
      case 'dark':
        themeMode = AppThemeMode.dark;
        break;
      case 'system':
        themeMode = AppThemeMode.system;
        break;
      default:
        themeMode = AppThemeMode.system;
    }

    ref.read(themeNotifierProvider.notifier).setThemeMode(themeMode);
  }

  /// Handle profile icon tap - show popup if profile incomplete, otherwise navigate to profile
  Future<void> _handleProfileTap(
      BuildContext context, WidgetRef ref, TranslationService translationService) async {
    final currentContext = context;
    try {
      final userService = ref.read(userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      final user = ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

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
  void _showProfileCompletionPopup(BuildContext context, TranslationService translationService) {
    showDialog(
      context: context,
      builder: (context) => CentralizedProfileCompletionPopup(
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
      ResponsiveSystem.spacing(context, baseSpacing: 60), // Approximate Y position
    );
    final sourceSize = Size(ResponsiveSystem.spacing(context, baseSpacing: 40),
        ResponsiveSystem.spacing(context, baseSpacing: 40)); // Approximate size of profile icon

    // Use hero navigation with zoom-out effect from profile icon
    HeroNavigationWithRipple.pushWithRipple(
      context,
      const UserEditScreen(),
      sourcePosition,
      sourceSize,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      rippleColor: ThemeProperties.getPrimaryColor(context),
      rippleRadius: 100.0,
    );
  }

  /// Navigate to profile with slide animation
  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  Widget _buildHeroSection() {
    final primaryGradient = ThemeProperties.getPrimaryGradient(context);
    return Container(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 30)),
          bottomRight: Radius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 30)),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 60, // Adjusted for better collapse behavior
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
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),

            // Subtitle only (title is handled by SliverAppBar)
            Text(
              'Discover your cosmic blueprint and life path',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeProperties.getPrimaryTextColor(context).withValues(alpha: 0.9),
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
