/// Formatting utilities for the Vedic Astrology Pro application
library;

import 'package:intl/intl.dart';

/// Formats date in DD-MM-YYYY format
String formatDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

/// Formats date in DD MMM YYYY format
String formatDateLong(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

/// Formats time in HH:MM format
String formatTime(DateTime time) {
  return DateFormat('HH:mm').format(time);
}

/// Formats time in HH:MM AM/PM format
String formatTime12Hour(DateTime time) {
  return DateFormat('hh:mm a').format(time);
}

/// Formats date and time together
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
}

/// Formats latitude with 4 decimal places
String formatLatitude(double latitude) {
  return latitude.toStringAsFixed(4);
}

/// Formats longitude with 4 decimal places
String formatLongitude(double longitude) {
  return longitude.toStringAsFixed(4);
}

/// Formats percentage with 1 decimal place
String formatPercentage(double percentage) {
  return '${percentage.toStringAsFixed(1)}%';
}

/// Formats compatibility score
String formatCompatibilityScore(double score) {
  return '${score.toStringAsFixed(0)}% Compatible';
}

/// Formats dasha period with years
String formatDashaPeriod(String planet, double years) {
  return '$planet Dasha (${years.toStringAsFixed(1)} years remaining)';
}

/// Formats nakshatra name with pada
String formatNakshatraWithPada(String nakshatra, int pada) {
  return '$nakshatra - ${_getPadaText(pada)}';
}

/// Formats rashi name
String formatRashiName(int rashiNumber) {
  const rashiNames = [
    'Mesha (Aries)',
    'Vrishabha (Taurus)',
    'Mithuna (Gemini)',
    'Karka (Cancer)',
    'Simha (Leo)',
    'Kanya (Virgo)',
    'Tula (Libra)',
    'Vrishchika (Scorpio)',
    'Dhanu (Sagittarius)',
    'Makara (Capricorn)',
    'Kumbha (Aquarius)',
    'Meena (Pisces)',
  ];
  return rashiNumber > 0 && rashiNumber <= 12
      ? rashiNames[rashiNumber - 1]
      : 'Unknown';
}

/// Formats nakshatra name
String formatNakshatraName(int nakshatraNumber) {
  const nakshatraNames = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];
  return nakshatraNumber > 0 && nakshatraNumber <= 27
      ? nakshatraNames[nakshatraNumber - 1]
      : 'Unknown';
}

/// Formats Hindu month name
String formatHinduMonthName(int month) {
  const hinduMonths = [
    'Chaitra',
    'Vaishakha',
    'Jyeshtha',
    'Ashadha',
    'Shravana',
    'Bhadrapada',
    'Ashwin',
    'Kartika',
    'Margashirsha',
    'Pausha',
    'Magha',
    'Phalguna',
  ];
  return month > 0 && month <= 12 ? hinduMonths[month - 1] : 'Unknown';
}

/// Formats Gregorian month name
String formatGregorianMonthName(int month) {
  const gregorianMonths = [
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
  return month > 0 && month <= 12 ? gregorianMonths[month - 1] : 'Unknown';
}

/// Formats short month name
String formatShortMonthName(int month) {
  const shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return month > 0 && month <= 12 ? shortMonths[month - 1] : 'Unknown';
}

String _getPadaText(int pada) {
  switch (pada) {
    case 1:
      return '1st Pada';
    case 2:
      return '2nd Pada';
    case 3:
      return '3rd Pada';
    case 4:
      return '4th Pada';
    default:
      return 'Unknown Pada';
  }
}
