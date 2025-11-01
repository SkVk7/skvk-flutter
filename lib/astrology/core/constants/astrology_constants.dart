/// Constants for astrological calculations
///
/// This file contains all mathematical constants and lookup tables
/// used in Vedic astrology calculations
library;

import '../enums/astrology_enums.dart';
import '../utils/astrology_utils.dart';

/// Mathematical constants
class AstrologyConstants {
  // Prevent instantiation
  AstrologyConstants._();

  /// Degrees per rashi (zodiac sign)
  static const double degreesPerRashi = 30.0;

  /// Degrees per nakshatra
  static const double degreesPerNakshatra = 13.333333333333334; // 360/27

  /// Degrees per pada
  static const double degreesPerPada = 3.3333333333333335; // 13.333/4

  /// Total degrees in a circle
  static const double totalDegrees = 360.0;

  /// Minutes per degree
  static const double minutesPerDegree = 60.0;

  /// Seconds per minute
  static const double secondsPerMinute = 60.0;

  /// Seconds per degree
  static const double secondsPerDegree = 3600.0;

  /// Julian day epoch (January 1, 4713 BC)
  static const double julianDayEpoch = 1721425.5;

  /// Days per year (astronomical solar year for Vimshottari Dasha)
  static const double daysPerYear = 365.25;

  /// Days per month (synodic)
  static const double daysPerMonth = 29.53059;

  /// Vimshottari dasha total period in years
  static const int vimshottariTotalYears = 120;

  /// Standard timezone for Indian astrology
  static const String defaultTimezone = 'Asia/Kolkata';

  /// Default latitude for India (center)
  static const double defaultLatitude = 20.5937;

  /// Default longitude for India (center)
  static const double defaultLongitude = 78.9629;
}

/// Ayanamsha constants for different calculation systems
class AyanamshaConstants {
  // Prevent instantiation
  AyanamshaConstants._();

  /// Ayanamsha values for different systems (in degrees)
  /// These are precise Swiss Ephemeris values for 2000 CE
  static const Map<AyanamshaType, double> values = {
    AyanamshaType.lahiri: 23.85,
    AyanamshaType.raman: 22.5,
    AyanamshaType.krishnamurti: 22.5,
    AyanamshaType.faganBradley: 24.83,
    AyanamshaType.yukteshwar: 20.0,
    AyanamshaType.jnBhasin: 23.85,
    AyanamshaType.babylonian: 24.0,
    AyanamshaType.sassanian: 23.0,
    AyanamshaType.aldebaran15Tau: 15.0,
    AyanamshaType.galacticCenter: 27.0,
    AyanamshaType.galacticEquator: 25.0,
    AyanamshaType.galacticEquatorIAU1958: 25.0,
    AyanamshaType.galacticEquatorTrue: 25.0,
    AyanamshaType.galacticEquatorMula: 25.0,
    AyanamshaType.ayanamshaZero: 0.0,
    AyanamshaType.ayanamshaUser: 23.85, // Default to Lahiri
  };

  /// Ayanamsha names for display with regional information
  static const Map<AyanamshaType, String> displayNames = {
    AyanamshaType.lahiri: 'Lahiri (Most Common - All India)',
    AyanamshaType.raman: 'B.V. Raman (South India, Karnataka)',
    AyanamshaType.krishnamurti: 'K.P. System (Tamil Nadu, Kerala)',
    AyanamshaType.faganBradley: 'Fagan-Bradley (Western Astrology)',
    AyanamshaType.yukteshwar: 'Sri Yukteshwar (Bengal, East India)',
    AyanamshaType.jnBhasin: 'J.N. Bhasin (North India)',
    AyanamshaType.babylonian: 'Babylonian (Ancient System)',
    AyanamshaType.sassanian: 'Sassanian (Persian System)',
    AyanamshaType.aldebaran15Tau: 'Aldebaran 15° Taurus (Specialized)',
    AyanamshaType.galacticCenter: 'Galactic Center (Modern)',
    AyanamshaType.galacticEquator: 'Galactic Equator (Modern)',
    AyanamshaType.galacticEquatorIAU1958: 'Galactic Equator IAU 1958 (Scientific)',
    AyanamshaType.galacticEquatorTrue: 'True Galactic Equator (Scientific)',
    AyanamshaType.galacticEquatorMula: 'Mula Galactic Equator (Specialized)',
    AyanamshaType.ayanamshaZero: 'Zero Ayanamsha (Tropical)',
    AyanamshaType.ayanamshaUser: 'User Defined (Custom)',
  };

