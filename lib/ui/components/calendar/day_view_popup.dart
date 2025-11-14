/// Detailed Day View Popup Widget
///
/// Shows comprehensive information for a selected date including:
/// - Tithi, Nakshatra, Festivals
/// - Amavasya/Pournami status
/// - Available Gadiyalu (auspicious times)
/// - Lunar phase information
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/utils/validation/error_message_helper.dart';

class DayViewPopup extends ConsumerStatefulWidget {
  const DayViewPopup({
    required this.selectedDate,
    required this.latitude,
    required this.longitude,
    required this.ayanamsha,
    required this.onClose,
    super.key,
    this.dayData, // Optional pre-loaded data
  });
  final DateTime selectedDate;
  final double latitude;
  final double longitude;
  final String ayanamsha;
  final Map<String, dynamic>? dayData;
  final VoidCallback onClose;

  @override
  ConsumerState<DayViewPopup> createState() => _DayViewPopupState();
}

class _DayViewPopupState extends ConsumerState<DayViewPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic>? _dayData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Use pre-loaded data if available, otherwise try to load it
    if (widget.dayData != null) {
      unawaited(
        LoggingHelper.logDebug(
          'Using pre-loaded day data: ${widget.dayData?['tithiName'] ?? 'N/A'}',
          source: 'DayViewPopup',
        ),
      );
      setState(() {
        _dayData = _normalizeDayData(widget.dayData!);
        _isLoading = false;
      });
    } else {
      unawaited(
        LoggingHelper.logDebug(
          'No pre-loaded data, attempting to load...',
          source: 'DayViewPopup',
        ),
      );
      // Fallback: try to load data if not provided
      _loadDayData();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDayData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // extracted from the month API response. When used standalone, it falls back to empty data.
      // To implement standalone fetching, we would need to:
      // 1. Call getCalendarMonth API for the selected date's month
      // 2. Extract the specific day from the month response
      if (mounted) {
        setState(() {
          _dayData = widget.dayData != null
              ? _normalizeDayData(widget.dayData!)
              : <String, dynamic>{};
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        final userFriendlyMessage =
            ErrorMessageHelper.getUserFriendlyMessage(e);
        setState(() {
          _errorMessage = userFriendlyMessage;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.5),
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildPopupContent(context),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPopupContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      margin: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
        boxShadow: [
          BoxShadow(
            color: ThemeHelpers.getShadowColor(context),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 20),
            offset:
                Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 10)),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? _buildLoadingState(context)
                : _errorMessage != null
                    ? _buildErrorState(context)
                    : _buildDayContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeHelpers.getPrimaryColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 16),
          ),
          topRight: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 16),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.calendar,
            color: ThemeHelpers.getSurfaceColor(context),
            size: ResponsiveSystem.iconSize(context, baseSize: 24),
          ),
          ResponsiveSystem.sizedBox(
            context,
            width: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Day View',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeHelpers.getSurfaceColor(context),
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                ),
                Text(
                  '${widget.selectedDate.day} ${_getMonthName(widget.selectedDate.month)} ${widget.selectedDate.year}',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                    color: ThemeHelpers.getSurfaceColor(context)
                        .withValues(alpha: 0.8),
                  ),
                ),
                if (_dayData != null) ...[
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                  ),
                  Text(
                    _dayData!['tithiName'] as String? ?? 'Not available',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeHelpers.getSurfaceColor(context)
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              LucideIcons.x,
              color: ThemeHelpers.getSurfaceColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeHelpers.getPrimaryColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
          Text(
            'Loading day information...',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveSystem.iconSize(context, baseSize: 48),
            color: ThemeHelpers.getErrorColor(context),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
          Text(
            _errorMessage ?? 'Failed to load day data',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeHelpers.getErrorColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 16),
          ),
          ElevatedButton(
            onPressed: _loadDayData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContent(BuildContext context) {
    if (_dayData == null) return Container();

    return SingleChildScrollView(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(context),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 20),
          ),
          _buildLunarInfo(context),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 20),
          ),
          _buildFestivals(context),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 20),
          ),
          _buildGadiyalu(context),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.1),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          _buildInfoRow(
            context,
            'Tithi',
            _dayData!['tithiName'] as String? ?? 'Not available',
            LucideIcons.moon,
          ),
          _buildInfoRow(
            context,
            'Nakshatra',
            _dayData!['nakshatraName'] as String? ?? 'Not available',
            LucideIcons.star,
          ),
          _buildInfoRow(
            context,
            'Paksha',
            _dayData!['pakshaName'] as String? ?? 'Not available',
            LucideIcons.calendar,
          ),
          _buildInfoRow(
            context,
            'Yoga',
            _dayData!['yogaName'] as String? ?? 'Not available',
            LucideIcons.activity,
          ),
          _buildInfoRow(
            context,
            'Karana',
            _dayData!['karanaName'] as String? ?? 'Not available',
            LucideIcons.clock,
          ),
        ],
      ),
    );
  }

  Widget _buildLunarInfo(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSecondaryColor(context).withValues(alpha: 0.1),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeHelpers.getSecondaryColor(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lunar Information',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          _buildInfoRow(
            context,
            'Sunrise',
            _dayData!['sunriseTime'] as String? ?? 'Not available',
            LucideIcons.sunrise,
          ),
          _buildInfoRow(
            context,
            'Sunset',
            _dayData!['sunsetTime'] as String? ?? 'Not available',
            LucideIcons.sunset,
          ),
          _buildInfoRow(
            context,
            'Moonrise',
            _dayData!['moonriseTime'] as String? ?? 'Not available',
            LucideIcons.moon,
          ),
          _buildInfoRow(
            context,
            'Moonset',
            _dayData!['moonsetTime'] as String? ?? 'Not available',
            LucideIcons.moon,
          ),
        ],
      ),
    );
  }

  Widget _buildFestivals(BuildContext context) {
    final festivalsRaw = _dayData!['festivals'];
    final festivals = _convertToListOfMaps(festivalsRaw);

    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSecondaryColor(context).withValues(alpha: 0.1),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeHelpers.getSecondaryColor(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Festivals & Observances',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          if (festivals.isEmpty)
            Text(
              'No festivals on this day',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeHelpers.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...festivals.map((festival) {
              final festivalName = festival['name'] as String? ?? 'Festival';
              return _buildFestivalItem(context, festivalName);
            }),
        ],
      ),
    );
  }

  Widget _buildGadiyalu(BuildContext context) {
    final gadiyalu = <Map<String, String>>[
      {
        'name': 'Rahu Kalam',
        'time': _dayData!['rahuKalam'] as String? ?? 'Not available',
        'description': 'Avoid important activities',
      },
      {
        'name': 'Yama Ganda',
        'time': _dayData!['yamaGanda'] as String? ?? 'Not available',
        'description': 'Avoid new ventures',
      },
      {
        'name': 'Gulika Kalam',
        'time': _dayData!['gulikaKalam'] as String? ?? 'Not available',
        'description': 'Avoid auspicious activities',
      },
    ];

    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSuccessColor(context).withValues(alpha: 0.1),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeHelpers.getSuccessColor(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auspicious Times (Gadiyalu)',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
              color: ThemeHelpers.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(
            context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 12),
          ),
          if (gadiyalu.isEmpty)
            Text(
              'No auspicious times available',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeHelpers.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...gadiyalu.map((gadi) => _buildGadiyaluItem(context, gadi)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: ResponsiveSystem.only(
        context,
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
            color: ThemeHelpers.getPrimaryColor(context),
          ),
          ResponsiveSystem.sizedBox(
            context,
            width: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                fontWeight: FontWeight.w500,
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                fontWeight: FontWeight.w600,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalItem(BuildContext context, String festival) {
    return Container(
      margin: ResponsiveSystem.only(
        context,
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 8),
      ),
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: ThemeHelpers.getSecondaryColor(context).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.calendar,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
            color: ThemeHelpers.getSecondaryColor(context),
          ),
          ResponsiveSystem.sizedBox(
            context,
            width: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  festival,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight: FontWeight.w600,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGadiyaluItem(BuildContext context, Map<String, String> gadi) {
    return Container(
      margin: ResponsiveSystem.only(
        context,
        bottom: ResponsiveSystem.spacing(context, baseSpacing: 8),
      ),
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: ThemeHelpers.getSuccessColor(context).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.clock,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
            color: ThemeHelpers.getSuccessColor(context),
          ),
          ResponsiveSystem.sizedBox(
            context,
            width: ResponsiveSystem.spacing(context, baseSpacing: 8),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gadi['name'] ?? '',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight: FontWeight.w600,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                ),
                Text(
                  gadi['time'] ?? '',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                    color: ThemeHelpers.getSecondaryTextColor(context),
                  ),
                ),
                if (gadi['description']?.isNotEmpty ?? false) ...[
                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                  ),
                  Text(
                    gadi['description']!,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 12),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Normalize day data to convert all JavaScript arrays to proper Dart types
  /// This is necessary for Flutter web where JavaScript interop returns List<dynamic>
  Map<String, dynamic> _normalizeDayData(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is List) {
        if (key == 'festivals' || key == 'gadiyalu') {
          normalized[key] = _convertToListOfMaps(value);
        } else {
          // For other lists, convert to List<dynamic> safely
          normalized[key] = value.map((item) {
            if (item is Map<String, dynamic>) {
              return Map<String, dynamic>.from(item);
            } else if (item is Map) {
              return Map<String, dynamic>.from(item.cast<String, dynamic>());
            }
            return item;
          }).toList();
        }
      } else if (value is Map<String, dynamic>) {
        // Recursively normalize nested maps
        normalized[key] = _normalizeDayData(value);
      } else if (value is Map) {
        normalized[key] = _normalizeDayData(
          Map<String, dynamic>.from(value.cast<String, dynamic>()),
        );
      } else {
        // Copy primitive values as-is
        normalized[key] = value;
      }
    }

    return normalized;
  }

  /// Convert dynamic list to List<Map<String, dynamic>> safely
  /// Handles Flutter web's JavaScript interop where arrays come as List<dynamic>
  List<Map<String, dynamic>> _convertToListOfMaps(dynamic value) {
    if (value == null) return [];
    if (value is List<Map<String, dynamic>>) return value;
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
