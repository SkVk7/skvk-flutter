/// House System Information Helper
///
/// Provides detailed information about different house systems
/// and their regional/traditional usage for user selection
library;

import '../../astrology/core/enums/astrology_enums.dart';

/// Information about house systems
class HouseSystemInfo {
  final HouseSystem system;
  final String name;
  final String description;
  final List<String> regions;
  final List<String> traditions;
  final String usage;
  final bool isRecommended;
  final String calculationMethod;

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
}

/// Helper class for house system information
class HouseSystemInfoHelper {
  static const List<HouseSystemInfo> _houseSystemInfo = [
    HouseSystemInfo(
      system: HouseSystem.placidus,
      name: 'Placidus Houses',
      description: 'Most widely used house system in Western astrology, based on time divisions',
      regions: ['Western Countries', 'USA', 'Europe', 'Australia', 'Modern India'],
      traditions: ['Western Astrology', 'Modern Vedic', 'Psychological Astrology'],
      usage: 'Standard for most Western astrologers and modern Vedic practitioners',
      calculationMethod: 'Time-based divisions of the ecliptic',
      isRecommended: true,
    ),
    HouseSystemInfo(
      system: HouseSystem.whole,
      name: 'Whole Sign Houses',
      description: 'Traditional Vedic approach where each sign occupies an entire house',
      regions: ['India', 'Traditional Centers', 'Ancient Astrology'],
      traditions: ['Traditional Vedic', 'Hellenistic', 'Ancient Astrology'],
      usage: 'Original house system used in classical Vedic and Hellenistic astrology',
      calculationMethod: 'Each zodiac sign = one complete house',
      isRecommended: true,
    ),
    HouseSystemInfo(
      system: HouseSystem.equal,
      name: 'Equal Houses',
      description: 'Simple system where all houses are exactly 30 degrees wide',
      regions: ['India', 'Traditional Centers', 'Simple Systems'],
      traditions: ['Traditional Vedic', 'Simple Astrology', 'Beginner Systems'],
      usage: 'Easy to calculate, used in traditional Vedic astrology and for beginners',
      calculationMethod: 'Each house = exactly 30 degrees from ascendant',
    ),
    HouseSystemInfo(
      system: HouseSystem.koch,
      name: 'Koch Houses',
      description: 'Time-based house system developed by Walter Koch, popular in Germany',
      regions: ['Germany', 'Central Europe', 'German-speaking Countries'],
      traditions: ['German Astrology', 'Modern Western', 'Time-based Systems'],
      usage: 'Popular in German-speaking countries and Central Europe',
      calculationMethod: 'Time-based divisions with specific mathematical formula',
    ),
    HouseSystemInfo(
      system: HouseSystem.porphyry,
      name: 'Porphyry Houses',
      description: 'Ancient house system named after Porphyry, divides quadrants equally',
      regions: ['Ancient Centers', 'Traditional Astrology', 'Historical'],
      traditions: ['Ancient Astrology', 'Hellenistic', 'Traditional Western'],
      usage: 'Used in ancient and traditional Western astrology',
      calculationMethod: 'Equal division of quadrants between angles',
    ),
    HouseSystemInfo(
      system: HouseSystem.regiomontanus,
      name: 'Regiomontanus Houses',
      description: 'Spherical house system developed by Regiomontanus in the 15th century',
      regions: ['Europe', 'Historical', 'Traditional Western'],
      traditions: ['Medieval Astrology', 'Traditional Western', 'Historical'],
      usage: 'Used in medieval and traditional Western astrology',
      calculationMethod: 'Spherical projection onto the ecliptic',
    ),
    HouseSystemInfo(
      system: HouseSystem.campanus,
      name: 'Campanus Houses',
      description: 'House system developed by Campanus of Novara, based on prime vertical',
      regions: ['Europe', 'Historical', 'Traditional Western'],
      traditions: ['Medieval Astrology', 'Traditional Western', 'Historical'],
      usage: 'Used in medieval European astrology',
      calculationMethod: 'Prime vertical projection system',
    ),
    HouseSystemInfo(
      system: HouseSystem.alcabitius,
      name: 'Alcabitius Houses',
      description: 'Ancient house system developed by Al-Qabisi (Alcabitius)',
      regions: ['Middle East', 'Islamic World', 'Historical'],
      traditions: ['Islamic Astrology', 'Medieval Arabic', 'Traditional'],
      usage: 'Used in traditional Islamic and Arabic astrology',
      calculationMethod: 'Equal division of semi-arcs',
    ),
    HouseSystemInfo(
      system: HouseSystem.topocentric,
      name: 'Topocentric Houses',
      description: 'Modern house system developed by Wendel Polich and Anthony Nelson Page',
      regions: ['Modern Centers', 'Research', 'Contemporary Astrology'],
      traditions: ['Modern Western', 'Research-based', 'Contemporary'],
      usage: 'Used in modern astrological research and contemporary practice',
      calculationMethod: 'Topocentric projection system',
    ),
    HouseSystemInfo(
      system: HouseSystem.krusinski,
      name: 'Krusinski Houses',
      description: 'House system developed by Polish astrologer Krusinski',
      regions: ['Poland', 'Eastern Europe', 'Specialized'],
      traditions: ['Polish Astrology', 'Eastern European', 'Specialized'],
      usage: 'Used in Polish and some Eastern European astrological traditions',
      calculationMethod: 'Specialized mathematical projection',
    ),
    HouseSystemInfo(
      system: HouseSystem.axial,
      name: 'Axial Rotation Houses',
      description: 'House system based on axial rotation principles',
      regions: ['Research', 'Experimental', 'Modern'],
      traditions: ['Modern Research', 'Experimental', 'Contemporary'],
      usage: 'Used in experimental and research-based astrology',
      calculationMethod: 'Axial rotation-based calculations',
    ),
    HouseSystemInfo(
      system: HouseSystem.horizontal,
      name: 'Horizontal Houses',
      description: 'House system based on horizontal coordinate system',
      regions: ['Research', 'Specialized', 'Modern'],
      traditions: ['Modern Research', 'Specialized', 'Contemporary'],
      usage: 'Used in specialized astrological research',
      calculationMethod: 'Horizontal coordinate system projection',
    ),
    HouseSystemInfo(
      system: HouseSystem.polich,
      name: 'Polich/Page Houses',
      description: 'Modern house system developed by Wendel Polich and Anthony Nelson Page',
      regions: ['Modern Centers', 'Research', 'Contemporary'],
      traditions: ['Modern Western', 'Research-based', 'Contemporary'],
      usage: 'Used in modern astrological research and contemporary practice',
      calculationMethod: 'Modern mathematical projection system',
    ),
    HouseSystemInfo(
      system: HouseSystem.morinus,
      name: 'Morinus Houses',
      description: 'House system developed by Jean-Baptiste Morin (Morinus)',
      regions: ['France', 'Europe', 'Historical'],
      traditions: ['French Astrology', 'Historical', 'Traditional Western'],
      usage: 'Used in traditional French astrology and historical practice',
      calculationMethod: 'Historical French calculation method',
    ),
  ];

