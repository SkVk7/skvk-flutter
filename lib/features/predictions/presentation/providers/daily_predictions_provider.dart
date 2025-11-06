/// Daily Predictions Provider
///
/// Riverpod provider for daily predictions state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_daily_predictions_usecase.dart';

/// Daily predictions state
class DailyPredictionsState {
  final bool isLoading;
  final Map<String, String>? predictions;
  final String? errorMessage;

  const DailyPredictionsState({
    this.isLoading = false,
    this.predictions,
    this.errorMessage,
  });

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
  final GetDailyPredictionsUseCase _getDailyPredictionsUseCase;

  DailyPredictionsNotifier(this._getDailyPredictionsUseCase) : super(const DailyPredictionsState());

  /// Get daily predictions
  Future<void> getDailyPredictions({
    required Map<String, dynamic> birthData,
    required DateTime date,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getDailyPredictionsUseCase.call(
        birthData: birthData,
        date: date,
      );

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (predictions) => state = state.copyWith(
          isLoading: false,
          predictions: predictions,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get predictions: $e',
      );
    }
  }

  /// Clear predictions
  void clearPredictions() {
    state = const DailyPredictionsState();
  }
}

/// Provider for daily predictions use case
final dailyPredictionsUseCaseProvider = Provider<GetDailyPredictionsUseCase>((ref) {
  return GetDailyPredictionsUseCase();
});

/// Provider for daily predictions notifier
final dailyPredictionsNotifierProvider =
    StateNotifierProvider<DailyPredictionsNotifier, DailyPredictionsState>((ref) {
  final useCase = ref.watch(dailyPredictionsUseCaseProvider);
  return DailyPredictionsNotifier(useCase);
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
