/// Test Helpers
///
/// Common utilities and helpers for testing
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:skvk_application/core/errors/failures.dart';
import 'package:skvk_application/core/utils/either.dart';

/// Test helper for creating mock providers
class TestHelpers {
  /// Create a provider container for testing
  static ProviderContainer createTestContainer({
    List<Override>? overrides,
  }) {
    return ProviderContainer(
      overrides: overrides ?? [],
    );
  }

  /// Create a mock failure for testing
  static Failure createMockFailure({
    String message = 'Test failure',
    String? code,
    Map<String, dynamic>? details,
  }) {
    return UnexpectedFailure(
      message: message,
      code: code,
      details: details,
    );
  }

  /// Create a mock success result for testing
  static Result<T> createSuccessResult<T>(T value) {
    return ResultHelper.success(value);
  }

  /// Create a mock failure result for testing
  static Result<T> createFailureResult<T>({
    String message = 'Test failure',
    String? code,
    Map<String, dynamic>? details,
  }) {
    return ResultHelper.failure(
      createMockFailure(
        message: message,
        code: code,
        details: details,
      ),
    );
  }

  /// Wait for async operations to complete
  static Future<void> waitForAsync() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Pump and settle widgets
  static Future<void> pumpAndSettle(
    WidgetTester tester, {
    Duration duration = const Duration(seconds: 1),
  }) async {
    await tester.pumpAndSettle(duration);
  }

  /// Find widget by type
  static T findWidget<T extends Widget>(WidgetTester tester, Type type) {
    return tester.widget<T>(find.byType(type));
  }

  /// Find widget by key
  static T findWidgetByKey<T extends Widget>(
    WidgetTester tester,
    Key key,
  ) {
    return tester.widget<T>(find.byKey(key));
  }

  /// Tap widget by type
  static Future<void> tapWidget<T extends Widget>(
    WidgetTester tester,
    Type type,
  ) async {
    await tester.tap(find.byType(type));
    await tester.pumpAndSettle();
  }

  /// Tap widget by key
  static Future<void> tapWidgetByKey(
    WidgetTester tester,
    Key key,
  ) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  /// Enter text in a text field
  static Future<void> enterText(
    WidgetTester tester,
    String text, {
    Key? key,
    bool obscureText = false,
  }) async {
    final finder = key != null ? find.byKey(key) : find.text(text);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Verify widget is visible
  static void verifyWidgetVisible(WidgetTester tester, Key key) {
    expect(find.byKey(key), findsOneWidget);
  }

  /// Verify widget is not visible
  static void verifyWidgetNotVisible(WidgetTester tester, Key key) {
    expect(find.byKey(key), findsNothing);
  }

  /// Verify text is displayed
  static void verifyTextDisplayed(WidgetTester tester, String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify text is not displayed
  static void verifyTextNotDisplayed(WidgetTester tester, String text) {
    expect(find.text(text), findsNothing);
  }
}

/// Mock data generators for testing
class MockDataGenerators {
  /// Generate a random string
  static String randomString([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) =>
          chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length],
    ).join();
  }

  /// Generate a random integer
  static int randomInt([int max = 100]) {
    return DateTime.now().millisecondsSinceEpoch % max;
  }

  /// Generate a random double
  static double randomDouble([double max = 100.0]) {
    return (DateTime.now().millisecondsSinceEpoch % max.toInt()).toDouble();
  }

  /// Generate a random boolean
  static bool randomBool() {
    return DateTime.now().millisecondsSinceEpoch.isEven;
  }

  /// Generate a random date
  static DateTime randomDate() {
    return DateTime.now().subtract(
      Duration(days: randomInt(365)),
    );
  }
}
