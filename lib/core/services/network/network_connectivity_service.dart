/// Network Connectivity Service
///
/// Service to check network connectivity status
/// Used to ensure online streaming only (no offline downloads)
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network Connectivity Service
class NetworkConnectivityService {
  static NetworkConnectivityService? _instance;
  static NetworkConnectivityService get instance {
    _instance ??= NetworkConnectivityService._();
    return _instance!;
  }

  NetworkConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      // If check fails, assume no connection for safety
      return false;
    }
  }

  /// Get user-friendly offline message
  String getOfflineMessage() {
    return 'Please connect to the internet to stream audio. This app requires an active internet connection for streaming and monetization.';
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}

