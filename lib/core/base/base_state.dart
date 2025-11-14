/// Base State Classes
///
/// Provides base state classes for consistent state management
/// following Flutter best practices
library;

import 'package:equatable/equatable.dart';
import 'package:skvk_application/core/errors/failures.dart';

/// Base state class for all feature states
abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

/// Base state with loading indicator
class LoadingState extends BaseState {
  const LoadingState({this.message});
  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Base state with error
class ErrorState extends BaseState {
  const ErrorState({
    required this.failure,
    this.userMessage,
  });
  final Failure failure;
  final String? userMessage;

  @override
  List<Object?> get props => [failure, userMessage];
}

/// Base state with success
class SuccessState<T> extends BaseState {
  const SuccessState(this.data);
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Base state with initial/empty state
class InitialState extends BaseState {
  const InitialState();
}

/// Generic state wrapper that can represent any state
class AsyncState<T> extends BaseState {
  const AsyncState({
    this.data,
    this.isLoading = false,
    this.failure,
    this.message,
  });

  /// Create loading state
  factory AsyncState.loading([String? message]) {
    return AsyncState<T>(
      isLoading: true,
      message: message,
    );
  }

  /// Create success state
  factory AsyncState.success(T data, [String? message]) {
    return AsyncState<T>(
      data: data,
      message: message,
    );
  }

  /// Create error state
  factory AsyncState.error(Failure failure, [String? message]) {
    return AsyncState<T>(
      failure: failure,
      message: message,
    );
  }

  /// Create initial state
  factory AsyncState.initial() {
    return AsyncState<T>();
  }
  final T? data;
  final bool isLoading;
  final Failure? failure;
  final String? message;

  /// Check if state is loading
  bool get isLoaded => !isLoading && data != null;

  /// Check if state has error
  bool get hasError => failure != null;

  /// Check if state is initial
  bool get isInitial => !isLoading && data == null && failure == null;

  @override
  List<Object?> get props => [data, isLoading, failure, message];
}
