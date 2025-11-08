/// Region to Ayanamsha Mapper
///
/// Maps regions to their corresponding ayanamsha values
/// for calendar calculations
library;

import 'ayanamsha_info.dart';

/// Region information
class RegionInfo {
  final String name;
  final String ayanamsha;
  final String ayanamshaDisplayName;
  final bool isRecommended;

  const RegionInfo({
    required this.name,
    required this.ayanamsha,
    required this.ayanamshaDisplayName,
    this.isRecommended = false,
  });
}

/// Helper class for mapping regions to ayanamsha
class RegionAyanamshaMapper {
  /// Get all unique regions with their corresponding ayanamsha
  static List<RegionInfo> getAllRegions() {
    final Map<String, RegionInfo> regionMap = {};

    // Get all ayanamsha info
    final allAyanamshaInfo = AyanamshaInfoHelper.getAllAyanamshaInfo();

    // Build region map - prefer recommended ayanamsha for each region
    for (final ayanamshaInfo in allAyanamshaInfo) {
      for (final region in ayanamshaInfo.regions) {
        // If region doesn't exist or current ayanamsha is recommended, add/update
        if (!regionMap.containsKey(region) || ayanamshaInfo.isRecommended) {
          regionMap[region] = RegionInfo(
            name: region,
            ayanamsha: ayanamshaInfo.type,
            ayanamshaDisplayName: ayanamshaInfo.name,
            isRecommended: ayanamshaInfo.isRecommended,
          );
        }
      }
    }

    // Sort regions: recommended first, then alphabetically
    final regions = regionMap.values.toList();
    regions.sort((a, b) {
      if (a.isRecommended && !b.isRecommended) return -1;
      if (!a.isRecommended && b.isRecommended) return 1;
      return a.name.compareTo(b.name);
    });

    return regions;
  }

  /// Get ayanamsha for a specific region
  /// Returns the recommended ayanamsha for the region, or 'lahiri' as default
  static String getAyanamshaForRegion(String region) {
    final regions = getAllRegions();
    final regionInfo = regions.firstWhere(
      (info) => info.name.toLowerCase() == region.toLowerCase(),
      orElse: () => regions.firstWhere(
        (info) => info.isRecommended,
        orElse: () => RegionInfo(
          name: 'All India',
          ayanamsha: 'lahiri',
          ayanamshaDisplayName: 'Lahiri Ayanamsha',
          isRecommended: true,
        ),
      ),
    );
    return regionInfo.ayanamsha;
  }

  /// Get region info by name
  static RegionInfo? getRegionInfo(String regionName) {
    final regions = getAllRegions();
    try {
      return regions.firstWhere(
        (info) => info.name.toLowerCase() == regionName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get display name for region
  static String getDisplayName(String region) {
    final info = getRegionInfo(region);
    return info?.name ?? region;
  }

  /// Get ayanamsha display name for region
  static String getAyanamshaDisplayName(String region) {
    final info = getRegionInfo(region);
    return info?.ayanamshaDisplayName ?? 'Lahiri Ayanamsha';
  }
}
