import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// Widget for displaying astrology symbols with text
class AstrologySymbolWidget extends StatelessWidget {
  final String text;
  final String? symbol;
  final double? symbolSize;
  final TextStyle? textStyle;
  final double spacing;
  final int? rashiNumber;
  final int? nakshatraNumber;
  final String? planetSymbol;
  final bool showSymbol;
  final bool showTooltip;

  const AstrologySymbolWidget({
    super.key,
    required this.text,
    this.symbol,
    this.symbolSize,
    this.textStyle,
    this.spacing = 8.0,
    this.rashiNumber,
    this.nakshatraNumber,
    this.planetSymbol,
    this.showSymbol = true,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSymbolSize = symbolSize ?? ResponsiveSystem.iconSize(context, baseSize: 20);

    String? displaySymbol;
    if (showSymbol) {
      if (symbol != null) {
        displaySymbol = symbol;
      } else if (rashiNumber != null) {
        displaySymbol = _getRashiSymbol(rashiNumber!);
      } else if (nakshatraNumber != null) {
        displaySymbol = _getNakshatraSymbol(nakshatraNumber!);
      } else if (planetSymbol != null) {
        displaySymbol = planetSymbol;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (displaySymbol != null) ...[
          Text(
            displaySymbol,
            style: TextStyle(fontSize: effectiveSymbolSize),
          ),
          SizedBox(width: spacing),
        ],
        Text(
          text,
          style: textStyle,
        ),
      ],
    );
  }
}

// Helper methods to replace missing AstrologyUtils methods
String _getRashiSymbol(int rashiNumber) {
  const symbols = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
  return symbols[(rashiNumber - 1) % 12];
}

String _getNakshatraSymbol(int nakshatraNumber) {
  const symbols = [
    '★',
    '☆',
    '✦',
    '✧',
    '✩',
    '✪',
    '✫',
    '✬',
    '✭',
    '✮',
    '✯',
    '✰',
    '✱',
    '✲',
    '✳',
    '✴',
    '✵',
    '✶',
    '✷',
    '✸',
    '✹',
    '✺',
    '✻',
    '✼',
    '✽',
    '✾',
    '✿'
  ];
  return symbols[(nakshatraNumber - 1) % 27];
}