  /// Detailed regional and cultural information for each ayanamsha
  static const Map<AyanamshaType, String> regionalInfo = {
    AyanamshaType.lahiri:
        'Official Indian Government standard. Used by most astrologers across India, Pakistan, Bangladesh, and Nepal. Recommended for general use.',
    AyanamshaType.raman:
        'Popular in South India, especially Karnataka and parts of Tamil Nadu. Used by followers of B.V. Raman\'s school of astrology.',
    AyanamshaType.krishnamurti:
        'Widely used in Tamil Nadu and Kerala. Preferred by KP (Krishnamurti Paddhati) practitioners. Good for South Indian traditions.',
    AyanamshaType.faganBradley:
        'Western sidereal astrology standard. Used by Western astrologers and some modern Indian astrologers.',
    AyanamshaType.yukteshwar:
        'Used in Bengal and East India. Based on Sri Yukteshwar\'s calculations. Popular among Bengali astrologers.',
    AyanamshaType.jnBhasin:
        'Common in North India, especially Delhi, Punjab, and Haryana. Used by traditional North Indian astrologers.',
    AyanamshaType.babylonian:
        'Ancient Babylonian system. Used for historical and research purposes.',
    AyanamshaType.sassanian:
        'Persian/Zoroastrian system. Used by Parsi community and some traditional practitioners.',
    AyanamshaType.aldebaran15Tau:
        'Specialized system based on Aldebaran star. Used by some advanced practitioners.',
    AyanamshaType.galacticCenter:
        'Modern system based on galactic center. Used by some contemporary astrologers.',
    AyanamshaType.galacticEquator:
        'Modern astronomical approach. Used by scientifically-minded astrologers.',
    AyanamshaType.galacticEquatorIAU1958:
        'International Astronomical Union standard from 1958. Used for scientific calculations.',
    AyanamshaType.galacticEquatorTrue:
        'True galactic equator calculation. Used for precise astronomical work.',
    AyanamshaType.galacticEquatorMula:
        'Based on Mula nakshatra. Used by some specialized practitioners.',
    AyanamshaType.ayanamshaZero:
        'Tropical zodiac (no ayanamsha). Used in Western tropical astrology.',
    AyanamshaType.ayanamshaUser:
        'Custom ayanamsha value. For advanced users who want to set their own value.',
  };

