/// Regional Variation Service - Regional Adjustments and Variations
///
/// This service handles all regional variations and adjustments
/// following the Single Responsibility Principle.
library;

import '../enums/astrology_enums.dart';
import 'interfaces/regional_calendar_interfaces.dart';
// Removed: Timezone service import - UTC datetime should be passed directly

/// Regional variation service implementation
class RegionalVariationService implements IRegionalVariationService {
  static RegionalVariationService? _instance;
  // Removed: Timezone service - UTC datetime should be passed directly

  RegionalVariationService._();

  static RegionalVariationService get instance {
    _instance ??= RegionalVariationService._();
    return _instance!;
  }

  @override
  Future<Map<String, dynamic>> getFestivalVariations({
    required String festivalName,
    required RegionalCalendar regionalCalendar,
  }) async {
    final festivalKey = festivalName.toLowerCase();

    // Get variations from the comprehensive festival variations map
    return _getFestivalVariationsMap()[festivalKey]?[regionalCalendar] ?? {};
  }

  @override
  Future<Duration> calculateRegionalAdjustment({
    required DateTime baseDate,
    required Map<String, dynamic> variations,
    required double latitude,
    required double longitude,
    RegionalCalendar? regionalCalendar,
  }) async {
    // Removed: Timezone adjustments - UTC datetime should be passed directly

    // Apply regional calendar adjustments
    final calendarAdjustment = variations['dateAdjustment'] as int? ?? 0;

    // Apply seasonal adjustments
    final seasonalAdjustment = _getSeasonalAdjustment(baseDate, latitude);

    // Apply cultural adjustments
    final culturalAdjustment =
        regionalCalendar != null ? _getCulturalAdjustment(regionalCalendar, baseDate) : 0;

    return Duration(
      days: calendarAdjustment + seasonalAdjustment + culturalAdjustment,
      hours: 0, // Removed timezone adjustment - UTC datetime should be passed directly
    );
  }

  @override
  Future<int> getTimezoneAdjustment({
    required double latitude,
    required double longitude,
  }) async {
    // Removed: Timezone adjustment - UTC datetime should be passed directly
    return 0;
  }

  /// Get seasonal adjustment based on latitude and date
  int _getSeasonalAdjustment(DateTime date, double latitude) {
    // Apply seasonal variations based on latitude
    if (latitude > 30.0) {
      // Northern regions - adjust for winter/summer
      return date.month >= 10 || date.month <= 3 ? 1 : 0;
    } else if (latitude < 15.0) {
      // Southern regions - adjust for monsoon
      return date.month >= 6 && date.month <= 9 ? -1 : 0;
    }
    return 0;
  }

  /// Get cultural adjustment based on regional calendar
  int _getCulturalAdjustment(RegionalCalendar regionalCalendar, DateTime date) {
    switch (regionalCalendar) {
      case RegionalCalendar.tamil:
        // Tamil calendar has different month calculations
        return _getTamilAdjustment(date);
      case RegionalCalendar.malayalam:
        // Malayalam calendar has different month calculations
        return _getMalayalamAdjustment(date);
      case RegionalCalendar.bengali:
        // Bengali calendar has different month calculations
        return _getBengaliAdjustment(date);
      case RegionalCalendar.gujarati:
        // Gujarati calendar has different month calculations
        return _getGujaratiAdjustment(date);
      default:
        return 0;
    }
  }

  /// Get Tamil calendar adjustment
  int _getTamilAdjustment(DateTime date) {
    // Tamil calendar starts in April (Chithirai)
    if (date.month >= 4 && date.month <= 6) {
      return -1; // Early year adjustment
    }
    return 0;
  }

  /// Get Malayalam calendar adjustment
  int _getMalayalamAdjustment(DateTime date) {
    // Malayalam calendar starts in April (Medam)
    if (date.month >= 4 && date.month <= 6) {
      return -1; // Early year adjustment
    }
    return 0;
  }

  /// Get Bengali calendar adjustment
  int _getBengaliAdjustment(DateTime date) {
    // Bengali calendar starts in April (Boishakh)
    if (date.month >= 4 && date.month <= 6) {
      return -1; // Early year adjustment
    }
    return 0;
  }

  /// Get Gujarati calendar adjustment
  int _getGujaratiAdjustment(DateTime date) {
    // Gujarati calendar starts in October (Kartik)
    if (date.month >= 10 || date.month <= 3) {
      return 1; // Late year adjustment
    }
    return 0;
  }

