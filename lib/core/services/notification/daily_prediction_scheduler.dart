/// Daily Prediction Scheduler Service
///
/// Schedules daily prediction fetching at sunrise (5:30/6 AM) or when internet connects
/// for the first time of the day. Triggers notifications with prediction summary.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/services/astrology/astrology_service_bridge.dart';
import 'package:skvk_application/core/services/notification/daily_prediction_notification_service.dart';
import 'package:skvk_application/core/services/shared/cache_service.dart';
import 'package:skvk_application/core/services/user/user_storage_service.dart';
import 'package:skvk_application/core/utils/either.dart';
import 'package:workmanager/workmanager.dart';

/// Daily prediction scheduler service
class DailyPredictionScheduler {
  DailyPredictionScheduler._();

  factory DailyPredictionScheduler.instance() {
    return _instance ??= DailyPredictionScheduler._();
  }
  static DailyPredictionScheduler? _instance;
  static const String _lastFetchDateKey = 'daily_prediction_last_fetch_date';
  static const String _backgroundTaskName = 'dailyPredictionTask';

  late Connectivity? _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isInitialized = false;

  /// Initialize the scheduler
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _connectivity = Connectivity();

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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      debugPrint('Error scheduling daily task: $e');
    }
  }

  /// Calculate initial delay until next 5:30 AM
  Duration _getInitialDelay() {
    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, 5, 30);

    if (now.isAfter(nextRun)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }

    return nextRun.difference(now);
  }

  /// Listen to connectivity changes
  void _listenToConnectivity() {
    _connectivitySubscription = _connectivity!.onConnectivityChanged.listen(
      (results) async {
        final hasInternet = results.any(
          (result) => result != ConnectivityResult.none,
        );

        if (hasInternet) {
          final userStorageService = UserStorageService.instance();
          await userStorageService.initialize();
          final userResult = await userStorageService.getCurrentUser();
          final user = ResultHelper.isSuccess(userResult)
              // ignore: unnecessary_cast
              ? ResultHelper.getValue(userResult) as UserModel?
              : null;

          if (user == null) {
            // No user - show create profile notification
            await DailyPredictionNotificationService.instance()
                .showCreateProfileNotification();
            return;
          }

          final lastFetchDate = await _getLastFetchDate();
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);

          if (lastFetchDate == null || lastFetchDate.isBefore(todayDate)) {
            debugPrint(
              'First internet connection of the day - fetching daily predictions',
            );
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
      final lastFetchDate = await _getLastFetchDate();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (lastFetchDate != null && lastFetchDate.isAtSameMomentAs(todayDate)) {
        debugPrint('Daily prediction already fetched today');
        return;
      }

      // Invalidate old prediction caches when scheduler runs on a new day
      try {
        CacheService.instance().clearByType(CacheType.predictions);
        debugPrint('Old prediction caches invalidated for new day');
      } on Exception catch (e) {
        debugPrint('Error invalidating old prediction caches: $e');
        // Continue even if cache invalidation fails
      }

      final userStorageService = UserStorageService.instance();
      await userStorageService.initialize();
      final userResult = await userStorageService.getCurrentUser();
      final user = ResultHelper.isSuccess(userResult)
          // ignore: unnecessary_cast
          ? ResultHelper.getValue(userResult) as UserModel?
          : null;

      if (user == null) {
        debugPrint('No user data available for daily prediction');
        await DailyPredictionNotificationService.instance()
            .showCreateProfileNotification();
        return;
      }

      // Fetch daily prediction
      final bridge = AstrologyServiceBridge.instance();
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

      await DailyPredictionNotificationService.instance()
          .showDailyPredictionNotification(
        predictions: predictions,
        userName: user.name,
      );

      await _saveLastFetchDate(todayDate);

      debugPrint('Daily prediction fetched and notification shown');
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      debugPrint('Error getting last fetch date: $e');
      return null;
    }
  }

  /// Save last fetch date
  Future<void> _saveLastFetchDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastFetchDateKey, date.millisecondsSinceEpoch);
    } on Exception catch (e) {
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
        final scheduler = DailyPredictionScheduler.instance();
        await scheduler.fetchAndNotifyDailyPrediction();
        return Future.value(true);
      }

      return Future.value(false);
    } on Exception catch (e) {
      debugPrint('Error in background task: $e');
      return Future.value(false);
    }
  });
}

/// Provider for daily prediction scheduler
final dailyPredictionSchedulerProvider =
    Provider<DailyPredictionScheduler>((ref) {
  return DailyPredictionScheduler.instance();
});
