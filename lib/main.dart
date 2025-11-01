import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

// Core imports
import 'core/design_system/design_system.dart';
import 'core/config/production_config.dart';
import 'core/architecture/module_registry.dart';
import 'core/theme/theme_provider.dart';

// Screen imports
import 'screens/home_screen.dart' as home_screen;
import 'screens/pradakshana_screen.dart' as pradakshana_screen;
import 'features/user/presentation/screens/user_profile_screen.dart' as user_screen;
import 'features/user/presentation/screens/user_edit_screen.dart' as edit_user_screen;
import 'features/matching/presentation/screens/matching_screen.dart' as matching_screen;
import 'features/horoscope/presentation/screens/horoscope_screen.dart' as horoscope_screen;
import 'features/calendar/presentation/screens/hindu_calendar_screen.dart' as calendar_screen;
import 'features/predictions/presentation/screens/predictions_screen.dart' as predictions_screen;

// Service imports
import 'astrology/astrology_library.dart';
import 'core/di/astrology_di_container.dart';

// Logging system
import 'core/logging/app_logger.dart';

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

  // Initialize logging system first
  try {
    await AppLogger().initialize();
    await AppLogger().info('Logging system initialized', source: 'main');
  } catch (e) {
    // Fallback to basic logging if centralized system fails
    debugPrint('Failed to initialize logging system: $e');
  }

  // Initialize module registry
  try {
    final moduleRegistry = ModuleRegistry();

    // Register all modules
    moduleRegistry.registerModule(CoreModule());
    moduleRegistry.registerModule(UserModule());
    moduleRegistry.registerModule(AstrologyModule());
    moduleRegistry.registerModule(HoroscopeModule());
    moduleRegistry.registerModule(MatchingModule());
    moduleRegistry.registerModule(CalendarModule());
    moduleRegistry.registerModule(PredictionsModule());

    // Initialize all modules
    await moduleRegistry.initializeAll();
    await AppLogger().info('All modules initialized successfully', source: 'main');
  } catch (e) {
    await AppLogger().error('Failed to initialize modules: $e', source: 'main');
    throw Exception('Failed to initialize application modules: $e');
  }

  // Initialize the centralized astrology library with 100% precise calculations
  try {
    await AstrologyLibrary.initialize();
    await AppLogger().info('Astrology library initialized with maximum precision', source: 'main');
  } catch (e) {
    await AppLogger().error('Failed to initialize AstrologyLibrary: $e', source: 'main');
    // Don't continue if astrology service fails - precision is critical
    throw Exception('Failed to initialize precise astrology library: $e');
  }

  // Initialize Astrology Facade and related DI so feature screens can use AstrologyFacade.instance
  try {
    await AstrologyDIContainer.instance.initialize();
    await AppLogger().info('Astrology DI (Facade/Engine/Business) initialized', source: 'main');
  } catch (e) {
    await AppLogger().error('Failed to initialize Astrology DI: $e', source: 'main');
    throw Exception('Failed to initialize Astrology DI: $e');
  }

  // Log production configuration
  if (ProductionConfig.isProduction) {
    await AppLogger().info('Running in production mode', source: 'main');
  } else {
    await AppLogger().info('Running in development mode', source: 'main');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

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
    // Use the theme provider to get the current theme mode
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: '🔮 ${ProductionConfig.appName}',
      theme: ThemeSystem.lightTheme,
      darkTheme: ThemeSystem.darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const home_screen.HomeScreen(),
        '/pradakshana': (context) => const pradakshana_screen.PradakshanaScreen(),
        '/user': (context) => const edit_user_screen.UserEditScreen(),
        '/matching': (context) => const matching_screen.MatchingScreen(),
        '/horoscope': (context) => const horoscope_screen.HoroscopeScreen(),
        '/calendar': (context) => const calendar_screen.HinduCalendarScreen(),
        '/predictions': (context) => const predictions_screen.PredictionsScreen(),
        '/edit-profile': (context) => const edit_user_screen.UserEditScreen(),
        '/profile': (context) => const user_screen.UserProfileScreen(),
        '/settings': (context) => const user_screen.UserProfileScreen(),
      },
      // Production-ready settings
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Prevent text scaling issues
          ),
          child: child!,
        );
      },
      // Performance optimizations
      debugShowMaterialGrid: false,
      showPerformanceOverlay: ProductionConfig.enablePerformanceOverlay,
      // Accessibility
      debugShowCheckedModeBanner: false,
      // Localization support
      supportedLocales: ProductionConfig.supportedLocales,
      locale: ProductionConfig.defaultLocale,
    );
  }
}
