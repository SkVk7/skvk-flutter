/// Matching Form Storage Service
///
/// Service for storing and retrieving matching form data to persist user inputs
/// across app sessions for better UX
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/logging/logging_helper.dart';

/// Service to store and retrieve matching form data
class MatchingFormStorageService {
  static MatchingFormStorageService? _instance;
  SharedPreferences? _prefs;

  // Storage keys
  static const String _groomDataKey = 'matching_groom_data';
  static const String _brideDataKey = 'matching_bride_data';
  static const String _ayanamshaKey = 'matching_ayanamsha';
  static const String _houseSystemKey = 'matching_house_system';

  // Private constructor for singleton
  MatchingFormStorageService._();

  /// Get singleton instance
  static MatchingFormStorageService get instance {
    _instance ??= MatchingFormStorageService._();
    return _instance!;
  }

  /// Initialize the service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      LoggingHelper.logInfo('Matching Form Storage Service initialized');
    } catch (e) {
      LoggingHelper.logError(
          'Failed to initialize matching form storage service',
          source: 'MatchingFormStorageService',
          error: e);
      rethrow;
    }
  }

  /// Save groom form data
  Future<void> saveGroomData({
    required String name,
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _ensureInitialized();

      final groomData = {
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'timeOfBirth': timeOfBirth,
        'placeOfBirth': placeOfBirth,
        'latitude': latitude,
        'longitude': longitude,
      };

      await _prefs!.setString(_groomDataKey, json.encode(groomData));
      LoggingHelper.logInfo('Groom data saved successfully');
    } catch (e) {
      LoggingHelper.logError('Failed to save groom data',
          source: 'MatchingFormStorageService', error: e);
    }
  }

  /// Save bride form data
  Future<void> saveBrideData({
    required String name,
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _ensureInitialized();

      final brideData = {
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'timeOfBirth': timeOfBirth,
        'placeOfBirth': placeOfBirth,
        'latitude': latitude,
        'longitude': longitude,
      };

      await _prefs!.setString(_brideDataKey, json.encode(brideData));
      LoggingHelper.logInfo('Bride data saved successfully');
    } catch (e) {
      LoggingHelper.logError('Failed to save bride data',
          source: 'MatchingFormStorageService', error: e);
    }
  }

  /// Save ayanamsha selection
  Future<void> saveAyanamsha(String ayanamsha) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(_ayanamshaKey, ayanamsha);
      LoggingHelper.logInfo('Ayanamsha saved successfully');
    } catch (e) {
      LoggingHelper.logError('Failed to save ayanamsha',
          source: 'MatchingFormStorageService', error: e);
    }
  }

  /// Get groom form data
  Future<Map<String, dynamic>?> getGroomData() async {
    try {
      await _ensureInitialized();
      final groomDataString = _prefs!.getString(_groomDataKey);
      if (groomDataString != null) {
        return json.decode(groomDataString);
      }
      return null;
    } catch (e) {
      LoggingHelper.logError('Failed to get groom data',
          source: 'MatchingFormStorageService', error: e);
      return null;
    }
  }

  /// Get bride form data
  Future<Map<String, dynamic>?> getBrideData() async {
    try {
      await _ensureInitialized();
      final brideDataString = _prefs!.getString(_brideDataKey);
      if (brideDataString != null) {
        return json.decode(brideDataString);
      }
      return null;
    } catch (e) {
      LoggingHelper.logError('Failed to get bride data',
          source: 'MatchingFormStorageService', error: e);
      return null;
    }
  }

  /// Get ayanamsha selection
  Future<String?> getAyanamsha() async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(_ayanamshaKey);
    } catch (e) {
      LoggingHelper.logError('Failed to get ayanamsha',
          source: 'MatchingFormStorageService', error: e);
      return null;
    }
  }

  /// Save house system selection
  Future<void> saveHouseSystem(String houseSystem) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(_houseSystemKey, houseSystem);
      LoggingHelper.logInfo('House system saved successfully');
    } catch (e) {
      LoggingHelper.logError('Failed to save house system',
          source: 'MatchingFormStorageService', error: e);
    }
  }

  /// Get house system selection
  Future<String?> getHouseSystem() async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(_houseSystemKey);
    } catch (e) {
      LoggingHelper.logError('Failed to get house system',
          source: 'MatchingFormStorageService', error: e);
      return null;
    }
  }

  /// Clear all matching form data
  Future<void> clearAllData() async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(_groomDataKey);
      await _prefs!.remove(_brideDataKey);
      await _prefs!.remove(_ayanamshaKey);
      await _prefs!.remove(_houseSystemKey);
      LoggingHelper.logInfo('All matching form data cleared');
    } catch (e) {
      LoggingHelper.logError('Failed to clear matching form data',
          source: 'MatchingFormStorageService', error: e);
    }
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
}
