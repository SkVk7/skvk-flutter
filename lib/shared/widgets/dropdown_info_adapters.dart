/// Dropdown Info Adapters
///
/// Adapter classes that implement DropdownItemInfo interface
/// for different types of information (house systems, ayanamsa, etc.)
library;

import '../../core/utils/house_system_info.dart';
import '../../core/utils/ayanamsha_info.dart';
import '../../astrology/core/enums/astrology_enums.dart';
import 'enhanced_dropdown_widgets.dart';

/// Adapter for HouseSystemInfo to implement DropdownItemInfo
class HouseSystemInfoAdapter implements DropdownItemInfo {
  final HouseSystemInfo _info;

  const HouseSystemInfoAdapter(this._info);

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
  final AyanamshaInfo _info;

  const AyanamshaInfoAdapter(this._info);

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
  static HouseSystemInfoAdapter getHouseSystemInfo(HouseSystem system) {
    final info = HouseSystemInfoHelper.getHouseSystemInfo(system);
    return HouseSystemInfoAdapter(info!);
  }

  /// Get ayanamsa info adapter
  static AyanamshaInfoAdapter getAyanamshaInfo(AyanamshaType type) {
    final info = AyanamshaInfoHelper.getAyanamshaInfo(type);
    return AyanamshaInfoAdapter(info!);
  }
}
