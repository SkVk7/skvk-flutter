/// Astrology Name Service
///
/// Maps numeric IDs to names in different languages for:
/// - Tithi (1-30)
/// - Nakshatra (1-27)
/// - Yoga (1-27)
/// - Karana (1-11)
/// - Moon Sign (1-12)
/// - Sun Sign (1-12)
/// - Paksha (1-2)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skvk_application/core/services/language/language_service.dart';

class AstrologyNameService {
  factory AstrologyNameService() => _instance;
  AstrologyNameService._internal();
  static final AstrologyNameService _instance =
      AstrologyNameService._internal();

  // Tithi names (1-30)
  static const Map<int, Map<SupportedLanguage, String>> _tithiNames = {
    1: {
      SupportedLanguage.english: 'Pratipada',
      SupportedLanguage.hindi: 'प्रतिपदा',
      SupportedLanguage.telugu: 'ప్రతిపద',
    },
    2: {
      SupportedLanguage.english: 'Dwitiya',
      SupportedLanguage.hindi: 'द्वितीया',
      SupportedLanguage.telugu: 'ద్వితీయ',
    },
    3: {
      SupportedLanguage.english: 'Tritiya',
      SupportedLanguage.hindi: 'तृतीया',
      SupportedLanguage.telugu: 'తృతీయ',
    },
    4: {
      SupportedLanguage.english: 'Chaturthi',
      SupportedLanguage.hindi: 'चतुर्थी',
      SupportedLanguage.telugu: 'చతుర్థి',
    },
    5: {
      SupportedLanguage.english: 'Panchami',
      SupportedLanguage.hindi: 'पंचमी',
      SupportedLanguage.telugu: 'పంచమి',
    },
    6: {
      SupportedLanguage.english: 'Shashthi',
      SupportedLanguage.hindi: 'षष्ठी',
      SupportedLanguage.telugu: 'షష్ఠి',
    },
    7: {
      SupportedLanguage.english: 'Saptami',
      SupportedLanguage.hindi: 'सप्तमी',
      SupportedLanguage.telugu: 'సప్తమి',
    },
    8: {
      SupportedLanguage.english: 'Ashtami',
      SupportedLanguage.hindi: 'अष्टमी',
      SupportedLanguage.telugu: 'అష్టమి',
    },
    9: {
      SupportedLanguage.english: 'Navami',
      SupportedLanguage.hindi: 'नवमी',
      SupportedLanguage.telugu: 'నవమి',
    },
    10: {
      SupportedLanguage.english: 'Dashami',
      SupportedLanguage.hindi: 'दशमी',
      SupportedLanguage.telugu: 'దశమి',
    },
    11: {
      SupportedLanguage.english: 'Ekadashi',
      SupportedLanguage.hindi: 'एकादशी',
      SupportedLanguage.telugu: 'ఏకాదశి',
    },
    12: {
      SupportedLanguage.english: 'Dwadashi',
      SupportedLanguage.hindi: 'द्वादशी',
      SupportedLanguage.telugu: 'ద్వాదశి',
    },
    13: {
      SupportedLanguage.english: 'Trayodashi',
      SupportedLanguage.hindi: 'त्रयोदशी',
      SupportedLanguage.telugu: 'త్రయోదశి',
    },
    14: {
      SupportedLanguage.english: 'Chaturdashi',
      SupportedLanguage.hindi: 'चतुर्दशी',
      SupportedLanguage.telugu: 'చతుర్దశి',
    },
    15: {
      SupportedLanguage.english: 'Purnima',
      SupportedLanguage.hindi: 'पूर्णिमा',
      SupportedLanguage.telugu: 'పూర్ణిమ',
    },
    16: {
      SupportedLanguage.english: 'Pratipada',
      SupportedLanguage.hindi: 'प्रतिपदा',
      SupportedLanguage.telugu: 'ప్రతిపద',
    },
    17: {
      SupportedLanguage.english: 'Dwitiya',
      SupportedLanguage.hindi: 'द्वितीया',
      SupportedLanguage.telugu: 'ద్వితీయ',
    },
    18: {
      SupportedLanguage.english: 'Tritiya',
      SupportedLanguage.hindi: 'तृतीया',
      SupportedLanguage.telugu: 'తృతీయ',
    },
    19: {
      SupportedLanguage.english: 'Chaturthi',
      SupportedLanguage.hindi: 'चतुर्थी',
      SupportedLanguage.telugu: 'చతుర్థి',
    },
    20: {
      SupportedLanguage.english: 'Panchami',
      SupportedLanguage.hindi: 'पंचमी',
      SupportedLanguage.telugu: 'పంచమి',
    },
    21: {
      SupportedLanguage.english: 'Shashthi',
      SupportedLanguage.hindi: 'षष्ठी',
      SupportedLanguage.telugu: 'షష్ఠి',
    },
    22: {
      SupportedLanguage.english: 'Saptami',
      SupportedLanguage.hindi: 'सप्तमी',
      SupportedLanguage.telugu: 'సప్తమి',
    },
    23: {
      SupportedLanguage.english: 'Ashtami',
      SupportedLanguage.hindi: 'अष्टमी',
      SupportedLanguage.telugu: 'అష్టమి',
    },
    24: {
      SupportedLanguage.english: 'Navami',
      SupportedLanguage.hindi: 'नवमी',
      SupportedLanguage.telugu: 'నవమి',
    },
    25: {
      SupportedLanguage.english: 'Dashami',
      SupportedLanguage.hindi: 'दशमी',
      SupportedLanguage.telugu: 'దశమి',
    },
    26: {
      SupportedLanguage.english: 'Ekadashi',
      SupportedLanguage.hindi: 'एकादशी',
      SupportedLanguage.telugu: 'ఏకాదశి',
    },
    27: {
      SupportedLanguage.english: 'Dwadashi',
      SupportedLanguage.hindi: 'द्वादशी',
      SupportedLanguage.telugu: 'ద్వాదశి',
    },
    28: {
      SupportedLanguage.english: 'Trayodashi',
      SupportedLanguage.hindi: 'त्रयोदशी',
      SupportedLanguage.telugu: 'త్రయోదశి',
    },
    29: {
      SupportedLanguage.english: 'Chaturdashi',
      SupportedLanguage.hindi: 'चतुर्दशी',
      SupportedLanguage.telugu: 'చతుర్దశి',
    },
    30: {
      SupportedLanguage.english: 'Amavasya',
      SupportedLanguage.hindi: 'अमावस्या',
      SupportedLanguage.telugu: 'అమావాస్య',
    },
  };

