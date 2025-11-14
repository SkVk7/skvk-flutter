/// Modern User Profile Screen
///
/// A comprehensive user profile screen with Hindu traditional aesthetics
/// accessible from all screens in the application
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/constants/app_constants.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/core/features/user/entities/user_entity.dart'
    as entity;
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/services/astrology/astrology_service_bridge.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/core/services/user/user_service.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:skvk_application/core/utils/validation/profile_completion_checker.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/components/user/profile_header_widget.dart';
import 'package:skvk_application/ui/components/user/profile_info_card.dart';
import 'package:skvk_application/ui/screens/user_edit_screen.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _astrologyData;
  bool _isLoadingAstrology = false;
  Timer? _astrologyRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when screen becomes active (e.g., after navigation)
    unawaited(
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _loadUserData();
          if (_currentUser != null) {
            _loadAstrologyData();
          }
        }
      }),
    );
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Try to get user data with a shorter timeout using Riverpod provider
      final userService = ref.read(userServiceProvider.notifier);

      // Force refresh the user service to ensure we have the latest data
      await userService.refreshUserData();

      // Wait a bit for the state to be updated
      unawaited(Future.delayed(const Duration(milliseconds: 100)));

      final userFromState = ref.read(userServiceProvider);
      await LoggingHelper.logDebug(
        'User from provider state: ${userFromState != null ? 'FOUND' : 'NULL'}',
        source: 'UserProfile',
      );

      if (userFromState != null) {
        await LoggingHelper.logDebug(
          'User details: ${userFromState.name}, DOB: ${userFromState.dateOfBirth}, TOB: ${userFromState.timeOfBirth}',
          source: 'UserProfile',
        );
        await LoggingHelper.logDebug(
          'Location: ${userFromState.latitude}, ${userFromState.longitude}',
          source: 'UserProfile',
        );
        await LoggingHelper.logDebug(
          'User name length: ${userFromState.name.length}, isEmpty: ${userFromState.name.isEmpty}',
          source: 'UserProfile',
        );
      } else {
        await LoggingHelper.logDebug('User from state is NULL',
            source: 'UserProfile',);
      }

      final result = await userService.getCurrentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return ResultHelper.failure(
            const UnexpectedFailure(message: 'Request timeout'),
          );
        },
      );

      final user = ResultHelper.isSuccess(result)
          ? ResultHelper.getValue(result)
          : userFromState;

      await LoggingHelper.logDebug(
        'User loading result: ${ResultHelper.isSuccess(result) ? 'SUCCESS' : 'FAILURE'}',
        source: 'UserProfile',
      );
      if (user != null) {
        await LoggingHelper.logDebug(
          'Final user details: ${user.name}, DOB: ${user.dateOfBirth}, TOB: ${user.timeOfBirth}',
          source: 'UserProfile',
        );
        await LoggingHelper.logDebug(
          'Location: ${user.latitude}, ${user.longitude}',
          source: 'UserProfile',
        );
        await LoggingHelper.logDebug(
          'User name length: ${user.name.length}, isEmpty: ${user.name.isEmpty}',
          source: 'UserProfile',
        );
      } else {
        await LoggingHelper.logDebug('No user data received',
            source: 'UserProfile',);
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
          _errorMessage = null; // Clear any previous error messages
        });

        if (user != null) {
          await LoggingHelper.logDebug(
            'User loaded, starting astrology data load...',
            source: 'UserProfile',
          );
          unawaited(_loadAstrologyData());
          _startAstrologyRefreshTimer();
        } else {
          await LoggingHelper.logDebug(
            'No user found, skipping astrology data load',
            source: 'UserProfile',
          );
        }
      }
    } on Exception {
      // Try fallback method using Riverpod provider
      try {
        final userService = ref.read(userServiceProvider.notifier);
        final result = await userService.getCurrentUser();
        final user = ResultHelper.isSuccess(result)
            ? ResultHelper.getValue(result)
            : null;

        if (mounted) {
          setState(() {
            _currentUser = user;
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } on Exception {
        if (mounted) {
          setState(() {
            _currentUser = null;
            _isLoading = false;
            // Don't set error message for common initialization issues
            // Let it show the "Create Profile" screen instead
            _errorMessage = null;
          });
        }
      }
    }
  }

  Future<void> _loadAstrologyData() async {
    if (_isLoadingAstrology) return; // Prevent multiple simultaneous loads

    try {
      if (mounted) {
        setState(() {
          _isLoadingAstrology = true;
          _astrologyData =
              null; // Clear any cached data to force fresh calculation
        });
      }

      if (_currentUser == null) {
        if (mounted) {
          setState(() {
            _astrologyData = null;
            _isLoadingAstrology = false;
          });
        }
        return;
      }

      // Use the optimized user service method that handles caching
      final userService = ref.read(userServiceProvider.notifier);
      await LoggingHelper.logDebug(
        'Loading astrology data for user: ${_currentUser!.name}',
        source: 'UserProfile',
      );
      await LoggingHelper.logDebug(
        'Birth details: ${_currentUser!.dateOfBirth} ${_currentUser!.timeOfBirth}',
        source: 'UserProfile',
      );
      await LoggingHelper.logDebug(
        'Location: ${_currentUser!.latitude}, ${_currentUser!.longitude}',
        source: 'UserProfile',
      );

      final userServiceState = ref.read(userServiceProvider);
      await LoggingHelper.logDebug(
        'User service state: ${userServiceState != null ? 'HAS_USER' : 'NO_USER'}',
        source: 'UserProfile',
      );
      if (userServiceState != null) {
        await LoggingHelper.logDebug(
          'User service user: ${userServiceState.name}',
          source: 'UserProfile',
        );
      }

      final startTime = DateTime.now();
      final astrologyData = await userService.getFormattedAstrologyData();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      await LoggingHelper.logDebug(
        'Astrology data loaded in: ${duration.inMilliseconds}ms',
        source: 'UserProfile',
      );
      await LoggingHelper.logDebug(
        'Data received: ${astrologyData != null ? 'SUCCESS' : 'NULL'}',
        source: 'UserProfile',
      );
      if (astrologyData != null) {
        await LoggingHelper.logDebug(
          'Data keys: ${astrologyData.keys.toList()}',
          source: 'UserProfile',
        );
      } else {
        await LoggingHelper.logDebug(
          'Attempting fallback: calling astrology library directly...',
          source: 'UserProfile',
        );
        try {
          final bridge = AstrologyServiceBridge.instance();

          final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
            _currentUser!.latitude,
            _currentUser!.longitude,
          );

          final fixedBirthData = await bridge.getBirthData(
            localBirthDateTime: _currentUser!.localBirthDateTime,
            timezoneId: timezoneId,
            latitude: _currentUser!.latitude,
            longitude: _currentUser!.longitude,
            ayanamsha: _currentUser!.ayanamsha,
          );

          final rashiMap = fixedBirthData['rashi'] as Map<String, dynamic>?;
          final nakshatraMap =
              fixedBirthData['nakshatra'] as Map<String, dynamic>?;
          final padaMap = fixedBirthData['pada'] as Map<String, dynamic>?;
          final birthChartMap =
              fixedBirthData['birthChart'] as Map<String, dynamic>?;
          final dashaMap = fixedBirthData['dasha'] as Map<String, dynamic>?;
          final houseLords =
              birthChartMap?['houseLords'] as Map<String, dynamic>?;

          final fallbackData = {
            'moonRashi': rashiMap,
            'moonNakshatra': nakshatraMap,
            'moonPada': padaMap,
            'ascendant': houseLords?['House 1'] ?? 'Unknown',
            'birthChart': birthChartMap ?? {},
            'dasha': dashaMap ?? {},
            'calculatedAt': fixedBirthData['calculatedAt'] as String? ??
                DateTime.now().toIso8601String(),
          };

          await LoggingHelper.logDebug('Fallback data created successfully',
              source: 'UserProfile',);
          if (mounted) {
            setState(() {
              _astrologyData = fallbackData;
              _isLoadingAstrology = false;
            });
          }
          return;
        } on Exception catch (fallbackError) {
          await LoggingHelper.logError(
            'Fallback also failed: $fallbackError',
            error: fallbackError,
            stackTrace: StackTrace.current,
            source: 'UserProfile',
          );
        }
      }

      if (mounted) {
        setState(() {
          _astrologyData = astrologyData;
          _isLoadingAstrology = false;
        });
      }
    } on Exception catch (e) {
      await LoggingHelper.logError(
        'Error loading astrology data: $e',
        error: e,
        stackTrace: StackTrace.current,
        source: 'UserProfile',
      );
      if (mounted) {
        setState(() {
          _astrologyData = null;
          _isLoadingAstrology = false;
        });
      }
    }
  }

  void _startAstrologyRefreshTimer() {
    _astrologyRefreshTimer?.cancel();
    _astrologyRefreshTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_astrologyData == null &&
          _currentUser != null &&
          !_isLoadingAstrology) {
        _loadAstrologyData();
      } else if (_astrologyData != null) {
        // Stop timer once data is loaded
        timer.cancel();
      }

      // Stop timer after 30 seconds to prevent infinite polling
      if (timer.tick > 6) {
        // 6 * 5 seconds = 30 seconds
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _astrologyRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ResponsiveSystem.init(context); // Removed - not needed
    final translationService = ref.watch(translationServiceProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth:
                            ResponsiveSystem.spacing(context, baseSpacing: 3),
                      ),
                      ResponsiveSystem.sizedBox(
                        context,
                        height: ResponsiveSystem.spacing(
                          context,
                          baseSpacing: 16,
                        ),
                      ),
                      Text(
                        translationService.translateContent(
                          'loading_profile',
                          fallback: 'Loading profile...',
                        ),
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 16),
                          color: ThemeHelpers.getPrimaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: ThemeHelpers.getPrimaryTextColor(context),
                            size: ResponsiveSystem.iconSize(
                              context,
                              baseSize: 64,
                            ),
                          ),
                          ResponsiveSystem.sizedBox(
                            context,
                            height: ResponsiveSystem.spacing(
                              context,
                              baseSpacing: 16,
                            ),
                          ),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: ResponsiveSystem.fontSize(
                                context,
                                baseSize: 16,
                              ),
                              color: ThemeHelpers.getPrimaryTextColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          ResponsiveSystem.sizedBox(
                            context,
                            height: ResponsiveSystem.spacing(
                              context,
                              baseSpacing: 16,
                            ),
                          ),
                          ModernButton(
                            text: translationService.translateContent(
                              'retry',
                              fallback: 'Retry',
                            ),
                            onPressed: _loadUserData,
                            width: ResponsiveSystem.screenWidth(context) * 0.3,
                          ),
                        ],
                      ),
                    )
                  : _currentUser == null ||
                          !ProfileCompletionChecker.isProfileComplete(
                            _currentUser,
                          )
                      ? Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_add,
                                    color: ThemeHelpers.getPrimaryTextColor(
                                      context,
                                    ),
                                    size: ResponsiveSystem.iconSize(
                                      context,
                                      baseSize: 64,
                                    ),
                                  ),
                                  ResponsiveSystem.sizedBox(
                                    context,
                                    height: ResponsiveSystem.spacing(
                                      context,
                                      baseSpacing: 16,
                                    ),
                                  ),
                                  Text(
                                    _currentUser == null
                                        ? translationService.translateContent(
                                            'no_profile_found',
                                            fallback: 'No Profile Found',
                                          )
                                        : translationService.translateContent(
                                            'complete_your_profile',
                                            fallback: 'Complete Your Profile',
                                          ),
                                    style: TextStyle(
                                      fontSize: ResponsiveSystem.fontSize(
                                        context,
                                        baseSize: 20,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: ThemeHelpers.getPrimaryTextColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                  ResponsiveSystem.sizedBox(
                                    context,
                                    height: ResponsiveSystem.spacing(
                                      context,
                                      baseSpacing: 8,
                                    ),
                                  ),
                                  Text(
                                    'Create your profile to get started',
                                    style: TextStyle(
                                      fontSize: ResponsiveSystem.fontSize(
                                        context,
                                        baseSize: 16,
                                      ),
                                      color: ThemeHelpers.getSecondaryTextColor(
                                        context,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  ResponsiveSystem.sizedBox(
                                    context,
                                    height: ResponsiveSystem.spacing(
                                      context,
                                      baseSpacing: 24,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ModernButton(
                                        text:
                                            translationService.translateContent(
                                          'retry',
                                          fallback: 'Retry',
                                        ),
                                        onPressed: _loadUserData,
                                        icon: Icons.refresh,
                                        width: ResponsiveSystem.screenWidth(
                                              context,
                                            ) *
                                            0.25,
                                        backgroundColor:
                                            ThemeHelpers.getPrimaryColor(
                                          context,
                                        ).withValues(alpha: 0.1),
                                        textColor: ThemeHelpers.getPrimaryColor(
                                          context,
                                        ),
                                      ),
                                      ResponsiveSystem.sizedBox(
                                        context,
                                        width: ResponsiveSystem.spacing(
                                          context,
                                          baseSpacing: 12,
                                        ),
                                      ),
                                      ModernButton(
                                        text:
                                            translationService.translateContent(
                                          'create_profile',
                                          fallback: 'Create Profile',
                                        ),
                                        onPressed: () =>
                                            _editProfile(context, null),
                                        icon: Icons.person_add,
                                        width: ResponsiveSystem.screenWidth(
                                              context,
                                            ) *
                                            0.35,
                                        backgroundColor:
                                            ThemeHelpers.getSurfaceColor(
                                          context,
                                        ),
                                        textColor: ThemeHelpers.getPrimaryColor(
                                          context,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Back button positioned at top-left
                            Positioned(
                              top: ResponsiveSystem.spacing(
                                context,
                                baseSpacing: 16,
                              ),
                              left: ResponsiveSystem.spacing(
                                context,
                                baseSpacing: 16,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: ThemeHelpers.getPrimaryTextColor(
                                    context,
                                  ),
                                  size: ResponsiveSystem.iconSize(
                                    context,
                                    baseSize: 28,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
                                },
                                tooltip: 'Back to Home',
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      ThemeHelpers.getSurfaceColor(context)
                                          .withValues(alpha: 0.8),
                                  shape: const CircleBorder(),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Builder(
                          builder: (context) {
                            final user = _currentUser;

                            return CustomScrollView(
                              slivers: [
                                // App Bar
                                SliverAppBar(
                                  expandedHeight: ResponsiveSystem.spacing(
                                    context,
                                    baseSpacing: 120,
                                  ),
                                  pinned: true,
                                  backgroundColor:
                                      ThemeHelpers.getTransparentColor(
                                    context,
                                  ),
                                  elevation: 0,
                                  toolbarHeight: ResponsiveSystem.spacing(
                                    context,
                                    baseSpacing: 60,
                                  ),
                                  leading: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: ThemeHelpers.getPrimaryTextColor(
                                          context,),
                                      size: ResponsiveSystem.iconSize(
                                        context,
                                        baseSize: 28,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/',
                                        (route) => false,
                                      );
                                    },
                                    tooltip: 'Back to Home',
                                  ),
                                  flexibleSpace: FlexibleSpaceBar(
                                    title: Text(
                                      'Profile',
                                      style: TextStyle(
                                        fontSize: ResponsiveSystem.fontSize(
                                          context,
                                          baseSize: 18,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color: ThemeHelpers.getPrimaryTextColor(
                                            context,),
                                      ),
                                    ),
                                    background: Container(
                                      decoration: BoxDecoration(
                                        gradient:
                                            ThemeHelpers.getPrimaryGradient(
                                                context,),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    // Language Dropdown Widget
                                    LanguageDropdown(
                                      onLanguageChanged: (value) async {
                                        await LoggingHelper.logInfo(
                                          'Language changed to: $value',
                                        );
                                        ScreenHandlers.handleLanguageChange(
                                            ref, value,);
                                      },
                                    ),
                                    // Theme Dropdown Widget
                                    ThemeDropdown(
                                      onThemeChanged: (value) async {
                                        await LoggingHelper.logInfo(
                                          'Theme changed to: $value',
                                        );
                                        ScreenHandlers.handleThemeChange(
                                            ref, value,);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.share,
                                        color: ThemeHelpers.getPrimaryTextColor(
                                            context,),
                                        size: ResponsiveSystem.iconSize(
                                          context,
                                          baseSize: 24,
                                        ), // Consistent with other app bar icons
                                      ),
                                      onPressed: () => _shareProfile(
                                        context,
                                        user != null
                                            ? () {
                                                unawaited(
                                                  LoggingHelper.logDebug(
                                                    'Converting UserModel to UserEntity: name=${user.name}, length=${user.name.length}',
                                                    source: 'UserProfile',
                                                  ),
                                                );
                                                return entity.UserEntity(
                                                  id: user.id,
                                                  username: user.name,
                                                  dateOfBirth: user.dateOfBirth,
                                                  timeOfBirth:
                                                      entity.TimeOfBirth(
                                                    hour: user.timeOfBirth.hour,
                                                    minute:
                                                        user.timeOfBirth.minute,
                                                  ),
                                                  placeOfBirth:
                                                      user.placeOfBirth,
                                                  latitude: user.latitude,
                                                  longitude: user.longitude,
                                                  sex: user.sex,
                                                  // ayanamsha removed as it's not in UserEntity
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now(),
                                                );
                                              }()
                                            : null,
                                        translationService,
                                      ),
                                      tooltip:
                                          translationService.translateContent(
                                        'share_profile',
                                        fallback: 'Share Profile',
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: ThemeHelpers.getPrimaryTextColor(
                                            context,),
                                        size: ResponsiveSystem.iconSize(
                                          context,
                                          baseSize: 24,
                                        ), // Consistent with other app bar icons
                                      ),
                                      onPressed: () => _editProfile(
                                        context,
                                        user != null
                                            ? () {
                                                unawaited(
                                                  LoggingHelper.logDebug(
                                                    'Converting UserModel to UserEntity for edit: name=${user.name}, length=${user.name.length}',
                                                    source: 'UserProfile',
                                                  ),
                                                );
                                                return entity.UserEntity(
                                                  id: user.id,
                                                  username: user.name,
                                                  dateOfBirth: user.dateOfBirth,
                                                  timeOfBirth:
                                                      entity.TimeOfBirth(
                                                    hour: user.timeOfBirth.hour,
                                                    minute:
                                                        user.timeOfBirth.minute,
                                                  ),
                                                  placeOfBirth:
                                                      user.placeOfBirth,
                                                  latitude: user.latitude,
                                                  longitude: user.longitude,
                                                  sex: user.sex,
                                                  // ayanamsha removed as it's not in UserEntity
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now(),
                                                );
                                              }()
                                            : null,
                                      ),
                                      tooltip:
                                          translationService.translateContent(
                                        'edit_profile',
                                        fallback: 'Edit Profile',
                                      ),
                                    ),
                                  ],
                                ),

                                // Profile Content
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: ResponsiveSystem.only(
                                      context,
                                      top: ResponsiveSystem.spacing(
                                        context,
                                        baseSpacing: 20,
                                      ),
                                      left: ResponsiveSystem.spacing(
                                        context,
                                        baseSpacing: 16,
                                      ),
                                      right: ResponsiveSystem.spacing(
                                        context,
                                        baseSpacing: 16,
                                      ),
                                      bottom: ResponsiveSystem.spacing(
                                        context,
                                        baseSpacing: 16,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Profile Header
                                        ProfileHeaderWidget(
                                          user: user,
                                          onProfilePictureChanged:
                                              (imagePath) =>
                                                  _handleProfilePictureChanged(
                                            imagePath,
                                            translationService,
                                          ),
                                        ),

                                        ResponsiveSystem.sizedBox(
                                          context,
                                          height: ResponsiveSystem.spacing(
                                            context,
                                            baseSpacing: 24,
                                          ),
                                        ),

                                        // Profile Statistics - Removed widget
                                        // ProfileStatisticsWidget(user: user),

                                        ResponsiveSystem.sizedBox(
                                          context,
                                          height: ResponsiveSystem.spacing(
                                            context,
                                            baseSpacing: 24,
                                          ),
                                        ),

                                        // Personal Information
                                        ProfileInfoCard(
                                          title: 'Personal Information',
                                          icon: Icons.face,
                                          children: [
                                            _buildInfoRow(
                                              'Name',
                                              (user?.name.isNotEmpty ?? false)
                                                  ? user!.name
                                                  : ((user?.username
                                                              ?.isNotEmpty ??
                                                          false)
                                                      ? user!.username!
                                                      : 'Not provided'),
                                            ),
                                            _buildInfoRow(
                                              'Date of Birth',
                                              _formatDate(
                                                user?.dateOfBirth,
                                              ),
                                            ),
                                            _buildInfoRow(
                                              'Time of Birth',
                                              _formatTime(
                                                user?.timeOfBirth,
                                              ),
                                            ),
                                            _buildInfoRow(
                                              'Place of Birth',
                                              user?.placeOfBirth ??
                                                  'Not provided',
                                            ),
                                            _buildInfoRow(
                                              'Gender',
                                              user?.sex ?? 'Not specified',
                                            ),
                                          ],
                                        ),

                                        ResponsiveSystem.sizedBox(
                                          context,
                                          height: ResponsiveSystem.spacing(
                                            context,
                                            baseSpacing: 16,
                                          ),
                                        ),

                                        // Astrological Information
                                        ProfileInfoCard(
                                          title: 'Birth Chart Information',
                                          icon: Icons.star,
                                          onTap: _astrologyData == null
                                              ? _loadAstrologyData
                                              : null,
                                          children: [
                                            _buildAstrologyInfoRow(
                                              'Moon Sign (Rashi)',
                                              _getAstrologyValue(
                                                'moonRashi',
                                              ),
                                              rashiNumber:
                                                  _getAstrologyRashiNumber(
                                                'moonRashi',
                                              ),
                                            ),
                                            _buildAstrologyInfoRow(
                                              'Birth Star (Nakshatra)',
                                              _getAstrologyValue(
                                                'moonNakshatra',
                                              ),
                                              nakshatraNumber:
                                                  _getAstrologyNakshatraNumber(
                                                'moonNakshatra',
                                              ),
                                            ),
                                            _buildAstrologyInfoRow(
                                              'Star Quarter (Pada)',
                                              _getAstrologyValue(
                                                'moonPada',
                                              ),
                                            ),
                                            _buildAstrologyInfoRow(
                                              'Rising Sign (Ascendant)',
                                              _getAstrologyValue(
                                                'ascendant',
                                              ),
                                              rashiNumber:
                                                  _getAstrologyRashiNumber(
                                                'ascendant',
                                              ),
                                            ),
                                          ],
                                        ),

                                        ResponsiveSystem.sizedBox(
                                          context,
                                          height: ResponsiveSystem.spacing(
                                            context,
                                            baseSpacing: 24,
                                          ),
                                        ),

                                        // App Information
                                        ProfileInfoCard(
                                          title: 'Application Information',
                                          icon: Icons.info,
                                          children: [
                                            _buildInfoRow(
                                              'App Version',
                                              AppConstants.appVersion,
                                            ),
                                            _buildInfoRow(
                                              'Profile Status',
                                              'Active',
                                            ),
                                            _buildInfoRow(
                                              'Data Source',
                                              'Local Storage',
                                            ),
                                          ],
                                        ),

                                        ResponsiveSystem.sizedBox(
                                          context,
                                          height: 32,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: ResponsiveSystem.symmetric(
        context,
        vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 15),
                fontWeight: FontWeight.w700,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 15),
                color: ThemeHelpers.getSecondaryTextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstrologyInfoRow(
    String label,
    String value, {
    int? rashiNumber,
    int? nakshatraNumber,
  }) {
    return InfoRow(
      label: label,
      value: value,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not provided';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfBirth? time) {
    if (time == null) return 'Not provided';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getAstrologyValue(String key) {
    if (_isLoadingAstrology) {
      return 'Calculating...';
    }

    if (_astrologyData == null) {
      return 'Tap to calculate';
    }

    final dynamic value = _astrologyData![key];

    if (value == null || value.toString().isEmpty) {
      return 'Not available';
    }
    return _convertToUserFriendlyText(key, value);
  }

  String _convertToUserFriendlyText(String key, dynamic value) {
    if (value is Map<String, dynamic>) {
      if (value.containsKey('englishName')) {
        return value['englishName'] as String? ?? 'Unknown';
      } else if (value.containsKey('name')) {
        return value['name'] as String? ?? 'Unknown';
      } else if (value.containsKey('number')) {
        return '${value['number']}';
      }
      return 'Unknown';
    } else if (value is String) {
      if (key.toLowerCase().contains('nakshatra') && value.contains(' ')) {
        // Extract just the name part (everything after the first space)
        final parts = value.split(' ');
        if (parts.length > 1) {
          return parts.skip(1).join(' ');
        }
      }
      return value; // Already a string, return as is
    } else if (value is int) {
      switch (key.toLowerCase()) {
        case 'moonrashi':
        case 'rashi':
        case 'moonsign':
          // Use direct property access from birth data if available
          return 'Rashi $value'; // Simplified display
        case 'moonnakshatra':
        case 'nakshatra':
        case 'birthstar':
          return 'Nakshatra $value'; // Simplified display
        case 'moonpada':
        case 'pada':
        case 'starquarter':
          return 'Pada $value'; // Simplified display
        case 'ascendant':
        case 'rising_sign':
        case 'lagna':
          return 'Lagna $value'; // Simplified display
        default:
          return value.toString();
      }
    }

    return value.toString();
  }

  int? _getAstrologyRashiNumber(String key) {
    if (_astrologyData == null) return null;

    final dynamic value = _astrologyData![key];
    if (value is Map<String, dynamic>) {
      return value['number'] as int?;
    } else if (value is int) {
      return value;
    }
    return null;
  }

  int? _getAstrologyNakshatraNumber(String key) {
    if (_astrologyData == null) return null;

    final dynamic value = _astrologyData![key];
    if (value is Map<String, dynamic>) {
      return value['number'] as int?;
    } else if (value is int) {
      return value;
    }
    return null;
  }

  // Duplicate methods removed - now using centralized AstrologyUtils

  Future<void> _handleProfilePictureChanged(
    String? imagePath,
    TranslationService translationService,
  ) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = entity.UserEntity(
        id: _currentUser!.id,
        username: _currentUser!.name,
        dateOfBirth: _currentUser!.dateOfBirth,
        timeOfBirth: entity.TimeOfBirth(
          hour: _currentUser!.timeOfBirth.hour,
          minute: _currentUser!.timeOfBirth.minute,
        ),
        placeOfBirth: _currentUser!.placeOfBirth,
        sex: _currentUser!.sex,
        latitude: _currentUser!.latitude,
        longitude: _currentUser!.longitude,
      );

      final userService = ref.read(userServiceProvider.notifier);
      final userModel = UserModel.create(
        name: updatedUser.username,
        dateOfBirth: updatedUser.dateOfBirth,
        timeOfBirth: TimeOfBirth(
          hour: updatedUser.timeOfBirth.hour,
          minute: updatedUser.timeOfBirth.minute,
        ),
        placeOfBirth: updatedUser.placeOfBirth,
        latitude: updatedUser.latitude,
        longitude: updatedUser.longitude,
        sex: updatedUser.sex,
      );
      await userService.setUser(userModel);

      setState(() {
        _currentUser = userModel;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              imagePath != null
                  ? 'Profile picture updated!'
                  : 'Profile picture removed!',
            ),
            backgroundColor: ThemeHelpers.getPrimaryColor(context),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              translationService.translateContent(
                'error_updating_profile_picture',
                fallback: 'Error updating profile picture: $e',
              ),
            ),
            backgroundColor: ThemeHelpers.getErrorColor(context),
          ),
        );
      }
    }
  }

  Future<void> _editProfile(
      BuildContext context, entity.UserEntity? user,) async {
    // Store current user data to detect changes
    final previousUser = _currentUser;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserEditScreen(),
      ),
    );

    // Refresh user data when returning from edit screen
    await _loadUserData();

    final currentUser = _currentUser;
    bool userDataChanged = false;

    if (previousUser != null && currentUser != null) {
      userDataChanged = previousUser.dateOfBirth != currentUser.dateOfBirth ||
          previousUser.timeOfBirth != currentUser.timeOfBirth ||
          previousUser.placeOfBirth != currentUser.placeOfBirth ||
          previousUser.latitude != currentUser.latitude ||
          previousUser.longitude != currentUser.longitude;
    } else if (currentUser != null) {
      // New user created
      userDataChanged = true;
    }

    if (userDataChanged && currentUser != null) {
      setState(() {
        _astrologyData = null;
      });
      await _loadAstrologyData();
    } else if (currentUser != null) {
      // Just reload astrology data (no changes detected)
      await _loadAstrologyData();
    }
  }

  void _shareProfile(
    BuildContext context,
    entity.UserEntity? user,
    TranslationService translationService,
  ) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translationService.translateContent(
              'no_profile_to_share',
              fallback: 'No profile to share',
            ),
          ),
          backgroundColor: ThemeHelpers.getPrimaryColor(context),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          translationService.translateContent(
            'profile_sharing_coming_soon',
            fallback: 'Profile sharing feature coming soon',
          ),
        ),
        backgroundColor: ThemeHelpers.getPrimaryColor(context),
      ),
    );
  }
}
