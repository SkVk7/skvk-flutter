/// Matching State Management
///
/// Proper state management for matching feature following Flutter best practices
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/perform_matching_usecase.dart';
import '../../../../core/utils/either.dart';

/// Matching state
class MatchingState {
  final bool isLoading;
  final bool showResults;
  final double? compatibilityScore;
  final Map<String, String>? kootaDetails;
  final String? errorMessage;
  final String? successMessage;

  const MatchingState({
    this.isLoading = false,
    this.showResults = false,
    this.compatibilityScore,
    this.kootaDetails,
    this.errorMessage,
    this.successMessage,
  });

  MatchingState copyWith({
    bool? isLoading,
    bool? showResults,
    double? compatibilityScore,
    Map<String, String>? kootaDetails,
    String? errorMessage,
    String? successMessage,
  }) {
    return MatchingState(
      isLoading: isLoading ?? this.isLoading,
      showResults: showResults ?? this.showResults,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      kootaDetails: kootaDetails ?? this.kootaDetails,
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
    print(
        '🔍 DEBUG: MatchingNotifier.performMatching called with ${person1Data.name} and ${person2Data.name}');
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    try {
      print('🔍 DEBUG: Calling _performMatchingUseCase');
      final result = await _performMatchingUseCase(person1Data, person2Data, 
          ayanamsha: ayanamsha, houseSystem: houseSystem);
      print('🔍 DEBUG: Use case result: ${result.isSuccess}');

      if (result.isSuccess) {
        final matchingResult = result.value!;
        state = state.copyWith(
          isLoading: false,
          showResults: true,
          compatibilityScore: matchingResult.compatibilityScore,
          kootaDetails: matchingResult.kootaDetails,
          successMessage: 'Matching completed successfully!',
        );

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          state = state.copyWith(successMessage: null);
        });
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.failure?.message ?? 'Matching failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: $e',
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
