/// Daily Prediction Notification Service
///
/// Handles showing notifications for daily predictions with summary and deep link
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';

/// Daily prediction notification service
class DailyPredictionNotificationService {
  DailyPredictionNotificationService._();

  factory DailyPredictionNotificationService.instance() {
    return _instance ??= DailyPredictionNotificationService._();
  }
  static DailyPredictionNotificationService? _instance;
  FlutterLocalNotificationsPlugin? _notifications;
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _notifications = FlutterLocalNotificationsPlugin();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings();

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      await LoggingHelper.logInfo(
        'Daily prediction notification service initialized',
        source: 'DailyPredictionNotificationService',
      );
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Error initializing notification service: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'DailyPredictionNotificationService',
      );
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notifications!
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.requestNotificationsPermission();
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _notifications!.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Error requesting notification permissions: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'DailyPredictionNotificationService',
      );
    }
  }

  /// Show daily prediction notification
  Future<void> showDailyPredictionNotification({
    required Map<String, dynamic> predictions,
    String? userName,
  }) async {
    try {
      if (!_isInitialized || _notifications == null) {
        await initialize();
      }

      final isDarkMode = await _getIsDarkMode();

      // Extract prediction summary
      final generalOutlook =
          predictions['generalOutlook'] as String? ?? 'Good day ahead';

      // Extract rashi and nakshatra from moon data if available
      final moonData = predictions['moon'] as Map<String, dynamic>?;
      String? rashi;
      String? nakshatra;

      if (moonData != null) {
        final rashiMap = moonData['rashi'] as Map<String, dynamic>?;
        final nakshatraMap = moonData['nakshatra'] as Map<String, dynamic>?;
        rashi =
            rashiMap?['name'] as String? ?? rashiMap?['englishName'] as String?;
        nakshatra = nakshatraMap?['name'] as String? ??
            nakshatraMap?['englishName'] as String?;
      }

      // Fallback to direct fields if moon data not available
      rashi ??= predictions['rashi'] as String? ?? '';
      nakshatra ??= predictions['nakshatra'] as String? ?? '';

      final title = userName != null
          ? '🌟 Daily Prediction for $userName'
          : '🌟 Your Daily Prediction';

      final body = _createNotificationBody(
        generalOutlook: generalOutlook,
        rashi: rashi,
        nakshatra: nakshatra,
      );

      final primaryColor = isDarkMode
          ? DesignTokens.darkButtonColors['primary']!
          : DesignTokens.lightButtonColors['primary']!;

      final androidDetails = AndroidNotificationDetails(
        'daily_predictions',
        'Daily Predictions',
        channelDescription: 'Notifications for daily astrological predictions',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: primaryColor,
        colorized: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'Tap to view full prediction',
        ),
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'daily_predictions',
      );

      // Notification details
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.show(
        1001, // Unique notification ID for daily predictions
        title,
        body,
        details,
        payload: 'predictions', // Deep link payload
      );

      await LoggingHelper.logInfo(
        'Daily prediction notification shown',
        source: 'DailyPredictionNotificationService',
      );
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Error showing daily prediction notification: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'DailyPredictionNotificationService',
      );
    }
  }

  /// Get theme mode from storage
  Future<bool> _getIsDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex =
          prefs.getInt('app_theme_mode') ?? AppThemeMode.system.index;
      final mode = AppThemeMode.values[themeIndex];

      if (mode == AppThemeMode.system) {
        // Use system brightness
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
      }

      return mode == AppThemeMode.dark;
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Error getting theme mode: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'DailyPredictionNotificationService',
      );
      // Default to light mode on error
      return false;
    }
  }

  /// Create notification body with summary
  /// Uses responsive sizing from design tokens
  String _createNotificationBody({
    required String generalOutlook,
    String? rashi,
    String? nakshatra,
  }) {
    final buffer = StringBuffer();

    // Using bodyMedium font size as base for notification text
    final maxLength = (DesignTokens.fontSizes.bodyMedium * 10)
        .round(); // ~140 chars for medium screens

    final outlook = generalOutlook.length > maxLength
        ? '${generalOutlook.substring(0, maxLength - 3)}...'
        : generalOutlook;
    buffer.writeln(outlook);

    if (rashi != null && rashi.isNotEmpty) {
      buffer.writeln('Rashi: $rashi');
    }
    if (nakshatra != null && nakshatra.isNotEmpty) {
      buffer.writeln('Nakshatra: $nakshatra');
    }

    buffer.writeln('\nTap to view full prediction');

    return buffer.toString();
  }

  /// Handle notification tap
  /// Returns the payload for navigation handling
  static String? _lastNotificationPayload;

  static String? get lastNotificationPayload => _lastNotificationPayload;

  static void clearLastNotificationPayload() {
    _lastNotificationPayload = null;
  }

  void _onNotificationTapped(NotificationResponse response) {
    unawaited(
      LoggingHelper.logDebug(
        'Notification tapped: ${response.payload}',
        source: 'DailyPredictionNotificationService',
      ),
    );
    _lastNotificationPayload = response.payload;

    // The app should check lastNotificationPayload and navigate accordingly
    // Payloads: 'predictions' -> navigate to predictions screen
    //          'create_profile' -> navigate to profile creation screen
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      if (_notifications != null) {
        await _notifications!.cancelAll();
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Error canceling notifications: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'DailyPredictionNotificationService',
      );
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      if (_notifications != null) {
        await _notifications!.cancel(id);
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Error canceling notification: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'DailyPredictionNotificationService',
      );
    }
  }

  /// Show notification prompting user to create profile
  Future<void> showCreateProfileNotification() async {
    try {
      if (!_isInitialized || _notifications == null) {
        await initialize();
      }

      final isDarkMode = await _getIsDarkMode();

      final primaryColor = isDarkMode
          ? DesignTokens.darkButtonColors['primary']!
          : DesignTokens.lightButtonColors['primary']!;

      const title = '🌟 Get Daily Predictions';
      const body =
          'Create your user profile to receive personalized daily astrological predictions and insights.';

      final androidDetails = AndroidNotificationDetails(
        'daily_predictions',
        'Daily Predictions',
        channelDescription: 'Notifications for daily astrological predictions',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: primaryColor,
        colorized: true,
        styleInformation: const BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'Tap to create your profile',
        ),
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'daily_predictions',
      );

      // Notification details
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.show(
        1002, // Unique notification ID for create profile prompt
        title,
        body,
        details,
        payload: 'create_profile', // Deep link payload
      );

      await LoggingHelper.logInfo(
        'Create profile notification shown',
        source: 'DailyPredictionNotificationService',
      );
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Error showing create profile notification: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'DailyPredictionNotificationService',
      );
    }
  }
}
