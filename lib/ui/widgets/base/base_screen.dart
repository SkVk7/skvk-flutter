/// Base Screen
///
/// Provides base screen widget with common functionality
/// following Flutter best practices
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/base/base_state.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/ui/components/common/error_widget.dart'
    as error_widget;
import 'package:skvk_application/ui/components/common/loading_widget.dart';
import 'package:skvk_application/ui/mixins/screen_base_mixin.dart';

/// Base screen widget with common functionality
abstract class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});
}

/// Base screen state with common functionality
abstract class BaseScreenState<T extends BaseScreen> extends ConsumerState<T>
    with ScreenBaseMixin {
  /// Build the screen content
  Widget buildContent(BuildContext context);

  /// Handle errors
  void handleError(Failure failure) {
    // Override in subclasses for custom error handling
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildContent(context),
    );
  }
}

/// Base screen with async state handling
abstract class BaseAsyncScreen<T> extends BaseScreen {
  const BaseAsyncScreen({super.key});
}

/// Base screen state with async state handling
abstract class BaseAsyncScreenState<T extends BaseAsyncScreen, D>
    extends BaseScreenState<T> {
  /// Get the async state
  AsyncState<D> getAsyncState();

  /// Build content when data is loaded
  Widget buildContentWithData(BuildContext context, D data);

  /// Build loading widget
  Widget buildLoading(BuildContext context) {
    return const LoadingWidget();
  }

  /// Build error widget
  Widget buildError(BuildContext context, Failure failure) {
    return error_widget.ErrorWidget(
      failure: failure,
      onRetry: () {
        // Override in subclasses
      },
    );
  }

  /// Build empty widget
  Widget buildEmpty(BuildContext context) {
    return Center(
      child: Text(
        'No data available',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final state = getAsyncState();

    if (state.isLoading) {
      return buildLoading(context);
    }

    if (state.hasError && state.failure != null) {
      return buildError(context, state.failure!);
    }

    if (state.data != null) {
      return buildContentWithData(context, state.data as D);
    }

    return buildEmpty(context);
  }
}
