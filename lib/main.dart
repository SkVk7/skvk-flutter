// Core imports
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/production_config.dart';
import 'core/architecture/module_registry.dart';
import 'ui/themes/theme_provider.dart';
import 'ui/themes/app_themes.dart';

// Screen imports
import 'ui/screens/home_screen.dart' as home_screen;
import 'ui/screens/pradakshana_screen.dart' as pradakshana_screen;
import 'ui/screens/user_profile_screen.dart' as user_screen;
import 'ui/screens/user_edit_screen.dart' as edit_user_screen;
import 'ui/screens/matching_screen.dart' as matching_screen;
import 'ui/screens/horoscope_screen.dart' as horoscope_screen;
import 'ui/screens/calendar_screen.dart' as calendar_screen;
import 'ui/screens/predictions_screen.dart' as predictions_screen;
import 'ui/screens/audio_screen.dart' as audio_screen;
// Audio components
import 'ui/components/audio/index.dart';

// Service imports
import 'core/utils/astrology/timezone_util.dart';

// Logging system
import 'core/logging/app_logger.dart';
import 'core/services/notification/daily_prediction_scheduler.dart';
import 'core/services/notification/daily_prediction_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for production-ready appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize logging system first (non-blocking - run in background)
  AppLogger().initialize().catchError((e) {
    developer.log('Failed to initialize logging system: $e', name: 'main');
  });

  // Initialize module registry (lightweight - just registration)
  try {
    final moduleRegistry = ModuleRegistry();

    // Register all modules (synchronous - fast)
    moduleRegistry.registerModule(CoreModule());
    moduleRegistry.registerModule(UserModule());
    moduleRegistry.registerModule(AstrologyModule());
    moduleRegistry.registerModule(HoroscopeModule());
    moduleRegistry.registerModule(MatchingModule());
    moduleRegistry.registerModule(CalendarModule());
    moduleRegistry.registerModule(PredictionsModule());

    // Initialize all modules in background (non-blocking)
    moduleRegistry.initializeAll().catchError((e) {
      developer.log('Failed to initialize modules: $e', name: 'main');
    });
  } catch (e) {
    developer.log('Failed to register modules: $e', name: 'main');
  }

  // Initialize timezone utility in background (non-blocking)
  TimezoneUtil.initialize().catchError((e) {
    developer.log('Failed to initialize timezone utility: $e', name: 'main');
  });

  // Initialize daily prediction services in background (non-blocking)
  // These are not critical for app startup
  Future.microtask(() async {
    try {
      final scheduler = DailyPredictionScheduler.instance;
      await scheduler.initialize();

      final notificationService = DailyPredictionNotificationService.instance;
      await notificationService.initialize();
    } catch (e) {
      developer.log('Failed to initialize daily prediction services: $e',
          name: 'main');
      // Don't throw - app should still work without notifications
    }
  });

  // Log production configuration (non-blocking)
  Future.microtask(() async {
    try {
      if (ProductionConfig.isProduction) {
        await AppLogger().info('Running in production mode', source: 'main');
      } else {
        await AppLogger().info('Running in development mode', source: 'main');
      }
    } catch (e) {
      developer.log('Failed to log production config: $e', name: 'main');
    }
  });

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Global Navigator key for accessing Navigator from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationNavigation();
  }

  /// Check if app was opened from notification
  void _checkNotificationNavigation() {
    // Check if app was opened from notification
    final payload = DailyPredictionNotificationService.lastNotificationPayload;
    if (payload == 'predictions') {
      // Navigate to predictions screen after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushNamed('/predictions');
        }
      });
      // Clear the payload
      DailyPredictionNotificationService.clearLastNotificationPayload();
    } else if (payload == 'create_profile') {
      // Navigate to profile creation screen after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushNamed('/edit-profile');
        }
      });
      // Clear the payload
      DailyPredictionNotificationService.clearLastNotificationPayload();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Refresh theme when system theme changes
    ref.read(themeNotifierProvider.notifier).refreshSystemTheme();
  }

  @override
  Widget build(BuildContext context) {
    // Use the new theme provider to get the current theme
    final themeState = ref.watch(themeNotifierProvider);

    return themeState.when(
      data: (state) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: '🔮 ${ProductionConfig.appName}',
          theme: state.theme,
          themeMode: state.themeMode,
          initialRoute: '/',
          routes: {
            '/': (BuildContext context) => const home_screen.HomeScreen() as Widget,
            '/pradakshana': (BuildContext context) =>
                const pradakshana_screen.PradakshanaScreen() as Widget,
            '/user': (BuildContext context) =>
                const edit_user_screen.UserEditScreen() as Widget,
            '/matching': (BuildContext context) =>
                const matching_screen.MatchingScreen() as Widget,
            '/horoscope': (BuildContext context) =>
                const horoscope_screen.HoroscopeScreen() as Widget,
            '/calendar': (BuildContext context) =>
                const calendar_screen.CalendarScreen() as Widget,
            '/predictions': (BuildContext context) =>
                const predictions_screen.PredictionsScreen() as Widget,
            '/audio': (BuildContext context) =>
                const audio_screen.AudioScreen() as Widget,
            '/edit-profile': (BuildContext context) =>
                const edit_user_screen.UserEditScreen() as Widget,
            '/profile': (BuildContext context) =>
                const user_screen.UserProfileScreen() as Widget,
            '/settings': (BuildContext context) =>
                const user_screen.UserProfileScreen() as Widget,
          },
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  child!,
                  // Mini Player - Bottom sticky (visible across whole app)
                  // Positioned at bottom, only captures touches within its bounds
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: const MiniPlayer(),
                  ),
                ],
              ),
            );
          },
          debugShowMaterialGrid: false,
          showPerformanceOverlay: ProductionConfig.enablePerformanceOverlay,
          debugShowCheckedModeBanner: false,
          supportedLocales: ProductionConfig.supportedLocales,
          locale: ProductionConfig.defaultLocale,
        );
      },
      loading: () {
        // Show loading with default theme
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: '🔮 ${ProductionConfig.appName}',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/',
          routes: {
            '/': (BuildContext context) => const home_screen.HomeScreen() as Widget,
            '/pradakshana': (BuildContext context) =>
                const pradakshana_screen.PradakshanaScreen() as Widget,
            '/user': (BuildContext context) =>
                const edit_user_screen.UserEditScreen() as Widget,
            '/matching': (BuildContext context) =>
                const matching_screen.MatchingScreen() as Widget,
            '/horoscope': (BuildContext context) =>
                const horoscope_screen.HoroscopeScreen() as Widget,
            '/calendar': (BuildContext context) =>
                const calendar_screen.CalendarScreen() as Widget,
            '/predictions': (BuildContext context) =>
                const predictions_screen.PredictionsScreen() as Widget,
            '/audio': (BuildContext context) =>
                const audio_screen.AudioScreen() as Widget,
            '/edit-profile': (BuildContext context) =>
                const edit_user_screen.UserEditScreen() as Widget,
            '/profile': (BuildContext context) =>
                const user_screen.UserProfileScreen() as Widget,
            '/settings': (BuildContext context) =>
                const user_screen.UserProfileScreen() as Widget,
          },
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  child!,
                  // Mini Player - Bottom sticky (visible across whole app)
                  // Positioned at bottom, only captures touches within its bounds
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: const MiniPlayer(),
                  ),
                ],
              ),
            );
          },
          debugShowMaterialGrid: false,
          showPerformanceOverlay: ProductionConfig.enablePerformanceOverlay,
          debugShowCheckedModeBanner: false,
          supportedLocales: ProductionConfig.supportedLocales,
          locale: ProductionConfig.defaultLocale,
        );
      },
      error: (error, stack) {
        // Show error with default theme
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: '🔮 ${ProductionConfig.appName}',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/',
          routes: {
            '/': (BuildContext context) => const home_screen.HomeScreen() as Widget,
            '/pradakshana': (BuildContext context) =>
                const pradakshana_screen.PradakshanaScreen() as Widget,
            '/user': (BuildContext context) =>
                const edit_user_screen.UserEditScreen() as Widget,
            '/matching': (BuildContext context) =>
                const matching_screen.MatchingScreen() as Widget,
            '/horoscope': (BuildContext context) =>
                const horoscope_screen.HoroscopeScreen() as Widget,
            '/calendar': (BuildContext context) =>
                const calendar_screen.CalendarScreen() as Widget,
            '/predictions': (BuildContext context) =>
                const predictions_screen.PredictionsScreen() as Widget,
            '/audio': (BuildContext context) =>
                const audio_screen.AudioScreen() as Widget,
            '/edit-profile': (BuildContext context) =>
                const edit_user_screen.UserEditScreen() as Widget,
            '/profile': (BuildContext context) =>
                const user_screen.UserProfileScreen() as Widget,
            '/settings': (BuildContext context) =>
                const user_screen.UserProfileScreen() as Widget,
          },
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  child!,
                  // Mini Player - Bottom sticky (visible across whole app)
                  // Positioned at bottom, only captures touches within its bounds
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: const MiniPlayer(),
                  ),
                ],
              ),
            );
          },
          debugShowMaterialGrid: false,
          showPerformanceOverlay: ProductionConfig.enablePerformanceOverlay,
          debugShowCheckedModeBanner: false,
          supportedLocales: ProductionConfig.supportedLocales,
          locale: ProductionConfig.defaultLocale,
        );
      },
    );
  }
}
