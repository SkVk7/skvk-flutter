/// House System Information Helper
///
/// Provides detailed information about different house systems
/// and their regional/traditional usage for user selection
library;

/// Information about house systems
class HouseSystemInfo {
  const HouseSystemInfo({
    required this.system,
    required this.name,
    required this.description,
    required this.regions,
    required this.traditions,
    required this.usage,
    required this.calculationMethod,
    this.isRecommended = false,
  });
  final String system;
  final String name;
  final String description;
  final List<String> regions;
  final List<String> traditions;
  final String usage;
  final bool isRecommended;
  final String calculationMethod;
}

/// Helper class for house system information
class HouseSystemInfoHelper {
  static const List<String> _houseSystemTypes = [
    'placidus',
    'whole',
    'equal',
    'koch',
    'porphyry',
    'regiomontanus',
    'campanus',
    'alcabitius',
    'topocentric',
    'krusinski',
    'vehlow',
    'axial',
    'horizontal',
    'polichPage',
    'morinus',
    'carter',
    'equalMidheaven',
    'wholeSign',
    'sripati',
    'sriLanka',
  ];

  static const List<HouseSystemInfo> _houseSystemInfo = [
    HouseSystemInfo(
      system: 'placidus',
      name: 'Placidus Houses',
      description:
          'Most widely used house system in Western astrology, based on time divisions',
      regions: [
        'Western Countries',
        'USA',
        'Europe',
        'Australia',
        'Modern India',
      ],
      traditions: [
        'Western Astrology',
        'Modern Vedic',
        'Psychological Astrology',
      ],
      usage:
          'Standard for most Western astrologers and modern Vedic practitioners',
      calculationMethod: 'Time-based divisions of the ecliptic',
      isRecommended: true,
    ),
    HouseSystemInfo(
      system: 'whole',
      name: 'Whole Sign Houses',
      description:
          'Traditional Vedic approach where each sign occupies an entire house',
      regions: ['India', 'Traditional Centers', 'Ancient Astrology'],
      traditions: ['Traditional Vedic', 'Hellenistic', 'Ancient Astrology'],
      usage:
          'Original house system used in classical Vedic and Hellenistic astrology',
      calculationMethod: 'Each zodiac sign = one complete house',
      isRecommended: true,
    ),
    HouseSystemInfo(
      system: 'equal',
      name: 'Equal Houses',
      description: 'Simple system where all houses are exactly 30 degrees wide',
      regions: ['India', 'Traditional Centers', 'Simple Systems'],
      traditions: ['Traditional Vedic', 'Simple Astrology', 'Beginner Systems'],
      usage:
          'Easy to calculate, used in traditional Vedic astrology and for beginners',
      calculationMethod: 'Each house = exactly 30 degrees from ascendant',
    ),
    HouseSystemInfo(
      system: 'koch',
      name: 'Koch Houses',
      description:
          'Time-based house system developed by Walter Koch, popular in Germany',
      regions: ['Germany', 'Central Europe', 'German-speaking Countries'],
      traditions: ['German Astrology', 'Modern Western', 'Time-based Systems'],
      usage: 'Popular in German-speaking countries and Central Europe',
      calculationMethod:
          'Time-based divisions with specific mathematical formula',
    ),
    HouseSystemInfo(
      system: 'porphyry',
      name: 'Porphyry Houses',
      description:
          'Ancient house system named after Porphyry, divides quadrants equally',
      regions: ['Ancient Centers', 'Traditional Astrology', 'Historical'],
      traditions: ['Ancient Astrology', 'Hellenistic', 'Traditional Western'],
      usage: 'Used in ancient and traditional Western astrology',
      calculationMethod: 'Equal division of quadrants between angles',
    ),
    HouseSystemInfo(
      system: 'regiomontanus',
      name: 'Regiomontanus Houses',
      description:
          'Spherical house system developed by Regiomontanus in the 15th century',
      regions: ['Europe', 'Historical', 'Traditional Western'],
      traditions: ['Medieval Astrology', 'Traditional Western', 'Historical'],
      usage: 'Used in medieval and traditional Western astrology',
      calculationMethod: 'Spherical projection onto the ecliptic',
    ),
    HouseSystemInfo(
      system: 'campanus',
      name: 'Campanus Houses',
      description:
          'House system developed by Campanus of Novara, based on prime vertical',
      regions: ['Europe', 'Historical', 'Traditional Western'],
      traditions: ['Medieval Astrology', 'Traditional Western', 'Historical'],
      usage: 'Used in medieval European astrology',
      calculationMethod: 'Prime vertical projection system',
    ),
    HouseSystemInfo(
      system: 'alcabitius',
      name: 'Alcabitius Houses',
      description:
          'Medieval house system developed by Al-Qabisi, popular in Arabic astrology',
      regions: ['Middle East', 'Medieval Europe', 'Historical'],
      traditions: [
        'Medieval Astrology',
        'Arabic Astrology',
        'Traditional Western',
      ],
      usage: 'Used in medieval Arabic and European astrology',
      calculationMethod: 'Prime vertical-based system with specific formula',
    ),
    HouseSystemInfo(
      system: 'topocentric',
      name: 'Topocentric Houses',
      description:
          'House system based on topocentric coordinates, developed by Wendel Polich',
      regions: ['International', 'Modern Western'],
      traditions: ['Modern Western', 'Topocentric Astrology'],
      usage: 'Used in modern topocentric astrology',
      calculationMethod: 'Topocentric coordinate-based system',
    ),
    HouseSystemInfo(
      system: 'krusinski',
      name: 'Krusinski Houses',
      description: 'House system developed by Polish astrologer Krusinski',
      regions: ['Poland', 'Central Europe'],
      traditions: ['Modern Western', 'Polish Astrology'],
      usage: 'Used in Polish astrological circles',
      calculationMethod: 'Specific mathematical formula',
    ),
    HouseSystemInfo(
      system: 'vehlow',
      name: 'Vehlow Houses',
      description: 'House system developed by German astrologer Vehlow',
      regions: ['Germany', 'Central Europe'],
      traditions: ['German Astrology', 'Modern Western'],
      usage: 'Used in German astrological circles',
      calculationMethod: 'Specific mathematical formula',
    ),
    HouseSystemInfo(
      system: 'axial',
      name: 'Axial Rotation Houses',
      description: 'House system based on axial rotation',
      regions: ['International', 'Modern Western'],
      traditions: ['Modern Western', 'Experimental'],
      usage: 'Used in experimental modern astrology',
      calculationMethod: 'Axial rotation-based system',
    ),
    HouseSystemInfo(
      system: 'horizontal',
      name: 'Horizontal Houses',
      description: 'House system based on horizontal plane',
      regions: ['International', 'Modern Western'],
      traditions: ['Modern Western', 'Experimental'],
      usage: 'Used in experimental modern astrology',
      calculationMethod: 'Horizontal plane-based system',
    ),
    HouseSystemInfo(
      system: 'polichPage',
      name: 'Polich-Page Houses',
      description: 'House system developed by Polich and Page',
      regions: ['International', 'Modern Western'],
      traditions: ['Modern Western', 'Experimental'],
      usage: 'Used in experimental modern astrology',
      calculationMethod: 'Specific mathematical formula',
    ),
    HouseSystemInfo(
      system: 'morinus',
      name: 'Morinus Houses',
      description: 'House system developed by Jean-Baptiste Morin',
      regions: ['France', 'Historical'],
      traditions: ['Historical', 'Traditional Western'],
      usage: 'Used in historical French astrology',
      calculationMethod: 'Specific mathematical formula',
    ),
    HouseSystemInfo(
      system: 'carter',
      name: 'Carter Houses',
      description: 'House system developed by Charles Carter',
      regions: ['UK', 'International'],
      traditions: ['Modern Western', 'British Astrology'],
      usage: 'Used in British astrological circles',
      calculationMethod: 'Specific mathematical formula',
    ),
    HouseSystemInfo(
      system: 'equalMidheaven',
      name: 'Equal Midheaven Houses',
      description:
          'House system where houses are equal with midheaven as reference',
      regions: ['International', 'Modern Western'],
      traditions: ['Modern Western', 'Experimental'],
      usage: 'Used in experimental modern astrology',
      calculationMethod: 'Equal houses from midheaven',
    ),
    HouseSystemInfo(
      system: 'wholeSign',
      name: 'Whole Sign Houses',
      description: 'Traditional whole sign house system',
      regions: ['India', 'Traditional Centers'],
      traditions: ['Traditional Vedic', 'Hellenistic'],
      usage: 'Used in traditional Vedic and Hellenistic astrology',
      calculationMethod: 'Each sign = one complete house',
    ),
    HouseSystemInfo(
      system: 'sripati',
      name: 'Sripati Houses',
      description: 'Traditional Indian house system named after Sripati',
      regions: ['India', 'Traditional Centers'],
      traditions: ['Traditional Vedic', 'Sripati School'],
      usage: 'Used in traditional Indian astrology',
      calculationMethod: 'Traditional Indian calculation method',
    ),
    HouseSystemInfo(
      system: 'sriLanka',
      name: 'Sri Lanka Houses',
      description: 'House system used in Sri Lankan astrology',
      regions: ['Sri Lanka', 'South Asia'],
      traditions: ['Sri Lankan Astrology', 'Regional Vedic'],
      usage: 'Used in Sri Lankan astrological traditions',
      calculationMethod: 'Sri Lankan calculation method',
    ),
  ];

