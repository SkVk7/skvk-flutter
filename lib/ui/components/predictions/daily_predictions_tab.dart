import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/services/astrology/astrology_service_bridge.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/core/services/user/user_service.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:skvk_application/core/utils/validation/error_message_helper.dart';
import 'package:skvk_application/core/utils/validation/profile_completion_checker.dart';

class DailyPredictionsTab extends ConsumerStatefulWidget {
  const DailyPredictionsTab({super.key});

  @override
  ConsumerState<DailyPredictionsTab> createState() =>
      _DailyPredictionsTabState();
}

class _DailyPredictionsTabState extends ConsumerState<DailyPredictionsTab> {
  Map<String, String>? _dailyPrediction;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _fetchDailyPredictions();
  }

  Future<void> _fetchDailyPredictions() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final translationService = ref.read(translationServiceProvider);

      final userService = ref.read(userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      final user =
          ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

      if (user == null || !ProfileCompletionChecker.isProfileComplete(user)) {
        if (mounted) {
          unawaited(Navigator.pushNamed(context, '/edit-profile'));
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final currentUser = user;
      final birthDate = currentUser.localBirthDateTime;

      // Use AstrologyServiceBridge for timezone handling
      final bridge = AstrologyServiceBridge.instance();

      final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
        currentUser.latitude,
        currentUser.longitude,
      );

      final birthData = await bridge.getBirthData(
        localBirthDateTime: birthDate,
        timezoneId: timezoneId,
        latitude: currentUser.latitude,
        longitude: currentUser.longitude,
        ayanamsha: currentUser.ayanamsha,
      );

      final rashiMap = birthData['rashi'] as Map<String, dynamic>?;
      final nakshatraMap = birthData['nakshatra'] as Map<String, dynamic>?;
      final padaMap = birthData['pada'] as Map<String, dynamic>?;

      final moonData = {
        'nakshatra': nakshatraMap?['number'] as int? ?? 0,
        'pada': padaMap?['number'] as int? ?? 0,
        'rashi': rashiMap?['number'] as int? ?? 0,
      };

      final precisePredictions = await bridge.getPredictions(
        localBirthDateTime: birthDate,
        birthTimezoneId: timezoneId,
        birthLatitude: currentUser.latitude,
        birthLongitude: currentUser.longitude,
        localTargetDateTime: DateTime.now(),
        targetTimezoneId: timezoneId,
        currentLatitude: currentUser.latitude,
        currentLongitude: currentUser.longitude,
        predictionType: 'daily',
        ayanamsha: currentUser.ayanamsha,
      );

      // Store prediction data from API
      // Extract prediction data from API response
      final rashiNameMap = {
        1: 'Aries',
        2: 'Taurus',
        3: 'Gemini',
        4: 'Cancer',
        5: 'Leo',
        6: 'Virgo',
        7: 'Libra',
        8: 'Scorpio',
        9: 'Sagittarius',
        10: 'Capricorn',
        11: 'Aquarius',
        12: 'Pisces',
      };

      final nakshatraNameMap = {
        1: 'Ashwini',
        2: 'Bharani',
        3: 'Krittika',
        4: 'Rohini',
        5: 'Mrigashira',
        6: 'Ardra',
        7: 'Punarvasu',
        8: 'Pushya',
        9: 'Ashlesha',
        10: 'Magha',
        11: 'Purva Phalguni',
        12: 'Uttara Phalguni',
        13: 'Hasta',
        14: 'Chitra',
        15: 'Swati',
        16: 'Vishakha',
        17: 'Anuradha',
        18: 'Jyeshtha',
        19: 'Mula',
        20: 'Purva Ashadha',
        21: 'Uttara Ashadha',
        22: 'Shravana',
        23: 'Dhanishtha',
        24: 'Shatabhisha',
        25: 'Purva Bhadrapada',
        26: 'Uttara Bhadrapada',
        27: 'Revati',
      };

      final rashiEnglishName = rashiNameMap[moonData['rashi']] ?? 'Pisces';
      final nakshatraEnglishName =
          nakshatraNameMap[moonData['nakshatra']] ?? 'Uttara Bhadrapada';

      // Extract data from API response structure
      // API returns: predictions.career.content, predictions.health.content, etc.
      final predictionsMap =
          precisePredictions['predictions'] as Map<String, dynamic>? ?? {};
      final careerMap = predictionsMap['career'] as Map<String, dynamic>?;
      final healthMap = predictionsMap['health'] as Map<String, dynamic>?;
      final financeMap = predictionsMap['finance'] as Map<String, dynamic>?;

      // Extract dasha information
      final dashaMap = precisePredictions['dasha'] as Map<String, dynamic>?;
      final dashaInfluence = dashaMap?['influence'] as String?;

      // Extract lucky numbers and colors (using camelCase)
      final luckyNumbersMap =
          precisePredictions['luckyNumbers'] as Map<String, dynamic>?;
      final luckyNumbersList = luckyNumbersMap?['numbers'] as List<dynamic>?;
      final luckyNumbers =
          luckyNumbersList?.map((n) => n.toString()).join(', ') ?? '1, 3, 7';

      final luckyColorsMap =
          precisePredictions['luckyColors'] as Map<String, dynamic>?;
      final luckyColorsList = luckyColorsMap?['colors'] as List<dynamic>?;
      final luckyColors = luckyColorsList?.join(', ') ?? 'Blue, Green';

      // Extract auspicious and avoid times (using camelCase)
      final auspiciousTimeMap =
          precisePredictions['auspiciousTime'] as Map<String, dynamic>?;
      final auspiciousTime =
          auspiciousTimeMap?['time'] as String? ?? 'Morning 6-8 AM';

      final avoidTimeMap =
          precisePredictions['avoidTime'] as Map<String, dynamic>?;
      final avoidTime = avoidTimeMap?['time'] as String? ?? 'Evening 6-8 PM';

      // Extract remedies
      final remediesMap =
          precisePredictions['remedies'] as Map<String, dynamic>?;
      final remedies = remediesMap?['content'] as String? ??
          'Chant mantras, donate to charity';

      _dailyPrediction = {
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'prediction': careerMap?['content'] as String? ??
            translationService.translateContent(
              'good_day_ahead',
              fallback: 'Good day ahead',
            ),
        'rashi': rashiEnglishName,
        'nakshatra': nakshatraEnglishName,
        'generalOutlook': careerMap?['content'] as String? ??
            translationService.translateContent(
              'good_day_ahead',
              fallback: 'Good day ahead',
            ),
        'love': translationService.translateContent(
          'harmony_in_relationships',
          fallback: 'Harmony in relationships',
        ), // Love not in API response, use default
        'career': careerMap?['content'] as String? ??
            translationService.translateContent(
              'progress_in_work',
              fallback: 'Progress in work',
            ),
        'health': healthMap?['content'] as String? ??
            translationService.translateContent(
              'good_health',
              fallback: 'Good health',
            ),
        'finance': financeMap?['content'] as String? ??
            translationService.translateContent(
              'stable_finances',
              fallback: 'Stable finances',
            ),
        'luckyNumbers': luckyNumbers,
        'luckyColors': luckyColors,
        'auspiciousTime': auspiciousTime,
        'avoidTime': avoidTime,
        'dashaInfluence': dashaInfluence ??
            translationService.translateContent(
              'current_dasha_effects',
              fallback: 'Current dasha period influence',
            ),
        'remedies': remedies,
      };

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        // Use centralized error message helper
        final errorMsg = ErrorMessageHelper.getUserFriendlyMessage(e);

        setState(() {
          _isLoading = false;
          _errorMessage = errorMsg;
          // DO NOT set dummy data - keep _dailyPrediction as null
          _dailyPrediction = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationService = ref.watch(translationServiceProvider);

    if (_isLoading) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: ThemeHelpers.getPrimaryColor(context),
              ),
              SizedBox(
                height: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              Text(
                translationService.translateContent(
                  'fetching_data',
                  fallback: 'Fetching predictions...',
                ),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
              SizedBox(
                height: ResponsiveSystem.spacing(context, baseSpacing: 8),
              ),
              Text(
                translationService.translateContent(
                  'please_wait',
                  fallback: 'Please wait',
                ),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _dailyPrediction == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveSystem.spacing(context, baseSpacing: 24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveSystem.iconSize(context, baseSize: 64),
                  color: ThemeHelpers.getErrorColor(context),
                ),
                SizedBox(
                  height: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                Text(
                  translationService.translateContent(
                    'error_loading_predictions',
                    fallback: 'Unable to Load Predictions',
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                    color: ThemeHelpers.getSecondaryTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ResponsiveSystem.spacing(context, baseSpacing: 24),
                ),
                ElevatedButton.icon(
                  onPressed: _isRetrying
                      ? null
                      : () {
                          setState(() {
                            _errorMessage = null;
                            _isRetrying = true;
                          });
                          _fetchDailyPredictions().then((_) {
                            if (mounted) {
                              setState(() {
                                _isRetrying = false;
                              });
                            }
                          });
                        },
                  icon: _isRetrying
                      ? SizedBox(
                          width:
                              ResponsiveSystem.iconSize(context, baseSize: 20),
                          height:
                              ResponsiveSystem.iconSize(context, baseSize: 20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(LucideIcons.refreshCw),
                  label: Text(
                    _isRetrying
                        ? translationService.translateContent(
                            'retrying',
                            fallback: 'Retrying...',
                          )
                        : translationService.translateContent(
                            'retry',
                            fallback: 'Retry',
                          ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHelpers.getPrimaryColor(context),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveSystem.spacing(context, baseSpacing: 24),
                      vertical:
                          ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_dailyPrediction == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: ThemeHelpers.getPrimaryColor(context),
              ),
              SizedBox(
                height: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              Text(
                translationService.translateContent(
                  'loading_data',
                  fallback: 'Loading predictions...',
                ),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: BackgroundGradients.getBackgroundGradient(
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          ResponsiveSystem.spacing(context, baseSpacing: 16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User's Astrological Information
            _buildAstrologicalInfoSection(),

            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'general_outlook',
                fallback: 'General Outlook',
              ),
              icon: LucideIcons.eye,
              content: _dailyPrediction!['generalOutlook']!,
              explanation: translationService.translateContent(
                'based_on_planetary_positions',
                fallback:
                    'Based on current planetary positions and dasha influences',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'love_relationships',
                fallback: 'Love & Relationships',
              ),
              icon: LucideIcons.heart,
              content: _dailyPrediction!['love']!,
              explanation: translationService.translateContent(
                'venus_moon_influences',
                fallback: 'Venus and Moon influences on emotional connections',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'career_work',
                fallback: 'Career & Work',
              ),
              icon: LucideIcons.briefcase,
              content: _dailyPrediction!['career']!,
              explanation: translationService.translateContent(
                'sun_mars_influences',
                fallback: 'Sun and Mars influences on professional growth',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'health_wellness',
                fallback: 'Health & Wellness',
              ),
              icon: LucideIcons.heart,
              content: _dailyPrediction!['health']!,
              explanation: translationService.translateContent(
                'moon_mars_health_influences',
                fallback:
                    'Moon and Mars influences on physical and mental health',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'finance_wealth',
                fallback: 'Finance & Wealth',
              ),
              icon: LucideIcons.coins,
              content: _dailyPrediction!['finance']!,
              explanation: translationService.translateContent(
                'jupiter_venus_finances',
                fallback: 'Jupiter and Venus influences on financial matters',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'lucky_numbers',
                fallback: 'Lucky Numbers',
              ),
              icon: LucideIcons.hash,
              content: _dailyPrediction!['luckyNumbers']!,
              explanation: translationService.translateContent(
                'numerical_associations',
                fallback:
                    'Based on current planetary positions and their numerical associations',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'lucky_colors',
                fallback: 'Lucky Colors',
              ),
              icon: LucideIcons.palette,
              content: _dailyPrediction!['luckyColors']!,
              explanation: translationService.translateContent(
                'colors_strong_planets',
                fallback: 'Colors associated with currently strong planets',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'auspicious_time',
                fallback: 'Auspicious Time',
              ),
              icon: LucideIcons.clock,
              content: _dailyPrediction!['auspiciousTime']!,
              explanation: translationService.translateContent(
                'best_time_activities',
                fallback:
                    'Best time for important activities based on planetary influences',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'avoid_time',
                fallback: 'Avoid Time',
              ),
              icon: LucideIcons.clock,
              content: _dailyPrediction!['avoidTime']!,
              explanation: translationService.translateContent(
                'avoid_important_decisions',
                fallback: 'Time to avoid important decisions or activities',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'dasha_influence',
                fallback: 'Dasha Influence',
              ),
              icon: LucideIcons.star,
              content: _dailyPrediction!['dashaInfluence']!,
              explanation: translationService.translateContent(
                'current_dasha_effects',
                fallback:
                    'Current planetary period and its effects on your life',
              ),
            ),
            _buildModernPredictionCard(
              title: translationService.translateHeader(
                'remedies',
                fallback: 'Remedies',
              ),
              icon: LucideIcons.shield,
              content: _dailyPrediction!['remedies']!,
              explanation: translationService.translateContent(
                'suggested_remedies',
                fallback: 'Suggested remedies to enhance positive influences',
              ),
            ),
            SizedBox(
              height: ResponsiveSystem.spacing(context, baseSpacing: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPredictionCard({
    required String title,
    required IconData icon,
    required String content,
    required String explanation,
  }) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 16),
      ),
      elevation: ResponsiveSystem.elevation(context, baseElevation: 6),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
      ),
      color: ThemeHelpers.getSurfaceColor(context),
      shadowColor: ThemeHelpers.getShadowColor(context),
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: ThemeHelpers.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 24),
                ),
                SizedBox(
                  width: ResponsiveSystem.spacing(context, baseSpacing: 12),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 18),
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            Text(
              content,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
            SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
            Text(
              explanation,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeHelpers.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get daily predictions from API

  /// Build astrological information section with symbols
  Widget _buildAstrologicalInfoSection() {
    if (_dailyPrediction == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 16),
      ),
      padding:
          EdgeInsets.all(ResponsiveSystem.spacing(context, baseSpacing: 16)),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        boxShadow: [
          BoxShadow(
            color: ThemeHelpers.getShadowColor(context),
            blurRadius: ResponsiveSystem.elevation(context, baseElevation: 8),
            offset:
                Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.star,
                color: ThemeHelpers.getPrimaryColor(context),
                size: ResponsiveSystem.iconSize(context, baseSize: 24),
              ),
              SizedBox(
                width: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              Text(
                'Your Astrological Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
          Row(
            children: [
              const Text('Moon Sign (Rashi): '),
              Text(_dailyPrediction!['rashi']!),
            ],
          ),
          Row(
            children: [
              const Text('Birth Star (Nakshatra): '),
              Text(_dailyPrediction!['nakshatra']!),
            ],
          ),
        ],
      ),
    );
  }
}
