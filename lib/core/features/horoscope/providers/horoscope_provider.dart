/// Horoscope State Management
///
/// Proper state management for horoscope feature following Flutter best practices
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/di/injection_container.dart';
import 'package:skvk_application/core/features/horoscope/repositories/horoscope_repository.dart';
import 'package:skvk_application/core/features/horoscope/usecases/generate_horoscope_usecase.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:skvk_application/core/utils/validation/error_message_helper.dart';

/// Horoscope state
class HoroscopeState {
  const HoroscopeState({
    this.isLoading = false,
    this.horoscopeData,
    this.errorMessage,
    this.successMessage,
  });
  final bool isLoading;
  final HoroscopeData? horoscopeData;
  final String? errorMessage;
  final String? successMessage;

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
    await LoggingHelper.logDebug('HoroscopeNotifier.generateHoroscope called',
        source: 'HoroscopeProvider',);
    state = state.copyWith(
      isLoading: true,
    );

    try {
      final result = await _generateHoroscopeUseCase();
      await LoggingHelper.logDebug(
          'Horoscope generation result: ${result.isSuccess}',
          source: 'HoroscopeProvider',);

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          horoscopeData: result.value,
          successMessage: 'Horoscope generated successfully!',
        );

        unawaited(
          Future.delayed(const Duration(seconds: 3), () {
            state = state.copyWith();
          }),
        );
      } else {
        final errorMessage =
            result.failure?.message ?? 'Failed to generate horoscope';
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(errorMessage);
        state = state.copyWith(
          isLoading: false,
          errorMessage: userFriendlyMessage,
        );
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Exception in horoscope generation: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'HoroscopeProvider',
      );
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith();
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith();
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
