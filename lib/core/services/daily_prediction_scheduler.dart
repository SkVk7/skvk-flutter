/// Daily Prediction Scheduler Service
///
/// Schedules daily prediction fetching at sunrise (5:30/6 AM) or when internet connects
/// for the first time of the day. Triggers notifications with prediction summary.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workmanager/workmanager.dart';
import '../utils/either.dart';
import 'user_storage_service.dart';
import 'astrology_service_bridge.dart';
import 'daily_prediction_notification_service.dart';
import 'cache_service.dart';

/// Daily prediction scheduler service
class DailyPredictionScheduler {
  static DailyPredictionScheduler? _instance;
  static DailyPredictionScheduler get instance {
    _instance ??= DailyPredictionScheduler._();
    return _instance!;
  }

  DailyPredictionScheduler._();

  static const String _lastFetchDateKey = 'daily_prediction_last_fetch_date';
  static const String _backgroundTaskName = 'dailyPredictionTask';
  
  Connectivity? _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isInitialized = false;

  /// Initialize the scheduler
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize connectivity listener
      _connectivity = Connectivity();
      
      // Initialize WorkManager for background tasks
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Schedule daily task at sunrise (5:30 AM)
      await _scheduleDailyTask();

      // Listen for internet connectivity
      _listenToConnectivity();

      _isInitialized = true;
      debugPrint('Daily prediction scheduler initialized');
    } catch (e) {
      debugPrint('Error initializing daily prediction scheduler: $e');
    }
  }

  /// Schedule daily task at sunrise (5:30 AM)
  Future<void> _scheduleDailyTask() async {
    try {
      // Cancel existing task if any
      await Workmanager().cancelByUniqueName(_backgroundTaskName);

      // Schedule task at 5:30 AM daily
      // Using periodic task that runs once per day
      await Workmanager().registerPeriodicTask(
        _backgroundTaskName,
        _backgroundTaskName,
        frequency: const Duration(hours: 24),
        initialDelay: _getInitialDelay(),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      debugPrint('Daily prediction task scheduled at 5:30 AM');
    } catch (e) {
      debugPrint('Error scheduling daily task: $e');
    }
  }

  /// Calculate initial delay until next 5:30 AM
  Duration _getInitialDelay() {
    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, 5, 30);

    // If 5:30 AM has passed today, schedule for tomorrow
    if (now.isAfter(nextRun)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }

    return nextRun.difference(now);
  }

  /// Listen to connectivity changes
  void _listenToConnectivity() {
    _connectivitySubscription = _connectivity!.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        // Check if we have internet connection
        final hasInternet = results.any(
          (result) => result != ConnectivityResult.none,
        );

        if (hasInternet) {
          // Check if user exists first
          final userStorageService = UserStorageService.instance;
          await userStorageService.initialize();
          final userResult = await userStorageService.getCurrentUser();
          final user = ResultHelper.isSuccess(userResult)
              ? ResultHelper.getValue(userResult)
              : null;

          if (user == null) {
            // No user - show create profile notification
            await DailyPredictionNotificationService.instance.showCreateProfileNotification();
            return;
          }

          // Check if we've already fetched today
          final lastFetchDate = await _getLastFetchDate();
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);

          if (lastFetchDate == null || lastFetchDate.isBefore(todayDate)) {
            // First internet connection of the day - fetch predictions
            debugPrint('First internet connection of the day - fetching daily predictions');
            await fetchAndNotifyDailyPrediction();
          }
        }
      },
    );
  }

  /// Fetch and notify daily prediction
  /// Public method for background tasks
  Future<void> fetchAndNotifyDailyPrediction() async {
    try {
      // Check if already fetched today
      final lastFetchDate = await _getLastFetchDate();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (lastFetchDate != null && lastFetchDate.isAtSameMomentAs(todayDate)) {
        debugPrint('Daily prediction already fetched today');
        return;
      }

      // Invalidate old prediction caches when scheduler runs on a new day
      // This ensures fresh data is fetched and old caches are cleaned up
      try {
        final cacheService = CacheService.instance;
        cacheService.clearByType(CacheType.predictions);
        debugPrint('Old prediction caches invalidated for new day');
      } catch (e) {
        debugPrint('Error invalidating old prediction caches: $e');
        // Continue even if cache invalidation fails
      }

      // Get user data from storage (for background tasks)
      final userStorageService = UserStorageService.instance;
      await userStorageService.initialize();
      final userResult = await userStorageService.getCurrentUser();
      final user = ResultHelper.isSuccess(userResult)
          ? ResultHelper.getValue(userResult)
          : null;

      if (user == null) {
        debugPrint('No user data available for daily prediction');
        // Show notification prompting user to create profile
        await DailyPredictionNotificationService.instance.showCreateProfileNotification();
        return;
      }

      // Fetch daily prediction
      final bridge = AstrologyServiceBridge.instance;
      final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
        user.latitude,
        user.longitude,
      );

      final predictions = await bridge.getPredictions(
        localBirthDateTime: user.localBirthDateTime,
        birthTimezoneId: timezoneId,
        birthLatitude: user.latitude,
        birthLongitude: user.longitude,
        localTargetDateTime: DateTime.now(),
        targetTimezoneId: timezoneId,
        currentLatitude: user.latitude,
        currentLongitude: user.longitude,
        predictionType: 'daily',
        ayanamsha: user.ayanamsha,
      );

      // Show notification
      await DailyPredictionNotificationService.instance.showDailyPredictionNotification(
        predictions: predictions,
        userName: user.name,
      );

      // Save fetch date
      await _saveLastFetchDate(todayDate);

      debugPrint('Daily prediction fetched and notification shown');
    } catch (e) {
      debugPrint('Error fetching daily prediction: $e');
    }
  }

  /// Get last fetch date
  Future<DateTime?> _getLastFetchDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastFetchDateKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last fetch date: $e');
      return null;
    }
  }

  /// Save last fetch date
  Future<void> _saveLastFetchDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastFetchDateKey, date.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving last fetch date: $e');
    }
  }

  /// Manually trigger daily prediction fetch (for testing or immediate fetch)
  Future<void> triggerDailyPrediction() async {
    await fetchAndNotifyDailyPrediction();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}

/// Background task callback (must be top-level function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('Background task executed: $task');

      if (task == 'dailyPredictionTask') {
        // Initialize scheduler and fetch prediction
        final scheduler = DailyPredictionScheduler.instance;
        await scheduler.fetchAndNotifyDailyPrediction();
        return Future.value(true);
      }

      return Future.value(false);
    } catch (e) {
      debugPrint('Error in background task: $e');
      return Future.value(false);
    }
  });
}

/// Provider for daily prediction scheduler
final dailyPredictionSchedulerProvider = Provider<DailyPredictionScheduler>((ref) {
  return DailyPredictionScheduler.instance;
});

