/// Koota Grid Layout Component
///
/// Reusable two-column layout for koota cards
library;

import 'package:flutter/material.dart';
import '../../utils/responsive_system.dart';
import 'koota_card.dart';
import 'koota_info_helper.dart';

/// Koota Grid Layout - Two-column layout for koota cards
class KootaGridLayout extends StatelessWidget {
  final List<MapEntry<String, String>> kootaEntries;

  const KootaGridLayout({
    super.key,
    required this.kootaEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Create rows of 2 columns each
        for (int i = 0; i < kootaEntries.length; i += 2) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First column
              Expanded(
                child: KootaCard(
                  kootaName: kootaEntries[i].key,
                  score: kootaEntries[i].value,
                  kootaInfo: KootaInfoHelper.getKootaInfo(kootaEntries[i].key),
                ),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16)),
              // Second column (if exists)
              Expanded(
                child: i + 1 < kootaEntries.length
                    ? KootaCard(
                        kootaName: kootaEntries[i + 1].key,
                        score: kootaEntries[i + 1].value,
                        kootaInfo: KootaInfoHelper.getKootaInfo(kootaEntries[i + 1].key),
                      )
                    : const SizedBox.shrink(), // Empty space if odd number of items
              ),
            ],
          ),
          // Add spacing between rows (except for the last row)
          if (i + 2 < kootaEntries.length)
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
        ],
      ],
    );
  }
}

