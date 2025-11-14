/// Calendar Day Detail Popup
///
/// A detailed popup showing comprehensive Hindu information for a selected day
/// including abhijit, rahu, ketu, and ghadiyalu information
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/design_system/design_system.dart';
import 'package:skvk_application/core/utils/validation/error_message_helper.dart';

class CalendarDayDetailPopup extends StatefulWidget {
  const CalendarDayDetailPopup({
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.onClose,
    super.key,
    this.ayanamsha = 'lahiri',
  });
  final DateTime date;
  final double latitude;
  final double longitude;
  final String ayanamsha;
  final VoidCallback onClose;

  @override
  State<CalendarDayDetailPopup> createState() => _CalendarDayDetailPopupState();
}

class _CalendarDayDetailPopupState extends State<CalendarDayDetailPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? _detailedData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDetailedData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    _contentAnimationController.forward();
  }

  Future<void> _loadDetailedData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // To implement standalone fetching, we would need to:
      // 1. Call getCalendarMonth API for the date's month
      // 2. Extract the specific day from the month response
      // Consider using this widget from calendar_month_view which already has month data loaded.
      setState(() {
        _detailedData = {
          'tithi': 'Not available',
          'nakshatra': 'Not available',
          'paksha': 'Not available',
          'yoga': 'Not available',
          'karana': 'Not available',
          'festivals': <Map<String, dynamic>>[],
          'abhijit': <String, dynamic>{},
          'rahu': <String, dynamic>{},
          'ketu': <String, dynamic>{},
          'ghadiyalu': <String, dynamic>{},
          'sunrise': null,
          'sunset': null,
          'moonrise': null,
          'moonset': null,
        };
        _isLoading = false;
      });
    } on Exception catch (e) {
      final userFriendlyMessage = ErrorMessageHelper.getUserFriendlyMessage(e);
      setState(() {
        _errorMessage = userFriendlyMessage;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onClose,
        child: ColoredBox(
          color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on content
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
          ),
        ),
      ),
    );
  }

  Widget _buildPopupContent(BuildContext context) {
    return Container(
      width: ResponsiveSystem.screenWidth(context) * 0.9,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSurfaceColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
        boxShadow: [
          BoxShadow(
            color: ThemeHelpers.getShadowColor(context).withValues(alpha: 0.3),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 20),
            offset:
                Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 10)),
          ),
        ],
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: _isLoading
            ? _buildLoadingContent(context)
            : _errorMessage != null
                ? _buildErrorContent(context)
                : _buildDetailedContent(context),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: ThemeHelpers.getPrimaryColor(context),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          Text(
            'Loading detailed information...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveSystem.iconSize(context, baseSize: 48),
            color: ThemeHelpers.getErrorColor(context),
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeHelpers.getErrorColor(context),
                ),
            textAlign: TextAlign.center,
          ),
          ResponsiveSystem.sizedBox(context, height: 16),
          ElevatedButton(
            onPressed: _loadDetailedData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedContent(BuildContext context) {
    if (_detailedData == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        _buildHeader(context),

        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: ResponsiveSystem.all(context, baseSpacing: 16),
            child: Column(
              children: [
                // Basic Information
                _buildBasicInfo(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Festivals
                if (_detailedData!['festivals'] != null &&
                    (_detailedData!['festivals'] as List).isNotEmpty)
                  _buildFestivals(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Abhijit Information
                _buildAbhijitInfo(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Rahu and Ketu
                _buildRahuKetuInfo(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Ghadiyalu
                _buildGhadiyaluInfo(context),

                ResponsiveSystem.sizedBox(context, height: 16),

                // Sun and Moon Times
                _buildSunMoonTimes(context),
              ],
            ),
          ),
        ),
      ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(widget.date),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ThemeHelpers.getSurfaceColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ResponsiveSystem.sizedBox(context, height: 4),
                Text(
                  _getDayName(widget.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ThemeHelpers.getSurfaceColor(context)
                            .withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              color: ThemeHelpers.getSurfaceColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return _buildInfoSection(
      context,
      'Basic Information',
      Icons.info_outline,
      [
        _buildInfoRow(context, 'Tithi', _detailedData!['tithi'] ?? ''),
        _buildInfoRow(context, 'Nakshatra', _detailedData!['nakshatra'] ?? ''),
        _buildInfoRow(context, 'Paksha', _detailedData!['paksha'] ?? ''),
        _buildInfoRow(context, 'Yoga', _detailedData!['yoga'] ?? ''),
        _buildInfoRow(context, 'Karana', _detailedData!['karana'] ?? ''),
      ],
    );
  }

  Widget _buildFestivals(BuildContext context) {
    final festivals =
        _detailedData!['festivals'] as List<Map<String, dynamic>>? ?? [];

    return _buildInfoSection(
      context,
      'Festivals',
      Icons.celebration,
      festivals
          .map(
            (festival) => _buildInfoRow(
              context,
              festival['name'] as String? ?? 'Festival',
              (festival['description'] as String? ?? '').isNotEmpty
                  ? (festival['description'] as String)
                  : 'Hindu Festival',
            ),
          )
          .toList(),
    );
  }

  Widget _buildAbhijitInfo(BuildContext context) {
    final abhijit = _detailedData!['abhijit'] as Map<String, dynamic>;

    return _buildInfoSection(
      context,
      'Abhijit Muhurat',
      Icons.schedule,
      [
        _buildInfoRow(
          context,
          'Status',
          abhijit['isActive'] ? 'Active' : 'Inactive',
          isActive: abhijit['isActive'],
        ),
        _buildInfoRow(
          context,
          'Time',
          '${abhijit['startTime']} - ${abhijit['endTime']}',
        ),
        _buildInfoRow(context, 'Duration', abhijit['duration']),
      ],
    );
  }

  Widget _buildRahuKetuInfo(BuildContext context) {
    final rahu = _detailedData!['rahu'] as Map<String, dynamic>;
    final ketu = _detailedData!['ketu'] as Map<String, dynamic>;

    return _buildInfoSection(
      context,
      'Rahu & Ketu',
      Icons.visibility,
      [
        _buildInfoRow(
            context, 'Rahu Rashi', 'Rashi ${rahu['rashi'] as String? ?? ''}',),
        _buildInfoRow(
          context,
          'Rahu Degree',
          '${(rahu['degree'] as num?)?.toStringAsFixed(2) ?? '0.00'}°',
        ),
        _buildInfoRow(
            context, 'Ketu Rashi', 'Rashi ${ketu['rashi'] as String? ?? ''}',),
        _buildInfoRow(
          context,
          'Ketu Degree',
          '${(ketu['degree'] as num?)?.toStringAsFixed(2) ?? '0.00'}°',
        ),
      ],
    );
  }

  Widget _buildGhadiyaluInfo(BuildContext context) {
    final ghadiyalu = _detailedData!['ghadiyalu'] as List<Map<String, dynamic>>;

    return _buildInfoSection(
      context,
      'Ghadiyalu (8 Periods)',
      Icons.access_time,
      ghadiyalu
          .map(
            (ghadi) => _buildInfoRow(
              context,
              ghadi['name'],
              '${ghadi['startTime']} - ${ghadi['endTime']}',
              isAuspicious: ghadi['isAuspicious'],
            ),
          )
          .toList(),
    );
  }

  Widget _buildSunMoonTimes(BuildContext context) {
    return _buildInfoSection(
      context,
      'Sun & Moon Times',
      Icons.wb_sunny,
      [
        _buildInfoRow(
          context,
          'Sunrise',
          _formatTime(_detailedData!['sunrise']),
        ),
        _buildInfoRow(
          context,
          'Sunset',
          _formatTime(_detailedData!['sunset']),
        ),
        _buildInfoRow(
          context,
          'Moonrise',
          _formatTime(_detailedData!['moonrise']),
        ),
        _buildInfoRow(
          context,
          'Moonset',
          _formatTime(_detailedData!['moonset']),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: ThemeHelpers.getCardColor(context),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        border: Border.all(
          color: ThemeHelpers.getPrimaryColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
                color: ThemeHelpers.getPrimaryColor(context),
              ),
              ResponsiveSystem.sizedBox(context, width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ThemeHelpers.getPrimaryTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(context, height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool? isActive,
    bool? isAuspicious,
  }) {
    return Padding(
      padding: ResponsiveSystem.symmetric(context, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeHelpers.getSecondaryTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isActive != null)
                  Container(
                    width: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    height: ResponsiveSystem.spacing(context, baseSpacing: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? ThemeHelpers.getSuccessColor(context)
                          : ThemeHelpers.getErrorColor(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                if (isActive != null)
                  ResponsiveSystem.sizedBox(context, width: 8),
                if (isAuspicious != null)
                  Icon(
                    isAuspicious ? Icons.star : Icons.star_border,
                    size: ResponsiveSystem.iconSize(context, baseSize: 16),
                    color: isAuspicious
                        ? ThemeHelpers.getPrimaryColor(context)
                        : ThemeHelpers.getSecondaryTextColor(context),
                  ),
                if (isAuspicious != null)
                  ResponsiveSystem.sizedBox(context, width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ThemeHelpers.getPrimaryTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
