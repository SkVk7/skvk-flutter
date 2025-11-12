/// Home Screen - Premium Modern Layout
///
/// Refactored to new UI folder structure with:
/// - Modern premium UI design
/// - Strong visual hierarchy
/// - Dark theme with gold accents (saffron for highlights only)
/// - Subtle 1px low-opacity borders
/// - Improved typography scale
/// - Sliver-based layout for performance
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// UI Utils - Use only these for consistency
import '../utils/theme_helpers.dart';
import '../utils/responsive_system.dart';
import '../utils/screen_handlers.dart';
// Core imports
import '../../core/utils/validation/profile_completion_checker.dart';
import '../../core/services/user/user_service.dart';
import '../../core/utils/either.dart';
import '../../core/services/language/translation_service.dart';
import '../../core/navigation/animated_navigation.dart';
import '../../core/navigation/hero_navigation.dart'; // For HeroNavigationWithRipple
import '../../core/logging/logging_helper.dart';
// UI Components - Reusable components
import '../components/cards/main_cta_card.dart';
import '../components/home/index.dart';
import '../components/common/index.dart';
import '../components/dialogs/feature_access_dialog.dart';
// Audio imports
import '../../core/services/audio/audio_controller.dart';
// Screen imports
import 'calendar_screen.dart';
import 'predictions_screen.dart';
import 'matching_screen.dart';
import 'user_edit_screen.dart';
import 'pradakshana_screen.dart';
import 'books_screen.dart';