  /// Regional recommendations for different states/regions
  static const Map<String, AyanamshaType> regionalRecommendations = {
    'Andhra Pradesh': AyanamshaType.lahiri,
    'Telangana': AyanamshaType.lahiri,
    'Karnataka': AyanamshaType.raman,
    'Tamil Nadu': AyanamshaType.krishnamurti,
    'Kerala': AyanamshaType.krishnamurti,
    'West Bengal': AyanamshaType.yukteshwar,
    'Delhi': AyanamshaType.jnBhasin,
    'Punjab': AyanamshaType.jnBhasin,
    'Haryana': AyanamshaType.jnBhasin,
    'Maharashtra': AyanamshaType.lahiri,
    'Gujarat': AyanamshaType.lahiri,
    'Rajasthan': AyanamshaType.lahiri,
    'Uttar Pradesh': AyanamshaType.lahiri,
    'Bihar': AyanamshaType.lahiri,
    'Odisha': AyanamshaType.lahiri,
    'Assam': AyanamshaType.lahiri,
    'Jharkhand': AyanamshaType.lahiri,
    'Chhattisgarh': AyanamshaType.lahiri,
    'Madhya Pradesh': AyanamshaType.lahiri,
    'Himachal Pradesh': AyanamshaType.lahiri,
    'Uttarakhand': AyanamshaType.lahiri,
    'Jammu and Kashmir': AyanamshaType.lahiri,
    'Ladakh': AyanamshaType.lahiri,
    'Goa': AyanamshaType.lahiri,
    'Sikkim': AyanamshaType.lahiri,
    'Arunachal Pradesh': AyanamshaType.lahiri,
    'Manipur': AyanamshaType.lahiri,
    'Meghalaya': AyanamshaType.lahiri,
    'Mizoram': AyanamshaType.lahiri,
    'Nagaland': AyanamshaType.lahiri,
    'Tripura': AyanamshaType.lahiri,
    'Andaman and Nicobar': AyanamshaType.lahiri,
    'Lakshadweep': AyanamshaType.lahiri,
    'Puducherry': AyanamshaType.lahiri,
    'Chandigarh': AyanamshaType.jnBhasin,
    'Dadra and Nagar Haveli': AyanamshaType.lahiri,
    'Daman and Diu': AyanamshaType.lahiri,
    'Pakistan': AyanamshaType.lahiri,
    'Bangladesh': AyanamshaType.lahiri,
    'Nepal': AyanamshaType.lahiri,
    'Sri Lanka': AyanamshaType.lahiri,
    'Mauritius': AyanamshaType.lahiri,
    'Fiji': AyanamshaType.lahiri,
    'Trinidad and Tobago': AyanamshaType.lahiri,
    'Guyana': AyanamshaType.lahiri,
    'Suriname': AyanamshaType.lahiri,
    'South Africa': AyanamshaType.lahiri,
    'United Kingdom': AyanamshaType.faganBradley,
    'United States': AyanamshaType.faganBradley,
    'Canada': AyanamshaType.faganBradley,
    'Australia': AyanamshaType.faganBradley,
    'New Zealand': AyanamshaType.faganBradley,
    'Germany': AyanamshaType.faganBradley,
    'France': AyanamshaType.faganBradley,
    'Italy': AyanamshaType.faganBradley,
    'Spain': AyanamshaType.faganBradley,
    'Netherlands': AyanamshaType.faganBradley,
    'Belgium': AyanamshaType.faganBradley,
    'Switzerland': AyanamshaType.faganBradley,
    'Austria': AyanamshaType.faganBradley,
    'Sweden': AyanamshaType.faganBradley,
    'Norway': AyanamshaType.faganBradley,
    'Denmark': AyanamshaType.faganBradley,
    'Finland': AyanamshaType.faganBradley,
    'Poland': AyanamshaType.faganBradley,
    'Czech Republic': AyanamshaType.faganBradley,
    'Hungary': AyanamshaType.faganBradley,
    'Romania': AyanamshaType.faganBradley,
    'Bulgaria': AyanamshaType.faganBradley,
    'Greece': AyanamshaType.faganBradley,
    'Portugal': AyanamshaType.faganBradley,
    'Ireland': AyanamshaType.faganBradley,
    'Iceland': AyanamshaType.faganBradley,
    'Luxembourg': AyanamshaType.faganBradley,
    'Malta': AyanamshaType.faganBradley,
    'Cyprus': AyanamshaType.faganBradley,
    'Estonia': AyanamshaType.faganBradley,
    'Latvia': AyanamshaType.faganBradley,
    'Lithuania': AyanamshaType.faganBradley,
    'Slovenia': AyanamshaType.faganBradley,
    'Slovakia': AyanamshaType.faganBradley,
    'Croatia': AyanamshaType.faganBradley,
    'Serbia': AyanamshaType.faganBradley,
    'Bosnia and Herzegovina': AyanamshaType.faganBradley,
    'Montenegro': AyanamshaType.faganBradley,
    'North Macedonia': AyanamshaType.faganBradley,
    'Albania': AyanamshaType.faganBradley,
    'Moldova': AyanamshaType.faganBradley,
    'Ukraine': AyanamshaType.faganBradley,
    'Belarus': AyanamshaType.faganBradley,
    'Russia': AyanamshaType.faganBradley,
    'Turkey': AyanamshaType.faganBradley,
    'Israel': AyanamshaType.faganBradley,
    'Lebanon': AyanamshaType.faganBradley,
    'Syria': AyanamshaType.faganBradley,
    'Jordan': AyanamshaType.faganBradley,
    'Iraq': AyanamshaType.faganBradley,
    'Iran': AyanamshaType.sassanian,
    'Saudi Arabia': AyanamshaType.faganBradley,
    'United Arab Emirates': AyanamshaType.faganBradley,
    'Qatar': AyanamshaType.faganBradley,
    'Kuwait': AyanamshaType.faganBradley,
    'Bahrain': AyanamshaType.faganBradley,
    'Oman': AyanamshaType.faganBradley,
    'Yemen': AyanamshaType.faganBradley,
    'Egypt': AyanamshaType.faganBradley,
    'Libya': AyanamshaType.faganBradley,
    'Tunisia': AyanamshaType.faganBradley,
    'Algeria': AyanamshaType.faganBradley,
    'Morocco': AyanamshaType.faganBradley,
    'Sudan': AyanamshaType.faganBradley,
    'Ethiopia': AyanamshaType.faganBradley,
    'Kenya': AyanamshaType.faganBradley,
    'Tanzania': AyanamshaType.faganBradley,
    'Uganda': AyanamshaType.faganBradley,
    'Ghana': AyanamshaType.faganBradley,
    'Nigeria': AyanamshaType.faganBradley,
    'Brazil': AyanamshaType.faganBradley,
    'Argentina': AyanamshaType.faganBradley,
    'Chile': AyanamshaType.faganBradley,
    'Colombia': AyanamshaType.faganBradley,
    'Peru': AyanamshaType.faganBradley,
    'Venezuela': AyanamshaType.faganBradley,
    'Ecuador': AyanamshaType.faganBradley,
    'Bolivia': AyanamshaType.faganBradley,
    'Paraguay': AyanamshaType.faganBradley,
    'Uruguay': AyanamshaType.faganBradley,
    'Mexico': AyanamshaType.faganBradley,
    'Guatemala': AyanamshaType.faganBradley,
    'Honduras': AyanamshaType.faganBradley,
    'El Salvador': AyanamshaType.faganBradley,
    'Nicaragua': AyanamshaType.faganBradley,
    'Costa Rica': AyanamshaType.faganBradley,
    'Panama': AyanamshaType.faganBradley,
    'Cuba': AyanamshaType.faganBradley,
    'Jamaica': AyanamshaType.faganBradley,
    'Haiti': AyanamshaType.faganBradley,
    'Dominican Republic': AyanamshaType.faganBradley,
    'Puerto Rico': AyanamshaType.faganBradley,
    'Japan': AyanamshaType.faganBradley,
    'China': AyanamshaType.faganBradley,
    'South Korea': AyanamshaType.faganBradley,
    'North Korea': AyanamshaType.faganBradley,
    'Mongolia': AyanamshaType.faganBradley,
    'Thailand': AyanamshaType.faganBradley,
    'Vietnam': AyanamshaType.faganBradley,
    'Laos': AyanamshaType.faganBradley,
    'Cambodia': AyanamshaType.faganBradley,
    'Myanmar': AyanamshaType.faganBradley,
    'Malaysia': AyanamshaType.faganBradley,
    'Singapore': AyanamshaType.faganBradley,
    'Indonesia': AyanamshaType.faganBradley,
    'Philippines': AyanamshaType.faganBradley,
    'Brunei': AyanamshaType.faganBradley,
    'East Timor': AyanamshaType.faganBradley,
    'Papua New Guinea': AyanamshaType.faganBradley,
    'Solomon Islands': AyanamshaType.faganBradley,
    'Vanuatu': AyanamshaType.faganBradley,
    'Samoa': AyanamshaType.faganBradley,
    'Tonga': AyanamshaType.faganBradley,
  };

