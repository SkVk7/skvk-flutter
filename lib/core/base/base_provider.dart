/// Base Provider
///
/// Provides base classes for Riverpod providers
/// following Flutter best practices
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_state.dart';
import '../errors/failures.dart';
import '../utils/either.dart';

/// Base state notifier with common functionality
abstract class BaseStateNotifier<T extends BaseState>
    extends StateNotifier<T> {
  BaseStateNotifier(super.state);

  /// Handle result and update state
  void handleResult<R>(
    Result<R> result, {
    required T Function(T, R data) onSuccess,
    T Function(T, Failure failure)? onFailure,
    void Function(Failure)? onError,
  }) {
    result.fold(
      (failure) {
        if (onFailure != null) {
          state = onFailure(state, failure);
        }
        if (onError != null) {
          onError(failure);
        }
      },
      (data) {
        state = onSuccess(state, data);
      },
    );
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    // Override in subclasses to handle loading state
  }

  /// Set error state
  void setError(Failure failure) {
    // Override in subclasses to handle error state
  }
}

/// Base async notifier for handling async operations
abstract class BaseAsyncNotifier<T> extends StateNotifier<AsyncState<T>> {
  BaseAsyncNotifier() : super(AsyncState<T>.initial());

  /// Execute async operation
  Future<void> execute(
    Future<Result<T>> Function() operation, {
    String? loadingMessage,
  }) async {
    state = AsyncState<T>.loading(loadingMessage);

    final result = await operation();

    result.fold(
      (failure) {
        state = AsyncState<T>.error(failure);
      },
      (data) {
        state = AsyncState<T>.success(data);
      },
    );
  }

  /// Refresh data
  Future<void> refresh() async {
    // Override in subclasses
  }

  /// Reset state
  void reset() {
    state = AsyncState<T>.initial();
  }
}