  // Nakshatra names (1-27)
  static const Map<int, Map<SupportedLanguage, String>> _nakshatraNames = {
    1: {
      SupportedLanguage.english: 'Ashwini',
      SupportedLanguage.hindi: 'अश्विनी',
      SupportedLanguage.telugu: 'అశ్విని',
    },
    2: {
      SupportedLanguage.english: 'Bharani',
      SupportedLanguage.hindi: 'भरणी',
      SupportedLanguage.telugu: 'భరణి',
    },
    3: {
      SupportedLanguage.english: 'Krittika',
      SupportedLanguage.hindi: 'कृत्तिका',
      SupportedLanguage.telugu: 'కృత్తిక',
    },
    4: {
      SupportedLanguage.english: 'Rohini',
      SupportedLanguage.hindi: 'रोहिणी',
      SupportedLanguage.telugu: 'రోహిణి',
    },
    5: {
      SupportedLanguage.english: 'Mrigashira',
      SupportedLanguage.hindi: 'मृगशिरा',
      SupportedLanguage.telugu: 'మృగశిర',
    },
    6: {
      SupportedLanguage.english: 'Ardra',
      SupportedLanguage.hindi: 'आर्द्रा',
      SupportedLanguage.telugu: 'ఆర్ద్ర',
    },
    7: {
      SupportedLanguage.english: 'Punarvasu',
      SupportedLanguage.hindi: 'पुनर्वसु',
      SupportedLanguage.telugu: 'పునర్వసు',
    },
    8: {
      SupportedLanguage.english: 'Pushya',
      SupportedLanguage.hindi: 'पुष्य',
      SupportedLanguage.telugu: 'పుష్య',
    },
    9: {
      SupportedLanguage.english: 'Ashlesha',
      SupportedLanguage.hindi: 'आश्लेषा',
      SupportedLanguage.telugu: 'ఆశ్లేష',
    },
    10: {
      SupportedLanguage.english: 'Magha',
      SupportedLanguage.hindi: 'मघा',
      SupportedLanguage.telugu: 'మఘ',
    },
    11: {
      SupportedLanguage.english: 'Purva Phalguni',
      SupportedLanguage.hindi: 'पूर्व फाल्गुनी',
      SupportedLanguage.telugu: 'పూర్వ ఫల్గుణి',
    },
    12: {
      SupportedLanguage.english: 'Uttara Phalguni',
      SupportedLanguage.hindi: 'उत्तर फाल्गुनी',
      SupportedLanguage.telugu: 'ఉత్తర ఫల్గుణి',
    },
    13: {
      SupportedLanguage.english: 'Hasta',
      SupportedLanguage.hindi: 'हस्त',
      SupportedLanguage.telugu: 'హస్త',
    },
    14: {
      SupportedLanguage.english: 'Chitra',
      SupportedLanguage.hindi: 'चित्रा',
      SupportedLanguage.telugu: 'చిత్ర',
    },
    15: {
      SupportedLanguage.english: 'Swati',
      SupportedLanguage.hindi: 'स्वाती',
      SupportedLanguage.telugu: 'స్వాతి',
    },
    16: {
      SupportedLanguage.english: 'Vishakha',
      SupportedLanguage.hindi: 'विशाखा',
      SupportedLanguage.telugu: 'విశాఖ',
    },
    17: {
      SupportedLanguage.english: 'Anuradha',
      SupportedLanguage.hindi: 'अनुराधा',
      SupportedLanguage.telugu: 'అనురాధ',
    },
    18: {
      SupportedLanguage.english: 'Jyeshtha',
      SupportedLanguage.hindi: 'ज्येष्ठा',
      SupportedLanguage.telugu: 'జ్యేష్ఠ',
    },
    19: {
      SupportedLanguage.english: 'Mula',
      SupportedLanguage.hindi: 'मूल',
      SupportedLanguage.telugu: 'మూల',
    },
    20: {
      SupportedLanguage.english: 'Purva Ashadha',
      SupportedLanguage.hindi: 'पूर्व आषाढ़ा',
      SupportedLanguage.telugu: 'పూర్వ ఆషాఢ',
    },
    21: {
      SupportedLanguage.english: 'Uttara Ashadha',
      SupportedLanguage.hindi: 'उत्तर आषाढ़ा',
      SupportedLanguage.telugu: 'ఉత్తర ఆషాఢ',
    },
    22: {
      SupportedLanguage.english: 'Shravana',
      SupportedLanguage.hindi: 'श्रवण',
      SupportedLanguage.telugu: 'శ్రవణ',
    },
    23: {
      SupportedLanguage.english: 'Dhanishta',
      SupportedLanguage.hindi: 'धनिष्ठा',
      SupportedLanguage.telugu: 'ధనిష్ఠ',
    },
    24: {
      SupportedLanguage.english: 'Shatabhisha',
      SupportedLanguage.hindi: 'शतभिषा',
      SupportedLanguage.telugu: 'శతభిష',
    },
    25: {
      SupportedLanguage.english: 'Purva Bhadrapada',
      SupportedLanguage.hindi: 'पूर्व भाद्रपद',
      SupportedLanguage.telugu: 'పూర్వ భాద్రపద',
    },
    26: {
      SupportedLanguage.english: 'Uttara Bhadrapada',
      SupportedLanguage.hindi: 'उत्तर भाद्रपद',
      SupportedLanguage.telugu: 'ఉత్తర భాద్రపద',
    },
    27: {
      SupportedLanguage.english: 'Revati',
      SupportedLanguage.hindi: 'रेवती',
      SupportedLanguage.telugu: 'రేవతి',
    },
  };

