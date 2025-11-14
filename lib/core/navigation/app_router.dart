/// App Router Configuration
///
/// Modern routing using go_router for type-safe navigation
/// Replaces the old MaterialApp routes with a more maintainable solution
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skvk_application/ui/screens/audio_screen.dart';
import 'package:skvk_application/ui/screens/calendar_screen.dart';
import 'package:skvk_application/ui/screens/home_screen.dart';
import 'package:skvk_application/ui/screens/horoscope_screen.dart';
import 'package:skvk_application/ui/screens/matching_screen.dart';
import 'package:skvk_application/ui/screens/pradakshana_screen.dart';
import 'package:skvk_application/ui/screens/predictions_screen.dart';
import 'package:skvk_application/ui/screens/user_edit_screen.dart';
import 'package:skvk_application/ui/screens/user_profile_screen.dart';

/// App route paths
class AppRoutePaths {
  static const String home = '/';
  static const String pradakshana = '/pradakshana';
  static const String user = '/user';
  static const String matching = '/matching';
  static const String horoscope = '/horoscope';
  static const String calendar = '/calendar';
  static const String predictions = '/predictions';
  static const String audio = '/audio';
  static const String editProfile = '/edit-profile';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// App router configuration
class AppRouter {
  /// Create the router configuration
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutePaths.home,
      routes: [
        GoRoute(
          path: AppRoutePaths.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.pradakshana,
          name: 'pradakshana',
          builder: (context, state) => const PradakshanaScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.user,
          name: 'user',
          builder: (context, state) => const UserEditScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.matching,
          name: 'matching',
          builder: (context, state) => const MatchingScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.horoscope,
          name: 'horoscope',
          builder: (context, state) => const HoroscopeScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.calendar,
          name: 'calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.predictions,
          name: 'predictions',
          builder: (context, state) => const PredictionsScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.audio,
          name: 'audio',
          builder: (context, state) => const AudioScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.editProfile,
          name: 'editProfile',
          builder: (context, state) => const UserEditScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.profile,
          name: 'profile',
          builder: (context, state) => const UserProfileScreen(),
        ),
        GoRoute(
          path: AppRoutePaths.settings,
          name: 'settings',
          builder: (context, state) => const UserProfileScreen(),
        ),
      ],
      errorBuilder: (context, state) => _ErrorScreen(
        error: state.error,
      ),
      redirect: (context, state) {
        return null;
      },
      debugLogDiagnostics: true,
    );
  }
}

/// Error screen for navigation errors
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Navigation Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
