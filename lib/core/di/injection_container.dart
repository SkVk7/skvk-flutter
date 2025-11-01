/// Dependency injection container
///
/// This handles dependency injection for the entire application
/// following the Dependency Inversion Principle
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core services
import '../interfaces/user_repository_interface.dart';

// User feature
import '../../features/user/presentation/providers/user_provider.dart' as user_providers;
import '../../features/user/data/repositories/user_repository_impl.dart';

// Matching feature
import '../../features/matching/domain/repositories/matching_repository.dart';
import '../../features/matching/data/repositories/matching_repository_impl.dart';

// Horoscope feature
import '../../features/horoscope/domain/repositories/horoscope_repository.dart';
import '../../features/horoscope/data/repositories/horoscope_repository_impl.dart';

/// Dependency injection container
class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  late final ProviderContainer _container;

  /// Initialize the dependency injection container
  Future<void> initialize() async {
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Create the provider container with overrides
    _container = ProviderContainer(
      overrides: [
        // Override SharedPreferences provider
        sharedPreferencesProvider.overrideWithValue(prefs),

        // Override repository implementations
        userRepositoryProvider.overrideWith((ref) {
          final userService = ref.watch(user_providers.userServiceProvider.notifier);
          return UserRepositoryImpl(userService: userService);
        }),

        matchingRepositoryProvider.overrideWith((ref) {
          return MatchingRepositoryImpl();
        }),

        horoscopeRepositoryProvider.overrideWith((ref) {
          final userRepository = ref.watch(userRepositoryProvider);
          return HoroscopeRepositoryImpl(userRepository: userRepository);
        }),
      ],
    );
  }

  /// Get a provider from the container
  T read<T>(Provider<T> provider) {
    return _container.read(provider);
  }

  /// Watch a provider from the container
  ProviderSubscription<T> listen<T>(
    Provider<T> provider,
    void Function(T? previous, T next) listener,
  ) {
    return _container.listen(provider, listener);
  }

  /// Dispose the container
  void dispose() {
    _container.dispose();
  }
}

/// Global instance of the injection container
final injectionContainer = InjectionContainer();

/// Provider for the injection container
final injectionContainerProvider = Provider<InjectionContainer>((ref) {
  return injectionContainer;
});

/// Helper function to get providers from the global container
T getIt<T>(Provider<T> provider) {
  return injectionContainer.read(provider);
}

/// Helper function to watch providers from the global container
ProviderSubscription<T> watchIt<T>(
  Provider<T> provider,
  void Function(T? previous, T next) listener,
) {
  return injectionContainer.listen(provider, listener);
}

// ============================================================================
// PROVIDER DEFINITIONS
// ============================================================================

/// User repository provider
final userRepositoryProvider = Provider<UserRepositoryInterface>((ref) {
  final userService = ref.watch(user_providers.userServiceProvider.notifier);
  return UserRepositoryImpl(userService: userService);
});

/// Matching repository provider
final matchingRepositoryProvider = Provider<MatchingRepository>((ref) {
  return MatchingRepositoryImpl();
});

/// Horoscope repository provider
final horoscopeRepositoryProvider = Provider<HoroscopeRepository>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return HoroscopeRepositoryImpl(userRepository: userRepository);
});

/// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});
