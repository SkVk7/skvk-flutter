/// Async State Builder
///
/// Reusable widget for handling async states (loading, error, success)
/// following Flutter best practices
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/base/base_state.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/ui/components/common/error_widget.dart'
    as error_widget;
import 'package:skvk_application/ui/components/common/loading_widget.dart';

/// Builder for async states
class AsyncStateBuilder<T> extends StatelessWidget {
  const AsyncStateBuilder({
    required this.state,
    required this.builder,
    super.key,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyWidget,
    this.emptyMessage,
  });
  final AsyncState<T> state;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget Function(Failure failure)? errorBuilder;
  final Widget? emptyWidget;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return loadingWidget ?? const LoadingWidget();
    }

    if (state.hasError && state.failure != null) {
      if (errorBuilder != null) {
        return errorBuilder!(state.failure!);
      }
      return error_widget.ErrorWidget(
        failure: state.failure!,
      );
    }

    if (state.data != null) {
      return builder(state.data as T);
    }

    // Empty/Initial state
    return emptyWidget ??
        Center(
          child: Text(
            emptyMessage ?? 'No data available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
  }
}

/// Simplified async state builder for common use cases
class SimpleAsyncStateBuilder<T> extends StatelessWidget {
  const SimpleAsyncStateBuilder({
    required this.state,
    required this.builder,
    super.key,
    this.onRetry,
  });
  final AsyncState<T> state;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AsyncStateBuilder<T>(
      state: state,
      builder: builder,
      errorBuilder: (failure) => error_widget.ErrorWidget(
        failure: failure,
        onRetry: onRetry,
      ),
    );
  }
}