  // Yoga names (1-27)
  static const Map<int, Map<SupportedLanguage, String>> _yogaNames = {
    1: {
      SupportedLanguage.english: 'Vishkambha',
      SupportedLanguage.hindi: 'विष्कंभ',
      SupportedLanguage.telugu: 'విష్కంభ',
    },
    2: {
      SupportedLanguage.english: 'Priti',
      SupportedLanguage.hindi: 'प्रीति',
      SupportedLanguage.telugu: 'ప్రీతి',
    },
    3: {
      SupportedLanguage.english: 'Ayushman',
      SupportedLanguage.hindi: 'आयुष्मान',
      SupportedLanguage.telugu: 'ఆయుష్మాన్',
    },
    4: {
      SupportedLanguage.english: 'Saubhagya',
      SupportedLanguage.hindi: 'सौभाग्य',
      SupportedLanguage.telugu: 'సౌభాగ్య',
    },
    5: {
      SupportedLanguage.english: 'Shobhana',
      SupportedLanguage.hindi: 'शोभन',
      SupportedLanguage.telugu: 'శోభన',
    },
    6: {
      SupportedLanguage.english: 'Atiganda',
      SupportedLanguage.hindi: 'अतिगंड',
      SupportedLanguage.telugu: 'అతిగండ',
    },
    7: {
      SupportedLanguage.english: 'Sukarma',
      SupportedLanguage.hindi: 'सुकर्म',
      SupportedLanguage.telugu: 'సుకర్మ',
    },
    8: {
      SupportedLanguage.english: 'Dhriti',
      SupportedLanguage.hindi: 'धृति',
      SupportedLanguage.telugu: 'ధృతి',
    },
    9: {
      SupportedLanguage.english: 'Shula',
      SupportedLanguage.hindi: 'शूल',
      SupportedLanguage.telugu: 'శూల',
    },
    10: {
      SupportedLanguage.english: 'Ganda',
      SupportedLanguage.hindi: 'गंड',
      SupportedLanguage.telugu: 'గండ',
    },
    11: {
      SupportedLanguage.english: 'Vriddhi',
      SupportedLanguage.hindi: 'वृद्धि',
      SupportedLanguage.telugu: 'వృద్ధి',
    },
    12: {
      SupportedLanguage.english: 'Dhruva',
      SupportedLanguage.hindi: 'ध्रुव',
      SupportedLanguage.telugu: 'ధ్రువ',
    },
    13: {
      SupportedLanguage.english: 'Vyaghata',
      SupportedLanguage.hindi: 'व्याघात',
      SupportedLanguage.telugu: 'వ్యాఘాత',
    },
    14: {
      SupportedLanguage.english: 'Harshana',
      SupportedLanguage.hindi: 'हर्षण',
      SupportedLanguage.telugu: 'హర్షణ',
    },
    15: {
      SupportedLanguage.english: 'Vajra',
      SupportedLanguage.hindi: 'वज्र',
      SupportedLanguage.telugu: 'వజ్ర',
    },
    16: {
      SupportedLanguage.english: 'Siddhi',
      SupportedLanguage.hindi: 'सिद्धि',
      SupportedLanguage.telugu: 'సిద్ధి',
    },
    17: {
      SupportedLanguage.english: 'Vyatipata',
      SupportedLanguage.hindi: 'व्यतिपात',
      SupportedLanguage.telugu: 'వ్యతిపాత',
    },
    18: {
      SupportedLanguage.english: 'Variyan',
      SupportedLanguage.hindi: 'वरीयान',
      SupportedLanguage.telugu: 'వరీయాన్',
    },
    19: {
      SupportedLanguage.english: 'Parigha',
      SupportedLanguage.hindi: 'परिघ',
      SupportedLanguage.telugu: 'పరిఘ',
    },
    20: {
      SupportedLanguage.english: 'Shiva',
      SupportedLanguage.hindi: 'शिव',
      SupportedLanguage.telugu: 'శివ',
    },
    21: {
      SupportedLanguage.english: 'Siddha',
      SupportedLanguage.hindi: 'सिद्ध',
      SupportedLanguage.telugu: 'సిద్ధ',
    },
    22: {
      SupportedLanguage.english: 'Sadhya',
      SupportedLanguage.hindi: 'साध्य',
      SupportedLanguage.telugu: 'సాధ్య',
    },
    23: {
      SupportedLanguage.english: 'Shubha',
      SupportedLanguage.hindi: 'शुभ',
      SupportedLanguage.telugu: 'శుభ',
    },
    24: {
      SupportedLanguage.english: 'Shukla',
      SupportedLanguage.hindi: 'शुक्ल',
      SupportedLanguage.telugu: 'శుక్ల',
    },
    25: {
      SupportedLanguage.english: 'Brahma',
      SupportedLanguage.hindi: 'ब्रह्म',
      SupportedLanguage.telugu: 'బ్రహ్మ',
    },
    26: {
      SupportedLanguage.english: 'Indra',
      SupportedLanguage.hindi: 'इंद्र',
      SupportedLanguage.telugu: 'ఇంద్ర',
    },
    27: {
      SupportedLanguage.english: 'Vaidhriti',
      SupportedLanguage.hindi: 'वैधृति',
      SupportedLanguage.telugu: 'వైధృతి',
    },
  };

