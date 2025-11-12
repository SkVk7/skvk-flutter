/// User Async Provider
///
/// Modern async provider for user using BaseAsyncNotifier
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../base/base_provider.dart';
import '../../../base/base_state.dart';
import '../../../models/user/user_model.dart';
import '../usecases/get_user_usecase.dart';
import '../../../di/injection_container.dart';

/// User async provider using BaseAsyncNotifier
class UserAsyncProvider extends BaseAsyncNotifier<UserModel?> {
  late final GetUserUseCaseSimple _getUserUseCase;

  @override
  Future<void> refresh() async {
    await execute(() => _getUserUseCase());
  }

  /// Initialize with use case
  void initialize(GetUserUseCaseSimple useCase) {
    _getUserUseCase = useCase;
  }
}

/// Provider for UserAsyncProvider
final userAsyncProvider = StateNotifierProvider<UserAsyncProvider, AsyncState<UserModel?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  final useCase = GetUserUseCaseSimple(repository);
  final provider = UserAsyncProvider();
  provider.initialize(useCase);
  
  // Load user on initialization
  provider.refresh();
  
  return provider;
});

