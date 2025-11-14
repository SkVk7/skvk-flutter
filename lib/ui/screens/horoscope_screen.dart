import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import 'package:skvk_application/core/features/user/providers/user_provider.dart'
    as user_providers;
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/navigation/hero_navigation.dart'; // For HeroNavigationWithRipple
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/core/utils/astrology/horoscope_insights_generator.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:skvk_application/core/utils/validation/profile_completion_checker.dart';
import 'package:skvk_application/ui/components/app_bar/index.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/components/dialogs/index.dart';
import 'package:skvk_application/ui/screens/user_edit_screen.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

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

        if (_isProfileComplete && user != null && !_isDisposed) {
          await _generateHoroscope(user);
        }
      }
    } on Exception catch (e) {
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

      final userService = ref.read(user_providers.userServiceProvider.notifier);
      final Map<String, dynamic>? birthData =
          await userService.getFormattedAstrologyData();

      if (mounted && !_isDisposed) {
        setState(() {
          // Use camelCase only
          _birthChart = birthData!['birthChart'] as Map<String, dynamic>?;
          _fixedBirthData = birthData;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
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
          title: translationService.translateHeader(
            'horoscope_title',
            fallback: 'Horoscope',
          ),
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: BackgroundGradients.getBackgroundGradient(
              isDark: Theme.of(context).brightness == Brightness.dark,
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
          title: translationService.translateHeader(
            'horoscope_title',
            fallback: 'Horoscope',
          ),
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: BackgroundGradients.getBackgroundGradient(
              isDark: Theme.of(context).brightness == Brightness.dark,
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
                    translationService.translateHeader(
                      'horoscope_title',
                      fallback: 'Your Horoscope',
                    ),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 24),
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                  ResponsiveSystem.sizedBox(context, height: 16),
                  Text(
                    translationService.translateContent(
                      'horoscope_message',
                      fallback:
                          'Please complete your profile to view your personalized horoscope.',
                    ),
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
                      fallback: 'Complete Profile',
                    ),
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
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
                  onLanguageChanged: (value) async {
                    await LoggingHelper.logInfo('Language changed to: $value');
                    ScreenHandlers.handleLanguageChange(ref, value);
                  },
                ),
                // Theme Dropdown Widget
                ThemeDropdown(
                  onThemeChanged: (value) async {
                    await LoggingHelper.logInfo('Theme changed to: $value');
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
                  translationService.translateHeader(
                    'horoscope_title',
                    fallback: 'Horoscope',
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                background: _buildHeroSection(),
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
          const SectionTitle(
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
            const SectionTitle(
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
          const SectionTitle(
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
              _fixedBirthData!['rashi'] as Map<String, dynamic>?,
            ),
            icon: Icons.nightlight_round,
          ),
          InfoRow(
            label: 'Nakshatra (Birth Star)',
            value: _getRashiOrNakshatraName(
              _fixedBirthData!['nakshatra'] as Map<String, dynamic>?,
            ),
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
            value: _getPlanetDisplayName(
              (_fixedBirthData!['rashi'] as Map<String, dynamic>?)?['lord']
                  as String?,
            ),
            icon: Icons.king_bed,
          ),
          InfoRow(
            label: 'Nakshatra Lord',
            value: _getPlanetDisplayName(
              (_fixedBirthData!['nakshatra'] as Map<String, dynamic>?)?['lord']
                  as String?,
            ),
            icon: Icons.star_border,
          ),
          InfoRow(
            label: 'Element',
            value: _getElementDisplayName(
              (_fixedBirthData!['rashi'] as Map<String, dynamic>?)?['element']
                  as String?,
            ),
            icon: Icons.water_drop,
          ),
          InfoRow(
            label: 'Quality',
            value: _getQualityDisplayName(
              (_fixedBirthData!['rashi'] as Map<String, dynamic>?)?['quality']
                  as String?,
            ),
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
          const SectionTitle(
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
          _buildPersonalityInsight('Core Identity',
              HoroscopeInsightsGenerator.getSunInsight(_birthChart),),
          _buildPersonalityInsight('Emotional Nature',
              HoroscopeInsightsGenerator.getMoonInsight(_birthChart),),
          _buildPersonalityInsight('Energy & Drive',
              HoroscopeInsightsGenerator.getMarsInsight(_birthChart),),
          _buildPersonalityInsight('Wisdom & Growth',
              HoroscopeInsightsGenerator.getJupiterInsight(_birthChart),),
          _buildPersonalityInsight('Love & Relationships',
              HoroscopeInsightsGenerator.getVenusInsight(_birthChart),),
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
          const SectionTitle(
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
          _buildLifeInsight('Career & Success',
              HoroscopeInsightsGenerator.getCareerInsight(_birthChart),),
          _buildLifeInsight('Relationships & Love',
              HoroscopeInsightsGenerator.getMarriageInsight(_birthChart),),
          _buildLifeInsight('Wealth & Resources',
              HoroscopeInsightsGenerator.getWealthInsight(_birthChart),),
          _buildLifeInsight('Health & Wellbeing',
              HoroscopeInsightsGenerator.getHealthInsight(_birthChart),),
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
          const SectionTitle(
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
          _buildCurrentInsight('Rising Sign',
              HoroscopeInsightsGenerator.getAscendantInsight(_birthChart),),
          _buildCurrentInsight('Current Focus',
              HoroscopeInsightsGenerator.getCurrentFocusInsight(_birthChart),),
          _buildCurrentInsight('Best Time for Action',
              HoroscopeInsightsGenerator.getBestTimeInsight(_birthChart),),
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

  // for better code reusability and maintainability

  // Helper methods for displaying astrological information
  String _getRashiOrNakshatraName(Map<String, dynamic>? data) {
    if (data == null) return 'Unknown';
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
  Future<void> _handleProfileTap(
    BuildContext context,
    WidgetRef ref,
    TranslationService translationService,
  ) async {
    if (!mounted) return;
    final currentContext = context;
    try {
      final userService = ref.read(user_providers.userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      if (!mounted) return;
      final user =
          ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

      // Use ProfileCompletionChecker to determine if user has real profile data
      if (user == null || !ProfileCompletionChecker.isProfileComplete(user)) {
        if (currentContext.mounted) {
          _showProfileCompletionPopup(currentContext, translationService);
        }
      } else {
        if (currentContext.mounted) {
          _navigateToProfile(currentContext);
        }
      }
    } on Exception {
      // On error, show profile completion popup
      if (currentContext.mounted) {
        _showProfileCompletionPopup(currentContext, translationService);
      }
    }
  }

  /// Show profile completion popup
  void _showProfileCompletionPopup(
    BuildContext context,
    TranslationService translationService,
  ) {
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
    final screenSize = MediaQuery.of(context).size;

    final sourcePosition = Offset(
      screenSize.width -
          ResponsiveSystem.spacing(
            context,
            baseSpacing: 60,
          ), // Approximate position of profile icon
      ResponsiveSystem.spacing(
        context,
        baseSpacing: 60,
      ), // Approximate Y position
    );
    final sourceSize = Size(
      ResponsiveSystem.spacing(
        context,
        baseSpacing: 40,
      ),
      ResponsiveSystem.spacing(
        context,
        baseSpacing: 40,
      ),
    ); // Approximate size of profile icon

    // Use hero navigation with zoom-out effect from profile icon
    HeroNavigationWithRipple.pushWithRipple(
      context,
      const UserEditScreen(),
      sourcePosition,
      sourceSize,
      rippleColor: ThemeHelpers.getPrimaryColor(context),
      rippleRadius: 100,
    );
  }

  /// Navigate to profile with slide animation
  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  Widget _buildHeroSection() {
    final primaryGradient = ThemeHelpers.getPrimaryGradient(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 30),
          ),
          bottomRight: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 30),
          ),
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
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),

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
