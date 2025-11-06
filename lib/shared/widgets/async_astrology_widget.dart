/// Async Astrology Widget
///
/// Provides non-blocking UI operations for astrology calculations
/// with progress indicators and error handling
library;

import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/astrology_service_bridge.dart';

/// Async astrology widget with progress indicators
class AsyncAstrologyWidget extends StatefulWidget {
  final UserModel user;
  final Widget Function(Map<String, dynamic> birthData) builder;
  final Widget Function()? loadingBuilder;
  final Widget Function(String error)? errorBuilder;
  final bool showProgressIndicator;
  final Duration loadingTimeout;

  const AsyncAstrologyWidget({
    super.key,
    required this.user,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.showProgressIndicator = true,
    this.loadingTimeout = const Duration(seconds: 30),
  });

  @override
  State<AsyncAstrologyWidget> createState() => _AsyncAstrologyWidgetState();
}

class _AsyncAstrologyWidgetState extends State<AsyncAstrologyWidget> {
  Future<Map<String, dynamic>>? _calculationFuture;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCalculation();
  }

  @override
  void didUpdateWidget(AsyncAstrologyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _startCalculation();
    }
  }

  void _startCalculation() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _calculationFuture = _calculateAstrologyData();
  }

  Future<Map<String, dynamic>> _calculateAstrologyData() async {
    try {
      // Use AstrologyServiceBridge for timezone handling and API calls
      final bridge = AstrologyServiceBridge.instance;

      // Get timezone from user's location
      final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
          widget.user.latitude, widget.user.longitude);

      // Get birth data from API (handles timezone conversion automatically)
      final birthData = await bridge.getBirthData(
        localBirthDateTime: widget.user.localBirthDateTime,
        timezoneId: timezoneId,
        latitude: widget.user.latitude,
        longitude: widget.user.longitude,
        ayanamsha: widget.user.ayanamsha,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      return birthData;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _calculationFuture,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return widget.loadingBuilder?.call() ?? _buildDefaultLoading();
        }

        // Error state
        if (snapshot.hasError || _error != null) {
          return widget.errorBuilder?.call(_error ?? snapshot.error.toString()) ??
              _buildDefaultError(_error ?? snapshot.error.toString());
        }

        // Success state
        if (snapshot.hasData) {
          return widget.builder(snapshot.data!);
        }

        // Fallback
        return _buildDefaultLoading();
      },
    );
  }

  Widget _buildDefaultLoading() {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showProgressIndicator) ...[
            const CircularProgressIndicator(),
            ResponsiveSystem.sizedBox(context, height: 16),
          ],
          Text(
            'Calculating astrology data...',
            style: TextStyle(fontSize: ResponsiveSystem.fontSize(context, baseSize: 16)),
            textAlign: TextAlign.center,
          ),
          if (widget.showProgressIndicator) ...[
            ResponsiveSystem.sizedBox(context, height: 8),
            Text(
              'This may take a few moments',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultError(String error) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: ThemeProperties.getErrorColor(context),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          Text(
            'Failed to calculate astrology data',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              fontWeight: FontWeight.bold,
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
              color: ThemeProperties.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          ElevatedButton(
            onPressed: _startCalculation,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Async astrology calculation with progress callback
class AsyncAstrologyCalculation {
  static Future<Map<String, dynamic>> calculateWithProgress({
    required UserModel user,
    required Function(double progress) onProgress,
    required Function(String message) onStatusUpdate,
  }) async {
    try {
      onStatusUpdate('Fetching birth data from API...');
      onProgress(0.2);

      // Use AstrologyServiceBridge for timezone handling and API calls
      final bridge = AstrologyServiceBridge.instance;

      // Get timezone from user's location
      final timezoneId = AstrologyServiceBridge.getTimezoneFromLocation(
          user.latitude, user.longitude);

      onProgress(0.5);
      onStatusUpdate('Calculating birth data...');

      final birthData = await bridge.getBirthData(
        localBirthDateTime: user.localBirthDateTime,
        timezoneId: timezoneId,
        latitude: user.latitude,
        longitude: user.longitude,
        ayanamsha: user.ayanamsha,
      );

      onProgress(1.0);
      onStatusUpdate('Calculation complete!');

      return birthData;
    } catch (e) {
      onStatusUpdate('Error: ${e.toString()}');
      rethrow;
    }
  }
}

/// Progress indicator for astrology calculations
class AstrologyProgressIndicator extends StatelessWidget {
  final double progress;
  final String message;
  final bool isIndeterminate;

  const AstrologyProgressIndicator({
    super.key,
    required this.progress,
    required this.message,
    this.isIndeterminate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isIndeterminate)
            const CircularProgressIndicator()
          else
            LinearProgressIndicator(
              value: progress,
              backgroundColor: ThemeProperties.getSurfaceColor(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ResponsiveSystem.sizedBox(context, height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (!isIndeterminate) ...[
            ResponsiveSystem.sizedBox(context, height: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: ThemeProperties.getSecondaryTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
