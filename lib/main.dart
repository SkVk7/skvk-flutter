import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/architecture/module_registry.dart';
import 'package:skvk_application/core/config/environment_config.dart';
import 'package:skvk_application/core/config/production_config.dart';
import 'package:skvk_application/core/errors/error_boundary.dart';
import 'package:skvk_application/core/logging/app_logger.dart';
import 'package:skvk_application/core/navigation/app_routes.dart';
import 'package:skvk_application/core/services/notification/daily_prediction_notification_service.dart';
import 'package:skvk_application/core/services/notification/daily_prediction_scheduler.dart';
import 'package:skvk_application/core/utils/astrology/timezone_util.dart';
import 'package:skvk_application/ui/components/audio/index.dart';
import 'package:skvk_application/ui/themes/app_themes.dart';
import 'package:skvk_application/ui/themes/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GlobalErrorHandler.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  unawaited(
    AppLogger().initialize().catchError((e) {
      developer.log('Failed to initialize logging system: $e', name: 'main');
    }),
  );

  if (EnvironmentConfig.isDevelopment) {
    developer.log(
      'Running in ${EnvironmentConfig.environmentName} mode',
      name: 'main',
    );
  }

  try {
    final moduleRegistry = ModuleRegistry()
      ..registerModule(CoreModule())
      ..registerModule(UserModule())
      ..registerModule(AstrologyModule())
      ..registerModule(HoroscopeModule())
      ..registerModule(MatchingModule())
      ..registerModule(CalendarModule())
      ..registerModule(PredictionsModule());

    unawaited(
      moduleRegistry.initializeAll().catchError((e) {
        developer.log('Failed to initialize modules: $e', name: 'main');
      }),
    );
  } on Exception catch (e) {
    developer.log('Failed to register modules: $e', name: 'main');
  }

  unawaited(
    TimezoneUtil.initialize().catchError((e) {
      developer.log('Failed to initialize timezone utility: $e', name: 'main');
    }),
  );

  unawaited(
    Future.microtask(() async {
      try {
        final scheduler = DailyPredictionScheduler.instance();
        await scheduler.initialize();

        final notificationService =
            DailyPredictionNotificationService.instance();
        await notificationService.initialize();
      } on Exception catch (e) {
        developer.log(
          'Failed to initialize daily prediction services: $e',
          name: 'main',
        );
      }
    }),
  );

  unawaited(
    Future.microtask(() async {
      try {
        if (ProductionConfig.isProduction) {
          await AppLogger().info('Running in production mode', source: 'main');
        } else {
          await AppLogger().info('Running in development mode', source: 'main');
        }
      } on Exception catch (e) {
        developer.log('Failed to log production config: $e', name: 'main');
      }
    }),
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

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
    final payload = DailyPredictionNotificationService.lastNotificationPayload;
    if (payload == 'predictions') {
      unawaited(
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushNamed('/predictions');
          }
        }),
      );
      DailyPredictionNotificationService.clearLastNotificationPayload();
    } else if (payload == 'create_profile') {
      unawaited(
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushNamed('/edit-profile');
          }
        }),
      );
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
    ref.read(themeNotifierProvider.notifier).refreshSystemTheme();
  }

  /// Build MaterialApp with common configuration
  Widget _buildMaterialApp({
    required ThemeData theme,
    required ThemeData darkTheme,
    required ThemeMode themeMode,
  }) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '🔮 ${ProductionConfig.appName}',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.getRoutes(),
      builder: _buildAppBuilder,
      debugShowCheckedModeBanner: false,
      supportedLocales: ProductionConfig.supportedLocales,
      locale: ProductionConfig.defaultLocale,
    );
  }

  /// Build app wrapper with MediaQuery and MiniPlayer
  Widget _buildAppBuilder(BuildContext context, Widget? child) {
    return ErrorBoundary(
      onError: (error, stackTrace) {},
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeNotifierProvider);

    return themeState.when(
      data: (state) {
        return _buildMaterialApp(
          theme: state.theme,
          darkTheme: AppThemes.darkTheme,
          themeMode: state.themeMode,
        );
      },
      loading: () {
        return _buildMaterialApp(
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
        );
      },
      error: (error, stack) {
        return _buildMaterialApp(
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
