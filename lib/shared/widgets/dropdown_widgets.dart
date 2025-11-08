/// Dropdown Widgets
///
/// Reusable widgets for creating dropdown items with descriptions,
/// regional information, and recommendation badges
library;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/design_system/design_system.dart';

/// Information interface for dropdown items
abstract class DropdownItemInfo {
  String get name;
  String get description;
  List<String> get regions;
  bool get isRecommended;
}

/// Dropdown item widget
class DropdownItem<T> extends StatelessWidget {
  final T value;
  final DropdownItemInfo info;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const DropdownItem({
    super.key,
    required this.value,
    required this.info,
    required this.primaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: ResponsiveSystem.spacing(context, baseSpacing: 50),
      ),
      padding: ResponsiveSystem.symmetric(context, horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                info.name,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor,
                ),
              ),
              if (info.isRecommended) ...[
                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
                Container(
                  padding: ResponsiveSystem.symmetric(context,
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(
                        ResponsiveSystem.borderRadius(context, baseRadius: 4)),
                  ),
                  child: Text(
                    'RECOMMENDED',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 10),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 2)),
          Text(
            info.description,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
              color: secondaryTextColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 2)),
          Wrap(
            spacing: ResponsiveSystem.spacing(context, baseSpacing: 4),
            runSpacing: ResponsiveSystem.spacing(context, baseSpacing: 2),
            children: info.regions
                .take(3)
                .map((region) => Container(
                      padding: ResponsiveSystem.symmetric(context,
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            ResponsiveSystem.borderRadius(context,
                                baseRadius: 4)),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                          width: ResponsiveSystem.borderWidth(context,
                              baseWidth: 1),
                        ),
                      ),
                      child: Text(
                        region,
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 10),
                          color: primaryColor,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// List tile for selection dialogs
class DropdownListTile<T> extends StatelessWidget {
  final T value;
  final DropdownItemInfo info;
  final bool isSelected;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const DropdownListTile({
    super.key,
    required this.value,
    required this.info,
    required this.isSelected,
    required this.primaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveSystem.symmetric(context, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 8)),
        border: Border.all(
          color:
              isSelected ? primaryColor : primaryColor.withValues(alpha: 0.2),
          width: isSelected
              ? ResponsiveSystem.borderWidth(context, baseWidth: 2)
              : ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                info.name,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor,
                ),
              ),
            ),
            if (info.isRecommended) ...[
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
              Container(
                padding: ResponsiveSystem.symmetric(context,
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(
                      ResponsiveSystem.borderRadius(context, baseRadius: 4)),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 10),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              info.description,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: secondaryTextColor,
              ),
            ),
            if (info.regions.isNotEmpty) ...[
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
              Wrap(
                spacing: ResponsiveSystem.spacing(context, baseSpacing: 4),
                runSpacing: ResponsiveSystem.spacing(context, baseSpacing: 2),
                children: info.regions
                    .take(3)
                    .map((region) => Container(
                          padding: ResponsiveSystem.symmetric(context,
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                ResponsiveSystem.borderRadius(context,
                                    baseRadius: 4)),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: ResponsiveSystem.borderWidth(context,
                                  baseWidth: 1),
                            ),
                          ),
                          child: Text(
                            region,
                            style: TextStyle(
                              fontSize: ResponsiveSystem.fontSize(context,
                                  baseSize: 10),
                              color: primaryColor,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: primaryColor,
                size: ResponsiveSystem.spacing(context, baseSpacing: 20),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

/// Current selection display widget
class CurrentSelection<T> extends StatelessWidget {
  final T value;
  final DropdownItemInfo info;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const CurrentSelection({
    super.key,
    required this.value,
    required this.info,
    required this.primaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveSystem.all(context, baseSpacing: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
            ResponsiveSystem.borderRadius(context, baseRadius: 8)),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.info,
                size: ResponsiveSystem.iconSize(context, baseSize: 16),
                color: primaryColor,
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
              Text(
                'Current Selection:',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
          Text(
            info.name,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
          Text(
            info.description,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
              color: secondaryTextColor,
            ),
          ),
          if (info.regions.isNotEmpty) ...[
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
            Wrap(
              spacing: ResponsiveSystem.spacing(context, baseSpacing: 4),
              runSpacing: ResponsiveSystem.spacing(context, baseSpacing: 2),
              children: info.regions
                  .take(3)
                  .map((region) => Container(
                        padding: ResponsiveSystem.symmetric(context,
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              ResponsiveSystem.borderRadius(context,
                                  baseRadius: 4)),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: ResponsiveSystem.borderWidth(context,
                                baseWidth: 1),
                          ),
                        ),
                        child: Text(
                          region,
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context,
                                baseSize: 10),
                            color: primaryColor,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Utility class for building dropdowns
class DropdownBuilder {
  /// Build dropdown items for a list of values
  static List<DropdownMenuItem<T>> buildDropdownItems<T>({
    required List<T> values,
    required DropdownItemInfo Function(T) getInfo,
    required Color primaryColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return values.map((T value) {
      final info = getInfo(value);
      return DropdownMenuItem<T>(
        value: value,
        child: DropdownItem<T>(
          value: value,
          info: info,
          primaryColor: primaryColor,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
        ),
      );
    }).toList();
  }

  /// Build list tiles for selection dialogs
  static List<Widget> buildListTiles<T>({
    required List<T> values,
    required DropdownItemInfo Function(T) getInfo,
    required T selectedValue,
    required Color primaryColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Function(T) onItemSelected,
  }) {
    return values.map((T value) {
      final info = getInfo(value);
      final isSelected = value == selectedValue;
      return DropdownListTile<T>(
        value: value,
        info: info,
        isSelected: isSelected,
        primaryColor: primaryColor,
        primaryTextColor: primaryTextColor,
        secondaryTextColor: secondaryTextColor,
        onTap: () => onItemSelected(value),
      );
    }).toList();
  }

  /// Build current selection display
  static Widget buildCurrentSelection<T>({
    required T value,
    required DropdownItemInfo Function(T) getInfo,
    required Color primaryColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final info = getInfo(value);
    return CurrentSelection<T>(
      value: value,
      info: info,
      primaryColor: primaryColor,
      primaryTextColor: primaryTextColor,
      secondaryTextColor: secondaryTextColor,
    );
  }
}
