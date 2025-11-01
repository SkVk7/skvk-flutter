import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Simple, production-ready location service using free APIs
class SimpleLocationService {
  static final SimpleLocationService _instance = SimpleLocationService._internal();
  factory SimpleLocationService() => _instance;
  SimpleLocationService._internal();

  /// Get coordinates from a place name using Nominatim (free, no API key required)
  Future<LocationResult> getCoordinatesFromPlaceName(String placeName) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('Searching for coordinates: $placeName', 'LocationService');
      }

      final encodedPlaceName = Uri.encodeComponent(placeName);
      final url =
          'https://nominatim.openstreetmap.org/search?q=$encodedPlaceName&format=json&limit=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'SKVK Astrology App/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final result = data.first;
          final lat = double.tryParse(result['lat']?.toString() ?? '0') ?? 0.0;
          final lon = double.tryParse(result['lon']?.toString() ?? '0') ?? 0.0;

          if (kDebugMode) {
            AppLogger.debug('Found coordinates: $lat, $lon', 'LocationService');
          }

          return LocationResult.success(
            latitude: lat,
            longitude: lon,
            placeName: result['display_name'] ?? placeName,
            address: result['display_name'] ?? placeName,
          );
        } else {
          return LocationResult.error('No location found for: $placeName');
        }
      } else {
        return LocationResult.error('Failed to fetch location data');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Location service error: $e', e, StackTrace.current, 'LocationService');
      }
      return LocationResult.error('Error fetching location: $e');
    }
  }

  /// Get place name from coordinates (reverse geocoding)
  Future<LocationResult> getPlaceNameFromCoordinates(double latitude, double longitude) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('🔍 Reverse geocoding: $latitude, $longitude');
      }

      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'SKVK Astrology App/1.0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final displayName = data['display_name'] ?? 'Unknown Location';

        if (kDebugMode) {
          print('✅ Found place: $displayName');
        }

        return LocationResult.success(
          latitude: latitude,
          longitude: longitude,
          placeName: displayName,
          address: displayName,
        );
      } else {
        return LocationResult.error('Failed to reverse geocode coordinates');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Reverse geocoding error: $e');
      }
      return LocationResult.error('Error reverse geocoding: $e');
    }
  }

  /// Search for places by query
  Future<List<LocationResult>> searchPlaces(String query) async {
    try {
      if (kDebugMode) {
        print('🔍 Searching places: $query');
      }

      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'SKVK Astrology App/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final results = data.map((item) {
          final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0;
          final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0;

          return LocationResult.success(
            latitude: lat,
            longitude: lon,
            placeName: item['display_name'] ?? query,
            address: item['display_name'] ?? query,
          );
        }).toList();

        if (kDebugMode) {
          print('✅ Found ${results.length} places');
        }

        return results;
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Place search error: $e');
      }
      return [];
    }
  }
}

/// Simple result class for location operations
class LocationResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final String? placeName;
  final String? address;
  final String? error;

  LocationResult._({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    this.placeName,
    this.address,
    this.error,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    required String placeName,
    required String address,
  }) {
    return LocationResult._(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      address: address,
    );
  }

  factory LocationResult.error(String error) {
    return LocationResult._(
      isSuccess: false,
      error: error,
    );
  }
}