  // Karana names (1-11)
  static const Map<int, Map<SupportedLanguage, String>> _karanaNames = {
    1: {
      SupportedLanguage.english: 'Bava',
      SupportedLanguage.hindi: 'बव',
      SupportedLanguage.telugu: 'బవ',
    },
    2: {
      SupportedLanguage.english: 'Balava',
      SupportedLanguage.hindi: 'बालव',
      SupportedLanguage.telugu: 'బాలవ',
    },
    3: {
      SupportedLanguage.english: 'Kaulava',
      SupportedLanguage.hindi: 'कौलव',
      SupportedLanguage.telugu: 'కౌలవ',
    },
    4: {
      SupportedLanguage.english: 'Taitila',
      SupportedLanguage.hindi: 'तैतिल',
      SupportedLanguage.telugu: 'తైతిల',
    },
    5: {
      SupportedLanguage.english: 'Gara',
      SupportedLanguage.hindi: 'गर',
      SupportedLanguage.telugu: 'గర',
    },
    6: {
      SupportedLanguage.english: 'Vanija',
      SupportedLanguage.hindi: 'वणिज',
      SupportedLanguage.telugu: 'వణిజ',
    },
    7: {
      SupportedLanguage.english: 'Bhadra',
      SupportedLanguage.hindi: 'भद्र',
      SupportedLanguage.telugu: 'భద్ర',
    },
    8: {
      SupportedLanguage.english: 'Shakuni',
      SupportedLanguage.hindi: 'शकुनि',
      SupportedLanguage.telugu: 'శకుని',
    },
    9: {
      SupportedLanguage.english: 'Chatushpada',
      SupportedLanguage.hindi: 'चतुष्पद',
      SupportedLanguage.telugu: 'చతుష్పద',
    },
    10: {
      SupportedLanguage.english: 'Naga',
      SupportedLanguage.hindi: 'नाग',
      SupportedLanguage.telugu: 'నాగ',
    },
    11: {
      SupportedLanguage.english: 'Kimstughna',
      SupportedLanguage.hindi: 'किंस्तुघ्न',
      SupportedLanguage.telugu: 'కింస్తుఘ్న',
    },
  };

