/// Ayanamsha Information Helper
///
/// Provides detailed information about different ayanamsha types
/// and their regional/traditional usage for user selection
library;

/// Information about ayanamsha types
class AyanamshaInfo {
  final String type;
  final String name;
  final String description;
  final List<String> regions;
  final List<String> traditions;
  final String usage;
  final bool isRecommended;

  const AyanamshaInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.regions,
    required this.traditions,
    required this.usage,
    this.isRecommended = false,
  });
}

/// Helper class for ayanamsha information
class AyanamshaInfoHelper {
  static const List<String> _ayanamshaTypes = [
    'lahiri',
    'raman',
    'krishnamurti',
    'faganBradley',
    'yukteshwar',
    'jnBhasin',
    'babylonian',
    'sassanian',
    'aldebaran15Tau',
    'galacticCenter',
  ];

  static const List<AyanamshaInfo> _ayanamshaInfo = [
    AyanamshaInfo(
      type: 'lahiri',
      name: 'Lahiri Ayanamsha',
      description:
          'Most widely used ayanamsha in India, officially adopted by the Government of India',
      regions: [
        'All India',
        'North India',
        'South India',
        'East India',
        'West India'
      ],
      traditions: ['Vedic', 'Modern Indian', 'Government Official'],
      usage: 'Standard for most Indian astrologers and government calculations',
      isRecommended: true,
    ),
    AyanamshaInfo(
      type: 'raman',
      name: 'B.V. Raman Ayanamsha',
      description: 'Developed by B.V. Raman, widely used in South India',
      regions: [
        'South India',
        'Karnataka',
        'Tamil Nadu',
        'Kerala',
        'Andhra Pradesh'
      ],
      traditions: ['Vedic', 'South Indian', 'Raman Tradition'],
      usage: 'Popular among South Indian astrologers and Raman followers',
    ),
    AyanamshaInfo(
      type: 'krishnamurti',
      name: 'K.P. (Krishnamurti) Ayanamsha',
      description: 'Used in Krishnamurti Paddhati (K.P.) system of astrology',
      regions: ['India', 'Sri Lanka', 'Malaysia', 'Singapore'],
      traditions: ['K.P. System', 'Sub-lord System', 'Modern Vedic'],
      usage: 'Essential for K.P. system calculations and sub-lord analysis',
    ),
    AyanamshaInfo(
      type: 'faganBradley',
      name: 'Fagan-Bradley Ayanamsha',
      description:
          'Western sidereal ayanamsha, used in Western sidereal astrology',
      regions: ['Western Countries', 'USA', 'Europe', 'Australia'],
      traditions: ['Western Sidereal', 'Modern Western'],
      usage: 'Standard for Western sidereal astrologers',
    ),
    AyanamshaInfo(
      type: 'yukteshwar',
      name: 'Sri Yukteshwar Ayanamsha',
      description:
          'Based on Sri Yukteshwar\'s calculations, used by some traditional schools',
      regions: ['India', 'Traditional Centers'],
      traditions: ['Traditional Vedic', 'Yukteshwar School'],
      usage: 'Used by followers of Sri Yukteshwar and traditional schools',
    ),
    AyanamshaInfo(
      type: 'jnBhasin',
      name: 'J.N. Bhasin Ayanamsha',
      description:
          'Developed by J.N. Bhasin, used in some North Indian traditions',
      regions: ['North India', 'Punjab', 'Haryana', 'Delhi'],
      traditions: ['North Indian', 'Bhasin School'],
      usage: 'Popular in North Indian astrological circles',
    ),
    AyanamshaInfo(
      type: 'babylonian',
      name: 'Babylonian Ayanamsha',
      description:
          'Ancient Babylonian ayanamsha, used in historical calculations',
      regions: ['Middle East', 'Historical'],
      traditions: ['Ancient Babylonian', 'Historical'],
      usage: 'For historical and ancient astrological studies',
    ),
    AyanamshaInfo(
      type: 'sassanian',
      name: 'Sassanian Ayanamsha',
      description: 'Persian Sassanian ayanamsha, used in Persian astrology',
      regions: ['Persia', 'Iran', 'Middle East'],
      traditions: ['Persian', 'Sassanian', 'Middle Eastern'],
      usage: 'Used in Persian and Middle Eastern astrological traditions',
    ),
    AyanamshaInfo(
      type: 'aldebaran15Tau',
      name: 'Aldebaran 15° Taurus',
      description: 'Fixed star ayanamsha based on Aldebaran at 15° Taurus',
      regions: ['International', 'Fixed Star Astrology'],
      traditions: ['Fixed Star', 'Modern Western'],
      usage: 'Used in fixed star astrology and some modern systems',
    ),
    AyanamshaInfo(
      type: 'galacticCenter',
      name: 'Galactic Center Ayanamsha',
      description:
          'Based on the Galactic Center, used in modern astrological research',
      regions: ['International', 'Research'],
      traditions: ['Modern', 'Research', 'Galactic'],
      usage: 'For modern astrological research and galactic studies',
    ),
  ];

  /// Get all ayanamsha types
  static List<String> getAllAyanamshaTypes() {
    return _ayanamshaTypes;
  }

  /// Get all ayanamsha information
  static List<AyanamshaInfo> getAllAyanamshaInfo() {
    return _ayanamshaInfo;
  }

  /// Get ayanamsha info by type
  static AyanamshaInfo? getAyanamshaInfo(String type) {
    try {
      return _ayanamshaInfo
          .firstWhere((info) => info.type == type.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Get recommended ayanamsha types
  static List<AyanamshaInfo> getRecommendedAyanamsha() {
    return _ayanamshaInfo.where((info) => info.isRecommended).toList();
  }

  /// Get ayanamsha types by region
  static List<AyanamshaInfo> getAyanamshaByRegion(String region) {
    return _ayanamshaInfo
        .where((info) => info.regions
            .any((r) => r.toLowerCase().contains(region.toLowerCase())))
        .toList();
  }

  /// Get ayanamsha types by tradition
  static List<AyanamshaInfo> getAyanamshaByTradition(String tradition) {
    return _ayanamshaInfo
        .where((info) => info.traditions
            .any((t) => t.toLowerCase().contains(tradition.toLowerCase())))
        .toList();
  }

  /// Get display name for ayanamsha type
  static String getDisplayName(String type) {
    final info = getAyanamshaInfo(type);
    return info?.name ?? type;
  }

  /// Get description for ayanamsha type
  static String getDescription(String type) {
    final info = getAyanamshaInfo(type);
    return info?.description ?? 'No description available';
  }

  /// Get regions for ayanamsha type
  static List<String> getRegions(String type) {
    final info = getAyanamshaInfo(type);
    return info?.regions ?? [];
  }

  /// Get traditions for ayanamsha type
  static List<String> getTraditions(String type) {
    final info = getAyanamshaInfo(type);
    return info?.traditions ?? [];
  }

  /// Get usage information for ayanamsha type
  static String getUsage(String type) {
    final info = getAyanamshaInfo(type);
    return info?.usage ?? 'No usage information available';
  }

  /// Check if ayanamsha is recommended
  static bool isRecommended(String type) {
    final info = getAyanamshaInfo(type);
    return info?.isRecommended ?? false;
  }
}
