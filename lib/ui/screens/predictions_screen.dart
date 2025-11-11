import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
// UI Utils - Use only these for consistency
import '../utils/theme_helpers.dart';
import '../utils/responsive_system.dart';
// Core imports
import '../../core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import '../../core/navigation/hero_navigation.dart'; // For HeroNavigationWithRipple
// Features imports
import '../components/predictions/daily_predictions_tab.dart';
// UI Components - Reusable components
import '../components/common/index.dart';
import '../components/dialogs/index.dart';
// Core imports
import '../../core/services/language/translation_service.dart';
import '../../core/services/user/user_service.dart';
import '../../core/utils/either.dart';
import '../../core/utils/validation/profile_completion_checker.dart';
import '../../core/logging/logging_helper.dart';
import 'user_edit_screen.dart';
import '../utils/screen_handlers.dart';

class PredictionsScreen extends ConsumerStatefulWidget {
  const PredictionsScreen({super.key});

  @override
  ConsumerState<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends ConsumerState<PredictionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Start entrance animation
    _animationController.forward();

    _checkProfileAndShowPopup();
  }

  Future<void> _checkProfileAndShowPopup() async {
    // Check if user profile is complete before showing predictions
    // The DailyPredictionsTab will handle the actual profile checking
    // This method is kept for future enhancements if needed
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = BackgroundGradients.getBackgroundGradient(
      isDark: isDark,
      isEvening: false,
      useSacredFire: false,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
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
                    onTap: () => _handleProfileTap(
                        context, ref, ref.watch(translationServiceProvider)),
                    tooltip:
                        ref.watch(translationServiceProvider).translateContent(
                              'my_profile',
                              fallback: 'My Profile',
                            ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Daily Predictions',
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

            // Daily Predictions Content
            const SliverToBoxAdapter(
              child: DailyPredictionsTab(),
            ),
          ],
        ),
      ),
    );
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
            // Sun Icon for Daily Predictions
            Icon(
              LucideIcons.sun,
              size: ResponsiveSystem.iconSize(context, baseSize: 40),
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),

            // Subtitle only (title is handled by SliverAppBar)
            Text(
              'Your personalized daily guidance from the stars',
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
}
