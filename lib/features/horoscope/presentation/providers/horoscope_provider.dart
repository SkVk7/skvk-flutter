/// Horoscope State Management
///
/// Proper state management for horoscope feature following Flutter best practices
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validation/error_message_helper.dart';
import '../../domain/repositories/horoscope_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/generate_horoscope_usecase.dart';
import '../../../../core/utils/either.dart';

/// Horoscope state
class HoroscopeState {
  final bool isLoading;
  final HoroscopeData? horoscopeData;
  final String? errorMessage;
  final String? successMessage;

  const HoroscopeState({
    this.isLoading = false,
    this.horoscopeData,
    this.errorMessage,
    this.successMessage,
  });

  HoroscopeState copyWith({
    bool? isLoading,
    HoroscopeData? horoscopeData,
    String? errorMessage,
    String? successMessage,
  }) {
    return HoroscopeState(
      isLoading: isLoading ?? this.isLoading,
      horoscopeData: horoscopeData ?? this.horoscopeData,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get hasHoroscopeData => horoscopeData != null;
  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
}

/// Horoscope notifier
class HoroscopeNotifier extends Notifier<HoroscopeState> {
  late final GenerateHoroscopeUseCase _generateHoroscopeUseCase;

  @override
  HoroscopeState build() {
    _generateHoroscopeUseCase = GenerateHoroscopeUseCase(
      horoscopeRepository: ref.read(horoscopeRepositoryProvider),
    );
    return const HoroscopeState();
  }

  /// Generate horoscope
  Future<void> generateHoroscope() async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);

    try {
      final result = await _generateHoroscopeUseCase();

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          horoscopeData: result.value!,
          successMessage: 'Horoscope generated successfully!',
        );

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          state = state.copyWith(successMessage: null);
        });
      } else {
        // Convert technical error to user-friendly message
        final errorMessage =
            result.failure?.message ?? 'Failed to generate horoscope';
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

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  /// Reset state
  void reset() {
    state = const HoroscopeState();
  }
}

/// Horoscope provider
final horoscopeProvider =
    NotifierProvider<HoroscopeNotifier, HoroscopeState>(() {
  return HoroscopeNotifier();
});

/// Convenience providers for specific state parts
final horoscopeIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(horoscopeProvider).isLoading;
});

final horoscopeDataProvider = Provider<HoroscopeData?>((ref) {
  return ref.watch(horoscopeProvider).horoscopeData;
});

final horoscopeErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(horoscopeProvider).errorMessage;
});

final horoscopeSuccessMessageProvider = Provider<String?>((ref) {
  return ref.watch(horoscopeProvider).successMessage;
});
