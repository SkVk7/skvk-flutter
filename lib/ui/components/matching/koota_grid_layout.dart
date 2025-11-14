/// Koota Grid Layout Component
///
/// Reusable two-column layout for koota cards
library;

import 'package:flutter/material.dart';
import 'package:skvk_application/ui/components/matching/koota_card.dart';
import 'package:skvk_application/ui/components/matching/koota_info_helper.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';

/// Koota Grid Layout - Two-column layout for koota cards
class KootaGridLayout extends StatelessWidget {
  const KootaGridLayout({
    required this.kootaEntries,
    super.key,
  });
  final List<MapEntry<String, String>> kootaEntries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < kootaEntries.length; i += 2) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: KootaCard(
                  kootaName: kootaEntries[i].key,
                  score: kootaEntries[i].value,
                  kootaInfo: KootaInfoHelper.getKootaInfo(kootaEntries[i].key),
                ),
              ),
              ResponsiveSystem.sizedBox(
                context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              // Second column (if exists)
              Expanded(
                child: i + 1 < kootaEntries.length
                    ? KootaCard(
                        kootaName: kootaEntries[i + 1].key,
                        score: kootaEntries[i + 1].value,
                        kootaInfo: KootaInfoHelper.getKootaInfo(
                            kootaEntries[i + 1].key,),
                      )
                    : const SizedBox
                        .shrink(), // Empty space if odd number of items
              ),
            ],
          ),
          if (i + 2 < kootaEntries.length)
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
        ],
      ],
    );
  }
}