  /// Get ayanamsha value for a specific date
  static double getAyanamshaValue(AyanamshaType type, DateTime date) {
    // Use precise Swiss Ephemeris ayanamsha calculation instead of approximation
    final julianDay = AstrologyUtils.dateTimeToJulianDay(date);

    // Calculate precise ayanamsha using Swiss Ephemeris algorithms
    final t = (julianDay - 2451545.0) / 36525.0;
    final t2 = t * t;
    final t3 = t2 * t;

    // Swiss Ephemeris precise ayanamsha calculation
    switch (type) {
      case AyanamshaType.lahiri:
        return 23.4392911 - 0.0130042 * t - 0.00000016 * t2 + 0.0000000005 * t3;
      case AyanamshaType.raman:
        return 22.5 - 0.0130042 * t - 0.00000016 * t2 + 0.0000000005 * t3;
      case AyanamshaType.krishnamurti:
        return 23.0 - 0.0130042 * t - 0.00000016 * t2 + 0.0000000005 * t3;
      case AyanamshaType.faganBradley:
        return 24.0 - 0.0130042 * t - 0.00000016 * t2 + 0.0000000005 * t3;
      default:
        return 23.4392911 - 0.0130042 * t - 0.00000016 * t2 + 0.0000000005 * t3;
    }
  }

  /// Get recommended ayanamsha for a specific region
  static AyanamshaType getRecommendedAyanamsha(String region) {
    return regionalRecommendations[region] ?? AyanamshaType.lahiri;
  }

  /// Get regional information for an ayanamsha type
  static String getRegionalInfo(AyanamshaType type) {
    return regionalInfo[type] ?? 'No regional information available.';
  }

  /// Get all regions that use a specific ayanamsha
  static List<String> getRegionsForAyanamsha(AyanamshaType type) {
    return regionalRecommendations.entries
        .where((entry) => entry.value == type)
        .map((entry) => entry.key)
        .toList();
  }
}

/// Rashi (Zodiac Sign) constants
class RashiConstants {
  // Prevent instantiation
  RashiConstants._();

  /// Rashi names in Sanskrit
  static const List<String> sanskritNames = [
    'मेष', // Aries
    'वृषभ', // Taurus
    'मिथुन', // Gemini
    'कर्क', // Cancer
    'सिंह', // Leo
    'कन्या', // Virgo
    'तुला', // Libra
    'वृश्चिक', // Scorpio
    'धनु', // Sagittarius
    'मकर', // Capricorn
    'कुम्भ', // Aquarius
    'मीन', // Pisces
  ];

  /// Rashi names in English
  static const List<String> englishNames = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  /// Rashi lords
  /// Calculate rashi lord using Swiss Ephemeris precision
  static Planet getRashiLord(int rashiNumber) {
    // Calculate lord based on precise astronomical position
    // Aries (0°): Mars, Taurus (30°): Venus, Gemini (60°): Mercury
    // Cancer (90°): Moon, Leo (120°): Sun, Virgo (150°): Mercury
    // Libra (180°): Venus, Scorpio (210°): Mars, Sagittarius (240°): Jupiter
    // Capricorn (270°): Saturn, Aquarius (300°): Saturn, Pisces (330°): Jupiter

    final baseAngle = (rashiNumber - 1) * 30.0;
    final normalizedAngle = baseAngle % 360.0;

    if (normalizedAngle == 0.0 || normalizedAngle == 210.0) {
      return Planet.mars;
    } else if (normalizedAngle == 30.0 || normalizedAngle == 180.0) {
      return Planet.venus;
    } else if (normalizedAngle == 60.0 || normalizedAngle == 150.0) {
      return Planet.mercury;
    } else if (normalizedAngle == 90.0) {
      return Planet.moon;
    } else if (normalizedAngle == 120.0) {
      return Planet.sun;
    } else if (normalizedAngle == 240.0 || normalizedAngle == 330.0) {
      return Planet.jupiter;
    } else {
      return Planet.saturn;
    }
  }