  /// Get all house system information
  static List<HouseSystemInfo> getAllHouseSystemInfo() {
    return _houseSystemInfo;
  }

  /// Get house system info by type
  static HouseSystemInfo? getHouseSystemInfo(HouseSystem system) {
    try {
      return _houseSystemInfo.firstWhere((info) => info.system == system);
    } catch (e) {
      return null;
    }
  }

  /// Get recommended house systems
  static List<HouseSystemInfo> getRecommendedHouseSystems() {
    return _houseSystemInfo.where((info) => info.isRecommended).toList();
  }

  /// Get house systems by region
  static List<HouseSystemInfo> getHouseSystemsByRegion(String region) {
    return _houseSystemInfo
        .where((info) => info.regions.any((r) => r.toLowerCase().contains(region.toLowerCase())))
        .toList();
  }

  /// Get house systems by tradition
  static List<HouseSystemInfo> getHouseSystemsByTradition(String tradition) {
    return _houseSystemInfo
        .where(
            (info) => info.traditions.any((t) => t.toLowerCase().contains(tradition.toLowerCase())))
        .toList();
  }

  /// Get display name for house system
  static String getDisplayName(HouseSystem system) {
    final info = getHouseSystemInfo(system);
    return info?.name ?? system.name;
  }

  /// Get description for house system
  static String getDescription(HouseSystem system) {
    final info = getHouseSystemInfo(system);
    return info?.description ?? 'No description available';
  }

  /// Get regions for house system
  static List<String> getRegions(HouseSystem system) {
    final info = getHouseSystemInfo(system);
    return info?.regions ?? [];
  }

  /// Get traditions for house system
  static List<String> getTraditions(HouseSystem system) {
    final info = getHouseSystemInfo(system);
    return info?.traditions ?? [];
  }

  /// Get usage information for house system
  static String getUsage(HouseSystem system) {
    final info = getHouseSystemInfo(system);
    return info?.usage ?? 'No usage information available';
  }

  /// Get calculation method for house system
  static String getCalculationMethod(HouseSystem system) {
    final info = getHouseSystemInfo(system);
    return info?.calculationMethod ?? 'No calculation method information available';
  }

  /// Check if house system is recommended
  static bool isRecommended(HouseSystem system) {
    final info = getHouseSystemInfo(system);
    return info?.isRecommended ?? false;
  }
}
