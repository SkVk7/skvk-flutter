/// Modern Hindu Calendar Screen
///
/// A comprehensive Hindu traditional calendar with all features
/// including years, months, days with relevant Hindu information
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/calendar_enums.dart';
import '../widgets/simple_calendar_month_view.dart';
import '../widgets/enhanced_calendar_year_view.dart';
import '../../../../core/services/translation_service.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';
import '../../../../shared/widgets/centralized_widgets.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/profile_completion_checker.dart';
import '../../../../core/logging/logging_helper.dart';
import '../../../../features/user/presentation/screens/user_edit_screen.dart';

class HinduCalendarScreen extends ConsumerStatefulWidget {
  const HinduCalendarScreen({super.key});

  @override
  ConsumerState<HinduCalendarScreen> createState() => _HinduCalendarScreenState();
}

class _HinduCalendarScreenState extends ConsumerState<HinduCalendarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _viewAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  // Animation variables removed to fix warnings

  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  CalendarView _currentView = CalendarView.month;
  int _selectedYear = DateTime.now().year;

  // Using centralized astrology library for calendar calculations

  // Additional state for enhanced features
  final bool _showFestivals = true;
  final bool _showAuspiciousTimes = true;
  final bool _showHinduInfo = true;

  // Regional selection for calendar calculations
  final AyanamshaType _selectedAyanamsha = AyanamshaType.lahiri;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers with proper durations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _viewAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Create entrance animations
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
      curve: Curves.easeInOut,
    ));

    // Animation variables removed to fix warnings

    _animationController.forward();
    _viewAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _viewAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationService = ref.watch(translationServiceProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
            isEvening: false,
            useSacredFire: false,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
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
                      // Calendar-specific controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Year Dropdown (Compact)
                          _buildCompactYearDropdown(),

                          ResponsiveSystem.sizedBox(context, width: 8),

                          // Year View Icon
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _currentView = CalendarView.year;
                              });
                            },
                            icon: Icon(
                              LucideIcons.calendar,
                              color: ThemeProperties.getPrimaryColor(context),
                              size: ResponsiveSystem.iconSize(context, baseSize: 20),
                            ),
                            tooltip: 'Year View',
                          ),
                        ],
                      ),

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
                        '📅 ${translationService.translateHeader('hindu_calendar', fallback: 'Hindu Calendar')}',
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

                  // Month View Calendar
                  SliverFillRemaining(
                    child: _currentView == CalendarView.year ? _buildYearView() : _buildMonthView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearView() {
    return EnhancedCalendarYearView(
      selectedYear: _selectedYear,
      selectedDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
      onMonthSelected: (date) {
        setState(() {
          _currentMonth = date;
          _currentView = CalendarView.month;
        });
      },
      latitude: 28.6139, // Default to Delhi
      longitude: 77.2090,
      ayanamsha: _selectedAyanamsha,
      showFestivals: _showFestivals,
      showAuspiciousTimes: _showAuspiciousTimes,
      showHinduInfo: _showHinduInfo,
    );
  }

  Widget _buildMonthView() {
    return SimpleCalendarMonthView(
      currentMonth: _currentMonth,
      selectedDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
          _currentMonth = DateTime(date.year, date.month);
        });
      },
      latitude: 28.6139, // Default to Delhi
      longitude: 77.2090,
      ayanamsha: _selectedAyanamsha,
    );
  }

  Widget _buildCompactYearDropdown() {
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final primaryTextColor = ThemeProperties.getPrimaryTextColor(context);
    final surfaceColor = ThemeProperties.getSurfaceColor(context);

    return Container(
      width: ResponsiveSystem.spacing(context, baseSpacing: 80), // Fixed compact width
      height: ResponsiveSystem.spacing(context, baseSpacing: 40), // Fixed compact height
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
        border: Border.all(
          color: primaryColor.withAlpha((0.2 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          isExpanded: true,
          alignment: Alignment.center, // Center the selected value
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
            color: primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: surfaceColor,
          icon: Icon(
            LucideIcons.chevronDown,
            size: ResponsiveSystem.iconSize(context, baseSize: 12),
            color: primaryColor,
          ),
          items: List.generate(101, (index) {
            final year = DateTime.now().year - 50 + index;
            return DropdownMenuItem<int>(
              value: year,
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                  color: primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center, // Center the text in dropdown items
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
          onChanged: (int? newValue) {
            if (newValue != null && newValue != _selectedYear) {
              setState(() {
                _selectedYear = newValue;
                _currentMonth = DateTime(newValue, _currentMonth.month);
              });
            }
          },
        ),
      ),
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
            // Calendar Icon
            Icon(
              LucideIcons.calendar,
              size: ResponsiveSystem.iconSize(context, baseSize: 40),
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),

            // Subtitle only (title is handled by SliverAppBar)
            Text(
              'Explore Hindu festivals, tithi, and auspicious days',
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
