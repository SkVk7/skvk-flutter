/// Detailed Day View Popup Widget
///
/// Shows comprehensive information for a selected date including:
/// - Tithi, Nakshatra, Festivals
/// - Amavasya/Pournami status
/// - Available Gadiyalu (auspicious times)
/// - Lunar phase information
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../astrology/core/enums/astrology_enums.dart';
import '../../../../astrology/astrology_library.dart';
import '../../../../astrology/core/facades/astrology_facade.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../astrology/core/models/calendar_models.dart';

class DetailedDayViewPopup extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final double latitude;
  final double longitude;
  final AyanamshaType ayanamsha;
  final DayData? dayData;
  final VoidCallback onClose;

  const DetailedDayViewPopup({
    super.key,
    required this.selectedDate,
    required this.latitude,
    required this.longitude,
    required this.ayanamsha,
    this.dayData, // Optional pre-loaded data
    required this.onClose,
  });

  @override
  ConsumerState<DetailedDayViewPopup> createState() => _DetailedDayViewPopupState();
}

class _DetailedDayViewPopupState extends ConsumerState<DetailedDayViewPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  DayData? _dayData;
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
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Use pre-loaded data if available, otherwise try to load it
    if (widget.dayData != null) {
      print('🔍 DEBUG: Using pre-loaded day data: ${widget.dayData!.tithiName}');
      setState(() {
        _dayData = widget.dayData;
        _isLoading = false;
      });
    } else {
      print('🔍 DEBUG: No pre-loaded data, attempting to load...');
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

      // Initialize astrology library if needed
      if (!AstrologyLibrary.isInitialized) {
        await AstrologyLibrary.initialize();
      }

      // Get month data and find the specific day
      final facade = AstrologyFacade.instance;
      final monthData = await facade.getMonthPanchang(
        year: widget.selectedDate.year,
        month: widget.selectedDate.month,
        region: RegionalCalendar.universal,
        latitude: widget.latitude,
        longitude: widget.longitude,
        timezoneId: 'Asia/Kolkata', // Default to Indian timezone
      );

      // Find the specific day data
      DayData? dayData;
      try {
        dayData = monthData.days.firstWhere(
          (day) => day.date.day == widget.selectedDate.day,
        );
      } catch (e) {
        dayData = null;
      }

      if (mounted) {
        setState(() {
          _dayData = dayData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load day data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha((0.5 * 255).round()),
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
        color: ThemeProperties.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
        boxShadow: [
          BoxShadow(
            color: ThemeProperties.getShadowColor(context),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 20),
            offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 10)),
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
        color: ThemeProperties.getPrimaryColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.calendar,
            color: ThemeProperties.getSurfaceColor(context),
            size: ResponsiveSystem.iconSize(context, baseSize: 24),
          ),
          ResponsiveSystem.sizedBox(context, width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Day View',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getSurfaceColor(context),
                  ),
                ),
                ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                Text(
                  '${widget.selectedDate.day} ${_getMonthName(widget.selectedDate.month)} ${widget.selectedDate.year}',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                    color: ThemeProperties.getSurfaceColor(context).withAlpha((0.8 * 255).round()),
                  ),
                ),
                if (_dayData != null) ...[
                  ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                  Text(
                    _dayData!.tithiName,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeProperties.getSurfaceColor(context).withAlpha((0.8 * 255).round()),
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
              color: ThemeProperties.getSurfaceColor(context),
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
              ThemeProperties.getPrimaryColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
          Text(
            'Loading day information...',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeProperties.getSecondaryTextColor(context),
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
            color: ThemeProperties.getErrorColor(context),
          ),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
          Text(
            _errorMessage ?? 'Failed to load day data',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              color: ThemeProperties.getErrorColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
          ElevatedButton(
            onPressed: _loadDayData,
            child: Text('Retry'),
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
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 20)),
          _buildLunarInfo(context),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 20)),
          _buildFestivals(context),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 20)),
          _buildGadiyalu(context),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeProperties.getPrimaryColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeProperties.getPrimaryColor(context).withAlpha((0.3 * 255).round()),
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
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          _buildInfoRow(context, 'Tithi', _dayData!.tithiName, LucideIcons.moon),
          _buildInfoRow(context, 'Nakshatra', _dayData!.nakshatraName, LucideIcons.star),
          _buildInfoRow(context, 'Paksha', _dayData!.pakshaName, LucideIcons.calendar),
          _buildInfoRow(context, 'Yoga', _dayData!.yogaName, LucideIcons.activity),
          _buildInfoRow(context, 'Karana', _dayData!.karanaName, LucideIcons.clock),
        ],
      ),
    );
  }

  Widget _buildLunarInfo(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeProperties.getSecondaryColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeProperties.getSecondaryColor(context).withAlpha((0.3 * 255).round()),
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
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          _buildInfoRow(context, 'Sunrise', _dayData!.sunriseTime, LucideIcons.sunrise),
          _buildInfoRow(context, 'Sunset', _dayData!.sunsetTime, LucideIcons.sunset),
          _buildInfoRow(context, 'Moonrise', _dayData!.moonriseTime, LucideIcons.moon),
          _buildInfoRow(context, 'Moonset', _dayData!.moonsetTime, LucideIcons.moon),
        ],
      ),
    );
  }

  Widget _buildFestivals(BuildContext context) {
    final festivals = _dayData!.festivals;
    
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeProperties.getSecondaryColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeProperties.getSecondaryColor(context).withAlpha((0.3 * 255).round()),
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
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          if (festivals.isEmpty)
            Text(
              'No festivals on this day',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeProperties.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...festivals.map((festival) => _buildFestivalItem(context, festival)),
        ],
      ),
    );
  }

  Widget _buildGadiyalu(BuildContext context) {
    // Create mock gadiyalu data since it's not in DayData
    final gadiyalu = <Map<String, String>>[
      {'name': 'Rahu Kalam', 'time': _dayData!.rahuKalam, 'description': 'Avoid important activities'},
      {'name': 'Yama Ganda', 'time': _dayData!.yamaGanda, 'description': 'Avoid new ventures'},
      {'name': 'Gulika Kalam', 'time': _dayData!.gulikaKalam, 'description': 'Avoid auspicious activities'},
    ];
    
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 16),
      decoration: BoxDecoration(
        color: ThemeProperties.getSuccessColor(context).withAlpha((0.1 * 255).round()),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
        border: Border.all(
          color: ThemeProperties.getSuccessColor(context).withAlpha((0.3 * 255).round()),
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
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          if (gadiyalu.isEmpty)
            Text(
              'No auspicious times available',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                color: ThemeProperties.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...gadiyalu.map((gadi) => _buildGadiyaluItem(context, gadi)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: ResponsiveSystem.only(context, bottom: ResponsiveSystem.spacing(context, baseSpacing: 8)),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
            color: ThemeProperties.getPrimaryColor(context),
          ),
          ResponsiveSystem.sizedBox(context, width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                fontWeight: FontWeight.w500,
                color: ThemeProperties.getSecondaryTextColor(context),
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
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalItem(BuildContext context, String festival) {
    return Container(
      margin: ResponsiveSystem.only(context, bottom: ResponsiveSystem.spacing(context, baseSpacing: 8)),
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeProperties.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: ThemeProperties.getSecondaryColor(context).withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.calendar,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
            color: ThemeProperties.getSecondaryColor(context),
          ),
          ResponsiveSystem.sizedBox(context, width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  festival,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight: FontWeight.w600,
                    color: ThemeProperties.getPrimaryTextColor(context),
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
      margin: ResponsiveSystem.only(context, bottom: ResponsiveSystem.spacing(context, baseSpacing: 8)),
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeProperties.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: ThemeProperties.getSuccessColor(context).withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.clock,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
            color: ThemeProperties.getSuccessColor(context),
          ),
          ResponsiveSystem.sizedBox(context, width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gadi['name'] ?? '',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight: FontWeight.w600,
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                ),
                ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                Text(
                  gadi['time'] ?? '',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                    color: ThemeProperties.getSecondaryTextColor(context),
                  ),
                ),
                if (gadi['description']?.isNotEmpty == true) ...[
                  ResponsiveSystem.sizedBox(context, height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                  Text(
                    gadi['description']!,
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                      color: ThemeProperties.getSecondaryTextColor(context),
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
