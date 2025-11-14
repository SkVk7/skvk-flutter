/// Dropdown Info Adapters
///
/// Adapter classes that implement DropdownItemInfo interface
/// for different types of information (house systems, ayanamsa, etc.)
library;

import 'package:skvk_application/core/utils/astrology/ayanamsha_info.dart';
import 'package:skvk_application/core/utils/astrology/house_system_info.dart';
import 'package:skvk_application/ui/components/dropdowns/dropdown_widgets.dart';

/// Adapter for HouseSystemInfo to implement DropdownItemInfo
class HouseSystemInfoAdapter implements DropdownItemInfo {
  const HouseSystemInfoAdapter(this._info);
  final HouseSystemInfo _info;

  @override
  String get name => _info.name;

  @override
  String get description => _info.description;

  @override
  List<String> get regions => _info.regions;

  @override
  bool get isRecommended => _info.isRecommended;
}

/// Adapter for AyanamshaInfo to implement DropdownItemInfo
class AyanamshaInfoAdapter implements DropdownItemInfo {
  const AyanamshaInfoAdapter(this._info);
  final AyanamshaInfo _info;

  @override
  String get name => _info.name;

  @override
  String get description => _info.description;

  @override
  List<String> get regions => _info.regions;

  @override
  bool get isRecommended => _info.isRecommended;
}

/// Utility class for creating info adapters
class DropdownInfoAdapters {
  /// Get house system info adapter
  static HouseSystemInfoAdapter? getHouseSystemInfo(String system) {
    final info = HouseSystemInfoHelper.getHouseSystemInfo(system);
    if (info == null) return null;
    return HouseSystemInfoAdapter(info);
  }

  /// Get ayanamsa info adapter
  static AyanamshaInfoAdapter? getAyanamshaInfo(String type) {
    final info = AyanamshaInfoHelper.getAyanamshaInfo(type);
    if (info == null) return null;
    return AyanamshaInfoAdapter(info);
  }
}
