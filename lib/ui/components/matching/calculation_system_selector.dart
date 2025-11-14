/// Calculation System Selector Component
///
/// Reusable component for selecting ayanamsha and house system
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/core/utils/astrology/ayanamsha_info.dart'
    show AyanamshaInfoHelper;
import 'package:skvk_application/core/utils/astrology/house_system_info.dart'
    show HouseSystemInfoHelper;
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Calculation System Selector - Ayanamsha and House System dropdowns
class CalculationSystemSelector extends StatelessWidget {
  const CalculationSystemSelector({
    required this.selectedAyanamsha,
    required this.selectedHouseSystem,
    required this.onAyanamshaChanged,
    required this.onHouseSystemChanged,
    super.key,
  });
  final String selectedAyanamsha;
  final String selectedHouseSystem;
  final ValueChanged<String> onAyanamshaChanged;
  final ValueChanged<String> onHouseSystemChanged;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Calculation System',
        ),
        ResponsiveSystem.sizedBox(
          context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 12),
        ),
        // Responsive layout: Row on larger screens, Column on small screens
        if (isSmallScreen)
          Column(
            children: [
              _buildAyanamshaDropdown(context),
              ResponsiveSystem.sizedBox(
                context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              _buildHouseSystemDropdown(context),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildAyanamshaDropdown(context),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12),
              ),
              Expanded(
                child: _buildHouseSystemDropdown(context),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAyanamshaDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedAyanamsha,
      decoration: InputDecoration(
        labelText: 'Ayanamsha',
        border: OutlineInputBorder(
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        ),
        filled: true,
        fillColor: ThemeHelpers.getSurfaceColor(context),
        contentPadding: ResponsiveSystem.all(context, baseSpacing: 16),
      ),
      style: TextStyle(
        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
        color: ThemeHelpers.getPrimaryTextColor(context),
      ),
      items: AyanamshaInfoHelper.getAllAyanamshaTypes().map((type) {
        final info = AyanamshaInfoHelper.getAyanamshaInfo(type);
        return DropdownMenuItem<String>(
          value: type,
          child: Text(info?.name ?? type),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onAyanamshaChanged(newValue);
        }
      },
    );
  }

  Widget _buildHouseSystemDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedHouseSystem,
      decoration: InputDecoration(
        labelText: 'House System',
        border: OutlineInputBorder(
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        ),
        filled: true,
        fillColor: ThemeHelpers.getSurfaceColor(context),
        contentPadding: ResponsiveSystem.all(context, baseSpacing: 16),
      ),
      style: TextStyle(
        fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
        color: ThemeHelpers.getPrimaryTextColor(context),
      ),
      items: HouseSystemInfoHelper.getAllHouseSystemTypes().map((system) {
        final info = HouseSystemInfoHelper.getHouseSystemInfo(system);
        return DropdownMenuItem<String>(
          value: system,
          child: Text(info?.name ?? system),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onHouseSystemChanged(newValue);
        }
      },
    );
  }
}
