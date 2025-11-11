/// Daily Prediction Notification Service
///
/// Handles showing notifications for daily predictions with summary and deep link
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/design_system/design_system.dart';

/// Daily prediction notification service
class DailyPredictionNotificationService {
  static DailyPredictionNotificationService? _instance;
  static DailyPredictionNotificationService get instance {
    _instance ??= DailyPredictionNotificationService._();
    return _instance!;
  }

  DailyPredictionNotificationService._();

  FlutterLocalNotificationsPlugin? _notifications;
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _notifications = FlutterLocalNotificationsPlugin();

      // Android initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize plugin
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
      debugPrint('Daily prediction notification service initialized');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
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
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
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

      // Get theme mode from storage
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

      // Create notification title
      final title = userName != null
          ? '🌟 Daily Prediction for $userName'
          : '🌟 Your Daily Prediction';

      // Create notification body with summary
      final body = _createNotificationBody(
        generalOutlook: generalOutlook,
        rashi: rashi,
        nakshatra: nakshatra,
      );

      // Get themed colors from design tokens
      final primaryColor = isDarkMode
          ? DesignTokens.darkButtonColors['primary']!
          : DesignTokens.lightButtonColors['primary']!;

      // Android notification details with themed colors
      final androidDetails = AndroidNotificationDetails(
        'daily_predictions',
        'Daily Predictions',
        channelDescription: 'Notifications for daily astrological predictions',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
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
      final iosDetails = DarwinNotificationDetails(
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

      // Show notification with deep link to predictions screen
      await _notifications!.show(
        1001, // Unique notification ID for daily predictions
        title,
        body,
        details,
        payload: 'predictions', // Deep link payload
      );

      debugPrint('Daily prediction notification shown');
    } catch (e) {
      debugPrint('Error showing daily prediction notification: $e');
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
    } catch (e) {
      debugPrint('Error getting theme mode: $e');
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

    // Calculate max length based on design tokens (responsive sizing)
    // Using bodyMedium font size as base for notification text
    final maxLength = (DesignTokens.fontSizes.bodyMedium * 10)
        .round(); // ~140 chars for medium screens

    // Add general outlook (truncated if too long)
    final outlook = generalOutlook.length > maxLength
        ? '${generalOutlook.substring(0, maxLength - 3)}...'
        : generalOutlook;
    buffer.writeln(outlook);

    // Add rashi and nakshatra if available
    if (rashi != null && rashi.isNotEmpty) {
      buffer.writeln('Rashi: $rashi');
    }
    if (nakshatra != null && nakshatra.isNotEmpty) {
      buffer.writeln('Nakshatra: $nakshatra');
    }

    // Add "Click to know more" message
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
    debugPrint('Notification tapped: ${response.payload}');
    _lastNotificationPayload = response.payload;

    // Navigation will be handled by the app's navigation system
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
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      if (_notifications != null) {
        await _notifications!.cancel(id);
      }
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  /// Show notification prompting user to create profile
  Future<void> showCreateProfileNotification() async {
    try {
      if (!_isInitialized || _notifications == null) {
        await initialize();
      }

      // Get theme mode from storage
      final isDarkMode = await _getIsDarkMode();

      // Get themed colors from design tokens
      final primaryColor = isDarkMode
          ? DesignTokens.darkButtonColors['primary']!
          : DesignTokens.lightButtonColors['primary']!;

      // Create notification title and body
      const title = '🌟 Get Daily Predictions';
      const body =
          'Create your user profile to receive personalized daily astrological predictions and insights.';

      // Android notification details with themed colors
      final androidDetails = AndroidNotificationDetails(
        'daily_predictions',
        'Daily Predictions',
        channelDescription: 'Notifications for daily astrological predictions',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: primaryColor,
        colorized: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'Tap to create your profile',
        ),
      );

      // iOS notification details
      final iosDetails = DarwinNotificationDetails(
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

      // Show notification with deep link to profile creation
      await _notifications!.show(
        1002, // Unique notification ID for create profile prompt
        title,
        body,
        details,
        payload: 'create_profile', // Deep link payload
      );

      debugPrint('Create profile notification shown');
    } catch (e) {
      debugPrint('Error showing create profile notification: $e');
    }
  }
}
