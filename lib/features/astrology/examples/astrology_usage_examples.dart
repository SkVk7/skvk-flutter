/// Astrology Usage Examples
///
/// This file demonstrates the proper usage of the astrology system
/// with the new bridge pattern and timezone handling.
///
/// Key Points:
/// - Always use AstrologyBusinessService for business operations
/// - Never call AstrologyLibrary directly from business layer
/// - All timezone conversions are handled automatically
/// - All DateTime inputs should be local time
library;

import 'dart:async';
import '../../../core/di/astrology_di_container.dart';
import '../../../astrology/core/entities/astrology_entities.dart';
import '../../../astrology/core/enums/astrology_enums.dart';
import '../../../astrology/astrology_library.dart';

/// Examples of proper astrology system usage
class AstrologyUsageExamples {
  /// Example 1: Initialize the system
  static Future<void> initializeSystem() async {
    // Initialize the DI container
    await AstrologyDIContainer.instance.initialize();

    print('✅ Astrology system initialized successfully');
  }

  /// Example 2: Get user birth chart (CORRECT way)
  static Future<FixedBirthData> getUserBirthChart() async {
    // Get business service from DI container
    final businessService = AstrologyDIContainer.instance.businessService;

    // Set user timezone preference
    await businessService.setUserTimezone('user123', 'Asia/Kolkata');

    // Set user astrology preferences
    await businessService.setUserPreferences('user123', {
      'ayanamsha': AyanamshaType.lahiri,
      'precision': CalculationPrecision.ultra,
    });

    // Get birth chart with local DateTime (timezone handled automatically)
    final birthChart = await businessService.getUserBirthChart(
      userId: 'user123',
      localBirthDateTime: DateTime(1997, 9, 17, 15, 45), // Local time
      latitude: 12.9716, // Bangalore
      longitude: 77.5946,
    );

    print('✅ Birth chart retrieved: ${birthChart.rashi.name}');
    return birthChart;
  }

  /// Example 3: Calculate compatibility (CORRECT way)
  static Future<CompatibilityResult> calculateCompatibility() async {
    final businessService = AstrologyDIContainer.instance.businessService;

    // Set timezones for both users
    await businessService.setUserTimezone('user1', 'Asia/Kolkata');
    await businessService.setUserTimezone('user2', 'America/New_York');

    // Calculate compatibility with local DateTimes
    final compatibility = await businessService.calculateCompatibility(
      user1Id: 'user1',
      user1LocalBirthDateTime: DateTime(1997, 9, 17, 15, 45), // Local time
      user1Latitude: 12.9716,
      user1Longitude: 77.5946,
      user2Id: 'user2',
      user2LocalBirthDateTime: DateTime(1995, 3, 22, 9, 30), // Local time
      user2Latitude: 40.7128,
      user2Longitude: -74.0060,
    );

    print('✅ Compatibility calculated: ${compatibility.overallScore} points');
    return compatibility;
  }

  /// Example 4: Get planetary positions (CORRECT way)
  static Future<PlanetaryPositions> getPlanetaryPositions() async {
    final businessService = AstrologyDIContainer.instance.businessService;

    // Get planetary positions for current time (local)
    final positions = await businessService.calculatePlanetaryPositions(
      userId: 'user123',
      localDateTime: DateTime.now(), // Local time
      latitude: 12.9716,
      longitude: 77.5946,
    );

    print('✅ Planetary positions calculated');
    return positions;
  }

  /// Example 5: Get timezone from location
  static Future<String> getTimezoneFromLocation() async {
    final businessService = AstrologyDIContainer.instance.businessService;

    // Get timezone from coordinates
    final timezone = await businessService.getTimezoneFromLocation(
      12.9716, // Bangalore latitude
      77.5946, // Bangalore longitude
    );

    print('✅ Timezone for Bangalore: $timezone');
    return timezone;
  }

  /// Example 6: Validate user input
  static Future<bool> validateUserInput() async {
    final businessService = AstrologyDIContainer.instance.businessService;

    // Validate birth data
    final isValid = await businessService.validateUserInput(
      birthDateTime: DateTime(1997, 9, 17, 15, 45),
      latitude: 12.9716,
      longitude: 77.5946,
    );

    print('✅ Input validation result: $isValid');
    return isValid;
  }

  /// Example 7: Get user astrology summary
  static Future<Map<String, dynamic>> getUserSummary() async {
    final businessService = AstrologyDIContainer.instance.businessService;

    // Get comprehensive astrology summary
    final summary = await businessService.getUserAstrologySummary(
      userId: 'user123',
      localBirthDateTime: DateTime(1997, 9, 17, 15, 45),
      latitude: 12.9716,
      longitude: 77.5946,
    );

    print('✅ User astrology summary generated');
    return summary;
  }

  // ============================================================================
  // ANTI-PATTERNS (WHAT NOT TO DO)
  // ============================================================================

  /// ❌ WRONG: Direct call to AstrologyLibrary (will throw error)
  static Future<void> wrongDirectLibraryCall() async {
    try {
      // This will throw an error because we're not using UTC
      await AstrologyLibrary.getFixedBirthData(
        birthDateTime: DateTime(1997, 9, 17, 15, 45), // ❌ Local time
        latitude: 12.9716,
        longitude: 77.5946,
      );
    } catch (e) {
      print('❌ Expected error: $e');
    }
  }

  /// ❌ WRONG: Manual timezone conversion in business layer
  static Future<void> wrongManualTimezoneConversion() async {
    // ❌ Don't do this - timezone conversion should be handled by the facade
    // Manual conversion logic here would be wrong and error-prone
    print('❌ Manual timezone conversion is not recommended');
  }

  // ============================================================================
  // TESTING EXAMPLES
  // ============================================================================

  /// Example: Testing with mock dependencies
  static Future<void> testWithMocks() async {
    // Create mock services for testing
    // (Implementation would depend on your testing framework)

    print('✅ Testing with mocks is supported via DI container');
  }

  /// Example: Reset container for testing
  static void resetForTesting() {
    AstrologyDIContainer.instance.reset();
    print('✅ Container reset for testing');
  }
}

/// Main function to demonstrate usage
Future<void> main() async {
  try {
    // Initialize the system
    await AstrologyUsageExamples.initializeSystem();

    // Get user birth chart
    await AstrologyUsageExamples.getUserBirthChart();

    // Calculate compatibility
    await AstrologyUsageExamples.calculateCompatibility();

    // Get planetary positions
    await AstrologyUsageExamples.getPlanetaryPositions();

    // Get timezone from location
    await AstrologyUsageExamples.getTimezoneFromLocation();

    // Validate user input
    await AstrologyUsageExamples.validateUserInput();

    // Get user summary
    await AstrologyUsageExamples.getUserSummary();

    // Demonstrate anti-patterns
    await AstrologyUsageExamples.wrongDirectLibraryCall();
    await AstrologyUsageExamples.wrongManualTimezoneConversion();

    print('🎉 All examples completed successfully!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
