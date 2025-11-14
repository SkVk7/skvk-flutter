/// Daily Predictions Provider
///
/// Riverpod provider for daily predictions state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/astrology/astrology_service_bridge.dart';
import 'package:skvk_application/core/services/user/user_service.dart';
import 'package:skvk_application/core/utils/astrology/timezone_util.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:skvk_application/core/utils/validation/error_message_helper.dart';
import 'package:skvk_application/core/utils/validation/profile_completion_checker.dart';

/// Daily predictions state
class DailyPredictionsState {
  const DailyPredictionsState({
    this.isLoading = false,
    this.predictions,
    this.errorMessage,
  });
  final bool isLoading;
  final Map<String, String>? predictions;
  final String? errorMessage;

  DailyPredictionsState copyWith({
    bool? isLoading,
    Map<String, String>? predictions,
    String? errorMessage,
  }) {
    return DailyPredictionsState(
      isLoading: isLoading ?? this.isLoading,
      predictions: predictions ?? this.predictions,
      errorMessage: errorMessage,
    );
  }

  bool get hasPredictions => predictions != null;
  bool get hasError => errorMessage != null;
}

/// Daily predictions notifier
class DailyPredictionsNotifier extends StateNotifier<DailyPredictionsState> {
  DailyPredictionsNotifier(this._ref) : super(const DailyPredictionsState());
  final Ref _ref;

  /// Get daily predictions using AstrologyServiceBridge.getPredictions directly
  Future<void> getDailyPredictions({
    required Map<String, dynamic> birthData,
    required DateTime date,
  }) async {
    await LoggingHelper.logDebug(
        'DailyPredictionsNotifier.getDailyPredictions called',
        source: 'DailyPredictionsProvider',);
    state = state.copyWith(isLoading: true);

    try {
      final userService = _ref.read(userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      final user =
          ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

      if (user == null || !ProfileCompletionChecker.isProfileComplete(user)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please complete your profile to get predictions',
        );
        return;
      }

      await TimezoneUtil.initialize();
      final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
        user.latitude,
        user.longitude,
      );

      // Use AstrologyServiceBridge for predictions
      final bridge = AstrologyServiceBridge.instance();
      final predictions = await bridge.getPredictions(
        localBirthDateTime: user.localBirthDateTime,
        birthTimezoneId: timezoneId,
        birthLatitude: user.latitude,
        birthLongitude: user.longitude,
        localTargetDateTime: date,
        targetTimezoneId: timezoneId,
        currentLatitude: user.latitude,
        currentLongitude: user.longitude,
        predictionType: 'daily',
        ayanamsha: user.ayanamsha,
      );

      // Extract prediction data from API response
      final predictionData = <String, String>{};
      if (predictions.containsKey('predictions')) {
        final preds = predictions['predictions'] as Map<String, dynamic>?;
        if (preds != null) {
          preds.forEach((key, value) {
            predictionData[key] = value.toString();
          });
        }
      }

      await LoggingHelper.logDebug(
          'Daily predictions retrieved: ${predictionData.length} items',
          source: 'DailyPredictionsProvider',);
      state = state.copyWith(
        isLoading: false,
        predictions: predictionData.isNotEmpty ? predictionData : null,
        errorMessage:
            predictionData.isEmpty ? 'No predictions available' : null,
      );
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Exception getting daily predictions: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'DailyPredictionsProvider',
      );
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
      );
    }
  }

  /// Clear predictions
  void clearPredictions() {
    state = const DailyPredictionsState();
  }
}

/// Provider for daily predictions notifier
final dailyPredictionsNotifierProvider =
    StateNotifierProvider<DailyPredictionsNotifier, DailyPredictionsState>(
        (ref) {
  return DailyPredictionsNotifier(ref);
});

/// Provider for daily predictions data
final dailyPredictionsProvider = Provider<Map<String, String>?>((ref) {
  final state = ref.watch(dailyPredictionsNotifierProvider);
  return state.predictions;
});

/// Provider for daily predictions loading state
final dailyPredictionsLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(dailyPredictionsNotifierProvider);
  return state.isLoading;
});

/// Provider for daily predictions error
final dailyPredictionsErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(dailyPredictionsNotifierProvider);
  return state.errorMessage;
});
