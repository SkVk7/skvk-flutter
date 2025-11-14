/// User Async Provider
///
/// Modern async provider for user using BaseAsyncNotifier
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/base/base_provider.dart';
import 'package:skvk_application/core/base/base_state.dart';
import 'package:skvk_application/core/di/injection_container.dart';
import 'package:skvk_application/core/features/user/usecases/get_user_usecase.dart';
import 'package:skvk_application/core/models/user/user_model.dart';

/// User async provider using BaseAsyncNotifier
class UserAsyncProvider extends BaseAsyncNotifier<UserModel?> {
  late final GetUserUseCaseSimple _getUserUseCase;

  @override
  Future<void> refresh() async {
    await execute(() => _getUserUseCase());
  }

  /// Initialize with use case
  // ignore: use_setters_to_change_properties
  void initialize(GetUserUseCaseSimple useCase) {
    _getUserUseCase = useCase;
  }
}

/// Provider for UserAsyncProvider
final userAsyncProvider =
    StateNotifierProvider<UserAsyncProvider, AsyncState<UserModel?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  final useCase = GetUserUseCaseSimple(repository);
  final provider = UserAsyncProvider()
    ..initialize(useCase)
    ..refresh();

  return provider;
});
