/// Location Search Field Component
///
/// Reusable location search field with suggestions for matching forms
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Location Search Field - Reusable location search with suggestions
class LocationSearchField extends StatelessWidget {
  const LocationSearchField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.onChanged,
    required this.onTap,
    required this.suggestions,
    required this.showSuggestions,
    required this.isSearching,
    required this.onSuggestionSelected,
    super.key,
    this.error,
  });
  final TextEditingController controller;
  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final List<Map<String, dynamic>> suggestions;
  final bool showSuggestions;
  final bool isSearching;
  final String? error;
  final ValueChanged<Map<String, dynamic>> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            fontWeight: FontWeight.w500,
            color: ThemeHelpers.getPrimaryTextColor(context),
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(
              LucideIcons.mapPin,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
              color: ThemeHelpers.getSecondaryTextColor(context),
            ),
            border: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeHelpers.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeHelpers.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeHelpers.getPrimaryColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
              ),
            ),
            filled: true,
            fillColor: ThemeHelpers.getSurfaceColor(context),
            contentPadding: ResponsiveSystem.all(context, baseSpacing: 16),
          ),
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeHelpers.getPrimaryTextColor(context),
          ),
          onChanged: onChanged,
          onTap: onTap,
        ),

        // Location suggestions dropdown
        if (showSuggestions && suggestions.isNotEmpty) ...[
          ResponsiveSystem.sizedBox(context, height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: ThemeHelpers.getSurfaceColor(context),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              border: Border.all(
                color: ThemeHelpers.getPrimaryColor(context)
                    .withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeHelpers.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: suggestions.map((suggestion) {
                return ListTile(
                  title: Text(
                    suggestion['name'] ?? 'Unknown Location',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                  subtitle: Text(
                    '${(suggestion['latitude'] as num?)?.toStringAsFixed(4) ?? ''}, ${(suggestion['longitude'] as num?)?.toStringAsFixed(4) ?? ''}',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 12),
                      color: ThemeHelpers.getSecondaryTextColor(context),
                    ),
                  ),
                  onTap: () => onSuggestionSelected(suggestion),
                );
              }).toList(),
            ),
          ),
        ],

        // Error message
        if (error != null) ...[
          ResponsiveSystem.sizedBox(context, height: 8),
          Container(
            padding: ResponsiveSystem.all(context, baseSpacing: 12),
            decoration: BoxDecoration(
              color: ThemeHelpers.getErrorColor(context).withValues(alpha: 0.1),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              border: Border.all(
                color: ThemeHelpers.getErrorColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveSystem.iconSize(context, baseSize: 16),
                  color: ThemeHelpers.getErrorColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeHelpers.getErrorColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