  // Paksha names (1-2)
  static const Map<int, Map<SupportedLanguage, String>> _pakshaNames = {
    1: {
      SupportedLanguage.english: 'Shukla Paksha',
      SupportedLanguage.hindi: 'शुक्ल पक्ष',
      SupportedLanguage.telugu: 'శుక్ల పక్ష',
    },
    2: {
      SupportedLanguage.english: 'Krishna Paksha',
      SupportedLanguage.hindi: 'कृष्ण पक्ष',
      SupportedLanguage.telugu: 'కృష్ణ పక్ష',
    },
  };

  /// Get Tithi name by ID and language
  String getTithiName(int tithiId, SupportedLanguage language) {
    final tithi = _tithiNames[tithiId];
    if (tithi == null) return 'Unknown';
    return tithi[language] ?? tithi[SupportedLanguage.english] ?? 'Unknown';
  }

  /// Get Nakshatra name by ID and language
  String getNakshatraName(int nakshatraId, SupportedLanguage language) {
    final nakshatra = _nakshatraNames[nakshatraId];
    if (nakshatra == null) return 'Unknown';
    return nakshatra[language] ??
        nakshatra[SupportedLanguage.english] ??
        'Unknown';
  }

  /// Get Yoga name by ID and language
  String getYogaName(int yogaId, SupportedLanguage language) {
    final yoga = _yogaNames[yogaId];
    if (yoga == null) return 'Unknown';
    return yoga[language] ?? yoga[SupportedLanguage.english] ?? 'Unknown';
  }

