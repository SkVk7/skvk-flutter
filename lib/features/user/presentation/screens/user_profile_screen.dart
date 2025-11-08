/// Modern User Profile Screen
///
/// A comprehensive user profile screen with Hindu traditional aesthetics
/// accessible from all screens in the application
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/constants/app_constants.dart';

import '../../../../core/utils/validation/profile_completion_checker.dart';
import '../../../../core/services/user/user_service.dart';
import '../../../../core/models/user/user_model.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../features/user/domain/entities/user_entity.dart' as entity;

import '../../../../shared/widgets/common/centralized_widgets.dart';
import '../../../../core/services/language/translation_service.dart';
import '../../../../core/design_system/theme/theme_provider.dart';
import '../../../../core/services/language/language_service.dart';
import '../../../../core/logging/logging_helper.dart';
import '../../../../core/services/astrology/astrology_service_bridge.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_info_card.dart';
import '../screens/user_edit_screen.dart';

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
    // Add a small delay to ensure any previous save operations are complete
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadUserData();
        // Also refresh astrology data to get the latest computed data
        if (_currentUser != null) {
          _loadAstrologyData();
        }
      }
    });
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
      await Future.delayed(const Duration(milliseconds: 100));

      // Check the provider state directly
      final userFromState = ref.read(userServiceProvider);
      AppLogger.debug(
          'User from provider state: ${userFromState != null ? 'FOUND' : 'NULL'}',
          'UserProfile');

      if (userFromState != null) {
        AppLogger.debug(
            'User details: ${userFromState.name}, DOB: ${userFromState.dateOfBirth}, TOB: ${userFromState.timeOfBirth}',
            'UserProfile');
        AppLogger.debug(
            'Location: ${userFromState.latitude}, ${userFromState.longitude}',
            'UserProfile');
        AppLogger.debug(
            'User name length: ${userFromState.name.length}, isEmpty: ${userFromState.name.isEmpty}',
            'UserProfile');
      } else {
        AppLogger.debug('User from state is NULL', 'UserProfile');
      }

      // Also try the getCurrentUser method as fallback
      final result = await userService.getCurrentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return ResultHelper.failure(
            UnexpectedFailure(message: 'Request timeout'),
          );
        },
      );

      final user = ResultHelper.isSuccess(result)
          ? ResultHelper.getValue(result)
          : userFromState;

      AppLogger.debug(
          'User loading result: ${ResultHelper.isSuccess(result) ? 'SUCCESS' : 'FAILURE'}',
          'UserProfile');
      if (user != null) {
        AppLogger.debug(
            'Final user details: ${user.name}, DOB: ${user.dateOfBirth}, TOB: ${user.timeOfBirth}',
            'UserProfile');
        AppLogger.debug(
            'Location: ${user.latitude}, ${user.longitude}', 'UserProfile');
        AppLogger.debug(
            'User name length: ${user.name.length}, isEmpty: ${user.name.isEmpty}',
            'UserProfile');
      } else {
        AppLogger.debug('No user data received', 'UserProfile');
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
          _errorMessage = null; // Clear any previous error messages
        });

        // Load astrology data if user exists
        if (user != null) {
          AppLogger.debug(
              'User loaded, starting astrology data load...', 'UserProfile');
          _loadAstrologyData();
          _startAstrologyRefreshTimer();
        } else {
          AppLogger.debug(
              'No user found, skipping astrology data load', 'UserProfile');
        }
      }
    } catch (e) {
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
      } catch (fallbackError) {
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
      AppLogger.debug('Loading astrology data for user: ${_currentUser!.name}',
          'UserProfile');
      AppLogger.debug(
          'Birth details: ${_currentUser!.dateOfBirth} ${_currentUser!.timeOfBirth}',
          'UserProfile');
      AppLogger.debug(
          'Location: ${_currentUser!.latitude}, ${_currentUser!.longitude}',
          'UserProfile');

      // Check if user service has the user data
      final userServiceState = ref.read(userServiceProvider);
      AppLogger.debug(
          'User service state: ${userServiceState != null ? 'HAS_USER' : 'NO_USER'}',
          'UserProfile');
      if (userServiceState != null) {
        AppLogger.debug(
            'User service user: ${userServiceState.name}', 'UserProfile');
      }

      final startTime = DateTime.now();
      final astrologyData = await userService.getFormattedAstrologyData();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      AppLogger.debug('Astrology data loaded in: ${duration.inMilliseconds}ms',
          'UserProfile');
      AppLogger.debug(
          'Data received: ${astrologyData != null ? 'SUCCESS' : 'NULL'}',
          'UserProfile');
      if (astrologyData != null) {
        AppLogger.debug(
            'Data keys: ${astrologyData.keys.toList()}', 'UserProfile');
      } else {
        AppLogger.debug(
            'Attempting fallback: calling astrology library directly...',
            'UserProfile');
        try {
          final bridge = AstrologyServiceBridge.instance;

          // Get timezone from user's location
          final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
              _currentUser!.latitude, _currentUser!.longitude);

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

          AppLogger.debug('Fallback data created successfully', 'UserProfile');
          if (mounted) {
            setState(() {
              _astrologyData = fallbackData;
              _isLoadingAstrology = false;
            });
          }
          return;
        } catch (fallbackError) {
          AppLogger.error('Fallback also failed: $fallbackError', fallbackError,
              StackTrace.current, 'UserProfile');
        }
      }

      if (mounted) {
        setState(() {
          _astrologyData = astrologyData;
          _isLoadingAstrology = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading astrology data: $e', e, StackTrace.current,
          'UserProfile');
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
    // Initialize responsive sizing
    // ResponsiveSystem.init(context); // Removed - not needed
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
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth:
                            ResponsiveSystem.spacing(context, baseSpacing: 3),
                      ),
                      ResponsiveSystem.sizedBox(context,
                          height: ResponsiveSystem.spacing(context,
                              baseSpacing: 16)),
                      Text(
                        translationService.translateContent('loading_profile',
                            fallback: 'Loading profile...'),
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 16),
                          color: ThemeProperties.getPrimaryTextColor(context),
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
                            color: ThemeProperties.getPrimaryTextColor(context),
                            size: ResponsiveSystem.iconSize(context,
                                baseSize: 64),
                          ),
                          ResponsiveSystem.sizedBox(context,
                              height: ResponsiveSystem.spacing(context,
                                  baseSpacing: 16)),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: ResponsiveSystem.fontSize(context,
                                  baseSize: 16),
                              color:
                                  ThemeProperties.getPrimaryTextColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          ResponsiveSystem.sizedBox(context,
                              height: ResponsiveSystem.spacing(context,
                                  baseSpacing: 16)),
                          CentralizedModernButton(
                            text: translationService.translateContent('retry',
                                fallback: 'Retry'),
                            onPressed: _loadUserData,
                            width: ResponsiveSystem.screenWidth(context) * 0.3,
                          ),
                        ],
                      ),
                    )
                  : _currentUser == null ||
                          !ProfileCompletionChecker.isProfileComplete(
                              _currentUser)
                      ? Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_add,
                                    color: ThemeProperties.getPrimaryTextColor(
                                        context),
                                    size: ResponsiveSystem.iconSize(context,
                                        baseSize: 64),
                                  ),
                                  ResponsiveSystem.sizedBox(context,
                                      height: ResponsiveSystem.spacing(context,
                                          baseSpacing: 16)),
                                  Text(
                                    _currentUser == null
                                        ? translationService.translateContent(
                                            'no_profile_found',
                                            fallback: 'No Profile Found')
                                        : translationService.translateContent(
                                            'complete_your_profile',
                                            fallback: 'Complete Your Profile'),
                                    style: TextStyle(
                                      fontSize: ResponsiveSystem.fontSize(
                                          context,
                                          baseSize: 20),
                                      fontWeight: FontWeight.bold,
                                      color:
                                          ThemeProperties.getPrimaryTextColor(
                                              context),
                                    ),
                                  ),
                                  ResponsiveSystem.sizedBox(context,
                                      height: ResponsiveSystem.spacing(context,
                                          baseSpacing: 8)),
                                  Text(
                                    'Create your profile to get started',
                                    style: TextStyle(
                                      fontSize: ResponsiveSystem.fontSize(
                                          context,
                                          baseSize: 16),
                                      color:
                                          ThemeProperties.getSecondaryTextColor(
                                              context),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  ResponsiveSystem.sizedBox(context,
                                      height: ResponsiveSystem.spacing(context,
                                          baseSpacing: 24)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CentralizedModernButton(
                                        text: translationService
                                            .translateContent('retry',
                                                fallback: 'Retry'),
                                        onPressed: () => _loadUserData(),
                                        icon: Icons.refresh,
                                        width: ResponsiveSystem.screenWidth(
                                                context) *
                                            0.25,
                                        backgroundColor:
                                            ThemeProperties.getPrimaryColor(
                                                    context)
                                                .withAlpha((0.1 * 255).round()),
                                        textColor:
                                            ThemeProperties.getPrimaryColor(
                                                context),
                                      ),
                                      ResponsiveSystem.sizedBox(context,
                                          width: ResponsiveSystem.spacing(
                                              context,
                                              baseSpacing: 12)),
                                      CentralizedModernButton(
                                        text: translationService
                                            .translateContent('create_profile',
                                                fallback: 'Create Profile'),
                                        onPressed: () =>
                                            _editProfile(context, null),
                                        icon: Icons.person_add,
                                        width: ResponsiveSystem.screenWidth(
                                                context) *
                                            0.35,
                                        backgroundColor:
                                            ThemeProperties.getSurfaceColor(
                                                context),
                                        textColor:
                                            ThemeProperties.getPrimaryColor(
                                                context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Back button positioned at top-left
                            Positioned(
                              top: ResponsiveSystem.spacing(context,
                                  baseSpacing: 16),
                              left: ResponsiveSystem.spacing(context,
                                  baseSpacing: 16),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: ThemeProperties.getPrimaryTextColor(
                                      context),
                                  size: ResponsiveSystem.iconSize(context,
                                      baseSize: 28),
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
                                      ThemeProperties.getSurfaceColor(context)
                                          .withAlpha((0.8 * 255).round()),
                                  shape: const CircleBorder(),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Builder(
                          builder: (context) {
                            final user = _currentUser;

                            return CentralizedFadeAnimation(
                              child: CentralizedSlideAnimation(
                                child: CustomScrollView(
                                  slivers: [
                                    // App Bar
                                    SliverAppBar(
                                      expandedHeight: ResponsiveSystem.spacing(
                                          context,
                                          baseSpacing: 120),
                                      floating: false,
                                      pinned: true,
                                      backgroundColor:
                                          ThemeProperties.getTransparentColor(
                                              context),
                                      elevation: 0,
                                      toolbarHeight: ResponsiveSystem.spacing(
                                          context,
                                          baseSpacing: 60),
                                      leading: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: ThemeProperties
                                              .getPrimaryTextColor(context),
                                          size: ResponsiveSystem.iconSize(
                                              context,
                                              baseSize: 28),
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
                                                baseSize: 18),
                                            fontWeight: FontWeight.bold,
                                            color: ThemeProperties
                                                .getPrimaryTextColor(context),
                                          ),
                                        ),
                                        background: Container(
                                          decoration: BoxDecoration(
                                            gradient: ThemeProperties
                                                .getPrimaryGradient(context),
                                          ),
                                        ),
                                        collapseMode: CollapseMode.parallax,
                                      ),
                                      actions: [
                                        // Language Dropdown Widget
                                        CentralizedLanguageDropdown(
                                          onLanguageChanged: (value) {
                                            LoggingHelper.logInfo(
                                                'Language changed to: $value');
                                            _handleLanguageChange(ref, value);
                                          },
                                        ),
                                        // Theme Dropdown Widget
                                        CentralizedThemeDropdown(
                                          onThemeChanged: (value) {
                                            LoggingHelper.logInfo(
                                                'Theme changed to: $value');
                                            _handleThemeChange(ref, value);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.share,
                                            color: ThemeProperties
                                                .getPrimaryTextColor(context),
                                            size: ResponsiveSystem.iconSize(
                                                context,
                                                baseSize:
                                                    24), // Consistent with other app bar icons
                                          ),
                                          onPressed: () => _shareProfile(
                                              context,
                                              user != null
                                                  ? () {
                                                      AppLogger.debug(
                                                          'Converting UserModel to UserEntity: name=${user.name}, length=${user.name.length}',
                                                          'UserProfile');
                                                      return entity.UserEntity(
                                                        id: user.id,
                                                        username: user.name,
                                                        dateOfBirth:
                                                            user.dateOfBirth,
                                                        timeOfBirth:
                                                            entity.TimeOfBirth(
                                                          hour: user
                                                              .timeOfBirth.hour,
                                                          minute: user
                                                              .timeOfBirth
                                                              .minute,
                                                        ),
                                                        placeOfBirth:
                                                            user.placeOfBirth,
                                                        latitude: user.latitude,
                                                        longitude:
                                                            user.longitude,
                                                        sex: user.sex,
                                                        // ayanamsha removed as it's not in UserEntity
                                                        createdAt:
                                                            DateTime.now(),
                                                        updatedAt:
                                                            DateTime.now(),
                                                      );
                                                    }()
                                                  : null,
                                              translationService),
                                          tooltip: translationService
                                              .translateContent('share_profile',
                                                  fallback: 'Share Profile'),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: ThemeProperties
                                                .getPrimaryTextColor(context),
                                            size: ResponsiveSystem.iconSize(
                                                context,
                                                baseSize:
                                                    24), // Consistent with other app bar icons
                                          ),
                                          onPressed: () => _editProfile(
                                              context,
                                              user != null
                                                  ? () {
                                                      AppLogger.debug(
                                                          'Converting UserModel to UserEntity for edit: name=${user.name}, length=${user.name.length}',
                                                          'UserProfile');
                                                      return entity.UserEntity(
                                                        id: user.id,
                                                        username: user.name,
                                                        dateOfBirth:
                                                            user.dateOfBirth,
                                                        timeOfBirth:
                                                            entity.TimeOfBirth(
                                                          hour: user
                                                              .timeOfBirth.hour,
                                                          minute: user
                                                              .timeOfBirth
                                                              .minute,
                                                        ),
                                                        placeOfBirth:
                                                            user.placeOfBirth,
                                                        latitude: user.latitude,
                                                        longitude:
                                                            user.longitude,
                                                        sex: user.sex,
                                                        // ayanamsha removed as it's not in UserEntity
                                                        createdAt:
                                                            DateTime.now(),
                                                        updatedAt:
                                                            DateTime.now(),
                                                      );
                                                    }()
                                                  : null),
                                          tooltip: translationService
                                              .translateContent('edit_profile',
                                                  fallback: 'Edit Profile'),
                                        ),
                                      ],
                                    ),

                                    // Profile Content
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: ResponsiveSystem.only(
                                          context,
                                          top: ResponsiveSystem.spacing(context,
                                              baseSpacing: 20),
                                          left: ResponsiveSystem.spacing(
                                              context,
                                              baseSpacing: 16),
                                          right: ResponsiveSystem.spacing(
                                              context,
                                              baseSpacing: 16),
                                          bottom: ResponsiveSystem.spacing(
                                              context,
                                              baseSpacing: 16),
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
                                                          translationService),
                                            ),

                                            ResponsiveSystem.sizedBox(context,
                                                height:
                                                    ResponsiveSystem.spacing(
                                                        context,
                                                        baseSpacing: 24)),

                                            // Profile Statistics - Removed widget
                                            // ProfileStatisticsWidget(user: user),

                                            ResponsiveSystem.sizedBox(context,
                                                height:
                                                    ResponsiveSystem.spacing(
                                                        context,
                                                        baseSpacing: 24)),

                                            // Personal Information
                                            ProfileInfoCard(
                                              title: 'Personal Information',
                                              icon: Icons.face,
                                              children: [
                                                _buildInfoRow(
                                                    'Name',
                                                    (user?.name.isNotEmpty ==
                                                            true)
                                                        ? user!.name
                                                        : ((user?.username
                                                                    ?.isNotEmpty ==
                                                                true)
                                                            ? user!.username!
                                                            : 'Not provided')),
                                                _buildInfoRow(
                                                    'Date of Birth',
                                                    _formatDate(
                                                        user?.dateOfBirth)),
                                                _buildInfoRow(
                                                    'Time of Birth',
                                                    _formatTime(
                                                        user?.timeOfBirth)),
                                                _buildInfoRow(
                                                    'Place of Birth',
                                                    user?.placeOfBirth ??
                                                        'Not provided'),
                                                _buildInfoRow(
                                                    'Gender',
                                                    user?.sex ??
                                                        'Not specified'),
                                              ],
                                            ),

                                            ResponsiveSystem.sizedBox(context,
                                                height:
                                                    ResponsiveSystem.spacing(
                                                        context,
                                                        baseSpacing: 16)),

                                            // Astrological Information
                                            ProfileInfoCard(
                                              title: 'Birth Chart Information',
                                              icon: Icons.star,
                                              onTap: _astrologyData == null
                                                  ? () => _loadAstrologyData()
                                                  : null,
                                              children: [
                                                _buildAstrologyInfoRow(
                                                    'Moon Sign (Rashi)',
                                                    _getAstrologyValue(
                                                        'moonRashi'),
                                                    rashiNumber:
                                                        _getAstrologyRashiNumber(
                                                            'moonRashi')),
                                                _buildAstrologyInfoRow(
                                                    'Birth Star (Nakshatra)',
                                                    _getAstrologyValue(
                                                        'moonNakshatra'),
                                                    nakshatraNumber:
                                                        _getAstrologyNakshatraNumber(
                                                            'moonNakshatra')),
                                                _buildAstrologyInfoRow(
                                                    'Star Quarter (Pada)',
                                                    _getAstrologyValue(
                                                        'moonPada')),
                                                _buildAstrologyInfoRow(
                                                    'Rising Sign (Ascendant)',
                                                    _getAstrologyValue(
                                                        'ascendant'),
                                                    rashiNumber:
                                                        _getAstrologyRashiNumber(
                                                            'ascendant')),
                                              ],
                                            ),

                                            ResponsiveSystem.sizedBox(context,
                                                height:
                                                    ResponsiveSystem.spacing(
                                                        context,
                                                        baseSpacing: 24)),

                                            // App Information
                                            ProfileInfoCard(
                                              title: 'Application Information',
                                              icon: Icons.info,
                                              children: [
                                                _buildInfoRow('App Version',
                                                    AppConstants.appVersion),
                                                _buildInfoRow(
                                                    'Profile Status', 'Active'),
                                                _buildInfoRow('Data Source',
                                                    'Local Storage'),
                                              ],
                                            ),

                                            ResponsiveSystem.sizedBox(context,
                                                height: 32),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 15),
                color: ThemeProperties.getSecondaryTextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstrologyInfoRow(String label, String value,
      {int? rashiNumber, int? nakshatraNumber}) {
    return CentralizedInfoRow(
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

    // Get value from the structured data
    dynamic value = _astrologyData![key];

    if (value == null || value.toString().isEmpty) {
      return 'Not available';
    }
    // Convert to user-friendly text
    return _convertToUserFriendlyText(key, value);
  }

  String _convertToUserFriendlyText(String key, dynamic value) {
    // Handle different data types from the API
    if (value is Map<String, dynamic>) {
      // Handle Map data from API
      if (value.containsKey('englishName')) {
        return value['englishName'] as String? ?? 'Unknown';
      } else if (value.containsKey('name')) {
        return value['name'] as String? ?? 'Unknown';
      } else if (value.containsKey('number')) {
        return '${value['number']}';
      }
      return 'Unknown';
    } else if (value is String) {
      // Handle string values - check if it contains symbol concatenation
      if (key.toLowerCase().contains('nakshatra') && value.contains(' ')) {
        // If nakshatra string contains spaces, it might have symbol concatenated
        // Extract just the name part (everything after the first space)
        final parts = value.split(' ');
        if (parts.length > 1) {
          // Return everything except the first part (which might be the symbol)
          return parts.skip(1).join(' ');
        }
      }
      return value; // Already a string, return as is
    } else if (value is int) {
      // Handle numeric values for backward compatibility
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

    dynamic value = _astrologyData![key];
    if (value is Map<String, dynamic>) {
      return value['number'] as int?;
    } else if (value is int) {
      return value;
    }
    return null;
  }

  int? _getAstrologyNakshatraNumber(String key) {
    if (_astrologyData == null) return null;

    dynamic value = _astrologyData![key];
    if (value is Map<String, dynamic>) {
      return value['number'] as int?;
    } else if (value is int) {
      return value;
    }
    return null;
  }

  // Duplicate methods removed - now using centralized AstrologyUtils

  void _handleProfilePictureChanged(
      String? imagePath, TranslationService translationService) async {
    if (_currentUser == null) return;

    try {
      // Create updated user with new profile picture path
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

      // Update user in service
      final userService = ref.read(userServiceProvider.notifier);
      // Convert UserEntity back to UserModel for service
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

      // Update local state
      setState(() {
        _currentUser = userModel;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(imagePath != null
                ? 'Profile picture updated!'
                : 'Profile picture removed!'),
            backgroundColor: ThemeProperties.getPrimaryColor(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translationService.translateContent(
                'error_updating_profile_picture',
                fallback: 'Error updating profile picture: $e')),
            backgroundColor: ThemeProperties.getErrorColor(context),
          ),
        );
      }
    }
  }

  void _editProfile(BuildContext context, entity.UserEntity? user) async {
    // Store current user data to detect changes
    final previousUser = _currentUser;

    // Navigate to edit screen using proper navigation
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserEditScreen(),
      ),
    );

    // Refresh user data when returning from edit screen
    await _loadUserData();

    // Check if user data has changed (birth details, location, etc.)
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

    // If user data changed, clear astrology cache and reload
    if (userDataChanged && currentUser != null) {
      // Clear astrology data to force recalculation
      setState(() {
        _astrologyData = null;
      });
      await _loadAstrologyData();
    } else if (currentUser != null) {
      // Just reload astrology data (no changes detected)
      await _loadAstrologyData();
    }
  }

  void _shareProfile(BuildContext context, entity.UserEntity? user,
      TranslationService translationService) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translationService.translateContent(
              'no_profile_to_share',
              fallback: 'No profile to share')),
          backgroundColor: ThemeProperties.getPrimaryColor(context),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translationService.translateContent(
            'profile_sharing_coming_soon',
            fallback: 'Profile sharing feature coming soon')),
        backgroundColor: ThemeProperties.getPrimaryColor(context),
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
}