/// Home Screen with Premium Modern Layout
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize with a slight delay for entrance animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isNavigating = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Reset navigation flag when returning to the app
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationService = ref.watch(translationServiceProvider);
    final playerState = ref.watch(audioControllerProvider);
    
    // Calculate bottom padding for mini player
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final miniPlayerHeight = ResponsiveSystem.responsive(
      context,
      mobile: ResponsiveSystem.spacing(context, baseSpacing: 88),
      tablet: ResponsiveSystem.spacing(context, baseSpacing: 96),
      desktop: ResponsiveSystem.spacing(context, baseSpacing: 104),
      largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 112),
    );
    final totalPlayerHeight = miniPlayerHeight + safeAreaBottom;
    final bottomPadding = (playerState.hasTrack && playerState.showMiniPlayer)
        ? totalPlayerHeight + ResponsiveSystem.spacing(context, baseSpacing: 16)
        : ResponsiveSystem.spacing(context, baseSpacing: 16);

    return Scaffold(
      backgroundColor: ThemeHelpers.getBackgroundColor(context),
      body: AnimatedOpacity(
        opacity: _isInitialized ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        child: CustomScrollView(
          slivers: [
            // Step 1: SliverAppBar pinned at top with header branding
            HomeAppBar(
              onProfileTap: () => ScreenHandlers.handleProfileTap(context, ref, translationService),
              onLanguageChanged: (value) => ScreenHandlers.handleLanguageChange(ref, value),
              onThemeChanged: (value) => ScreenHandlers.handleThemeChange(ref, value),
            ),

            // Content padding - Responsive padding based on screen size
            SliverPadding(
              padding: EdgeInsets.symmetric(
                // Responsive horizontal padding based on screen size
                horizontal: ResponsiveSystem.responsive(
                  context,
                  mobile: ResponsiveSystem.spacing(context, baseSpacing: 16),
                  tablet: ResponsiveSystem.spacing(context, baseSpacing: 24),
                  desktop: ResponsiveSystem.spacing(context, baseSpacing: 32),
                  largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 40),
                ),
                // Reduced top vertical padding by 35% (24 * 0.65 = 15.6)
                vertical: ResponsiveSystem.spacing(context, baseSpacing: 15.6),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Tagline below app title
                  WelcomeTagline(translationService: translationService),

                  // Responsive spacing between tagline and CTA
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.responsive(
                      context,
                      mobile: ResponsiveSystem.spacing(context, baseSpacing: 24),
                      tablet: ResponsiveSystem.spacing(context, baseSpacing: 28),
                      desktop: ResponsiveSystem.spacing(context, baseSpacing: 32),
                      largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 36),
                    ),
                  ),

                  // Step 2: Main CTA - Today's Guidance (large, full width)
                  MainCTACard(
                    title: translationService.translateHeader(
                      'todays_guidance',
                      fallback: 'Today\'s Guidance',
                    ),
                    subtitle: 'Get personalized insights for today',
                    icon: Icons.auto_awesome,
                    onTap: () => _navigateWithProfileCheck(
                      context,
                      '/predictions',
                      'Today\'s Guidance',
                      translationService,
                    ),
                  ),

                  // Responsive spacing between CTA and pill cards
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.responsive(
                      context,
                      mobile: ResponsiveSystem.spacing(context, baseSpacing: 12),
                      tablet: ResponsiveSystem.spacing(context, baseSpacing: 16),
                      desktop: ResponsiveSystem.spacing(context, baseSpacing: 20),
                      largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 24),
                    ),
                  ),

                  // Step 3: Two small action pill cards (Birth Chart + Calendar)
                  QuickActionsSection(
                    translationService: translationService,
                    onBirthChartTap: () => _navigateWithProfileCheck(
                      context,
                      '/horoscope',
                      'Birth Chart',
                      translationService,
                    ),
                    onCalendarTap: () => _navigateToCalendar(context),
                  ),

                  // Responsive spacing between pill cards and explore section
                  // Reduced vertical spacing by 18% (24 * 0.82 = 19.68, etc.)
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.responsive(
                      context,
                      mobile: ResponsiveSystem.spacing(context, baseSpacing: 19.68),
                      tablet: ResponsiveSystem.spacing(context, baseSpacing: 22.96),
                      desktop: ResponsiveSystem.spacing(context, baseSpacing: 26.24),
                      largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 32.8),
                    ),
                  ),

                  // Step 4: Explore grid - Section title
                  SectionTitle(
                    title: translationService.translateHeader(
                      'explore',
                      fallback: 'Explore',
                    ),
                    baseFontSize: 16,
                    letterSpacingPercent: 0.06,
                  ),

                  // Responsive spacing between title and grid
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.responsive(
                      context,
                      mobile: ResponsiveSystem.spacing(context, baseSpacing: 12),
                      tablet: ResponsiveSystem.spacing(context, baseSpacing: 16),
                      desktop: ResponsiveSystem.spacing(context, baseSpacing: 20),
                      largeDesktop: ResponsiveSystem.spacing(context, baseSpacing: 24),
                    ),
                  ),

                  // Features grid
                  FeaturesGrid(
                    translationService: translationService,
                    items: [
                      FeatureGridItem(
                        titleKey: 'compatibility_check',
                        fallbackTitle: 'Compatibility Check',
                        icon: Icons.favorite,
                        onTap: () => _navigateToRoute(context, '/matching'),
                      ),
                      FeatureGridItem(
                        titleKey: 'pradakshana_counter',
                        fallbackTitle: 'Pradakshana Counter',
                        icon: Icons.radio_button_checked,
                        onTap: () => _navigateToPradakshana(context),
                      ),
                      FeatureGridItem(
                        titleKey: 'devotional_audio',
                        fallbackTitle: 'Devotional Audio',
                        icon: Icons.music_note,
                        onTap: () => _navigateToAudio(context),
                      ),
                      FeatureGridItem(
                        titleKey: 'devotional_books',
                        fallbackTitle: 'Devotional Books',
                        icon: Icons.menu_book,
                        onTap: () => _navigateToBooks(context),
                      ),
                    ],
                  ),

                  ResponsiveSystem.sizedBox(
                    context,
                    height: bottomPadding,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }




  // Note: _handleProfileTap and _showProfileCompletionPopup have been moved to ScreenHandlers utility

  /// Navigate to a screen with profile completion check
  Future<void> _navigateWithProfileCheck(
    BuildContext context,
    String route,
    String featureName,
    TranslationService translationService,
  ) async {
    // Prevent multiple simultaneous navigation calls
    if (_isNavigating) {
      LoggingHelper.logDebug(
        'Home screen navigation already in progress, skipping',
        source: 'HomeScreen',
      );
      return;
    }

    final userService = ref.read(userServiceProvider.notifier);
    final result = await userService.getCurrentUser();
    final user = result.isSuccess ? result.value : null;

    if (user == null || !ProfileCompletionChecker.isProfileComplete(user)) {
      // Show our custom themed popup instead of the default one
      if (mounted) {
        _showFeatureAccessPopup(context, featureName, translationService);
      }
    } else {
      // Navigate to the requested route
      if (mounted && !_isNavigating) {
        _isNavigating = true;
        // Use a small delay to prevent navigation conflicts
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _navigateToRoute(context, route);
          // Reset navigation flag after a delay to ensure navigation completes
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _isNavigating = false;
            }
          });
        }
      }
    }
  }

  /// Show feature access popup
  void _showFeatureAccessPopup(BuildContext context, String featureName,
      TranslationService translationService) {
    FeatureAccessDialog.show(
      context,
      translationService: translationService,
      featureName: featureName,
      onCompleteProfile: () => _navigateToUser(context),
    );
  }

  /// Navigate to calendar with slide animation
  void _navigateToCalendar(BuildContext context) {
    AnimatedNavigation.pushSlide(
      context,
      const CalendarScreen(),
      direction: SlideDirection.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

  /// Navigate to pradakshana counter with slide animation
  void _navigateToPradakshana(BuildContext context) {
    AnimatedNavigation.pushSlide(
      context,
      const PradakshanaScreen(),
      direction: SlideDirection.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

  /// Navigate to audio screen with slide animation
  void _navigateToAudio(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;
    // Use route navigation to the new audio screen
    Navigator.of(context).pushNamed('/audio').then((_) {
      _isNavigating = false;
    });
  }

  /// Navigate to books screen with slide animation
  void _navigateToBooks(BuildContext context) {
    AnimatedNavigation.pushSlide(
      context,
      const BooksScreen(),
      direction: SlideDirection.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

  /// Navigate to predictions with scale animation
  void _navigateToPredictions(BuildContext context) {
    AnimatedNavigation.pushScale(
      context,
      const PredictionsScreen(),
      duration: const Duration(milliseconds: 350),
      beginScale: 0.8,
      endScale: 1.0,
    );
  }

  // Note: _handleLanguageChange and _handleThemeChange have been moved to ScreenHandlers utility

  /// Navigate to user edit screen with hero animation
  /// Uses ScreenHandlers for profile navigation
  void _navigateToUser(BuildContext context) {
    // Get the screen size for positioning using ResponsiveSystem
    // Using ResponsiveSystemExtensions.screenSize for consistency
    final screenSize = ResponsiveSystemExtensions.screenSize(context);

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
      rippleRadius: ResponsiveSystem.spacing(context, baseSpacing: 100),
    );
  }

  /// Navigate to profile with slide animation
  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToHoroscope(BuildContext context) {
    Navigator.pushNamed(context, '/horoscope');
  }

  /// Navigate to matching with slide animation
  void _navigateToMatching(BuildContext context) {
    AnimatedNavigation.pushSlide(
      context,
      const MatchingScreen(),
      direction: SlideDirection.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

  /// Navigate to route with appropriate animation based on route
  void _navigateToRoute(BuildContext context, String route) {
    switch (route) {
      case '/calendar':
        _navigateToCalendar(context);
        break;
      case '/predictions':
        _navigateToPredictions(context);
        break;
      case '/horoscope':
        _navigateToHoroscope(context);
        break;
      case '/matching':
        _navigateToMatching(context);
        break;
      case '/user':
        _navigateToUser(context);
        break;
      case '/profile':
        _navigateToProfile(context);
        break;
      default:
        // Default slide animation for unknown routes
        // Navigate to home if route is unknown
        Navigator.of(context).pop();
    }
  }
}

