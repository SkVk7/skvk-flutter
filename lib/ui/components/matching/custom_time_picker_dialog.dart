/// Custom Time Picker Dialog Component
///
/// Reusable custom time picker dialog with hour, minute, and AM/PM selection
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/responsive_system.dart';

/// Custom themed time picker dialog with reactive sizing
class CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePickerDialog({
    super.key,
    required this.initialTime,
  });

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();

  /// Show the time picker dialog
  static Future<TimeOfDay?> show(BuildContext context, TimeOfDay initialTime) {
    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) => CustomTimePickerDialog(initialTime: initialTime),
    );
  }
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late TimeOfDay _selectedTime;
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectedHour = _selectedTime.hourOfPeriod;
    _selectedMinute = _selectedTime.minute;
    _isAM = _selectedTime.period == DayPeriod.am;
  }

  void _updateTime() {
    final hour24 = _isAM ? _selectedHour : _selectedHour + 12;
    if (hour24 == 24) _selectedHour = 0;
    _selectedTime = TimeOfDay(hour: hour24, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeHelpers.getSurfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context,
            baseRadius: ResponsiveSystem.spacing(context, baseSpacing: 16)),
      ),
      child: Container(
        width: ResponsiveSystem.responsive(
          context,
          mobile: ResponsiveSystem.spacing(context, baseSpacing: 320),
          tablet: ResponsiveSystem.spacing(context, baseSpacing: 400),
          desktop: ResponsiveSystem.spacing(context, baseSpacing: 480),
        ),
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

            // Time Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Hour Selection
                _buildTimeSelector(
                  label: 'Hour',
                  value: _selectedHour.toString().padLeft(2, '0'),
                  onIncrement: () {
                    setState(() {
                      _selectedHour = (_selectedHour + 1) % 12;
                      if (_selectedHour == 0) _selectedHour = 12;
                      _updateTime();
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      _selectedHour = (_selectedHour - 1) % 12;
                      if (_selectedHour == 0) _selectedHour = 12;
                      _updateTime();
                    });
                  },
                ),

                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Minute Selection
                _buildTimeSelector(
                  label: 'Minute',
                  value: _selectedMinute.toString().padLeft(2, '0'),
                  onIncrement: () {
                    setState(() {
                      _selectedMinute = (_selectedMinute + 5) % 60;
                      _updateTime();
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      _selectedMinute = (_selectedMinute - 5) % 60;
                      if (_selectedMinute < 0) _selectedMinute = 55;
                      _updateTime();
                    });
                  },
                ),

                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // AM/PM Selection
                _buildPeriodSelector(),
              ],
            ),

            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

            // Clock Display
            _buildClockDisplay(),

            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                ),
                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedTime),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHelpers.getPrimaryColor(context),
                    foregroundColor:
                        ThemeHelpers.getPrimaryTextColor(context),
                    padding: ResponsiveSystem.symmetric(
                      context,
                      horizontal:
                          ResponsiveSystem.spacing(context, baseSpacing: 24),
                      vertical:
                          ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveSystem.circular(context,
                          baseRadius: ResponsiveSystem.spacing(context,
                              baseSpacing: 8)),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            color: ThemeHelpers.getSecondaryTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
        Container(
          width: ResponsiveSystem.spacing(context, baseSpacing: 80),
          height: ResponsiveSystem.spacing(context, baseSpacing: 100),
          decoration: BoxDecoration(
            color: ThemeHelpers.getSurfaceContainerColor(context),
            borderRadius: ResponsiveSystem.circular(context,
                baseRadius: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            border: Border.all(
              color: ThemeHelpers.getPrimaryColor(context),
              width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onIncrement,
                icon: Icon(
                  LucideIcons.chevronUp,
                  color: ThemeHelpers.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                  fontWeight: FontWeight.bold,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
              IconButton(
                onPressed: onDecrement,
                icon: Icon(
                  LucideIcons.chevronDown,
                  color: ThemeHelpers.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      children: [
        Text(
          'Period',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            color: ThemeHelpers.getSecondaryTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
        Container(
          width: ResponsiveSystem.spacing(context, baseSpacing: 80),
          height: ResponsiveSystem.spacing(context, baseSpacing: 100),
          decoration: BoxDecoration(
            color: ThemeHelpers.getSurfaceContainerColor(context),
            borderRadius: ResponsiveSystem.circular(context,
                baseRadius: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            border: Border.all(
              color: ThemeHelpers.getPrimaryColor(context),
              width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAM = true;
                    _updateTime();
                  });
                },
                child: Container(
                  width: ResponsiveSystem.screenWidth(context),
                  height: ResponsiveSystem.spacing(context, baseSpacing: 40),
                  decoration: BoxDecoration(
                    color: _isAM
                        ? ThemeHelpers.getPrimaryColor(context)
                        : ThemeHelpers.getTransparentColor(context),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          ResponsiveSystem.borderRadius(context, baseRadius: 10)),
                      topRight: Radius.circular(
                          ResponsiveSystem.borderRadius(context, baseRadius: 10)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'AM',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 16),
                        fontWeight: FontWeight.w600,
                        color: _isAM
                            ? ThemeHelpers.getPrimaryTextColor(context)
                            : ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAM = false;
                    _updateTime();
                  });
                },
                child: Container(
                  width: ResponsiveSystem.screenWidth(context),
                  height: ResponsiveSystem.spacing(context, baseSpacing: 40),
                  decoration: BoxDecoration(
                    color: !_isAM
                        ? ThemeHelpers.getPrimaryColor(context)
                        : ThemeHelpers.getTransparentColor(context),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                          ResponsiveSystem.borderRadius(context, baseRadius: 10)),
                      bottomRight: Radius.circular(
                          ResponsiveSystem.borderRadius(context, baseRadius: 10)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'PM',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 16),
                        fontWeight: FontWeight.w600,
                        color: !_isAM
                            ? ThemeHelpers.getPrimaryTextColor(context)
                            : ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClockDisplay() {
    return Container(
      width: ResponsiveSystem.spacing(context, baseSpacing: 120),
      height: ResponsiveSystem.spacing(context, baseSpacing: 120),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeHelpers.getSurfaceContainerColor(context),
        border: Border.all(
          color: ThemeHelpers.getPrimaryColor(context),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_selectedTime.hourOfPeriod.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                fontWeight: FontWeight.bold,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
            Text(
              _selectedTime.period == DayPeriod.am ? 'AM' : 'PM',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

