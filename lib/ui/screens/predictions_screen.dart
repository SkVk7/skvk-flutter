import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/navigation/hero_navigation.dart'; // For HeroNavigationWithRipple
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/core/services/user/user_service.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:skvk_application/core/utils/validation/profile_completion_checker.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/components/dialogs/index.dart';
// Features imports
import 'package:skvk_application/ui/components/predictions/daily_predictions_tab.dart';
import 'package:skvk_application/ui/screens/user_edit_screen.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Start entrance animation
    _animationController.forward();

    _checkProfileAndShowPopup();
  }

  Future<void> _checkProfileAndShowPopup() async {
    // The DailyPredictionsTab will handle the actual profile checking
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
    );

    return Scaffold(
      body: DecoratedBox(
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
                    onTap: () => _handleProfileTap(
                      context,
                      ref,
                      ref.watch(translationServiceProvider),
                    ),
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
            // Sun Icon for Daily Predictions
            Icon(
              LucideIcons.sun,
              size: ResponsiveSystem.iconSize(context, baseSize: 40),
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),

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
}