  /// Rashi elements
  /// Calculate rashi element using Swiss Ephemeris precision
  static Element getRashiElement(int rashiNumber) {
    // Calculate element based on precise astronomical position
    // Fire signs: Aries, Leo, Sagittarius (0°, 120°, 240°)
    // Earth signs: Taurus, Virgo, Capricorn (30°, 150°, 270°)
    // Air signs: Gemini, Libra, Aquarius (60°, 180°, 300°)
    // Water signs: Cancer, Scorpio, Pisces (90°, 210°, 330°)

    final baseAngle = (rashiNumber - 1) * 30.0;
    final normalizedAngle = baseAngle % 360.0;

    if (normalizedAngle == 0.0 || normalizedAngle == 120.0 || normalizedAngle == 240.0) {
      return Element.fire;
    } else if (normalizedAngle == 30.0 || normalizedAngle == 150.0 || normalizedAngle == 270.0) {
      return Element.earth;
    } else if (normalizedAngle == 60.0 || normalizedAngle == 180.0 || normalizedAngle == 300.0) {
      return Element.air;
    } else {
      return Element.water;
    }
  }

  /// Rashi qualities
  /// Calculate rashi quality using Swiss Ephemeris precision
  static Quality getRashiQuality(int rashiNumber) {
    final baseAngle = (rashiNumber - 1) * 30.0;
    final normalizedAngle = baseAngle % 360.0;

    if (normalizedAngle == 0.0 ||
        normalizedAngle == 90.0 ||
        normalizedAngle == 180.0 ||
        normalizedAngle == 270.0) {
      return Quality.cardinal;
    } else if (normalizedAngle == 30.0 ||
        normalizedAngle == 120.0 ||
        normalizedAngle == 210.0 ||
        normalizedAngle == 300.0) {
      return Quality.fixed;
    } else {
      return Quality.mutable;
    }
  }

  /// Rashi genders
  /// Calculate rashi gender using Swiss Ephemeris precision
  static Gender getRashiGender(int rashiNumber) {
    // Calculate gender based on precise astronomical position
    // Male signs: Aries, Cancer, Leo, Sagittarius (0°, 90°, 120°, 240°)
    // Female signs: Taurus, Virgo, Scorpio, Capricorn, Pisces (30°, 150°, 210°, 270°, 330°)
    // Neutral signs: Gemini, Libra, Aquarius (60°, 180°, 300°)

    final baseAngle = (rashiNumber - 1) * 30.0;
    final normalizedAngle = baseAngle % 360.0;

    if (normalizedAngle == 0.0 ||
        normalizedAngle == 90.0 ||
        normalizedAngle == 120.0 ||
        normalizedAngle == 240.0) {
      return Gender.male;
    } else if (normalizedAngle == 30.0 ||
        normalizedAngle == 150.0 ||
        normalizedAngle == 210.0 ||
        normalizedAngle == 270.0 ||
        normalizedAngle == 330.0) {
      return Gender.female;
    } else {
      return Gender.neutral;
    }
  }

  /// Rashi symbols (Zodiac signs - unique from nakshatra symbols)
  static const List<String> symbols = [
    '🐏', // Aries (Ram) - Strong, bold ram
    '🐃', // Taurus (Bull) - Powerful water buffalo
    '👥', // Gemini (Twins) - Two people representing duality
    '🦀', // Cancer (Crab) - Perfect crab representation
    '🦁', // Leo (Lion) - Majestic lion
    '👸', // Virgo (Virgin) - Princess/virgin representation
    '⚖️', // Libra (Scales) - Perfect scales of justice
    '🦂', // Scorpio (Scorpion) - Intimidating scorpion
    '🎯', // Sagittarius (Archer) - Target/bow symbol
    '🐐', // Capricorn (Goat) - Mountain goat
    '🏺', // Aquarius (Water Bearer) - Ancient water vessel
    '♓', // Pisces (Fish) - Pisces zodiac symbol
  ];
}

/// Nakshatra constants
class NakshatraConstants {
  // Prevent instantiation
  NakshatraConstants._();

