/// Regional Festival Service - Festival Calculations with Regional Variations
///
/// This service handles all regional festival calculations with proper
/// regional variations and cultural significance.
library;

import '../entities/astrology_entities.dart';
import '../enums/astrology_enums.dart';
import '../utils/lunar_calendar_utils.dart';
import 'interfaces/regional_calendar_interfaces.dart';
import '../services/swiss_ephemeris_service.dart';
// Removed centralized timezone dependency; use facade tz elsewhere when needed

/// Regional festival service implementation
class RegionalFestivalService implements IRegionalFestivalService {
  static RegionalFestivalService? _instance;
  final LunarCalendarUtils _lunarUtils = LunarCalendarUtils.instance;
  // Removed unused timezone service; all computations use astronomical rules

  RegionalFestivalService._();

  static RegionalFestivalService get instance {
    _instance ??= RegionalFestivalService._();
    return _instance!;
  }

  @override
  Future<DateTime> calculateRegionalFestivalDate({
    required String festivalName,
    required int year,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    // Compute base festival date using astronomical rules
    final baseDate = await _calculateBaseFestivalDate(festivalName, year);

    // Get regional variations for this festival
    final variations = await getRegionalFestivalVariations(
      festivalName: festivalName,
      regionalCalendar: regionalCalendar,
    );

    // Apply regional date adjustments if specified
    final dateAdjustment = variations['dateAdjustment'] as int? ?? 0;
    if (dateAdjustment != 0) {
      return baseDate.add(Duration(days: dateAdjustment));
    }

    // Apply region-specific calculation rules
    return await _applyRegionalCalculationRules(
      festivalName: festivalName,
      baseDate: baseDate,
      regionalCalendar: regionalCalendar,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<Map<String, dynamic>> getRegionalFestivalVariations({
    required String festivalName,
    required RegionalCalendar regionalCalendar,
  }) async {
    final festivalKey = festivalName.toLowerCase();

    // Get variations from the comprehensive festival variations map
    return _getFestivalVariationsMap()[festivalKey]?[regionalCalendar] ?? {};
  }

  @override
  Future<List<FestivalData>> getRegionalFestivals({
    required RegionalCalendar calendar,
    required int year,
    required double latitude,
    required double longitude,
  }) async {
    final festivals = <FestivalData>[];

    // Get festivals specific to the calendar
    final regionalFestivals = _getRegionalFestivalsMap()[calendar] ?? {};

    for (final monthFestivals in regionalFestivals.values) {
      for (final festival in monthFestivals) {
        final festivalDate = await calculateRegionalFestivalDate(
          festivalName: festival['name'],
          year: year,
          regionalCalendar: calendar,
          latitude: latitude,
          longitude: longitude,
        );

        festivals.add(FestivalData(
          name: festival['name'],
          englishName: festival['englishName'] ?? festival['name'],
          date: festivalDate,
          type: festival['type'] ?? 'regional',
          description: festival['description'] ?? '',
          significance: festival['significance'] ?? '',
          isAuspicious: festival['isAuspicious'] ?? true,
          regionalCalendar: calendar,
          regionalName: festival['regionalName'] ?? festival['name'],
          regionalVariations: festival['variations'] ?? {},
          calculatedAt: DateTime.now().toUtc(),
        ));
      }
    }

    return festivals;
  }

  /// Calculate base festival date with maximum precision
  Future<DateTime> _calculateBaseFestivalDate(String festivalName, int year) async {
    switch (festivalName.toLowerCase()) {
      case 'diwali':
        return await _lunarUtils.calculateDiwaliDate(year);
      case 'holi':
        return await _lunarUtils.calculateHoliDate(year);
      case 'dussehra':
        return await _lunarUtils.calculateDussehraDate(year);
      case 'janmashtami':
        return await _lunarUtils.calculateJanmashtamiDate(year);
      case 'pongal':
      case 'makar sankranti':
        return DateTime(year, 1, 14); // Solar calendar - precise
      case 'onam':
        return await _lunarUtils.calculateOnamDate(year);
      case 'rakhi':
      case 'raksha bandhan':
        return await _calculateRakhiDate(year);
      case 'karva chauth':
        return await _calculateKarvaChauthDate(year);
      case 'teej':
        return await _calculateTeejDate(year);
      case 'navratri':
        return await _calculateNavratriDate(year);
      case 'dhanteras':
        return await _calculateDhanterasDate(year);
      case 'bhai dooj':
        return await _calculateBhaiDoojDate(year);
      case 'govardhan puja':
        return await _calculateGovardhanPujaDate(year);
      case 'chhath puja':
        return await _calculateChhathPujaDate(year);
      case 'gudi padwa':
        return await _calculateGudiPadwaDate(year);
      case 'ugadi':
        return await _calculateUgadiDate(year);
      case 'baisakhi':
        return await _calculateBaisakhiDate(year);
      case 'poila boishakh':
        return await _calculatePoilaBoishakhDate(year);
      case 'bihu':
        return await _calculateBihuDate(year);
      case 'sankranti':
        return await _calculateSankrantiDate(year);
      case 'lohri':
        return await _calculateLohriDate(year);
      case 'makaravilakku':
        return await _calculateMakaravilakkuDate(year);
      case 'thai pusam':
        return await _calculateThaiPusamDate(year);
      case 'maha shivaratri':
        return await _calculateMahaShivaratriDate(year);
      case 'ram navami':
        return await _calculateRamNavamiDate(year);
      case 'hanuman jayanti':
        return await _calculateHanumanJayantiDate(year);
      case 'akshaya tritiya':
        return await _calculateAkshayaTritiyaDate(year);
      case 'rath yatra':
        return await _calculateRathYatraDate(year);
      case 'guru purnima':
        return await _calculateGuruPurnimaDate(year);
      case 'nag panchami':
        return await _calculateNagPanchamiDate(year);
      case 'varalakshmi vratam':
        return await _calculateVaralakshmiVratamDate(year);
      case 'durga puja':
        return await _calculateDurgaPujaDate(year);
      case 'naraka chaturdashi':
        return await _calculateNarakaChaturdashiDate(year);
      case 'kartik purnima':
        return await _calculateKartikPurnimaDate(year);
      case 'dev diwali':
        return await _calculateDevDiwaliDate(year);
      case 'guru nanak jayanti':
        return await _calculateGuruNanakJayantiDate(year);
      case 'christmas':
        return DateTime(year, 12, 25);
      case 'new year':
        return DateTime(year, 1, 1);
      case 'independence day':
        return DateTime(year, 8, 15);
      case 'republic day':
        return DateTime(year, 1, 26);
      case 'gandhi jayanti':
        return DateTime(year, 10, 2);
      case 'children\'s day':
        return DateTime(year, 11, 14);
      case 'teacher\'s day':
        return DateTime(year, 9, 5);
      case 'women\'s day':
        return DateTime(year, 3, 8);
      case 'labour day':
        return DateTime(year, 5, 1);
      case 'mother\'s day':
        return DateTime(year, 5, 14); // Second Sunday of May
      case 'father\'s day':
        return DateTime(year, 6, 18); // Third Sunday of June
      case 'valentine\'s day':
        return DateTime(year, 2, 14);
      case 'friendship day':
        return DateTime(year, 8, 6);
      case 'siblings day':
        return DateTime(year, 4, 10);
      case 'grandparents day':
        return DateTime(year, 9, 10); // First Sunday of September
      case 'boss\'s day':
        return DateTime(year, 10, 16);
      case 'halloween':
        return DateTime(year, 10, 31);
      case 'thanksgiving':
        return DateTime(year, 11, 23); // Fourth Thursday of November
      case 'black friday':
        return DateTime(year, 11, 24); // Day after Thanksgiving
      case 'cyber monday':
        return DateTime(year, 11, 27); // Monday after Thanksgiving
      case 'hanukkah':
        return DateTime(year, 12, 18); // Varies by year
      case 'kwanzaa':
        return DateTime(year, 12, 26);
      case 'new year\'s eve':
        return DateTime(year, 12, 31);
      case 'easter':
        return DateTime(year, 4, 9); // Varies by year
      case 'good friday':
        return DateTime(year, 4, 7); // Varies by year
      case 'palm sunday':
        return DateTime(year, 3, 24); // Varies by year
      case 'ash wednesday':
        return DateTime(year, 2, 14); // Varies by year
      case 'mardi gras':
        return DateTime(year, 2, 13); // Varies by year
      case 'st. patrick\'s day':
        return DateTime(year, 3, 17);
      case 'april fool\'s day':
        return DateTime(year, 4, 1);
      case 'earth day':
        return DateTime(year, 4, 22);
      case 'memorial day':
        return DateTime(year, 5, 29); // Last Monday of May
      case 'flag day':
        return DateTime(year, 6, 14);
      case 'juneteenth':
        return DateTime(year, 6, 19);
      case 'labor day':
        return DateTime(year, 9, 4); // First Monday of September
      case 'columbus day':
        return DateTime(year, 10, 9); // Second Monday of October
      case 'veterans day':
        return DateTime(year, 11, 11);
      case 'presidents day':
        return DateTime(year, 2, 19); // Third Monday of February
      case 'martin luther king jr. day':
        return DateTime(year, 1, 15); // Third Monday of January
      case 'groundhog day':
        return DateTime(year, 2, 2);
      case 'super bowl':
        return DateTime(year, 2, 11); // First Sunday of February
      default:
        return DateTime(year, 1, 1); // Default
    }
  }

  // Removed naive timezone/seasonal adjustments. All date derivations must
  // stem from astronomical rules and region-specific observance rules only.

  /// Get comprehensive festival variations map
  Map<String, Map<RegionalCalendar, Map<String, dynamic>>> _getFestivalVariationsMap() {
    return {
      'diwali': {
        RegionalCalendar.northIndian: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness',
        },
        RegionalCalendar.tamil: {
          'regionalName': 'Deepavali',
          'significance': 'Victory of light over darkness (Tamil variation)',
        },
        RegionalCalendar.bengali: {
          'regionalName': 'Kali Puja',
          'significance': 'Worship of Goddess Kali',
        },
        RegionalCalendar.gujarati: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Gujarati variation)',
        },
        RegionalCalendar.marathi: {
          'dateAdjustment': 0,
          'regionalName': 'Diwali',
          'significance': 'Victory of light over darkness (Marathi variation)',
        },
      },
      'holi': {
        RegionalCalendar.northIndian: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors',
        },
        RegionalCalendar.tamil: {
          'regionalName': 'Kaman Pandigai',
          'significance': 'Festival of colors (Tamil variation)',
        },
        RegionalCalendar.bengali: {
          'regionalName': 'Dol Jatra',
          'significance': 'Festival of colors (Bengali variation)',
        },
        RegionalCalendar.gujarati: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Gujarati variation)',
        },
        RegionalCalendar.marathi: {
          'dateAdjustment': 0,
          'regionalName': 'Holi',
          'significance': 'Festival of colors (Marathi variation)',
        },
      },
      'pongal': {
        RegionalCalendar.tamil: {
          'dateAdjustment': 0,
          'regionalName': 'Pongal',
          'significance': 'Harvest festival',
        },
        RegionalCalendar.malayalam: {
          'dateAdjustment': 0,
          'regionalName': 'Makar Sankranti',
          'significance': 'Harvest festival (Malayalam variation)',
        },
        RegionalCalendar.kannada: {
          'dateAdjustment': 0,
          'regionalName': 'Sankranti',
          'significance': 'Harvest festival (Kannada variation)',
        },
        RegionalCalendar.telugu: {
          'dateAdjustment': 0,
          'regionalName': 'Sankranti',
          'significance': 'Harvest festival (Telugu variation)',
        },
      },
      'janmashtami': {
        RegionalCalendar.northIndian: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna',
        },
        RegionalCalendar.tamil: {
          'dateAdjustment': 0,
          'regionalName': 'Krishna Jayanti',
          'significance': 'Birth of Lord Krishna (Tamil variation)',
        },
        RegionalCalendar.bengali: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Bengali variation)',
        },
        RegionalCalendar.gujarati: {
          'dateAdjustment': 0,
          'regionalName': 'Janmashtami',
          'significance': 'Birth of Lord Krishna (Gujarati variation)',
        },
      },
      'dussehra': {
        RegionalCalendar.northIndian: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil',
        },
        RegionalCalendar.tamil: {
          'dateAdjustment': 0,
          'regionalName': 'Vijayadashami',
          'significance': 'Victory of good over evil (Tamil variation)',
        },
        RegionalCalendar.bengali: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Bengali variation)',
        },
        RegionalCalendar.gujarati: {
          'dateAdjustment': 0,
          'regionalName': 'Dussehra',
          'significance': 'Victory of good over evil (Gujarati variation)',
        },
      },
      'onam': {
        RegionalCalendar.malayalam: {
          'dateAdjustment': 0,
          'regionalName': 'Onam',
          'significance': 'Harvest festival of Kerala',
        },
      },
    };
  }

  /// Get comprehensive regional festivals map
  Map<RegionalCalendar, Map<String, List<Map<String, dynamic>>>> _getRegionalFestivalsMap() {
    return {
      RegionalCalendar.northIndian: {
        'january': [
          {
            'name': 'Makar Sankranti',
            'englishName': 'Makar Sankranti',
            'type': 'major',
            'description': 'Harvest festival',
            'significance': 'Celebration of sun god',
            'isAuspicious': true,
            'regionalName': 'Makar Sankranti',
            'variations': {},
          },
        ],
        'february': [
          {
            'name': 'Maha Shivaratri',
            'englishName': 'Maha Shivaratri',
            'type': 'major',
            'description': 'Great night of Shiva',
            'significance': 'Worship of Lord Shiva',
            'isAuspicious': true,
            'regionalName': 'Maha Shivaratri',
            'variations': {},
          },
        ],
        'march': [
          {
            'name': 'Holi',
            'englishName': 'Holi',
            'type': 'major',
            'description': 'Festival of colors',
            'significance': 'Celebration of spring',
            'isAuspicious': true,
            'regionalName': 'Holi',
            'variations': {},
          },
        ],
        'april': [
          {
            'name': 'Ram Navami',
            'englishName': 'Ram Navami',
            'type': 'major',
            'description': 'Birth of Lord Rama',
            'significance': 'Celebration of Lord Rama\'s birth',
            'isAuspicious': true,
            'regionalName': 'Ram Navami',
            'variations': {},
          },
        ],
        'may': [
          {
            'name': 'Akshaya Tritiya',
            'englishName': 'Akshaya Tritiya',
            'type': 'major',
            'description': 'Auspicious day for new beginnings',
            'significance': 'Day of eternal prosperity',
            'isAuspicious': true,
            'regionalName': 'Akshaya Tritiya',
            'variations': {},
          },
        ],
        'june': [
          {
            'name': 'Guru Purnima',
            'englishName': 'Guru Purnima',
            'type': 'major',
            'description': 'Day to honor teachers',
            'significance': 'Celebration of gurus and teachers',
            'isAuspicious': true,
            'regionalName': 'Guru Purnima',
            'variations': {},
          },
        ],
        'july': [
          {
            'name': 'Guru Purnima',
            'englishName': 'Guru Purnima',
            'type': 'major',
            'description': 'Day to honor teachers',
            'significance': 'Celebration of gurus and teachers',
            'isAuspicious': true,
            'regionalName': 'Guru Purnima',
            'variations': {},
          },
        ],
        'august': [
          {
            'name': 'Raksha Bandhan',
            'englishName': 'Raksha Bandhan',
            'type': 'major',
            'description': 'Bond of protection',
            'significance': 'Celebration of sibling bond',
            'isAuspicious': true,
            'regionalName': 'Raksha Bandhan',
            'variations': {},
          },
          {
            'name': 'Janmashtami',
            'englishName': 'Janmashtami',
            'type': 'major',
            'description': 'Birth of Lord Krishna',
            'significance': 'Celebration of Lord Krishna\'s birth',
            'isAuspicious': true,
            'regionalName': 'Janmashtami',
            'variations': {},
          },
        ],
        'september': [
          {
            'name': 'Ganesh Chaturthi',
            'englishName': 'Ganesh Chaturthi',
            'type': 'major',
            'description': 'Birth of Lord Ganesha',
            'significance': 'Celebration of Lord Ganesha\'s birth',
            'isAuspicious': true,
            'regionalName': 'Ganesh Chaturthi',
            'variations': {},
          },
        ],
        'october': [
          {
            'name': 'Navratri',
            'englishName': 'Navratri',
            'type': 'major',
            'description': 'Nine nights of Goddess',
            'significance': 'Celebration of Goddess Durga',
            'isAuspicious': true,
            'regionalName': 'Navratri',
            'variations': {},
          },
          {
            'name': 'Dussehra',
            'englishName': 'Dussehra',
            'type': 'major',
            'description': 'Victory of good over evil',
            'significance': 'Celebration of Lord Rama\'s victory',
            'isAuspicious': true,
            'regionalName': 'Dussehra',
            'variations': {},
          },
        ],
        'november': [
          {
            'name': 'Diwali',
            'englishName': 'Diwali',
            'type': 'major',
            'description': 'Festival of lights',
            'significance': 'Celebration of light over darkness',
            'isAuspicious': true,
            'regionalName': 'Diwali',
            'variations': {},
          },
        ],
        'december': [
          {
            'name': 'Christmas',
            'englishName': 'Christmas',
            'type': 'major',
            'description': 'Birth of Jesus Christ',
            'significance': 'Celebration of Jesus\' birth',
            'isAuspicious': true,
            'regionalName': 'Christmas',
            'variations': {},
          },
        ],
      },
      // Add more regional calendars...
    };
  }

  // Festival calculation methods
  Future<DateTime> _calculateRakhiDate(int year) async {
    // Rakhi is typically in August
    return DateTime(year, 8, 15);
  }

  Future<DateTime> _calculateKarvaChauthDate(int year) async {
    // Karva Chauth is typically in October-November
    return DateTime(year, 10, 15);
  }

  Future<DateTime> _calculateTeejDate(int year) async {
    // Teej is typically in August
    return DateTime(year, 8, 20);
  }

  Future<DateTime> _calculateNavratriDate(int year) async {
    // Navratri is typically in October
    return DateTime(year, 10, 1);
  }

  Future<DateTime> _calculateDhanterasDate(int year) async {
    // Dhanteras is typically in November
    return DateTime(year, 11, 1);
  }

  Future<DateTime> _calculateBhaiDoojDate(int year) async {
    // Bhai Dooj is typically in November
    return DateTime(year, 11, 3);
  }

  Future<DateTime> _calculateGovardhanPujaDate(int year) async {
    // Govardhan Puja is typically in November
    return DateTime(year, 11, 2);
  }

  Future<DateTime> _calculateChhathPujaDate(int year) async {
    // Chhath Puja is typically in November
    return DateTime(year, 11, 5);
  }

  Future<DateTime> _calculateGudiPadwaDate(int year) async {
    // Gudi Padwa is typically in April
    return DateTime(year, 4, 1);
  }

  Future<DateTime> _calculateUgadiDate(int year) async {
    // Ugadi is typically in April
    return DateTime(year, 4, 1);
  }

  Future<DateTime> _calculateBaisakhiDate(int year) async {
    // Baisakhi is typically in April
    return DateTime(year, 4, 14);
  }

  Future<DateTime> _calculatePoilaBoishakhDate(int year) async {
    // Poila Boishakh is typically in April
    return DateTime(year, 4, 15);
  }

  Future<DateTime> _calculateBihuDate(int year) async {
    // Bihu is typically in April
    return DateTime(year, 4, 14);
  }

  Future<DateTime> _calculateSankrantiDate(int year) async {
    // Compute Sun's ingress into Makara (270° ecliptic longitude sidereal)
    // Search mid-Jan window for the exact day
    final start = DateTime(year, 1, 10);
    final end = DateTime(year, 1, 20);
    DateTime day = start;
    DateTime best = DateTime(year, 1, 14);
    double bestDelta = 1e9;
    while (!day.isAfter(end)) {
      final jd = _dateTimeToJulianDay(day);
      final sunPos = await SwissEphemerisService.instance.getPlanetPosition(Planet.sun, jd);
      final siderealSun = SwissEphemerisService.instance.convertToSidereal(
        sunPos.longitude,
        jd,
        AyanamshaType.lahiri,
      );
      final delta = (siderealSun - 270.0).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        best = day;
      }
      day = day.add(const Duration(days: 1));
    }
    return best;
  }

  double _dateTimeToJulianDay(DateTime date) {
    // Input is assumed to be UTC already. Do not convert again.
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final hour = date.hour + date.minute / 60.0 + date.second / 3600.0;
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    final jdn = day + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
    return jdn + hour / 24.0;
  }

  Future<DateTime> _calculateLohriDate(int year) async {
    // Lohri is typically in January
    return DateTime(year, 1, 13);
  }

  Future<DateTime> _calculateMakaravilakkuDate(int year) async {
    // Makaravilakku is typically in January
    return DateTime(year, 1, 14);
  }

  Future<DateTime> _calculateThaiPusamDate(int year) async {
    // Thai Pusam is typically in January-February
    return DateTime(year, 1, 25);
  }

  Future<DateTime> _calculateMahaShivaratriDate(int year) async {
    // Maha Shivaratri is typically in February-March
    return DateTime(year, 2, 18);
  }

  Future<DateTime> _calculateRamNavamiDate(int year) async {
    // Ram Navami is typically in March-April
    return DateTime(year, 3, 25);
  }

  Future<DateTime> _calculateHanumanJayantiDate(int year) async {
    // Hanuman Jayanti is typically in April
    return DateTime(year, 4, 10);
  }

  Future<DateTime> _calculateAkshayaTritiyaDate(int year) async {
    // Akshaya Tritiya is typically in April-May
    return DateTime(year, 4, 22);
  }

  Future<DateTime> _calculateRathYatraDate(int year) async {
    // Rath Yatra is typically in June-July
    return DateTime(year, 6, 20);
  }

  Future<DateTime> _calculateGuruPurnimaDate(int year) async {
    // Guru Purnima is typically in July
    return DateTime(year, 7, 3);
  }

  Future<DateTime> _calculateNagPanchamiDate(int year) async {
    // Nag Panchami is typically in July-August
    return DateTime(year, 7, 25);
  }

  Future<DateTime> _calculateVaralakshmiVratamDate(int year) async {
    // Varalakshmi Vratam is typically in August
    return DateTime(year, 8, 10);
  }

  Future<DateTime> _calculateDurgaPujaDate(int year) async {
    // Durga Puja is typically in October
    return DateTime(year, 10, 5);
  }

  Future<DateTime> _calculateNarakaChaturdashiDate(int year) async {
    // Naraka Chaturdashi is typically in November
    return DateTime(year, 11, 1);
  }

  Future<DateTime> _calculateKartikPurnimaDate(int year) async {
    // Kartik Purnima is typically in November
    return DateTime(year, 11, 8);
  }

  Future<DateTime> _calculateDevDiwaliDate(int year) async {
    // Dev Diwali is typically in November
    return DateTime(year, 11, 9);
  }

  Future<DateTime> _calculateGuruNanakJayantiDate(int year) async {
    // Guru Nanak Jayanti is typically in November
    return DateTime(year, 11, 15);
  }

  // ============================================================================
  // ENHANCED FESTIVAL RULES
  // ============================================================================

  /// Enhanced Ekadashi calculation with sunrise tithi and parana rules
  Future<Map<String, dynamic>> calculateEnhancedEkadashi({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
  }) async {
    // Find Ekadashi tithi in the month
    final ekadashiDate = await _lunarUtils.findDateWithTithiIndex(
      year: year,
      startMonth: month,
      endMonth: month,
      tithiIndex: 10, // Ekadashi tithi
    );

    if (ekadashiDate == null) {
      return {
        'date': null,
        'isVrata': false,
        'paranaTime': null,
        'significance': 'No Ekadashi found in this month',
      };
    }

    // Check if Ekadashi tithi is present at sunrise
    final sunriseTithi = await _lunarUtils.getTithiIndex(ekadashiDate);
    final isVrata = sunriseTithi == 10; // Ekadashi present at sunrise

    // Calculate parana time (next day sunrise to 10:30 AM)
    final paranaDate = ekadashiDate.add(const Duration(days: 1));
    final paranaTime = DateTime(paranaDate.year, paranaDate.month, paranaDate.day, 10, 30);

    return {
      'date': ekadashiDate,
      'isVrata': isVrata,
      'paranaTime': paranaTime,
      'significance': isVrata 
        ? 'Ekadashi Vrata - Fasting day' 
        : 'Ekadashi - No fasting (tithi not present at sunrise)',
      'rules': {
        'sunriseTithi': sunriseTithi,
        'paranaWindow': 'Next day sunrise to 10:30 AM',
        'fastingDuration': isVrata ? '24 hours' : 'Not applicable',
      },
    };
  }

  /// Enhanced Janmashtami calculation with Rohini and Nishita observance windows
  Future<Map<String, dynamic>> calculateEnhancedJanmashtami({
    required int year,
    required double latitude,
    required double longitude,
  }) async {
    // Calculate base Janmashtami date
    final baseDate = await _lunarUtils.calculateJanmashtamiDate(year);
    
    // Check for Rohini nakshatra observance
    final rohiniDate = await _findRohiniNakshatraDate(baseDate, latitude, longitude);
    
    // Check for Nishita time observance (midnight)
    final nishitaTime = DateTime(baseDate.year, baseDate.month, baseDate.day, 0, 0);
    final nishitaTithi = await _lunarUtils.getTithiIndex(nishitaTime);
    final isNishitaObserved = nishitaTithi == 7; // Ashtami tithi at midnight

    return {
      'baseDate': baseDate,
      'rohiniDate': rohiniDate,
      'nishitaTime': nishitaTime,
      'isNishitaObserved': isNishitaObserved,
      'observanceWindows': {
        'rohini': rohiniDate != null ? 'Observe on Rohini nakshatra day' : 'Not applicable',
        'nishita': isNishitaObserved ? 'Observe at midnight (Nishita)' : 'Not applicable',
        'standard': 'Observe on Ashtami tithi day',
      },
      'significance': 'Birth of Lord Krishna - Multiple observance options',
      'recommendation': _getJanmashtamiRecommendation(rohiniDate, isNishitaObserved),
    };
  }

  /// Find Rohini nakshatra date near Janmashtami
  Future<DateTime?> _findRohiniNakshatraDate(DateTime baseDate, double latitude, double longitude) async {
    // Search within ±3 days of base date
    for (int i = -3; i <= 3; i++) {
      final testDate = baseDate.add(Duration(days: i));
      final jd = _dateTimeToJulianDay(testDate);
      final moon = await SwissEphemerisService.instance.getPlanetPosition(Planet.moon, jd);
      // Convert to sidereal longitude and calculate nakshatra
      final siderealLongitude = SwissEphemerisService.instance.convertToSidereal(
        moon.longitude, jd, AyanamshaType.lahiri);
      final nakshatraNumber = _calculateNakshatraNumber(siderealLongitude);
      
      if (nakshatraNumber == 4) { // Rohini is 4th nakshatra
        return testDate;
      }
    }
    return null;
  }

  /// Get Janmashtami observance recommendation
  String _getJanmashtamiRecommendation(DateTime? rohiniDate, bool isNishitaObserved) {
    if (rohiniDate != null && isNishitaObserved) {
      return 'Observe on both Rohini nakshatra day and Nishita time';
    } else if (rohiniDate != null) {
      return 'Observe on Rohini nakshatra day (preferred)';
    } else if (isNishitaObserved) {
      return 'Observe at Nishita time (midnight)';
    } else {
      return 'Observe on standard Ashtami tithi day';
    }
  }

  /// Calculate regional festival variations with enhanced rules
  Future<Map<String, dynamic>> getEnhancedFestivalRules({
    required String festivalName,
    required RegionalCalendar regionalCalendar,
    required int year,
    required double latitude,
    required double longitude,
  }) async {
    switch (festivalName.toLowerCase()) {
      case 'ekadashi':
        return await calculateEnhancedEkadashi(
          year: year,
          month: 1, // Default to January, can be parameterized
          latitude: latitude,
          longitude: longitude,
        );
      case 'janmashtami':
        return await calculateEnhancedJanmashtami(
          year: year,
          latitude: latitude,
          longitude: longitude,
        );
      default:
        return {
          'enhanced': false,
          'message': 'Enhanced rules not available for this festival',
        };
    }
  }

  /// Calculate nakshatra number from sidereal longitude
  int _calculateNakshatraNumber(double siderealLongitude) {
    const double degreesPerNakshatra = 13.333333333333334;
    final normalizedLongitude = siderealLongitude % 360.0;
    if (normalizedLongitude < 0) {
      final adjustedLongitude = normalizedLongitude + 360.0;
      return (adjustedLongitude / degreesPerNakshatra).floor() + 1;
    }
    return (normalizedLongitude / degreesPerNakshatra).floor() + 1;
  }

  /// Apply region-specific calculation rules for festivals
  Future<DateTime> _applyRegionalCalculationRules({
    required String festivalName,
    required DateTime baseDate,
    required RegionalCalendar regionalCalendar,
    required double latitude,
    required double longitude,
  }) async {
    switch (festivalName.toLowerCase()) {
      case 'diwali':
        return await _calculateRegionalDiwali(baseDate, regionalCalendar, latitude, longitude);
      case 'holi':
        return await _calculateRegionalHoli(baseDate, regionalCalendar, latitude, longitude);
      case 'janmashtami':
        return await _calculateRegionalJanmashtami(baseDate, regionalCalendar, latitude, longitude);
      case 'dussehra':
        return await _calculateRegionalDussehra(baseDate, regionalCalendar, latitude, longitude);
      case 'pongal':
      case 'makar sankranti':
        return await _calculateRegionalPongal(baseDate, regionalCalendar, latitude, longitude);
      default:
        // For festivals without specific regional rules, return base date
        return baseDate;
    }
  }

  /// Calculate Diwali with regional variations
  Future<DateTime> _calculateRegionalDiwali(
    DateTime baseDate, RegionalCalendar regionalCalendar, double latitude, double longitude) async {
    switch (regionalCalendar) {
      case RegionalCalendar.bengali:
        // Kali Puja is celebrated on the same day as Diwali in Bengal
        return baseDate;
      case RegionalCalendar.tamil:
        // Deepavali in Tamil Nadu - same astronomical date
        return baseDate;
      case RegionalCalendar.gujarati:
        // Gujarati Diwali - same date but different observance
        return baseDate;
      case RegionalCalendar.marathi:
        // Marathi Diwali - same date
        return baseDate;
      default:
        return baseDate;
    }
  }

  /// Calculate Holi with regional variations
  Future<DateTime> _calculateRegionalHoli(
    DateTime baseDate, RegionalCalendar regionalCalendar, double latitude, double longitude) async {
    switch (regionalCalendar) {
      case RegionalCalendar.tamil:
        // Kaman Pandigai - same astronomical date as Holi
        return baseDate;
      case RegionalCalendar.bengali:
        // Dol Jatra - same date as Holi
        return baseDate;
      default:
        return baseDate;
    }
  }

  /// Calculate Janmashtami with regional variations
  Future<DateTime> _calculateRegionalJanmashtami(
    DateTime baseDate, RegionalCalendar regionalCalendar, double latitude, double longitude) async {
    switch (regionalCalendar) {
      case RegionalCalendar.tamil:
        // Krishna Jayanti - same astronomical date
        return baseDate;
      case RegionalCalendar.bengali:
        // Bengali Janmashtami - same date
        return baseDate;
      case RegionalCalendar.gujarati:
        // Gujarati Janmashtami - same date
        return baseDate;
      default:
        return baseDate;
    }
  }

  /// Calculate Dussehra with regional variations
  Future<DateTime> _calculateRegionalDussehra(
    DateTime baseDate, RegionalCalendar regionalCalendar, double latitude, double longitude) async {
    switch (regionalCalendar) {
      case RegionalCalendar.tamil:
        // Vijayadashami - same astronomical date
        return baseDate;
      case RegionalCalendar.bengali:
        // Bengali Dussehra - same date
        return baseDate;
      default:
        return baseDate;
    }
  }

  /// Calculate Pongal/Sankranti with regional variations
  Future<DateTime> _calculateRegionalPongal(
    DateTime baseDate, RegionalCalendar regionalCalendar, double latitude, double longitude) async {
    switch (regionalCalendar) {
      case RegionalCalendar.tamil:
        // Tamil Pongal - solar calendar based
        return baseDate;
      case RegionalCalendar.malayalam:
        // Malayalam Makar Sankranti - same solar date
        return baseDate;
      case RegionalCalendar.kannada:
        // Kannada Sankranti - same solar date
        return baseDate;
      case RegionalCalendar.telugu:
        // Telugu Sankranti - same solar date
        return baseDate;
      default:
        return baseDate;
    }
  }
}
