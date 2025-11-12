/// Matching State Management
///
/// Proper state management for matching feature following Flutter best practices
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/matching_repository.dart';
import '../../../di/injection_container.dart';
import '../usecases/perform_matching_usecase.dart';
import '../../../utils/either.dart';
import '../../../utils/validation/error_message_helper.dart';
import '../../../logging/logging_helper.dart';

/// Matching state
/// All data comes from the astrology-service API - no business logic here
class MatchingState {
  final bool isLoading;
  final bool showResults;
  final double? compatibilityScore; // Percentage from API
  final Map<String, String>? kootaDetails; // Koota scores from API
  final String? level; // Compatibility level from API
  final String? recommendation; // Recommendation text from API
  final int? totalScore; // Total score out of 36 from API
  final String? errorMessage;
  final String? successMessage;

  const MatchingState({
    this.isLoading = false,
    this.showResults = false,
    this.compatibilityScore,
    this.kootaDetails,
    this.level,
    this.recommendation,
    this.totalScore,
    this.errorMessage,
    this.successMessage,
  });

  MatchingState copyWith({
    bool? isLoading,
    bool? showResults,
    double? compatibilityScore,
    Map<String, String>? kootaDetails,
    String? level,
    String? recommendation,
    int? totalScore,
    String? errorMessage,
    String? successMessage,
  }) {
    return MatchingState(
      isLoading: isLoading ?? this.isLoading,
      showResults: showResults ?? this.showResults,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      kootaDetails: kootaDetails ?? this.kootaDetails,
      level: level ?? this.level,
      recommendation: recommendation ?? this.recommendation,
      totalScore: totalScore ?? this.totalScore,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get hasResults => showResults && compatibilityScore != null;
  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
}

/// Matching notifier
class MatchingNotifier extends Notifier<MatchingState> {
  late final PerformMatchingUseCase _performMatchingUseCase;

  @override
  MatchingState build() {
    _performMatchingUseCase = PerformMatchingUseCase(
      matchingRepository: ref.read(matchingRepositoryProvider),
    );
    return const MatchingState();
  }

  /// Perform matching with both persons' data
  Future<void> performMatching(PartnerData person1Data, PartnerData person2Data,
      {String? ayanamsha, String? houseSystem}) async {
    LoggingHelper.logDebug(
        'MatchingNotifier.performMatching called with ${person1Data.name} and ${person2Data.name}',
        source: 'MatchingProvider');
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);

    try {
      LoggingHelper.logDebug('Calling _performMatchingUseCase', source: 'MatchingProvider');
      final result = await _performMatchingUseCase.performMatching(person1Data, person2Data,
          ayanamsha: ayanamsha, houseSystem: houseSystem);
      LoggingHelper.logDebug('Use case result: ${result.isSuccess}', source: 'MatchingProvider');

      if (result.isSuccess) {
        final matchingResult = result.value!;
        state = state.copyWith(
          isLoading: false,
          showResults: true,
          compatibilityScore: matchingResult.compatibilityScore,
          kootaDetails: matchingResult.kootaDetails,
          level: matchingResult.level,
          recommendation: matchingResult.recommendation,
          totalScore: matchingResult.totalScore,
          successMessage: 'Matching completed successfully!',
        );

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          state = state.copyWith(successMessage: null);
        });
      } else {
        // Convert technical error to user-friendly message
        final errorMessage = result.failure?.message ?? 'Matching failed';
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(errorMessage);
        state = state.copyWith(
          isLoading: false,
          errorMessage: userFriendlyMessage,
        );
      }
    } catch (e) {
      // Convert technical error to user-friendly message
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
      );
    }
  }

  /// Edit partner details (go back to input screen)
  void editPartnerDetails() {
    state = state.copyWith(
      showResults: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  /// Reset state to initial values
  void resetState() {
    state = const MatchingState();
  }
}

/// Matching provider
final matchingProvider = NotifierProvider<MatchingNotifier, MatchingState>(() {
  return MatchingNotifier();
});

/// Convenience providers for specific state parts
final matchingIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(matchingProvider).isLoading;
});

final matchingShowResultsProvider = Provider<bool>((ref) {
  return ref.watch(matchingProvider).showResults;
});

final matchingCompatibilityScoreProvider = Provider<double?>((ref) {
  return ref.watch(matchingProvider).compatibilityScore;
});

final matchingKootaDetailsProvider = Provider<Map<String, String>?>((ref) {
  return ref.watch(matchingProvider).kootaDetails;
});

final matchingErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(matchingProvider).errorMessage;
});

final matchingSuccessMessageProvider = Provider<String?>((ref) {
  return ref.watch(matchingProvider).successMessage;
});