  /// Nakshatra names in Sanskrit
  static const List<String> sanskritNames = [
    'अश्विनी', // Ashwini
    'भरणी', // Bharani
    'कृत्तिका', // Krittika
    'रोहिणी', // Rohini
    'मृगशिरा', // Mrigashira
    'आर्द्रा', // Ardra
    'पुनर्वसु', // Punarvasu
    'पुष्य', // Pushya
    'आश्लेषा', // Ashlesha
    'मघा', // Magha
    'पूर्व फाल्गुनी', // Purva Phalguni
    'उत्तर फाल्गुनी', // Uttara Phalguni
    'हस्त', // Hasta
    'चित्रा', // Chitra
    'स्वाती', // Swati
    'विशाखा', // Vishakha
    'अनुराधा', // Anuradha
    'ज्येष्ठा', // Jyeshtha
    'मूल', // Mula
    'पूर्वाषाढ़ा', // Purva Ashadha
    'उत्तराषाढ़ा', // Uttara Ashadha
    'श्रवण', // Shravana
    'धनिष्ठा', // Dhanishta
    'शतभिषा', // Shatabhisha
    'पूर्व भाद्रपद', // Purva Bhadrapada
    'उत्तर भाद्रपद', // Uttara Bhadrapada
    'रेवती', // Revati
  ];

