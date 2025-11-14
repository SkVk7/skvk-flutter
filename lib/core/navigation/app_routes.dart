/// App Routes Configuration
///
/// Centralized route definitions to eliminate duplication
/// and improve maintainability
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/screens/audio_screen.dart' as audio_screen;
import 'package:skvk_application/ui/screens/calendar_screen.dart'
    as calendar_screen;
import 'package:skvk_application/ui/screens/home_screen.dart' as home_screen;
import 'package:skvk_application/ui/screens/horoscope_screen.dart'
    as horoscope_screen;
import 'package:skvk_application/ui/screens/matching_screen.dart'
    as matching_screen;
import 'package:skvk_application/ui/screens/pradakshana_screen.dart'
    as pradakshana_screen;
import 'package:skvk_application/ui/screens/predictions_screen.dart'
    as predictions_screen;
import 'package:skvk_application/ui/screens/user_edit_screen.dart'
    as edit_user_screen;
import 'package:skvk_application/ui/screens/user_profile_screen.dart'
    as user_screen;

/// App route definitions
///
/// This map is used throughout the app to ensure consistent routing
class AppRoutes {
  /// Route path constants
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

  /// Get all route definitions
  ///
  /// Returns a map of route paths to their corresponding widget builders
  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      home: (BuildContext context) => const home_screen.HomeScreen() as Widget,
      pradakshana: (BuildContext context) =>
          const pradakshana_screen.PradakshanaScreen() as Widget,
      user: (BuildContext context) =>
          const edit_user_screen.UserEditScreen() as Widget,
      matching: (BuildContext context) =>
          const matching_screen.MatchingScreen() as Widget,
      horoscope: (BuildContext context) =>
          const horoscope_screen.HoroscopeScreen() as Widget,
      calendar: (BuildContext context) =>
          const calendar_screen.CalendarScreen() as Widget,
      predictions: (BuildContext context) =>
          const predictions_screen.PredictionsScreen() as Widget,
      audio: (BuildContext context) =>
          const audio_screen.AudioScreen() as Widget,
      editProfile: (BuildContext context) =>
          const edit_user_screen.UserEditScreen() as Widget,
      profile: (BuildContext context) =>
          const user_screen.UserProfileScreen() as Widget,
      settings: (BuildContext context) =>
          const user_screen.UserProfileScreen() as Widget,
    };
  }
}
