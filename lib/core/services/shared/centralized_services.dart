/// Centralized Services
///
/// This file contains all centralized services for:
/// - Logging with consistent formatting
/// - DateTime conversion with timezone handling
/// - Error handling and reporting
/// - Common utility functions
library;

import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/shared/centralized_timezone_service.dart';

/// Centralized Logging Service
/// Provides consistent logging across the entire application
class CentralizedLoggingService {
  static CentralizedLoggingService? _instance;
  static CentralizedLoggingService get instance =>
      _instance ??= CentralizedLoggingService._();

  CentralizedLoggingService._();

  /// Log info messages with consistent formatting
  void logInfo(String message, {String? tag, Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = _formatLogMessage('INFO', message, tag, data, timestamp);
    debugPrint(logMessage);
  }

  /// Log warning messages with consistent formatting
  void logWarning(String message, {String? tag, Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        _formatLogMessage('WARNING', message, tag, data, timestamp);
    debugPrint(logMessage);
  }

  /// Log error messages with consistent formatting
  void logError(String message,
      {String? tag,
      Map<String, dynamic>? data,
      Object? error,
      StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        _formatLogMessage('ERROR', message, tag, data, timestamp);
    debugPrint(logMessage);

    if (error != null) {
      debugPrint('Error Details: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stack Trace: $stackTrace');
    }
  }

  /// Log debug messages with consistent formatting
  void logDebug(String message, {String? tag, Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        _formatLogMessage('DEBUG', message, tag, data, timestamp);
    debugPrint(logMessage);
  }

  String _formatLogMessage(String level, String message, String? tag,
      Map<String, dynamic>? data, String timestamp) {
    final tagStr = tag != null ? '[$tag] ' : '';
    final dataStr = data != null ? ' | Data: $data' : '';
    return '[$timestamp] $level: $tagStr$message$dataStr';
  }
}

/// Centralized DateTime Service
/// Provides consistent datetime handling across the application
class CentralizedDateTimeService {
  static CentralizedDateTimeService? _instance;
  static CentralizedDateTimeService get instance =>
      _instance ??= CentralizedDateTimeService._();

  CentralizedDateTimeService._();

  /// Format datetime for display with consistent formatting
  String formatDateTime(DateTime dateTime,
      {String? format, bool includeTime = true}) {
    if (format != null) {
      return _formatWithCustomFormat(dateTime, format);
    }

    if (includeTime) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Format time for display with consistent formatting
  String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Convert local time to UTC using centralized timezone service
  DateTime convertLocalToUTC(DateTime localTime, double longitude,
      [double? latitude]) {
    return CentralizedTimezoneService.instance
        .convertLocalToUTC(localTime, longitude, latitude);
  }

  /// Convert UTC time to local time using centralized timezone service
  DateTime convertUTCToLocal(DateTime utcTime, double longitude,
      [double? latitude]) {
    // Calculate timezone offset from longitude
    final offsetHours = longitude / 15.0;
    final offsetMinutes = (offsetHours * 60).round();

    // Convert from UTC to local time
    final localTime = utcTime.add(Duration(minutes: offsetMinutes));

    return localTime;
  }

  /// Get current timestamp in ISO format
  String getCurrentTimestamp() {
    return DateTime.now().toIso8601String();
  }

  /// Parse datetime from string with error handling
  DateTime? parseDateTime(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      CentralizedLoggingService.instance.logError(
        'Failed to parse datetime: $dateTimeString',
        error: e,
      );
      return null;
    }
  }

  String _formatWithCustomFormat(DateTime dateTime, String format) {
    // Simple custom format implementation
    // For more complex formatting, consider using intl package
    return format
        .replaceAll('yyyy', dateTime.year.toString())
        .replaceAll('MM', dateTime.month.toString().padLeft(2, '0'))
        .replaceAll('dd', dateTime.day.toString().padLeft(2, '0'))
        .replaceAll('HH', dateTime.hour.toString().padLeft(2, '0'))
        .replaceAll('mm', dateTime.minute.toString().padLeft(2, '0'))
        .replaceAll('ss', dateTime.second.toString().padLeft(2, '0'));
  }
}

/// Centralized Error Handling Service
/// Provides consistent error handling across the application
class CentralizedErrorService {
  static CentralizedErrorService? _instance;
  static CentralizedErrorService get instance =>
      _instance ??= CentralizedErrorService._();

  CentralizedErrorService._();

  /// Handle and log errors with consistent formatting
  void handleError(Object error, StackTrace stackTrace,
      {String? context, Map<String, dynamic>? additionalData}) {
    CentralizedLoggingService.instance.logError(
      'Error occurred${context != null ? ' in $context' : ''}',
      error: error,
      stackTrace: stackTrace,
      data: additionalData,
    );
  }

  /// Show error dialog with consistent styling
  void showErrorDialog(BuildContext context, String message,
      {String? title, VoidCallback? onRetry}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title ?? 'Error',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
            fontWeight: FontWeight.bold,
            color: ThemeProperties.getErrorColor(context),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  color: ThemeProperties.getPrimaryColor(context),
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: ThemeProperties.getPrimaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show success dialog with consistent styling
  void showSuccessDialog(BuildContext context, String message,
      {String? title, VoidCallback? onContinue}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title ?? 'Success',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
            fontWeight: FontWeight.bold,
            color: ThemeProperties.getSecondaryColor(context),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onContinue?.call();
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: ThemeProperties.getPrimaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centralized Validation Service
/// Provides consistent validation across the application
class CentralizedValidationService {
  static CentralizedValidationService? _instance;
  static CentralizedValidationService get instance =>
      _instance ??= CentralizedValidationService._();

  CentralizedValidationService._();

  /// Validate email with consistent error messages
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate name with consistent error messages
  String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    return null;
  }

  /// Validate phone number with consistent error messages
  String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate required field with consistent error messages
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  /// Validate date with consistent error messages
  String? validateDate(DateTime? date, {DateTime? minDate, DateTime? maxDate}) {
    if (date == null) {
      return 'Date is required';
    }

    if (minDate != null && date.isBefore(minDate)) {
      return 'Date cannot be before ${CentralizedDateTimeService.instance.formatDateTime(minDate)}';
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      return 'Date cannot be after ${CentralizedDateTimeService.instance.formatDateTime(maxDate)}';
    }

    return null;
  }
}

/// Centralized Animation Service
/// Provides consistent animations across the application
class CentralizedAnimationService {
  static CentralizedAnimationService? _instance;
  static CentralizedAnimationService get instance =>
      _instance ??= CentralizedAnimationService._();

  CentralizedAnimationService._();

  /// Standard animation durations for consistency
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  /// Standard animation curves for consistency
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve fastCurve = Curves.easeIn;

  /// Get responsive animation duration based on context
  Duration getResponsiveDuration(BuildContext context,
      {Duration? baseDuration}) {
    final base = baseDuration ?? mediumDuration;
    // Could add responsive logic here based on screen size or user preferences
    return base;
  }

  /// Get responsive animation curve based on context
  Curve getResponsiveCurve(BuildContext context, {Curve? baseCurve}) {
    // Could add responsive logic here based on screen size or user preferences
    return baseCurve ?? standardCurve;
  }
}

/// Centralized Storage Service
/// Provides consistent storage operations across the application
class CentralizedStorageService {
  static CentralizedStorageService? _instance;
  static CentralizedStorageService get instance =>
      _instance ??= CentralizedStorageService._();

  CentralizedStorageService._();

  /// Store string value with consistent error handling
  Future<bool> storeString(String key, String value) async {
    try {
      // Implementation would depend on the storage solution used
      // This is a placeholder for the actual implementation
      CentralizedLoggingService.instance
          .logInfo('Stored string value for key: $key');
      return true;
    } catch (e) {
      CentralizedLoggingService.instance.logError(
        'Failed to store string value for key: $key',
        error: e,
      );
      return false;
    }
  }

  /// Retrieve string value with consistent error handling
  Future<String?> getString(String key) async {
    try {
      // Implementation would depend on the storage solution used
      // This is a placeholder for the actual implementation
      CentralizedLoggingService.instance
          .logInfo('Retrieved string value for key: $key');
      return null; // Placeholder return
    } catch (e) {
      CentralizedLoggingService.instance.logError(
        'Failed to retrieve string value for key: $key',
        error: e,
      );
      return null;
    }
  }

  /// Store boolean value with consistent error handling
  Future<bool> storeBool(String key, bool value) async {
    try {
      return await storeString(key, value.toString());
    } catch (e) {
      CentralizedLoggingService.instance.logError(
        'Failed to store boolean value for key: $key',
        error: e,
      );
      return false;
    }
  }

  /// Retrieve boolean value with consistent error handling
  Future<bool?> getBool(String key) async {
    try {
      final value = await getString(key);
      if (value == null) return null;
      return value.toLowerCase() == 'true';
    } catch (e) {
      CentralizedLoggingService.instance.logError(
        'Failed to retrieve boolean value for key: $key',
        error: e,
      );
      return null;
    }
  }
}
