/// Providers Registry
///
/// Centralized export file for all Riverpod providers
/// Organized by feature for better maintainability and discoverability
library;

// ============================================================================
// ============================================================================

export '../../ui/themes/theme_provider.dart' show themeNotifierProvider;
// ============================================================================
// ============================================================================

// SharedPreferences provider is defined in injection_container.dart

// ============================================================================
// ============================================================================

export '../di/injection_container.dart'
    show
        userRepositoryProvider,
        matchingRepositoryProvider,
        horoscopeRepositoryProvider,
        sharedPreferencesProvider;
// ============================================================================
// HOROSCOPE FEATURE PROVIDERS
// ============================================================================

export '../features/horoscope/providers/horoscope_provider.dart'
    show
        horoscopeProvider,
        horoscopeIsLoadingProvider,
        horoscopeDataProvider,
        horoscopeErrorMessageProvider,
        horoscopeSuccessMessageProvider;
// ============================================================================
// MATCHING FEATURE PROVIDERS
// ============================================================================

export '../features/matching/providers/matching_provider.dart'
    show
        matchingProvider,
        matchingIsLoadingProvider,
        matchingShowResultsProvider,
        matchingCompatibilityScoreProvider,
        matchingKootaDetailsProvider,
        matchingErrorMessageProvider,
        matchingSuccessMessageProvider;
// ============================================================================
// PREDICTIONS FEATURE PROVIDERS
// ============================================================================

export '../features/predictions/providers/daily_predictions_provider.dart'
    show
        dailyPredictionsNotifierProvider,
        dailyPredictionsProvider,
        dailyPredictionsLoadingProvider,
        dailyPredictionsErrorProvider;
export '../features/user/providers/user_async_provider.dart'
    show userAsyncProvider;
export '../features/user/providers/user_profile_provider.dart'
    show
        userProfileProvider,
        userProfileFormDataProvider,
        userProfileIsLoadingProvider,
        userProfileIsEditingProvider,
        userProfileErrorMessageProvider,
        userProfileSuccessMessageProvider,
        userProfileHasUserProvider;
// ============================================================================
// USER FEATURE PROVIDERS
// ============================================================================

export '../features/user/providers/user_provider.dart' show userServiceProvider;
