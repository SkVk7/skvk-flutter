/// Extension methods for the Vedic Astrology Pro application
library;

import 'dart:math';
import 'package:flutter/material.dart';

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  DateTime get startOfYear {
    return DateTime(year);
  }

  /// Get end of year
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  /// Get age in years
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Check if date is weekend
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Get days until date
  int daysUntil(DateTime other) {
    return other.difference(this).inDays;
  }

  /// Get days since date
  int daysSince(DateTime other) {
    return difference(other).inDays;
  }
}

/// String extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is null or empty
  bool get isNullOrEmpty {
    return isEmpty;
  }

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty {
    return isNotEmpty;
  }

  /// Remove extra whitespace
  String get removeExtraWhitespace {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Check if string contains only digits
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

/// BuildContext extensions
extension BuildContextExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if device is tablet
  bool get isTablet {
    final size = MediaQuery.of(this).size;
    return size.width > 600;
  }

  /// Check if device is mobile
  bool get isMobile {
    final size = MediaQuery.of(this).size;
    return size.width <= 600;
  }

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Show snackbar
  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Check if list is null or empty
  bool get isNullOrEmpty {
    return isEmpty;
  }

  /// Check if list is not null and not empty
  bool get isNotNullOrEmpty {
    return isNotEmpty;
  }

  /// Get first element or null
  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  /// Get last element or null
  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  /// Get element at index or null
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Add element if not null
  void addIfNotNull(T? element) {
    if (element != null) add(element);
  }

  /// Add all elements if not null
  void addAllIfNotNull(Iterable<T>? elements) {
    if (elements != null) addAll(elements);
  }
}

/// Double extensions
extension DoubleExtensions on double {
  /// Round to specified decimal places
  double roundTo(int places) {
    final factor = pow(10, places);
    return (this * factor).round() / factor;
  }

  /// Check if value is approximately equal to another value
  bool isApproximatelyEqual(double other, {double tolerance = 0.001}) {
    return (this - other).abs() < tolerance;
  }

  /// Clamp value between min and max
  double clampBetween(double min, double max) {
    return this < min ? min : (this > max ? max : this);
  }
}

/// Int extensions
extension IntExtensions on int {
  /// Check if number is odd
  bool get isOdd => !isEven;

  /// Get ordinal string (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}
