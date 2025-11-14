import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:skvk_application/core/logging/app_logger.dart';

/// Simple, production-ready location service using free APIs
class SimpleLocationService {
  factory SimpleLocationService() => _instance;
  SimpleLocationService._internal();
  static final SimpleLocationService _instance =
      SimpleLocationService._internal();

  final _logger = AppLogger();

  /// Get coordinates from a place name using Nominatim (free, no API key required)
  Future<LocationResult> getCoordinatesFromPlaceName(String placeName) async {
    try {
      if (kDebugMode) {
        unawaited(
          _logger.debug(
            'Searching for coordinates: $placeName',
            source: 'LocationService',
          ),
        );
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
          final result = data.first as Map<String, dynamic>;
          final lat = double.tryParse(result['lat']?.toString() ?? '0') ?? 0.0;
          final lon = double.tryParse(result['lon']?.toString() ?? '0') ?? 0.0;

          if (kDebugMode) {
            unawaited(
              _logger.debug(
                'Found coordinates: $lat, $lon',
                source: 'LocationService',
              ),
            );
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
    } on Exception catch (e) {
      if (kDebugMode) {
        unawaited(
          _logger.error(
            'Location service error: $e',
            source: 'LocationService',
            metadata: {'error': e.toString()},
            stackTrace: StackTrace.current,
          ),
        );
      }
      return LocationResult.error('Error fetching location: $e');
    }
  }

  /// Get place name from coordinates (reverse geocoding)
  Future<LocationResult> getPlaceNameFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      if (kDebugMode) {
        unawaited(_logger.debug('🔍 Reverse geocoding: $latitude, $longitude'));
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
    } on Exception catch (e) {
      if (kDebugMode) {
        print('❌ Reverse geocoding error: $e');
      }
      return LocationResult.error('Error reverse geocoding: $e');
    }
  }

  /// Get device current location with fallback to country-level location
  /// Returns device location if permission granted, otherwise country-level location
  Future<LocationResult> getDeviceLocationWithFallback() async {
    try {
      // Try to get device location first
      final deviceLocation = await getDeviceLocation();
      if (deviceLocation.isSuccess) {
        return deviceLocation;
      }

      // Fallback to country-level location (less accurate but sufficient for calendar)
      if (kDebugMode) {
        unawaited(
          _logger.debug(
            'Device location not available, using country-level location',
            source: 'LocationService',
          ),
        );
      }

      final countryCode = await _getCountryCode();
      final countryLocation = await getCoordinatesFromPlaceName(countryCode);

      if (countryLocation.isSuccess) {
        return countryLocation;
      }

      // Final fallback: Use India's center coordinates (default)
      return LocationResult.success(
        latitude: 20.5937, // India center latitude
        longitude: 78.9629, // India center longitude
        placeName: 'India',
        address: 'India',
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        unawaited(
          _logger.error(
            'Error getting location with fallback: $e',
            source: 'LocationService',
            metadata: {'error': e.toString()},
            stackTrace: StackTrace.current,
          ),
        );
      }
      // Final fallback: Use India's center coordinates
      return LocationResult.success(
        latitude: 20.5937,
        longitude: 78.9629,
        placeName: 'India',
        address: 'India',
      );
    }
  }

  /// Get device current location
  Future<LocationResult> getDeviceLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.error('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.error(
          'Location permissions are permanently denied',
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy
            .medium, // Medium accuracy is sufficient for calendar
      );

      if (kDebugMode) {
        unawaited(
          _logger.debug(
            'Device location: ${position.latitude}, ${position.longitude}',
            source: 'LocationService',
          ),
        );
      }

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        placeName: 'Current Location',
        address: 'Current Location',
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        unawaited(
          _logger.error(
            'Error getting device location: $e',
            source: 'LocationService',
            metadata: {'error': e.toString()},
            stackTrace: StackTrace.current,
          ),
        );
      }
      return LocationResult.error('Error getting device location: $e');
    }
  }

  /// Get country code from device locale
  Future<String> _getCountryCode() async {
    try {
      // Try to get country from device locale
      final locale = PlatformDispatcher.instance.locale;
      if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
        final countryName = await _getCountryNameFromCode(locale.countryCode!);
        return countryName;
      }
      return 'India'; // Default fallback
    } on Exception {
      return 'India'; // Default fallback
    }
  }

  /// Get country name from country code
  Future<String> _getCountryNameFromCode(String countryCode) async {
    // Map of common country codes to country names
    final countryMap = {
      'IN': 'India',
      'US': 'United States',
      'GB': 'United Kingdom',
      'CA': 'Canada',
      'AU': 'Australia',
      'DE': 'Germany',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
      'BR': 'Brazil',
      'MX': 'Mexico',
      'JP': 'Japan',
      'CN': 'China',
      'KR': 'South Korea',
      'SG': 'Singapore',
      'MY': 'Malaysia',
      'TH': 'Thailand',
      'ID': 'Indonesia',
      'PH': 'Philippines',
      'VN': 'Vietnam',
      'AE': 'United Arab Emirates',
      'SA': 'Saudi Arabia',
      'ZA': 'South Africa',
      'EG': 'Egypt',
      'NG': 'Nigeria',
      'KE': 'Kenya',
      'PK': 'Pakistan',
      'BD': 'Bangladesh',
      'LK': 'Sri Lanka',
      'NP': 'Nepal',
      'BT': 'Bhutan',
      'MM': 'Myanmar',
    };

    return countryMap[countryCode.toUpperCase()] ?? countryCode;
  }

  /// Search for places by query
  Future<List<LocationResult>> searchPlaces(String query) async {
    try {
      if (kDebugMode) {
        print('🔍 Searching places: $query');
      }

      final encodedQuery = Uri.encodeComponent(query);
      final url =
          'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'SKVK Astrology App/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final results = data.map((item) {
          final itemMap = item as Map<String, dynamic>;
          final lat = double.tryParse(itemMap['lat']?.toString() ?? '0') ?? 0.0;
          final lon = double.tryParse(itemMap['lon']?.toString() ?? '0') ?? 0.0;

          return LocationResult.success(
            latitude: lat,
            longitude: lon,
            placeName: itemMap['display_name'] ?? query,
            address: itemMap['display_name'] ?? query,
          );
        }).toList();

        if (kDebugMode) {
          print('✅ Found ${results.length} places');
        }

        return results;
      } else {
        return [];
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('❌ Place search error: $e');
      }
      return [];
    }
  }
}

/// Simple result class for location operations
class LocationResult {
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
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final String? placeName;
  final String? address;
  final String? error;
}
