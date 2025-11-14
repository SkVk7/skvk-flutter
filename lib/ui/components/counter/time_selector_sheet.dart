/// Time Selector Sheet Component
///
/// Bottom sheet for selecting cooldown duration
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

class TimeSelectorSheet extends StatefulWidget {
  const TimeSelectorSheet({
    required this.initialDuration,
    required this.onDurationSelected,
    super.key,
  });
  final Duration initialDuration;
  final Function(Duration) onDurationSelected;

  @override
  State<TimeSelectorSheet> createState() => _TimeSelectorSheetState();
}

class _TimeSelectorSheetState extends State<TimeSelectorSheet> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late Duration _selectedDuration;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
    _hoursController = FixedExtentScrollController(
      initialItem: _selectedDuration.inHours,
    );
    _minutesController = FixedExtentScrollController(
      initialItem: _selectedDuration.inMinutes % 60,
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ResponsiveSystem for screen height instead of direct MediaQuery
    final screenHeight = ResponsiveSystemExtensions.screenHeight(context);
    final maxHeight = ResponsiveSystem.responsive(
      context,
      mobile: screenHeight * 0.6,
      tablet: screenHeight * 0.65,
      desktop: screenHeight * 0.7,
      largeDesktop: screenHeight * 0.7,
    );

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: ThemeHelpers.getSurfaceColor(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 24),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ResponsiveSystem.spacing(context, baseSpacing: 40),
            height: ResponsiveSystem.spacing(context, baseSpacing: 4),
            margin: ResponsiveSystem.symmetric(
              context,
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            decoration: BoxDecoration(
              color: ThemeHelpers.getDividerColor(context),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 2),
            ),
          ),

          // Title
          Padding(
            padding: ResponsiveSystem.symmetric(
              context,
              horizontal: ResponsiveSystem.spacing(context, baseSpacing: 20),
              vertical: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            child: Text(
              'Set Each Pradakshana Time',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                fontWeight: FontWeight.bold,
                color: ThemeHelpers.getPrimaryTextColor(context),
              ),
            ),
          ),

          // Time selectors
          Flexible(
            child: Row(
              children: [
                // Hours
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hours',
                        style: TextStyle(
                          fontSize: ResponsiveSystem.fontSize(
                            context,
                            baseSize: 14,
                          ),
                          fontWeight: FontWeight.w600,
                          color: ThemeHelpers.getPrimaryTextColor(context),
                        ),
                      ),
                      ResponsiveSystem.sizedBox(
                        context,
                        height:
                            ResponsiveSystem.spacing(context, baseSpacing: 8),
                      ),
                      Flexible(
                        child: Container(
                          height: ResponsiveSystem.spacing(
                            context,
                            baseSpacing: 200,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeHelpers.getSurfaceColor(context),
                            borderRadius: ResponsiveSystem.circular(
                              context,
                              baseRadius: 12,
                            ),
                            border: Border.all(
                              color: ThemeHelpers.getBorderColor(context),
                              width: ResponsiveSystem.borderWidth(
                                context,
                                baseWidth: 1,
                              ),
                            ),
                          ),
                          child: ListWheelScrollView.useDelegate(
                            controller: _hoursController,
                            itemExtent: ResponsiveSystem.spacing(
                              context,
                              baseSpacing: 50,
                            ),
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedDuration = Duration(
                                  hours: index,
                                  minutes: _selectedDuration.inMinutes % 60,
                                );
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final isSelected =
                                    index == _selectedDuration.inHours;
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: ResponsiveSystem.fontSize(
                                        context,
                                        baseSize: 20,
                                      ),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? ThemeHelpers.getPrimaryColor(
                                              context,)
                                          : ThemeHelpers.getPrimaryTextColor(
                                              context,),
                                    ),
                                  ),
                                );
                              },
                              childCount: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),

                // Minutes
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Minutes',
                        style: TextStyle(
                          fontSize: ResponsiveSystem.fontSize(
                            context,
                            baseSize: 14,
                          ),
                          fontWeight: FontWeight.w600,
                          color: ThemeHelpers.getPrimaryTextColor(context),
                        ),
                      ),
                      ResponsiveSystem.sizedBox(
                        context,
                        height:
                            ResponsiveSystem.spacing(context, baseSpacing: 8),
                      ),
                      Flexible(
                        child: Container(
                          height: ResponsiveSystem.spacing(
                            context,
                            baseSpacing: 200,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeHelpers.getSurfaceColor(context),
                            borderRadius: ResponsiveSystem.circular(
                              context,
                              baseRadius: 12,
                            ),
                            border: Border.all(
                              color: ThemeHelpers.getBorderColor(context),
                              width: ResponsiveSystem.borderWidth(
                                context,
                                baseWidth: 1,
                              ),
                            ),
                          ),
                          child: ListWheelScrollView.useDelegate(
                            controller: _minutesController,
                            itemExtent: ResponsiveSystem.spacing(
                              context,
                              baseSpacing: 50,
                            ),
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedDuration = Duration(
                                  hours: _selectedDuration.inHours,
                                  minutes: index,
                                );
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final isSelected =
                                    index == (_selectedDuration.inMinutes % 60);
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: ResponsiveSystem.fontSize(
                                        context,
                                        baseSize: 20,
                                      ),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? ThemeHelpers.getPrimaryColor(
                                              context,)
                                          : ThemeHelpers.getPrimaryTextColor(
                                              context,),
                                    ),
                                  ),
                                );
                              },
                              childCount: 60,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: ResponsiveSystem.all(context, baseSpacing: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDurationSelected(_selectedDuration);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelpers.getPrimaryColor(context),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: ResponsiveSystem.symmetric(
                    context,
                    vertical:
                        ResponsiveSystem.spacing(context, baseSpacing: 16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: ResponsiveSystem.circular(
                      context,
                      baseRadius: 12,
                    ),
                  ),
                ),
                child: Text(
                  'Set Time',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(
                      context,
                      baseSize: 16,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