  /// Get comprehensive festival variations map
  Map<String, Map<RegionalCalendar, Map<String, dynamic>>> _getFestivalVariationsMap() {
    return {
      'diwali': {
        RegionalCalendar.northIndian: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness',
          'culturalNotes': 'Celebrated with lamps and fireworks',
        },
        RegionalCalendar.tamil: {
          'dateAdjustment': -1,
          'regionalName': 'Deepavali',
          'significance': 'Victory of light over darkness (Tamil variation)',
          'culturalNotes': 'Celebrated with oil lamps and rangoli',
        },
        RegionalCalendar.bengali: {
          'dateAdjustment': 1,
          'regionalName': 'Kali Puja',
          'significance': 'Worship of Goddess Kali',
          'culturalNotes': 'Celebrated with Kali puja and special rituals',
        },
        RegionalCalendar.gujarati: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Gujarati variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.marathi: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Marathi variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.malayalam: {
          'dateAdjustment': -1,
          'regionalName': 'Deepavali',
          'significance': 'Victory of light over darkness (Malayalam variation)',
          'culturalNotes': 'Celebrated with oil lamps and traditional rituals',
        },
        RegionalCalendar.kannada: {
          'dateAdjustment': -1,
          'regionalName': 'Deepavali',
          'significance': 'Victory of light over darkness (Kannada variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.telugu: {
          'dateAdjustment': -1,
          'regionalName': 'Deepavali',
          'significance': 'Victory of light over darkness (Telugu variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.odia: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Odia variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.assamese: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Assamese variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.manipuri: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Manipuri variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.kashmiri: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Kashmiri variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.nepali: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Nepali variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.sikkimese: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Sikkimese variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
        RegionalCalendar.goan: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Goan variation)',
          'culturalNotes': 'Celebrated with lamps and traditional sweets',
        },
      },
      'holi': {
        RegionalCalendar.northIndian: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors',
          'culturalNotes': 'Celebrated with colors and water',
        },
        RegionalCalendar.tamil: {
          'dateAdjustment': -1,
          'regionalName': 'Kaman Pandigai',
          'significance': 'Festival of colors (Tamil variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.bengali: {
          'dateAdjustment': 1,
          'regionalName': 'Dol Jatra',
          'significance': 'Festival of colors (Bengali variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.gujarati: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Gujarati variation)',
          'culturalNotes': 'Celebrated with colors and traditional sweets',
        },
        RegionalCalendar.marathi: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Marathi variation)',
          'culturalNotes': 'Celebrated with colors and traditional sweets',
        },
        RegionalCalendar.malayalam: {
          'dateAdjustment': -1,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Malayalam variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.kannada: {
          'dateAdjustment': -1,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Kannada variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.telugu: {
          'dateAdjustment': -1,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Telugu variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.odia: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Odia variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.assamese: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Assamese variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.manipuri: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Manipuri variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.kashmiri: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Kashmiri variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.nepali: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Nepali variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.sikkimese: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Sikkimese variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
        RegionalCalendar.goan: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Goan variation)',
          'culturalNotes': 'Celebrated with colors and traditional rituals',
        },
      },
      'pongal': {
        RegionalCalendar.tamil: {
          'dateAdjustment': 0,
          'regionalName': 'Pongal',
          'significance': 'Harvest festival',
          'culturalNotes': 'Celebrated with rice and traditional sweets',
        },
        RegionalCalendar.malayalam: {
          'dateAdjustment': 0,
          'regionalName': 'Makar Sankranti',
          'significance': 'Harvest festival (Malayalam variation)',
          'culturalNotes': 'Celebrated with traditional sweets and rituals',
        },
        RegionalCalendar.kannada: {
          'dateAdjustment': 0,
          'regionalName': 'Sankranti',
          'significance': 'Harvest festival (Kannada variation)',
          'culturalNotes': 'Celebrated with traditional sweets and rituals',
        },
        RegionalCalendar.telugu: {
          'dateAdjustment': 0,
          'regionalName': 'Sankranti',
          'significance': 'Harvest festival (Telugu variation)',
          'culturalNotes': 'Celebrated with traditional sweets and rituals',
        },
      },
      'janmashtami': {
        RegionalCalendar.northIndian: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.tamil: {
          'dateAdjustment': 0,
          'regionalName': 'Krishna Jayanti',
          'significance': 'Birth of Lord Krishna (Tamil variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.bengali: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Bengali variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.gujarati: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Gujarati variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.marathi: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Marathi variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.malayalam: {
          'dateAdjustment': 0,
          'regionalName': 'Krishna Jayanti',
          'significance': 'Birth of Lord Krishna (Malayalam variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.kannada: {
          'dateAdjustment': 0,
          'regionalName': 'Krishna Jayanti',
          'significance': 'Birth of Lord Krishna (Kannada variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.telugu: {
          'dateAdjustment': 0,
          'regionalName': 'Krishna Jayanti',
          'significance': 'Birth of Lord Krishna (Telugu variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.odia: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Odia variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.assamese: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Assamese variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.manipuri: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Manipuri variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.kashmiri: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Kashmiri variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.nepali: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Nepali variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.sikkimese: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Sikkimese variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
        RegionalCalendar.goan: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Goan variation)',
          'culturalNotes': 'Celebrated with fasting and prayers',
        },
      },
      'dussehra': {
        RegionalCalendar.northIndian: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil',
          'culturalNotes': 'Celebrated with Ramlila and effigy burning',
        },
        RegionalCalendar.tamil: {
          'dateAdjustment': 0,
          'regionalName': 'Vijayadashami',
          'significance': 'Victory of good over evil (Tamil variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.bengali: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Bengali variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.gujarati: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Gujarati variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.marathi: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Marathi variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.malayalam: {
          'dateAdjustment': 0,
          'regionalName': 'Vijayadashami',
          'significance': 'Victory of good over evil (Malayalam variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.kannada: {
          'dateAdjustment': 0,
          'regionalName': 'Vijayadashami',
          'significance': 'Victory of good over evil (Kannada variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.telugu: {
          'dateAdjustment': 0,
          'regionalName': 'Vijayadashami',
          'significance': 'Victory of good over evil (Telugu variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.odia: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Odia variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.assamese: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Assamese variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.manipuri: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Manipuri variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.kashmiri: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Kashmiri variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.nepali: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Nepali variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.sikkimese: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Sikkimese variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
        RegionalCalendar.goan: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Goan variation)',
          'culturalNotes': 'Celebrated with traditional rituals and prayers',
        },
      },
      'onam': {
        RegionalCalendar.malayalam: {
          'dateAdjustment': 0,
          'regionalName': 'Onam',
          'significance': 'Harvest festival of Kerala',
          'culturalNotes': 'Celebrated with traditional feast and cultural programs',
        },
      },
    };
  }
}
