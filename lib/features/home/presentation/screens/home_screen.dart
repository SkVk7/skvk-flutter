import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common/centralized_widgets.dart';
import '../../../../core/utils/validation/profile_completion_checker.dart';
import '../../../../core/services/user/user_service.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/services/language/translation_service.dart';
import '../../../../core/navigation/animated_navigation.dart';
import '../../../../core/logging/logging_helper.dart';
import '../../../../core/design_system/theme/theme_provider.dart';
import '../../../../core/services/language/language_service.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../predictions/presentation/screens/predictions_screen.dart';
import '../../../matching/presentation/screens/matching_screen.dart';
import '../../../user/presentation/screens/user_edit_screen.dart';
import 'pradakshana_screen.dart';
import '../../../content/presentation/screens/audio_screen.dart';
import '../../../content/presentation/screens/books_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeProperties.getPrimaryColor(context),
        elevation: ResponsiveSystem.elevation(context, baseElevation: 4),
        toolbarHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
        title: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: ThemeProperties.getAppBarTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
            ResponsiveSystem.sizedBox(context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Flexible(
              child: Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                  fontWeight: FontWeight.bold,
                  color: ThemeProperties.getAppBarTextColor(context),
                ),
              ),
            ),
          ],
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: isDark,
            isEvening: false, // You can make this dynamic based on time
            useSacredFire: false,
          ),
        ),
        child: SafeArea(
          child: AnimatedOpacity(
            opacity: _isInitialized ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            child: CustomScrollView(
              slivers: [
                // Hero Welcome Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: ResponsiveSystem.only(context, top: 20),
                    child: CentralizedWelcomeSection(
                      title: translationService.translateContent(
                          'welcome_title',
                          fallback: 'Welcome to Vedic Astrology Pro'),
                      subtitle: translationService.translateContent(
                          'welcome_subtitle',
                          fallback:
                              'Discover what the stars have in store for you with personalized insights and guidance'),
                      icon: Icons.auto_awesome,
                      iconColor: ThemeProperties.getPrimaryColor(context),
                    ),
                  ),
                ),

                // Spacing between sections
                SliverToBoxAdapter(
                  child: ResponsiveSystem.sizedBox(context,
                      height:
                          ResponsiveSystem.spacing(context, baseSpacing: 40)),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: CentralizedQuickActionsSection(
                    title: translationService.translateHeader('quick_actions',
                        fallback: 'Quick Actions'),
                    actions: [
                      CentralizedQuickActionCard(
                        title: translationService.translateHeader(
                            'todays_guidance',
                            fallback: 'Today\'s Guidance'),
                        icon: Icons.auto_awesome,
                        color: ThemeProperties.getPrimaryColor(context),
                        onTap: () => _navigateWithProfileCheck(
                            context,
                            '/predictions',
                            'Today\'s Guidance',
                            translationService),
                        isDark: isDark,
                      ),
                      CentralizedQuickActionCard(
                        title: translationService.translateHeader(
                            'my_birth_chart',
                            fallback: 'My Birth Chart'),
                        icon: Icons.star,
                        color: ThemeProperties.getSecondaryColor(context),
                        onTap: () => _navigateWithProfileCheck(context,
                            '/horoscope', 'Birth Chart', translationService),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // Spacing between sections
                SliverToBoxAdapter(
                  child: ResponsiveSystem.sizedBox(context,
                      height:
                          ResponsiveSystem.spacing(context, baseSpacing: 40)),
                ),

                // Features Grid
                SliverToBoxAdapter(
                  child: CentralizedFeaturesGridSection(
                    title: translationService.translateHeader('features',
                        fallback: 'Features'),
                    features: [
                      CentralizedFeatureCard(
                        title: translationService.translateHeader(
                            'sacred_calendar',
                            fallback: 'Sacred Calendar'),
                        icon: Icons.calendar_today,
                        color: ThemeProperties.getPrimaryColor(context),
                        onTap: () => _navigateToCalendar(context),
                        isDark: isDark,
                      ),
                      CentralizedFeatureCard(
                        title: translationService.translateHeader(
                            'compatibility_check',
                            fallback: 'Compatibility Check'),
                        icon: Icons.favorite,
                        color: ThemeProperties.getErrorColor(context),
                        onTap: () => _navigateToRoute(context, '/matching'),
                        isDark: isDark,
                      ),
                      CentralizedFeatureCard(
                        title: translationService.translateHeader(
                            'pradakshana_counter',
                            fallback: 'Pradakshana Counter'),
                        icon: Icons.radio_button_checked,
                        color: ThemeProperties.getSuccessColor(context),
                        onTap: () => _navigateToPradakshana(context),
                        isDark: isDark,
                      ),
                      CentralizedFeatureCard(
                        title: translationService.translateHeader(
                            'devotional_audio',
                            fallback: 'Devotional Audio'),
                        icon: Icons.music_note,
                        color: ThemeProperties.getPrimaryColor(context),
                        onTap: () => _navigateToAudio(context),
                        isDark: isDark,
                      ),
                      CentralizedFeatureCard(
                        title: translationService.translateHeader(
                            'devotional_books',
                            fallback: 'Devotional Books'),
                        icon: Icons.menu_book,
                        color: ThemeProperties.getSecondaryColor(context),
                        onTap: () => _navigateToBooks(context),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // Spacing between sections
                SliverToBoxAdapter(
                  child: ResponsiveSystem.sizedBox(context,
                      height:
                          ResponsiveSystem.spacing(context, baseSpacing: 40)),
                ),

                // Bottom Spacing
                SliverToBoxAdapter(
                  child: ResponsiveSystem.sizedBox(context,
                      height:
                          ResponsiveSystem.spacing(context, baseSpacing: 32)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle profile icon tap - show popup if profile incomplete, otherwise navigate to profile
  Future<void> _handleProfileTap(BuildContext context, WidgetRef ref,
      TranslationService translationService) async {
    final currentContext = context;
    try {
      final userService = ref.read(userServiceProvider.notifier);
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

  /// Navigate to a screen with profile completion check
  Future<void> _navigateWithProfileCheck(
    BuildContext context,
    String route,
    String featureName,
    TranslationService translationService,
  ) async {
    // Prevent multiple simultaneous navigation calls
    if (_isNavigating) {
      print('🔍 DEBUG: Home screen navigation already in progress, skipping');
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
          ),
          title: Text(
            translationService.translateContent('complete_your_profile',
                fallback: 'Complete Your Profile'),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: ResponsiveSystem.iconSize(context, baseSize: 48),
                color: ThemeProperties.getPrimaryColor(context),
              ),
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
              Text(
                translationService.translateContent('complete_your_profile',
                    fallback: 'Complete Your Profile'),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
              Text(
                'To access $featureName, please complete your profile first.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
          actions: [
            CentralizedModernButton(
              text: translationService.translateContent('cancel',
                  fallback: 'Cancel'),
              onPressed: () => Navigator.of(context).pop(),
              width: ResponsiveSystem.screenWidth(context) * 0.3,
            ),
            CentralizedModernButton(
              text: translationService.translateContent('complete_profile',
                  fallback: 'Complete Profile'),
              onPressed: () {
                Navigator.of(context).pop();
                // Use animated navigation to avoid navigation stack issues
                _navigateToUser(context);
              },
              width: ResponsiveSystem.screenWidth(context) * 0.4,
            ),
          ],
        );
      },
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
    AnimatedNavigation.pushSlide(
      context,
      const AudioScreen(),
      direction: SlideDirection.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
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
      case 'te':
        language = SupportedLanguage.telugu;
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
      rippleColor: ThemeProperties.getPrimaryColor(context),
      rippleRadius: 100.0,
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
        AnimatedNavigation.pushSlide(
          context,
          ResponsiveSystem.sizedBox(
            context,
          ),
          direction: SlideDirection.rightToLeft,
        );
    }
  }
}