  /// Get all house system types
  static List<String> getAllHouseSystemTypes() {
    return _houseSystemTypes;
  }

  /// Get all house system information
  static List<HouseSystemInfo> getAllHouseSystemInfo() {
    return _houseSystemInfo;
  }

  /// Get house system info by type
  static HouseSystemInfo? getHouseSystemInfo(String system) {
    try {
      return _houseSystemInfo
          .firstWhere((info) => info.system == system.toLowerCase());
    } on Exception {
      return null;
    }
  }

  /// Get recommended house system types
  static List<HouseSystemInfo> getRecommendedHouseSystems() {
    return _houseSystemInfo.where((info) => info.isRecommended).toList();
  }

  /// Get house systems by region
  static List<HouseSystemInfo> getHouseSystemsByRegion(String region) {
    return _houseSystemInfo
        .where(
          (info) => info.regions
              .any((r) => r.toLowerCase().contains(region.toLowerCase())),
        )
        .toList();
  }

  /// Get house systems by tradition
  static List<HouseSystemInfo> getHouseSystemsByTradition(String tradition) {
    return _houseSystemInfo
        .where(
          (info) => info.traditions
              .any((t) => t.toLowerCase().contains(tradition.toLowerCase())),
        )
        .toList();
  }

  /// Get display name for house system
  static String getDisplayName(String system) {
    final info = getHouseSystemInfo(system);
    return info?.name ?? system;
  }

  /// Get description for house system
  static String getDescription(String system) {
    final info = getHouseSystemInfo(system);
    return info?.description ?? 'No description available';
  }

  /// Get regions for house system
  static List<String> getRegions(String system) {
    final info = getHouseSystemInfo(system);
    return info?.regions ?? [];
  }

  /// Get traditions for house system
  static List<String> getTraditions(String system) {
    final info = getHouseSystemInfo(system);
    return info?.traditions ?? [];
  }

  /// Get usage information for house system
  static String getUsage(String system) {
    final info = getHouseSystemInfo(system);
    return info?.usage ?? 'No usage information available';
  }

  /// Check if house system is recommended
  static bool isRecommended(String system) {
    final info = getHouseSystemInfo(system);
    return info?.isRecommended ?? false;
  }
}