  /// Get Karana name by ID and language
  String getKaranaName(int karanaId, SupportedLanguage language) {
    final karana = _karanaNames[karanaId];
    if (karana == null) return 'Unknown';
    return karana[language] ?? karana[SupportedLanguage.english] ?? 'Unknown';
  }

  /// Get Paksha name by ID and language
  String getPakshaName(int pakshaId, SupportedLanguage language) {
    final paksha = _pakshaNames[pakshaId];
    if (paksha == null) return 'Unknown';
    return paksha[language] ?? paksha[SupportedLanguage.english] ?? 'Unknown';
  }

  /// Extract numeric ID from string (e.g., "Tithi 5" -> 5)
  int? extractNumericId(String value) {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(value);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '');
    }
    return null;
  }

  /// Get Tithi name from string (handles both "Tithi 5" and "5")
  String getTithiNameFromString(String value, SupportedLanguage language) {
    final id = extractNumericId(value);
    if (id != null) {
      // Normalize to 1-30 range
      final normalizedId = ((id - 1) % 30) + 1;
      return getTithiName(normalizedId, language);
    }
    return value; // Return as-is if no number found
  }

  /// Get Nakshatra name from string
  String getNakshatraNameFromString(String value, SupportedLanguage language) {
    final id = extractNumericId(value);
    if (id != null) {
      // Normalize to 1-27 range
      final normalizedId = ((id - 1) % 27) + 1;
      return getNakshatraName(normalizedId, language);
    }
    return value;
  }

  /// Get Yoga name from string
  String getYogaNameFromString(String value, SupportedLanguage language) {
    final id = extractNumericId(value);
    if (id != null) {
      // Normalize to 1-27 range
      final normalizedId = ((id - 1) % 27) + 1;
      return getYogaName(normalizedId, language);
    }
    return value;
  }

  /// Get Karana name from string
  String getKaranaNameFromString(String value, SupportedLanguage language) {
    final id = extractNumericId(value);
    if (id != null) {
      // Normalize to 1-11 range
      final normalizedId = ((id - 1) % 11) + 1;
      return getKaranaName(normalizedId, language);
    }
    return value;
  }
}

final astrologyNameServiceProvider = Provider<AstrologyNameService>((ref) {
  return AstrologyNameService();
});
