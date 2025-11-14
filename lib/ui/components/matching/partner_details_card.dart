/// Partner Details Card Component
///
/// Reusable card for displaying partner (groom/bride) details in results
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skvk_application/ui/components/common/index.dart';

/// Partner Details Card - Displays partner information in results screen
class PartnerDetailsCard extends StatelessWidget {
  // "Groom Details" or "Bride Details"

  const PartnerDetailsCard({
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.title,
    super.key,
    this.nakshatram,
    this.raasi,
    this.pada,
  });
  final String name;
  final DateTime dateOfBirth;
  final TimeOfDay timeOfBirth;
  final String placeOfBirth;
  final String? nakshatram;
  final String? raasi;
  final String? pada;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(
                label: 'Name',
                value: name,
              ),
              InfoRow(
                label: 'DOB',
                value: DateFormat('dd-MM-yyyy').format(dateOfBirth),
              ),
              InfoRow(
                label: 'TOB',
                value: timeOfBirth.format(context),
              ),
              InfoRow(
                label: 'Place of Birth',
                value: placeOfBirth,
              ),
              InfoRow(
                label: 'Nakshatram',
                value: nakshatram ?? 'Not available',
              ),
              InfoRow(
                label: 'Raasi',
                value: raasi ?? 'Not available',
              ),
              InfoRow(
                label: 'Pada',
                value: pada ?? 'Not available',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
