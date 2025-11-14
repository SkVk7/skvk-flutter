/// Calendar Screen
///
/// A comprehensive traditional calendar with all features
/// including years, months, days with relevant astrological information
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import 'package:skvk_application/core/features/calendar/calendar_enums.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/navigation/hero_navigation.dart'; // For HeroNavigationWithRipple
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/core/services/user/user_service.dart';
import 'package:skvk_application/core/utils/astrology/region_ayanamsha_mapper.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:skvk_application/core/utils/validation/profile_completion_checker.dart';
import 'package:skvk_application/ui/components/calendar/calendar_month_view.dart';
import 'package:skvk_application/ui/components/calendar/calendar_year_view.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/components/dialogs/index.dart';
import 'package:skvk_application/ui/screens/user_edit_screen.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
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

  final bool _showFestivals = true;
  final bool _showAuspiciousTimes = true;
  final bool _showCalendarInfo = true;

  // Regional selection for calendar calculations
  String _selectedRegion = 'All India'; // Default region
  String _selectedAyanamsha =
      'lahiri'; // Default ayanamsha (will be updated based on region)

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _viewAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation variables removed to fix warnings

    _animationController.forward();
    _viewAnimationController.forward();

    _selectedAyanamsha =
        RegionAyanamshaMapper.getAyanamshaForRegion(_selectedRegion);
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
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
                      // Calendar-specific controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Region Dropdown (Compact)
                          _buildCompactRegionDropdown(),

                          ResponsiveSystem.sizedBox(context, width: 8),

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
                              color: ThemeHelpers.getPrimaryColor(context),
                              size: ResponsiveSystem.iconSize(
                                context,
                                baseSize: 20,
                              ),
                            ),
                            tooltip: 'Year View',
                          ),
                        ],
                      ),

                      // Language Dropdown Widget
                      LanguageDropdown(
                        onLanguageChanged: (value) async {
                          await LoggingHelper.logInfo(
                              'Language changed to: $value',);
                          ScreenHandlers.handleLanguageChange(ref, value);
                        },
                      ),

                      // Theme Dropdown Widget
                      ThemeDropdown(
                        onThemeChanged: (value) async {
                          await LoggingHelper.logInfo(
                              'Theme changed to: $value',);
                          ScreenHandlers.handleThemeChange(ref, value);
                        },
                      ),

                      // Profile Photo with Hover Effect
                      Padding(
                        padding: ResponsiveSystem.only(
                          context,
                          right:
                              ResponsiveSystem.spacing(context, baseSpacing: 8),
                        ),
                        child: ProfilePhoto(
                          key: const ValueKey('profile_icon'),
                          onTap: () => _handleProfileTap(
                            context,
                            ref,
                            translationService,
                          ),
                          tooltip: translationService.translateContent(
                            'my_profile',
                            fallback: 'My Profile',
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        '📅 ${translationService.translateHeader('calendar', fallback: 'Calendar')}',
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 18),
                          fontWeight: FontWeight.bold,
                          color: ThemeHelpers.getPrimaryTextColor(context),
                        ),
                      ),
                      background: _buildHeroSection(),
                    ),
                  ),

                  // Month View Calendar
                  SliverFillRemaining(
                    child: _currentView == CalendarView.year
                        ? _buildYearView()
                        : _buildMonthView(),
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
    // Location will be fetched inside CalendarYearView
    // Pass default values (will be overridden by device location)
    return CalendarYearView(
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
      latitude: 20.5937, // Default fallback (India center)
      longitude: 78.9629,
      ayanamsha: _selectedAyanamsha,
      showFestivals: _showFestivals,
      showAuspiciousTimes: _showAuspiciousTimes,
      showCalendarInfo: _showCalendarInfo,
    );
  }

  Widget _buildMonthView() {
    // Location will be fetched inside CalendarMonthView
    // Pass default values (will be overridden by device location)
    return CalendarMonthView(
      currentMonth: _currentMonth,
      selectedDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
          _currentMonth = DateTime(date.year, date.month);
        });
      },
      latitude: 20.5937, // Default fallback (India center)
      longitude: 78.9629,
      ayanamsha: _selectedAyanamsha,
    );
  }

  Widget _buildCompactRegionDropdown() {
    final primaryColor = ThemeHelpers.getPrimaryColor(context);
    final primaryTextColor = ThemeHelpers.getPrimaryTextColor(context);
    final surfaceColor = ThemeHelpers.getSurfaceColor(context);

    final allRegions = RegionAyanamshaMapper.getAllRegions();

    return Container(
      width: ResponsiveSystem.spacing(
        context,
        baseSpacing: 120,
      ), // Wider for region names
      height: ResponsiveSystem.spacing(context, baseSpacing: 40),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRegion,
          isExpanded: true,
          alignment: Alignment.centerLeft,
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
          items: allRegions.map((regionInfo) {
            return DropdownMenuItem<String>(
              value: regionInfo.name,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      regionInfo.name,
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 12),
                        color: primaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (regionInfo.isRecommended)
                    Container(
                      margin: EdgeInsets.only(
                        left: ResponsiveSystem.spacing(context, baseSpacing: 4),
                      ),
                      padding: ResponsiveSystem.symmetric(
                        context,
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: ResponsiveSystem.circular(
                          context,
                          baseRadius: 3,
                        ),
                      ),
                      child: Text(
                        '★',
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 8),
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newRegion) {
            if (newRegion != null && newRegion != _selectedRegion) {
              setState(() {
                _selectedRegion = newRegion;
                // Automatically update ayanamsha based on selected region
                _selectedAyanamsha =
                    RegionAyanamshaMapper.getAyanamshaForRegion(newRegion);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildCompactYearDropdown() {
    final primaryColor = ThemeHelpers.getPrimaryColor(context);
    final primaryTextColor = ThemeHelpers.getPrimaryTextColor(context);
    final surfaceColor = ThemeHelpers.getSurfaceColor(context);

    return Container(
      width: ResponsiveSystem.spacing(
        context,
        baseSpacing: 80,
      ), // Fixed compact width
      height: ResponsiveSystem.spacing(
        context,
        baseSpacing: 40,
      ), // Fixed compact height
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
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
                textAlign:
                    TextAlign.center, // Center the text in dropdown items
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
          onChanged: (newValue) {
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

  /// Handle profile icon tap - show popup if profile incomplete, otherwise navigate to profile
  Future<void> _handleProfileTap(
    BuildContext context,
    WidgetRef ref,
    TranslationService translationService,
  ) async {
    if (!mounted) return;
    final currentContext = context;
    try {
      final userService = ref.read(userServiceProvider.notifier);
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
            // Calendar Icon
            Icon(
              LucideIcons.calendar,
              size: ResponsiveSystem.iconSize(context, baseSize: 40),
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),

            // Subtitle only (title is handled by SliverAppBar)
            Text(
              'Explore festivals, tithi, and auspicious days',
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
