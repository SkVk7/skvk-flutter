/// Horoscope Insights Generator
///
/// Centralized utility for generating horoscope insights based on birth chart data
library;

class HoroscopeInsightsGenerator {
  /// Get planet data from planetary positions
  static Map<String, dynamic>? getPlanetData(
    Map<String, dynamic>? birthChart,
    String planetName,
  ) {
    final planetaryPositions =
        birthChart?['planetaryPositions'] as Map<String, dynamic>?;
    return planetaryPositions?[planetName] as Map<String, dynamic>?;
  }

  /// Calculate planetary strength (0.0 to 1.0)
  static double calculatePlanetaryStrength(
    Map<String, dynamic>? birthChart,
    String planet,
  ) {
    final planetName = planet[0].toUpperCase() + planet.substring(1);
    final planetData = getPlanetData(birthChart, planetName);

    if (planetData == null) return 0.5;

    final signName = planetData['rashi'] as String? ?? 'Unknown';
    final planetHouse = planetData['house'] as int?;
    final planetNakshatra = planetData['nakshatra'] as String?;

    if (signName == 'Unknown' ||
        planetHouse == null ||
        planetNakshatra == null) {
      return 0.5;
    }

    double strength = 0;
    strength += _getSignStrength(planet, signName);
    strength += _getHouseStrength(planetHouse.toString());
    strength += _getNakshatraStrength(planetNakshatra);
    strength += _getAspectStrength(planet);

    return (strength / 4.0).clamp(0.0, 1.0);
  }

  /// Calculate planetary aspects
  static List<String> calculatePlanetaryAspects(
    Map<String, dynamic>? birthChart,
    String planet,
  ) {
    final aspects = <String>[];
    final planetName = planet[0].toUpperCase() + planet.substring(1);
    final planetData = getPlanetData(birthChart, planetName);
    if (planetData == null) return aspects;

    final planetNames = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu',
    ];

    for (final otherPlanetName in planetNames) {
      if (otherPlanetName == planetName) continue;

      final otherPlanetData = getPlanetData(birthChart, otherPlanetName);
      if (otherPlanetData == null) continue;

      final aspect = _calculateAspect(planetData, otherPlanetData);
      if (aspect.isNotEmpty) {
        aspects
            .add('${_getPlanetName(otherPlanetName.toLowerCase())}: $aspect');
      }
    }