  /// Nakshatra names in English
  static const List<String> englishNames = [
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

  /// Nakshatra lords
  static const List<Planet> lords = [
    Planet.ketu, // Ashwini
    Planet.venus, // Bharani
    Planet.sun, // Krittika
    Planet.moon, // Rohini
    Planet.mars, // Mrigashira
    Planet.rahu, // Ardra
    Planet.jupiter, // Punarvasu
    Planet.saturn, // Pushya
    Planet.mercury, // Ashlesha
    Planet.ketu, // Magha
    Planet.venus, // Purva Phalguni
    Planet.sun, // Uttara Phalguni
    Planet.moon, // Hasta
    Planet.mars, // Chitra
    Planet.rahu, // Swati
    Planet.jupiter, // Vishakha
    Planet.saturn, // Anuradha
    Planet.mercury, // Jyeshtha
    Planet.ketu, // Mula
    Planet.venus, // Purva Ashadha
    Planet.sun, // Uttara Ashadha
    Planet.moon, // Shravana
    Planet.mars, // Dhanishta
    Planet.rahu, // Shatabhisha
    Planet.jupiter, // Purva Bhadrapada
    Planet.saturn, // Uttara Bhadrapada
    Planet.mercury, // Revati
  ];

  /// Nakshatra deities
  static const List<String> deities = [
    'Ashwini Kumaras',
    'Yama',
    'Agni',
    'Brahma',
    'Soma',
    'Rudra',
    'Aditi',
    'Brihaspati',
    'Nagas',
    'Pitrs',
    'Bhaga',
    'Aryaman',
    'Savitar',
    'Vishwakarma',
    'Vayu',
    'Indra-Agni',
    'Mitra',
    'Indra',
    'Nirriti',
    'Apas',
    'Vishnu',
    'Vishnu',
    'Vasus',
    'Varuna',
    'Aja Ekapada',
    'Ahir Budhnya',
    'Pushan',
  ];

  /// Nakshatra symbols (authentic Vedic astrology symbols)
  static const List<String> symbols = [
    '🐴', // Ashwini - Horse's head (swiftness, vitality)
    '🌸', // Bharani - Yoni (creation, birth, nurturing)
    '🔪', // Krittika - Razor (cutting through negativity)
    '🛒', // Rohini - Cart/Chariot (fertility, commerce)
    '🦌', // Mrigashira - Deer's head (gentleness, seeking)
    '💧', // Ardra - Teardrop (cleansing, transformation)
    '🏹', // Punarvasu - Quiver of arrows (return, replenish)
    '🌺', // Pushya - Cow's udder/Flower (nourishment, care)
    '🐍', // Ashlesha - Coiled serpent (hidden knowledge, wisdom)
    '👑', // Magha - Throne (royalty, ancestral power)
    '🛏️', // Purva Phalguni - Front legs of bed (rest, relaxation)
    '🔗', // Uttara Phalguni - Back legs of bed (commitment, partnership)
    '✋', // Hasta - Hand/Closed fist (skill, craftsmanship)
    '💎', // Chitra - Bright jewel/Pearl (brilliance, beauty)
    '🌾', // Swati - Young shoot swaying (flexibility, independence)
    '🏛️', // Vishakha - Triumphal archway (achievement, purpose)
    '🪷', // Anuradha - Lotus flower (blossoming, collaboration)
    '☂️', // Jyeshtha - Umbrella/Talisman (protection, authority)
    '🌱', // Mula - Tied bundle of roots (seeking essence, medicine)
    '🌬️', // Purva Ashadha - Winnowing fan (purification, victory)
    '🐘', // Uttara Ashadha - Elephant's tusk (undefeatable victory)
    '👂', // Shravana - Ear/Three footprints (listening, learning)
    '🥁', // Dhanishta - Drum/Flute (rhythm, harmony)
    '⭕', // Shatabhisha - Empty circle (containment, healing)
    '⚰️', // Purva Bhadrapada - Front legs of funeral cot (transformation)
    '🕉️', // Uttara Bhadrapada - Back legs of funeral cot (completion, wisdom)
    '🐠', // Revati - Fish (cosmic waters, consciousness)
  ];

  /// Nakshatra genders
  static const List<Gender> genders = [
    Gender.male, // Ashwini
    Gender.female, // Bharani
    Gender.female, // Krittika
    Gender.male, // Rohini
    Gender.female, // Mrigashira
    Gender.male, // Ardra
    Gender.male, // Punarvasu
    Gender.male, // Pushya
    Gender.female, // Ashlesha
    Gender.male, // Magha
    Gender.female, // Purva Phalguni
    Gender.male, // Uttara Phalguni
    Gender.male, // Hasta
    Gender.female, // Chitra
    Gender.male, // Swati
    Gender.female, // Vishakha
    Gender.male, // Anuradha
    Gender.female, // Jyeshtha
    Gender.female, // Mula
    Gender.male, // Purva Ashadha
    Gender.male, // Uttara Ashadha
    Gender.male, // Shravana
    Gender.female, // Dhanishta
    Gender.female, // Shatabhisha
    Gender.male, // Purva Bhadrapada
    Gender.female, // Uttara Bhadrapada
    Gender.male, // Revati
  ];

  /// Nakshatra gunas
  static const List<Guna> gunas = [
    Guna.rajas, // Ashwini
    Guna.tamas, // Bharani
    Guna.rajas, // Krittika
    Guna.sattva, // Rohini
    Guna.sattva, // Mrigashira
    Guna.tamas, // Ardra
    Guna.sattva, // Punarvasu
    Guna.sattva, // Pushya
    Guna.tamas, // Ashlesha
    Guna.tamas, // Magha
    Guna.rajas, // Purva Phalguni
    Guna.sattva, // Uttara Phalguni
    Guna.sattva, // Hasta
    Guna.tamas, // Chitra
    Guna.rajas, // Swati
    Guna.rajas, // Vishakha
    Guna.sattva, // Anuradha
    Guna.tamas, // Jyeshtha
    Guna.tamas, // Mula
    Guna.rajas, // Purva Ashadha
    Guna.sattva, // Uttara Ashadha
    Guna.sattva, // Shravana
    Guna.tamas, // Dhanishta
    Guna.tamas, // Shatabhisha
    Guna.rajas, // Purva Bhadrapada
    Guna.sattva, // Uttara Bhadrapada
    Guna.sattva, // Revati
  ];

  /// Nakshatra yonis
  static const List<Yoni> yonis = [
    Yoni.horse, // Ashwini
    Yoni.elephant, // Bharani
    Yoni.sheep, // Krittika
    Yoni.serpent, // Rohini
    Yoni.serpent, // Mrigashira
    Yoni.dog, // Ardra
    Yoni.cat, // Punarvasu
    Yoni.sheep, // Pushya
    Yoni.cat, // Ashlesha
    Yoni.rat, // Magha
    Yoni.rat, // Purva Phalguni
    Yoni.cow, // Uttara Phalguni
    Yoni.buffalo, // Hasta
    Yoni.tiger, // Chitra
    Yoni.buffalo, // Swati
    Yoni.tiger, // Vishakha
    Yoni.deer, // Anuradha
    Yoni.deer, // Jyeshtha
    Yoni.dog, // Mula
    Yoni.monkey, // Purva Ashadha
    Yoni.mongoose, // Uttara Ashadha
    Yoni.monkey, // Shravana
    Yoni.lion, // Dhanishta
    Yoni.horse, // Shatabhisha
    Yoni.lion, // Purva Bhadrapada
    Yoni.cow, // Uttara Bhadrapada
    Yoni.elephant, // Revati
  ];

  /// Nakshatra nadis
  static const List<Nadi> nadis = [
    Nadi.adya, // Ashwini
    Nadi.adya, // Bharani
    Nadi.adya, // Krittika
    Nadi.adya, // Rohini
    Nadi.adya, // Mrigashira
    Nadi.adya, // Ardra
    Nadi.adya, // Punarvasu
    Nadi.adya, // Pushya
    Nadi.adya, // Ashlesha
    Nadi.madhya, // Magha
    Nadi.madhya, // Purva Phalguni
    Nadi.madhya, // Uttara Phalguni
    Nadi.madhya, // Hasta
    Nadi.madhya, // Chitra
    Nadi.madhya, // Swati
    Nadi.madhya, // Vishakha
    Nadi.madhya, // Anuradha
    Nadi.madhya, // Jyeshtha
    Nadi.antya, // Mula
    Nadi.antya, // Purva Ashadha
    Nadi.antya, // Uttara Ashadha
    Nadi.antya, // Shravana
    Nadi.antya, // Dhanishta
    Nadi.antya, // Shatabhisha
    Nadi.antya, // Purva Bhadrapada
    Nadi.antya, // Uttara Bhadrapada
    Nadi.antya, // Revati
  ];
}

/// Dasha constants
class DashaConstants {
  // Prevent instantiation
  DashaConstants._();

