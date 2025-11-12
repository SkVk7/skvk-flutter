/// Providers Registry
///
/// Centralized export file for all Riverpod providers
/// Organized by feature for better maintainability and discoverability
library;

// ============================================================================
// CORE PROVIDERS
// ============================================================================

// SharedPreferences provider is defined in injection_container.dart

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

export '../di/injection_container.dart' show
    userRepositoryProvider,
    matchingRepositoryProvider,
    horoscopeRepositoryProvider,
    sharedPreferencesProvider;

// ============================================================================
// USER FEATURE PROVIDERS
// ============================================================================

export '../features/user/providers/user_provider.dart' show userServiceProvider;
export '../features/user/providers/user_async_provider.dart' show userAsyncProvider;
export '../features/user/providers/user_profile_provider.dart' show
    userProfileProvider,
    userProfileFormDataProvider,
    userProfileIsLoadingProvider,
    userProfileIsEditingProvider,
    userProfileErrorMessageProvider,
    userProfileSuccessMessageProvider,
    userProfileHasUserProvider;

// ============================================================================
// MATCHING FEATURE PROVIDERS
// ============================================================================

export '../features/matching/providers/matching_provider.dart' show
    matchingProvider,
    matchingIsLoadingProvider,
    matchingShowResultsProvider,
    matchingCompatibilityScoreProvider,
    matchingKootaDetailsProvider,
    matchingErrorMessageProvider,
    matchingSuccessMessageProvider;

// ============================================================================
// HOROSCOPE FEATURE PROVIDERS
// ============================================================================

export '../features/horoscope/providers/horoscope_provider.dart' show
    horoscopeProvider,
    horoscopeIsLoadingProvider,
    horoscopeDataProvider,
    horoscopeErrorMessageProvider,
    horoscopeSuccessMessageProvider;

// ============================================================================
// PREDICTIONS FEATURE PROVIDERS
// ============================================================================

export '../features/predictions/providers/daily_predictions_provider.dart' show
    dailyPredictionsNotifierProvider,
    dailyPredictionsProvider,
    dailyPredictionsLoadingProvider,
    dailyPredictionsErrorProvider;

// ============================================================================
// UI PROVIDERS
// ============================================================================

export '../../ui/themes/theme_provider.dart' show themeNotifierProvider;

