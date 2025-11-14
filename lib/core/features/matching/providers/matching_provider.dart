/// Matching State Management
///
/// Proper state management for matching feature following Flutter best practices
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/di/injection_container.dart';
import 'package:skvk_application/core/features/matching/repositories/matching_repository.dart';
import 'package:skvk_application/core/features/matching/usecases/perform_matching_usecase.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:skvk_application/core/utils/validation/error_message_helper.dart';

/// Matching state
/// All data comes from the astrology-service API - no business logic here
class MatchingState {
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
  final bool isLoading;
  final bool showResults;
  final double? compatibilityScore; // Percentage from API
  final Map<String, String>? kootaDetails; // Koota scores from API
  final String? level; // Compatibility level from API
  final String? recommendation; // Recommendation text from API
  final int? totalScore; // Total score out of 36 from API
  final String? errorMessage;
  final String? successMessage;

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
  Future<void> performMatching(
    PartnerData person1Data,
    PartnerData person2Data, {
    String? ayanamsha,
    String? houseSystem,
  }) async {
    await LoggingHelper.logDebug(
      'MatchingNotifier.performMatching called with ${person1Data.name} and ${person2Data.name}',
      source: 'MatchingProvider',
    );
    state = state.copyWith(
      isLoading: true,
    );

    try {
      await LoggingHelper.logDebug('Calling _performMatchingUseCase',
          source: 'MatchingProvider',);
      final result = await _performMatchingUseCase.performMatching(
        person1Data,
        person2Data,
        ayanamsha: ayanamsha,
        houseSystem: houseSystem,
      );
      await LoggingHelper.logDebug('Use case result: ${result.isSuccess}',
          source: 'MatchingProvider',);

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

        unawaited(
          Future.delayed(const Duration(seconds: 3), () {
            state = state.copyWith();
          }),
        );
      } else {
        final errorMessage = result.failure?.message ?? 'Matching failed';
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(errorMessage);
        state = state.copyWith(
          isLoading: false,
          errorMessage: userFriendlyMessage,
        );
      }
    } on Exception catch (e) {
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
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith();
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith();
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