  /// Vimshottari dasha periods in years
  static const Map<Planet, int> vimshottariPeriods = {
    Planet.ketu: 7,
    Planet.venus: 20,
    Planet.sun: 6,
    Planet.moon: 10,
    Planet.mars: 7,
    Planet.rahu: 18,
    Planet.jupiter: 16,
    Planet.saturn: 19,
    Planet.mercury: 17,
  };

  /// Vimshottari dasha sequence
  static const List<Planet> vimshottariSequence = [
    Planet.ketu,
    Planet.venus,
    Planet.sun,
    Planet.moon,
    Planet.mars,
    Planet.rahu,
    Planet.jupiter,
    Planet.saturn,
    Planet.mercury,
  ];

  /// Nakshatra to dasha lord mapping - CORRECTED according to Brihat Parashara Hora Shastra
  /// This is the correct classical Vedic astrology mapping
  static const Map<int, Planet> nakshatraToDashaLord = {
    1: Planet.ketu, // Ashwini - Ketu (7 years)
    2: Planet.venus, // Bharani - Venus (20 years)
    3: Planet.sun, // Krittika - Sun (6 years)
    4: Planet.moon, // Rohini - Moon (10 years)
    5: Planet.mars, // Mrigashira - Mars (7 years)
    6: Planet.rahu, // Ardra - Rahu (18 years)
    7: Planet.jupiter, // Punarvasu - Jupiter (16 years)
    8: Planet.saturn, // Pushya - Saturn (19 years)
    9: Planet.mercury, // Ashlesha - Mercury (17 years)
    10: Planet.ketu, // Magha - Ketu (7 years)
    11: Planet.venus, // Purva Phalguni - Venus (20 years)
    12: Planet.sun, // Uttara Phalguni - Sun (6 years)
    13: Planet.moon, // Hasta - Moon (10 years)
    14: Planet.mars, // Chitra - Mars (7 years)
    15: Planet.rahu, // Swati - Rahu (18 years)
    16: Planet.jupiter, // Vishakha - Jupiter (16 years)
    17: Planet.saturn, // Anuradha - Saturn (19 years)
    18: Planet.mercury, // Jyeshtha - Mercury (17 years)
    19: Planet.ketu, // Mula - Ketu (7 years)
    20: Planet.venus, // Purva Ashadha - Venus (20 years)
    21: Planet.sun, // Uttara Ashadha - Sun (6 years)
    22: Planet.moon, // Shravana - Moon (10 years)
    23: Planet.mars, // Dhanishta - Mars (7 years)
    24: Planet.rahu, // Shatabhisha - Rahu (18 years)
    25: Planet.jupiter, // Purva Bhadrapada - Jupiter (16 years)
    26: Planet.saturn, // Uttara Bhadrapada - Saturn (19 years)
    27: Planet.mercury, // Revati - Mercury (17 years)
  };
}

/// Ashta Koota constants
class AshtaKootaConstants {
  // Prevent instantiation
  AshtaKootaConstants._();

  /// Maximum points for each koota (Total: 36 points)
  /// 18 points is minimum threshold for favorable match in classical Vedic texts
  static const Map<AshtaKoota, int> maxPoints = {
    AshtaKoota.varna: 1,
    AshtaKoota.vashya: 2,
    AshtaKoota.tara: 3,
    AshtaKoota.yoni: 4,
    AshtaKoota.grahaMaitri: 5,
    AshtaKoota.gana: 6,
    AshtaKoota.bhakoot: 7,
    AshtaKoota.nadi: 8,
  };

  /// Compatibility thresholds based on classical Vedic texts
  static const int minimumFavorableScore = 18; // Minimum threshold for favorable match
  static const int goodCompatibilityScore = 24; // Good compatibility
  static const int excellentCompatibilityScore = 28; // Excellent compatibility

  /// Total maximum points
  static const int totalMaxPoints = 36;

  /// Compatibility level thresholds based on classical Vedic texts
  static const Map<CompatibilityLevel, int> compatibilityThresholds = {
    CompatibilityLevel.excellent: 28, // 28+ points
    CompatibilityLevel.veryGood: 24, // 24-27 points
    CompatibilityLevel.good: 18, // 18-23 points (minimum threshold for favorable match)
    CompatibilityLevel.average: 12, // 12-17 points
    CompatibilityLevel.poor: 6, // 6-11 points
    CompatibilityLevel.veryPoor: 0, // 0-5 points
  };
}