    return aspects;
  }

  /// Get Sun insight
  static String getSunInsight(Map<String, dynamic>? birthChart) {
    final sunData = getPlanetData(birthChart, 'Sun');
    if (sunData == null) return 'Your core identity is being calculated...';

    final sunRashi = sunData['rashi'] as String?;
    final sunHouse = sunData['house'] as int?;
    final sunNakshatra = sunData['nakshatra'] as String?;

    final sunStrength = calculatePlanetaryStrength(birthChart, 'sun');
    final sunAspects = calculatePlanetaryAspects(birthChart, 'sun');

    final sunRashiName = sunRashi ?? 'Unknown';
    final String baseInterpretation = _getSunSignInterpretation(sunRashiName);
    final String houseInfluence = _getHouseInfluence(sunHouse?.toString());
    final String nakshatraInfluence = _getNakshatraInfluence(sunNakshatra);
    final String strengthInfluence = _getStrengthInfluence(sunStrength);
    final String aspectInfluence = _getAspectInfluence(sunAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  /// Get Moon insight
  static String getMoonInsight(Map<String, dynamic>? birthChart) {
    final moonData = getPlanetData(birthChart, 'Moon');
    if (moonData == null) return 'Your emotional nature is being analyzed...';

    final moonRashi = moonData['rashi'] as String?;
    final moonHouse = moonData['house'] as int?;
    final moonNakshatra = moonData['nakshatra'] as String?;
    final moonStrength = calculatePlanetaryStrength(birthChart, 'moon');
    final moonAspects = calculatePlanetaryAspects(birthChart, 'moon');

    final moonRashiName = moonRashi ?? 'Unknown';
    final String baseInterpretation = _getMoonSignInterpretation(moonRashiName);
    final String houseInfluence = _getHouseInfluence(moonHouse?.toString());
    final String nakshatraInfluence = _getNakshatraInfluence(moonNakshatra);
    final String strengthInfluence = _getStrengthInfluence(moonStrength);
    final String aspectInfluence = _getAspectInfluence(moonAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  /// Get Mars insight
  static String getMarsInsight(Map<String, dynamic>? birthChart) {
    final marsData = getPlanetData(birthChart, 'Mars');
    if (marsData == null) return 'Your energy and drive are being assessed...';

    final marsRashi = marsData['rashi'] as String?;
    final marsHouse = marsData['house'] as int?;
    final marsNakshatra = marsData['nakshatra'] as String?;
    final marsStrength = calculatePlanetaryStrength(birthChart, 'mars');
    final marsAspects = calculatePlanetaryAspects(birthChart, 'mars');

    final marsRashiName = marsRashi ?? 'Unknown';
    final String baseInterpretation = _getMarsSignInterpretation(marsRashiName);
    final String houseInfluence = _getHouseInfluence(marsHouse?.toString());
    final String nakshatraInfluence = _getNakshatraInfluence(marsNakshatra);
    final String strengthInfluence = _getStrengthInfluence(marsStrength);
    final String aspectInfluence = _getAspectInfluence(marsAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  /// Get Jupiter insight
  static String getJupiterInsight(Map<String, dynamic>? birthChart) {
    final jupiterData = getPlanetData(birthChart, 'Jupiter');
    if (jupiterData == null) {
      return 'Your wisdom and growth potential are being evaluated...';
    }

    final jupiterRashi = jupiterData['rashi'] as String?;
    final jupiterHouse = jupiterData['house'] as int?;
    final jupiterNakshatra = jupiterData['nakshatra'] as String?;
    final jupiterStrength = calculatePlanetaryStrength(birthChart, 'jupiter');
    final jupiterAspects = calculatePlanetaryAspects(birthChart, 'jupiter');

    final jupiterRashiName = jupiterRashi ?? 'Unknown';
    final String baseInterpretation =
        _getJupiterSignInterpretation(jupiterRashiName);
    final String houseInfluence = _getHouseInfluence(jupiterHouse?.toString());
    final String nakshatraInfluence = _getNakshatraInfluence(jupiterNakshatra);
    final String strengthInfluence = _getStrengthInfluence(jupiterStrength);
    final String aspectInfluence = _getAspectInfluence(jupiterAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  /// Get Venus insight
  static String getVenusInsight(Map<String, dynamic>? birthChart) {
    final venusData = getPlanetData(birthChart, 'Venus');
    if (venusData == null) {
      return 'Your love and relationship style is being analyzed...';
    }

    final venusRashi = venusData['rashi'] as String?;
    final venusHouse = venusData['house'] as int?;
    final venusNakshatra = venusData['nakshatra'] as String?;
    final venusStrength = calculatePlanetaryStrength(birthChart, 'venus');
    final venusAspects = calculatePlanetaryAspects(birthChart, 'venus');

    final venusRashiName = venusRashi ?? 'Unknown';
    final String baseInterpretation =
        _getVenusSignInterpretation(venusRashiName);
    final String houseInfluence = _getHouseInfluence(venusHouse?.toString());
    final String nakshatraInfluence = _getNakshatraInfluence(venusNakshatra);
    final String strengthInfluence = _getStrengthInfluence(venusStrength);
    final String aspectInfluence = _getAspectInfluence(venusAspects);

    return '$baseInterpretation $houseInfluence $nakshatraInfluence $strengthInfluence $aspectInfluence';
  }

  /// Get house lord planet name
  static String? getHouseLord(
    Map<String, dynamic>? birthChart,
    int houseNumber,
  ) {
    final houseLords = birthChart?['houseLords'] as Map<String, dynamic>?;
    final houseLord = houseLords?['House $houseNumber'] as String?;

    if (houseLord != null && _isValidPlanetName(houseLord)) {
      return houseLord;
    }

    final ascendantData = birthChart?['ascendant'] as Map<String, dynamic>?;
    final ascendantRashi = ascendantData?['rashi'] as String?;
    if (ascendantRashi != null) {
      return _calculateHouseLordFromAscendant(houseNumber, ascendantRashi);
    }

    return null;
  }

  /// Get career insight
  static String getCareerInsight(Map<String, dynamic>? birthChart) {
    final careerLord = getHouseLord(birthChart, 10);
    if (careerLord == null) {
      final sunData = getPlanetData(birthChart, 'Sun');
      if (sunData != null) {
        final sunRashi = sunData['rashi'] as String? ?? 'Unknown';
        return _getCareerInsightByRashi(sunRashi);
      }
      return 'Your career potential is being analyzed...';
    }

    final careerData = getPlanetData(birthChart, careerLord);
    if (careerData == null) {
      final sunData = getPlanetData(birthChart, 'Sun');
      if (sunData != null) {
        final sunRashi = sunData['rashi'] as String? ?? 'Unknown';
        return _getCareerInsightByRashi(sunRashi);
      }
      return 'Your career potential is being analyzed...';
    }

    final careerRashiName = careerData['rashi'] as String? ?? 'Unknown';
    return _getCareerInsightByRashi(careerRashiName);
  }

  /// Get marriage insight
  static String getMarriageInsight(Map<String, dynamic>? birthChart) {
    final marriageLord = getHouseLord(birthChart, 7);
    if (marriageLord == null) {
      final venusData = getPlanetData(birthChart, 'Venus');
      if (venusData != null) {
        final venusRashi = venusData['rashi'] as String? ?? 'Unknown';
        return _getMarriageInsightByRashi(venusRashi);
      }
      return 'Your relationship potential is being analyzed...';
    }

    final marriageData = getPlanetData(birthChart, marriageLord);
    if (marriageData == null) {
      final venusData = getPlanetData(birthChart, 'Venus');
      if (venusData != null) {
        final venusRashi = venusData['rashi'] as String? ?? 'Unknown';
        return _getMarriageInsightByRashi(venusRashi);
      }
      return 'Your relationship potential is being analyzed...';
    }

    final marriageRashiName = marriageData['rashi'] as String? ?? 'Unknown';
    return _getMarriageInsightByRashi(marriageRashiName);
  }

  /// Get wealth insight
  static String getWealthInsight(Map<String, dynamic>? birthChart) {
    final wealthLord = getHouseLord(birthChart, 2);
    if (wealthLord == null) {
      final jupiterData = getPlanetData(birthChart, 'Jupiter');
      if (jupiterData != null) {
        final jupiterRashi = jupiterData['rashi'] as String? ?? 'Unknown';
        return _getWealthInsightByRashi(jupiterRashi);
      }
      return 'Your wealth potential is being analyzed...';
    }

    final wealthData = getPlanetData(birthChart, wealthLord);
    if (wealthData == null) {
      final jupiterData = getPlanetData(birthChart, 'Jupiter');
      if (jupiterData != null) {
        final jupiterRashi = jupiterData['rashi'] as String? ?? 'Unknown';
        return _getWealthInsightByRashi(jupiterRashi);
      }
      return 'Your wealth potential is being analyzed...';
    }

    final wealthRashiName = wealthData['rashi'] as String? ?? 'Unknown';
    return _getWealthInsightByRashi(wealthRashiName);
  }

  /// Get health insight
  static String getHealthInsight(Map<String, dynamic>? birthChart) {
    final healthLord = getHouseLord(birthChart, 6);
    if (healthLord == null) {
      final marsData = getPlanetData(birthChart, 'Mars');
      if (marsData != null) {
        final marsRashi = marsData['rashi'] as String? ?? 'Unknown';
        return _getHealthInsightByRashi(marsRashi);
      }
      return 'Your health patterns are being analyzed...';
    }

    final healthData = getPlanetData(birthChart, healthLord);
    if (healthData == null) {
      final marsData = getPlanetData(birthChart, 'Mars');
      if (marsData != null) {
        final marsRashi = marsData['rashi'] as String? ?? 'Unknown';
        return _getHealthInsightByRashi(marsRashi);
      }
      return 'Your health patterns are being analyzed...';
    }

    final healthRashiName = healthData['rashi'] as String? ?? 'Unknown';
    return _getHealthInsightByRashi(healthRashiName);
  }

  /// Get ascendant insight
  static String getAscendantInsight(Map<String, dynamic>? birthChart) {
    final ascendantData = birthChart?['ascendant'] as Map<String, dynamic>?;
    if (ascendantData == null) {
      return 'Your rising sign influence is being analyzed...';
    }

    final ascendantRashiName = ascendantData['rashi'] as String? ?? 'Unknown';
    return 'Your rising sign in $ascendantRashiName influences how others perceive you and your first impressions. This energy affects your approach to new situations and relationships.';
  }

  /// Get current focus insight
  static String getCurrentFocusInsight(Map<String, dynamic>? birthChart) {
    final sunData = getPlanetData(birthChart, 'Sun');
    if (sunData == null) return 'Your current focus is being determined...';

    final sunRashiName = sunData['rashi'] as String? ?? 'Unknown';
    return 'Your current focus is on developing your $sunRashiName qualities and expressing your authentic self. This is a time for personal growth and self-discovery.';
  }

  /// Get best time insight
  static String getBestTimeInsight(Map<String, dynamic>? birthChart) {
    final moonData = getPlanetData(birthChart, 'Moon');
    if (moonData == null) return 'Your best timing is being analyzed...';

    final moonRashiName = moonData['rashi'] as String? ?? 'Unknown';
    return 'Your best time for action is when you feel emotionally secure and connected to your $moonRashiName nature. Trust your intuition and act from your heart.';
  }

  // Private helper methods
  static double _getSignStrength(String planet, String signName) {
    switch (planet.toLowerCase()) {
      case 'sun':
        return signName.toLowerCase() == 'leo' ? 1.0 : 0.5;
      case 'moon':
        return signName.toLowerCase() == 'cancer' ? 1.0 : 0.5;
      case 'mars':
        return signName.toLowerCase() == 'aries' ? 1.0 : 0.5;
      case 'mercury':
        return (signName.toLowerCase() == 'gemini' ||
                signName.toLowerCase() == 'virgo')
            ? 1.0
            : 0.5;
      case 'jupiter':
        return (signName.toLowerCase() == 'sagittarius' ||
                signName.toLowerCase() == 'pisces')
            ? 1.0
            : 0.5;
      case 'venus':
        return (signName.toLowerCase() == 'taurus' ||
                signName.toLowerCase() == 'libra')
            ? 1.0
            : 0.5;
      case 'saturn':
        return (signName.toLowerCase() == 'capricorn' ||
                signName.toLowerCase() == 'aquarius')
            ? 1.0
            : 0.5;
      default:
        return 0.5;
    }
  }

  static double _getHouseStrength(String? house) {
    if (house == null) return 0.4;
    switch (house.toLowerCase()) {
      case 'first':
      case 'fourth':
      case 'seventh':
      case 'tenth':
        return 1;
      case 'second':
      case 'fifth':
      case 'eighth':
      case 'eleventh':
        return 0.7;
      default:
        return 0.4;
    }
  }

  static double _getNakshatraStrength(String? nakshatra) {
    if (nakshatra == null || nakshatra.isEmpty) return 0.5;
    return (nakshatra.length % 3 == 0) ? 1.0 : 0.7;
  }

  static double _getAspectStrength(String planet) {
    return 0.6;
  }

  static String _calculateAspect(
    Map<String, dynamic> planet1,
    Map<String, dynamic> planet2,
  ) {
    final longitude1 = planet1['longitude'] as double? ?? 0.0;
    final longitude2 = planet2['longitude'] as double? ?? 0.0;
    final diff = (longitude2 - longitude1).abs() % 360.0;
    final aspect = (diff / 30.0).floor() % 12;

    switch (aspect) {
      case 0:
        return 'Conjunction';
      case 2:
      case 10:
        return 'Sextile';
      case 3:
      case 9:
        return 'Square';
      case 4:
      case 8:
        return 'Trine';
      case 6:
        return 'Opposition';
      default:
        return '';
    }
  }

  static String _getPlanetName(String planet) {
    switch (planet.toLowerCase()) {
      case 'sun':
        return 'Sun';
      case 'moon':
        return 'Moon';
      case 'mars':
        return 'Mars';
      case 'mercury':
        return 'Mercury';
      case 'jupiter':
        return 'Jupiter';
      case 'venus':
        return 'Venus';
      case 'saturn':
        return 'Saturn';
      case 'rahu':
        return 'Rahu';
      case 'ketu':
        return 'Ketu';
      default:
        return planet.toUpperCase();
    }
  }

  static String _getHouseInfluence(String? house) {
    if (house == null) return '';

    final houseNum = int.tryParse(house) ?? 0;
    if (houseNum > 0 && houseNum <= 12) {
      switch (houseNum) {
        case 1:
          return 'This placement emphasizes your personality and first impressions.';
        case 2:
          return 'This placement influences your values and material resources.';
        case 3:
          return 'This placement affects your communication and immediate environment.';
        case 4:
          return 'This placement emphasizes your home life and emotional foundation.';
        case 5:
          return 'This placement influences your creativity and self-expression.';
        case 6:
          return 'This placement affects your daily routines and service to others.';
        case 7:
          return 'This placement emphasizes your partnerships and relationships.';
        case 8:
          return 'This placement influences transformation and shared resources.';
        case 9:
          return 'This placement affects your higher learning and philosophical outlook.';
        case 10:
          return 'This placement emphasizes your career and public reputation.';
        case 11:
          return 'This placement influences your hopes, dreams, and social connections.';
        case 12:
          return 'This placement affects your spirituality and subconscious mind.';
        default:
          return '';
      }
    }

    switch (house.toLowerCase()) {
      case 'first':
        return 'This placement emphasizes your personality and first impressions.';
      case 'second':
        return 'This placement influences your values and material resources.';
      case 'third':
        return 'This placement affects your communication and immediate environment.';
      case 'fourth':
        return 'This placement emphasizes your home life and emotional foundation.';
      case 'fifth':
        return 'This placement influences your creativity and self-expression.';
      case 'sixth':
        return 'This placement affects your daily routines and service to others.';
      case 'seventh':
        return 'This placement emphasizes your partnerships and relationships.';
      case 'eighth':
        return 'This placement influences transformation and shared resources.';
      case 'ninth':
        return 'This placement affects your higher learning and philosophical outlook.';
      case 'tenth':
        return 'This placement emphasizes your career and public reputation.';
      case 'eleventh':
        return 'This placement influences your hopes, dreams, and social connections.';
      case 'twelfth':
        return 'This placement affects your spirituality and subconscious mind.';
      default:
        return '';
    }
  }

  static String _getNakshatraInfluence(String? nakshatra) {
    if (nakshatra == null || nakshatra.isEmpty) return '';
    return 'The $nakshatra nakshatra influences your personality and life path.';
  }

  static String _getStrengthInfluence(double strength) {
    if (strength > 0.8) {
      return 'This planet is very strong in your chart, giving you exceptional abilities in this area.';
    } else if (strength > 0.6) {
      return 'This planet is well-placed in your chart, providing good support for your endeavors.';
    } else if (strength > 0.4) {
      return 'This planet has moderate strength, requiring some effort to manifest its qualities.';
    } else {
      return 'This planet may need extra attention and conscious development to reach its potential.';
    }
  }

  static String _getAspectInfluence(List<String> aspects) {
    if (aspects.isEmpty) return '';
    return 'The planetary aspects in your chart create unique dynamics: ${aspects.join(', ')}.';
  }

  static bool _isValidPlanetName(String name) {
    const validPlanets = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu',
    ];
    return validPlanets.contains(name);
  }

  static String? _calculateHouseLordFromAscendant(
    int houseNumber,
    String ascendantRashi,
  ) {
    const rashiLords = {
      'Aries': 'Mars',
      'Taurus': 'Venus',
      'Gemini': 'Mercury',
      'Cancer': 'Moon',
      'Leo': 'Sun',
      'Virgo': 'Mercury',
      'Libra': 'Venus',
      'Scorpio': 'Mars',
      'Sagittarius': 'Jupiter',
      'Capricorn': 'Saturn',
      'Aquarius': 'Saturn',
      'Pisces': 'Jupiter',
    };

    const rashiNames = [
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
    final ascendantIndex = rashiNames
        .indexWhere((r) => r.toLowerCase() == ascendantRashi.toLowerCase());
    if (ascendantIndex == -1) return null;

    final houseSignIndex = (ascendantIndex + houseNumber - 1) % 12;
    final houseSignName = rashiNames[houseSignIndex];

    return rashiLords[houseSignName];
  }

  // Sign interpretation methods
  static String _getSunSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your core identity is marked by natural leadership and pioneering spirit.';
      case 'taurus':
        return 'Your core identity is grounded in stability and practical wisdom.';
      case 'gemini':
        return 'Your core identity thrives on communication and intellectual curiosity.';
      case 'cancer':
        return 'Your core identity is deeply connected to nurturing and emotional intelligence.';
      case 'leo':
        return 'Your core identity shines through creativity and natural charisma.';
      case 'virgo':
        return 'Your core identity is defined by analytical precision and service to others.';
      case 'libra':
        return 'Your core identity seeks harmony and balance in all relationships.';
      case 'scorpio':
        return 'Your core identity is marked by intensity and transformative power.';
      case 'sagittarius':
        return 'Your core identity is driven by adventure and philosophical exploration.';
      case 'capricorn':
        return 'Your core identity is built on discipline and ambitious achievement.';
      case 'aquarius':
        return 'Your core identity is innovative and humanitarian in nature.';
      case 'pisces':
        return 'Your core identity is compassionate and spiritually attuned.';
      default:
        return 'Your core identity reflects your unique personality blend.';
    }
  }

  static String _getMoonSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your emotional nature responds quickly and needs excitement.';
      case 'taurus':
        return 'Your emotional nature seeks security through stability and comfort.';
      case 'gemini':
        return 'Your emotional nature processes feelings through communication.';
      case 'cancer':
        return 'Your emotional nature is deeply intuitive and nurturing.';
      case 'leo':
        return 'Your emotional nature expresses itself dramatically and needs recognition.';
      case 'virgo':
        return 'Your emotional nature processes feelings through analysis and service.';
      case 'libra':
        return 'Your emotional nature seeks harmony and balance in relationships.';
      case 'scorpio':
        return 'Your emotional nature experiences feelings intensely and needs transformation.';
      case 'sagittarius':
        return 'Your emotional nature needs freedom and philosophical understanding.';
      case 'capricorn':
        return 'Your emotional nature may suppress feelings to maintain control.';
      case 'aquarius':
        return 'Your emotional nature processes feelings through detachment and humanitarian concerns.';
      case 'pisces':
        return 'Your emotional nature is highly sensitive and spiritually attuned.';
      default:
        return 'Your emotional nature reflects your inner needs and feelings.';
    }
  }

  static String _getMarsSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your energy and drive are marked by tremendous initiative and leadership.';
      case 'taurus':
        return 'Your energy and drive are steady and persistent, preferring your own pace.';
      case 'gemini':
        return 'Your energy and drive are quick and versatile, excelling at multitasking.';
      case 'cancer':
        return 'Your energy and drive are emotional and protective, fighting for family.';
      case 'leo':
        return 'Your energy and drive are dramatic and confident, inspiring others.';
      case 'virgo':
        return 'Your energy and drive are precise and analytical, working through detailed planning.';
      case 'libra':
        return 'Your energy and drive prefer cooperation over confrontation.';
      case 'scorpio':
        return 'Your energy and drive are intense and transformative, requiring deep investigation.';
      case 'sagittarius':
        return 'Your energy and drive are enthusiastic and adventurous, exploring new territories.';
      case 'capricorn':
        return 'Your energy and drive are disciplined and ambitious, working toward long-term goals.';
      case 'aquarius':
        return 'Your energy and drive are innovative and independent, pursuing original ideas.';
      case 'pisces':
        return 'Your energy and drive are sensitive and intuitive, working best in service to others.';
      default:
        return 'Your energy and drive reflect how you take action and pursue goals.';
    }
  }

  static String _getJupiterSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your wisdom and growth expand through leadership and new initiatives.';
      case 'taurus':
        return "Your wisdom and growth come from building solid foundations and appreciating life's pleasures.";
      case 'gemini':
        return 'Your wisdom and growth expand through learning and communication.';
      case 'cancer':
        return 'Your wisdom and growth come from nurturing others and creating emotional security.';
      case 'leo':
        return 'Your wisdom and growth expand through creative expression and leadership.';
      case 'virgo':
        return 'Your wisdom and growth come from service and attention to detail.';
      case 'libra':
        return 'Your wisdom and growth expand through relationships and creating harmony.';
      case 'scorpio':
        return 'Your wisdom and growth come from transformation and deep understanding.';
      case 'sagittarius':
        return 'Your wisdom and growth expand through philosophy and adventure.';
      case 'capricorn':
        return 'Your wisdom and growth come from discipline and achievement.';
      case 'aquarius':
        return 'Your wisdom and growth expand through innovation and humanitarian service.';
      case 'pisces':
        return 'Your wisdom and growth come from compassion and spiritual understanding.';
      default:
        return 'Your wisdom and growth reflect your highest aspirations.';
    }
  }

  static String _getVenusSignInterpretation(String signName) {
    switch (signName.toLowerCase()) {
      case 'aries':
        return 'Your love and relationship style is passionate and direct.';
      case 'taurus':
        return 'Your love and relationship style values stability and sensuality.';
      case 'gemini':
        return 'Your love and relationship style needs mental stimulation and communication.';
      case 'cancer':
        return 'Your love and relationship style is nurturing and protective.';
      case 'leo':
        return 'Your love and relationship style is generous and dramatic.';
      case 'virgo':
        return 'Your love and relationship style shows love through service and attention to detail.';
      case 'libra':
        return 'Your love and relationship style needs harmony and partnership.';
      case 'scorpio':
        return 'Your love and relationship style experiences love intensely and needs deep connections.';
      case 'sagittarius':
        return 'Your love and relationship style needs freedom and adventure.';
      case 'capricorn':
        return 'Your love and relationship style is serious and responsible.';
      case 'aquarius':
        return 'Your love and relationship style needs independence and intellectual connection.';
      case 'pisces':
        return 'Your love and relationship style is compassionate and idealistic.';
      default:
        return 'Your love and relationship style reflects how you give and receive affection.';
    }
  }

  static String _getCareerInsightByRashi(String rashiName) {
    switch (rashiName.toLowerCase()) {
      case 'aries':
        return 'You excel in leadership roles and pioneering new ventures. Consider careers in management, entrepreneurship, or any field requiring initiative.';
      case 'taurus':
        return 'You thrive in stable, practical careers with tangible results. Consider finance, real estate, agriculture, or any field requiring persistence.';
      case 'gemini':
        return 'You excel in communication and information-based careers. Consider writing, teaching, sales, or any field requiring versatility.';
      case 'cancer':
        return 'You succeed in nurturing and protective careers. Consider healthcare, hospitality, real estate, or any field serving families.';
      case 'leo':
        return 'You excel in creative and leadership roles. Consider entertainment, management, or any field where you can inspire others.';
      case 'virgo':
        return 'You thrive in service and detail-oriented careers. Consider healthcare, research, or any field requiring precision and analysis.';
      case 'libra':
        return 'You succeed in partnership and harmony-focused careers. Consider law, diplomacy, or any field requiring balance and fairness.';
      case 'scorpio':
        return 'You excel in transformative and investigative careers. Consider psychology, research, or any field requiring deep understanding.';
      case 'sagittarius':
        return 'You thrive in expansive and educational careers. Consider teaching, travel, or any field requiring philosophical understanding.';
      case 'capricorn':
        return 'You excel in structured and ambitious careers. Consider management, government, or any field requiring discipline and long-term planning.';
      case 'aquarius':
        return 'You succeed in innovative and humanitarian careers. Consider technology, social work, or any field requiring originality and progress.';
      case 'pisces':
        return 'You excel in compassionate and service-oriented careers. Consider healthcare, arts, or any field requiring empathy and spiritual understanding.';
      default:
        return 'Your career potential reflects your natural abilities and the type of work that will bring you fulfillment and success.';
    }
  }

  static String _getMarriageInsightByRashi(String rashiName) {
    switch (rashiName.toLowerCase()) {
      case 'aries':
        return 'You need a partner who is independent and exciting. Your relationships may be passionate but require mutual respect for freedom.';
      case 'taurus':
        return 'You need a stable, loyal partner who values commitment. Your relationships are built on trust, security, and shared values.';
      case 'gemini':
        return 'You need a mentally stimulating partner who can communicate well. Your relationships thrive on intellectual connection and variety.';
      case 'cancer':
        return 'You need a nurturing, emotionally supportive partner. Your relationships are built on emotional security and family values.';
      case 'leo':
        return 'You need a partner who admires and appreciates you. Your relationships thrive on mutual respect and shared creative interests.';
      case 'virgo':
        return 'You need a practical, service-oriented partner. Your relationships are built on mutual support and helping each other improve.';
      case 'libra':
        return 'You need a harmonious, diplomatic partner. Your relationships thrive on balance, fairness, and shared aesthetic interests.';
      case 'scorpio':
        return 'You need a deeply committed, transformative partner. Your relationships require trust, intimacy, and mutual growth.';
      case 'sagittarius':
        return 'You need an adventurous, philosophical partner. Your relationships thrive on shared beliefs, travel, and intellectual exploration.';
      case 'capricorn':
        return 'You need a responsible, ambitious partner. Your relationships are built on mutual respect, shared goals, and long-term commitment.';
      case 'aquarius':
        return 'You need an independent, humanitarian partner. Your relationships thrive on friendship, shared ideals, and mutual freedom.';
      case 'pisces':
        return 'You need a compassionate, spiritually-minded partner. Your relationships are built on empathy, understanding, and mutual support.';
      default:
        return 'Your relationship potential reflects the type of partner who will complement your nature and support your growth.';
    }
  }

  static String _getWealthInsightByRashi(String rashiName) {
    switch (rashiName.toLowerCase()) {
      case 'aries':
        return 'You build wealth through leadership and new ventures. Your energy and initiative help you create opportunities for financial growth.';
      case 'taurus':
        return 'You build wealth through steady, practical means. Your persistence and appreciation for quality help you accumulate resources over time.';
      case 'gemini':
        return 'You build wealth through communication and versatility. Your ability to adapt and learn helps you create multiple income streams.';
      case 'cancer':
        return 'You build wealth through nurturing and protecting resources. Your emotional intelligence helps you make wise financial decisions.';
      case 'leo':
        return 'You build wealth through creative expression and leadership. Your confidence and charisma help you attract financial opportunities.';
      case 'virgo':
        return 'You build wealth through service and attention to detail. Your analytical skills help you make practical financial decisions.';
      case 'libra':
        return 'You build wealth through partnerships and balance. Your diplomatic skills help you create mutually beneficial financial relationships.';
      case 'scorpio':
        return 'You build wealth through transformation and deep understanding. Your intensity helps you uncover hidden financial opportunities.';
      case 'sagittarius':
        return 'You build wealth through expansion and philosophy. Your optimism and love of learning help you create opportunities for growth.';
      case 'capricorn':
        return 'You build wealth through discipline and long-term planning. Your ambition and practical approach help you achieve financial security.';
      case 'aquarius':
        return 'You build wealth through innovation and humanitarian service. Your originality helps you create unique financial opportunities.';
      case 'pisces':
        return "You build wealth through compassion and intuition. Your sensitivity helps you understand others' needs and create value.";
      default:
        return 'Your wealth potential reflects your natural abilities and the best ways for you to create and manage financial resources.';
    }
  }

  static String _getHealthInsightByRashi(String rashiName) {
    switch (rashiName.toLowerCase()) {
      case 'aries':
        return 'You have strong vitality but may need to manage stress and anger. Regular exercise and competitive activities help maintain your health.';
      case 'taurus':
        return 'You have good endurance but may need to watch your diet and exercise routine. Regular physical activity and healthy eating are essential.';
      case 'gemini':
        return 'You may experience stress-related health issues. Mental stimulation and regular communication help maintain your well-being.';
      case 'cancer':
        return 'Your health is closely tied to your emotional state. A nurturing environment and emotional security are important for your well-being.';
      case 'leo':
        return 'You have strong vitality but may need to manage your heart and blood pressure. Regular exercise and creative expression support your health.';
      case 'virgo':
        return 'You may be prone to stress-related digestive issues. A healthy diet, regular routine, and attention to details support your well-being.';
      case 'libra':
        return 'Your health is affected by relationship stress. Balance in all areas of life and harmonious relationships support your well-being.';
      case 'scorpio':
        return 'You have strong regenerative abilities but may need to manage intense emotions. Regular detoxification and emotional release support your health.';
      case 'sagittarius':
        return 'You have good overall health but may need to watch your liver and avoid overindulgence. Regular exercise and philosophical pursuits support your well-being.';
      case 'capricorn':
        return 'You may experience stress-related bone and joint issues. Regular exercise, proper nutrition, and stress management support your health.';
      case 'aquarius':
        return 'Your health may be affected by nervous system stress. Regular exercise, social connection, and innovative activities support your well-being.';
      case 'pisces':
        return 'You may be sensitive to environmental factors and emotions. Regular spiritual practices, boundaries, and emotional support are essential for your health.';
      default:
        return 'Your health patterns reflect your natural constitution and the areas where you need to pay special attention to maintain well-being.';
    }
  }
}
