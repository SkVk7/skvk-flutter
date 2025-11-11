import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'dart:async';
// UI Utils - Use only these for consistency
import '../utils/theme_helpers.dart';
import '../utils/responsive_system.dart';
// Core imports
import '../../core/services/location/simple_location_service.dart';
import '../../core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import '../../core/services/user/user_service.dart';
import '../../core/models/user/user_model.dart';
import '../../core/utils/either.dart';
import '../../core/utils/astrology/ayanamsha_info.dart';
import '../../core/utils/astrology/house_system_info.dart';
import '../components/forms/reusable_form_fields.dart';

/// User Edit Screen - Enhanced Version with Proper UI/UX
class UserEditScreen extends ConsumerStatefulWidget {
  const UserEditScreen({super.key});

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pobController = TextEditingController();

  // Form data with proper defaults
  DateTime _dob = DateTime.now().subtract(const Duration(days: 25 * 365));
  TimeOfDay _tob = TimeOfDay.now();
  String _sex = 'Male';
  String _ayanamsha = 'lahiri';
  String _houseSystem = 'placidus';

  // Location search state
  List<Map<String, dynamic>> _locationSuggestions = [];
  bool _isSearchingLocation = false;
  bool _showLocationSuggestions = false;
  Timer? _searchDebounceTimer;
  String? _locationError;

  // Coordinates (stored when location is selected)
  double _latitude = 28.6139; // Default to New Delhi
  double _longitude = 77.2090;

  @override
  void initState() {
    super.initState();
    // Keep POB field empty by default, like name field
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pobController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
            fontWeight: FontWeight.bold,
            color: ThemeHelpers.getAppBarTextColor(context),
          ),
        ),
        backgroundColor: ThemeHelpers.getPrimaryColor(context),
        elevation: ResponsiveSystem.elevation(context, baseElevation: 4),
        toolbarHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: isDark,
            isEvening: false,
            useSacredFire: false,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
                ResponsiveSystem.spacing(context, baseSpacing: 16)),
            child: Column(
              children: [
                // Name Field
                ReusableFormField(
                  label: 'Full Name',
                  isRequired: true,
                  prefixIcon: LucideIcons.user,
                  child: ReusableTextInput(
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    prefixIcon: LucideIcons.user,
                  ),
                ),

                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Date of Birth Field
                ReusableFormField(
                  label: 'Date of Birth',
                  isRequired: true,
                  prefixIcon: LucideIcons.calendar,
                  helperText:
                      'Your birth date for accurate astrological calculations',
                  child: ReusableDatePicker(
                    selectedDate: _dob,
                    onDateChanged: (date) {
                      setState(() {
                        _dob = date;
                      });
                    },
                    lastDate: DateTime.now(),
                    firstDate: DateTime(1900),
                  ),
                ),

                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Time of Birth Field
                ReusableFormField(
                  label: 'Time of Birth',
                  isRequired: true,
                  prefixIcon: LucideIcons.clock,
                  helperText: 'Exact time of birth for precise calculations',
                  child: ReusableTimePicker(
                    selectedTime: _tob,
                    onTimeChanged: (time) {
                      setState(() {
                        _tob = time;
                      });
                    },
                  ),
                ),

                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Place of Birth Field with Search
                ReusableFormField(
                  label: 'Place of Birth',
                  isRequired: true,
                  prefixIcon: LucideIcons.mapPin,
                  helperText: 'Type to search for your birth location',
                  child: _buildLocationSearchField(),
                ),

                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Gender Field
                ReusableFormField(
                  label: 'Gender',
                  isRequired: true,
                  prefixIcon: LucideIcons.user,
                  child: ReusableDropdown<String>(
                    value: _sex,
                    items: const ['Male', 'Female'],
                    onChanged: (value) {
                      setState(() {
                        _sex = value ?? 'Male';
                      });
                    },
                    itemBuilder: (item) => item,
                    hintText: 'Select gender',
                  ),
                ),

                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Ayanamsha System Field
                ReusableFormField(
                  label: 'Ayanamsha System',
                  isRequired: true,
                  prefixIcon: LucideIcons.compass,
                  helperText: 'Choose the ayanamsha system for calculations',
                  child: _buildAyanamshaSelector(),
                ),

                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // House System Field
                ReusableFormField(
                  label: 'House System',
                  isRequired: true,
                  prefixIcon: LucideIcons.building,
                  helperText: 'Select the house system for chart calculations',
                  child: _buildHouseSystemSelector(),
                ),

                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 32)),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeHelpers.getPrimaryColor(context),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        vertical:
                            ResponsiveSystem.spacing(context, baseSpacing: 16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: ResponsiveSystem.circular(context,
                            baseRadius: 12),
                      ),
                      elevation:
                          ResponsiveSystem.elevation(context, baseElevation: 4),
                    ),
                    child: Text(
                      'Save Profile',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build location search field with suggestions
  Widget _buildLocationSearchField() {
    return Column(
      children: [
        TextField(
          controller: _pobController,
          onChanged: _onLocationSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search for your birth location',
            prefixIcon: Icon(
              LucideIcons.mapPin,
              color: ThemeHelpers.getPrimaryColor(context),
            ),
            suffixIcon: _isSearchingLocation
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeHelpers.getPrimaryColor(context),
                      ),
                    ),
                  )
                : Icon(
                    LucideIcons.search,
                    color: ThemeHelpers.getSecondaryTextColor(context),
                  ),
            border: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
            ),
            filled: true,
            fillColor: ThemeHelpers.getSurfaceColor(context),
          ),
        ),
        if (_showLocationSuggestions && _locationSuggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(
              top: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            decoration: BoxDecoration(
              color: ThemeHelpers.getSurfaceColor(context),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              border: Border.all(
                color: ThemeHelpers.getBorderColor(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeHelpers.getShadowColor(context),
                  blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
                  offset: Offset(
                      0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _locationSuggestions.length,
              itemBuilder: (context, index) {
                final location = _locationSuggestions[index];
                return ListTile(
                  leading: Icon(
                    LucideIcons.mapPin,
                    color: ThemeHelpers.getPrimaryColor(context),
                  ),
                  title: Text(
                    location['name'] ?? 'Unknown Location',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeHelpers.getPrimaryTextColor(context),
                    ),
                  ),
                  onTap: () => _selectLocationSuggestion(location),
                );
              },
            ),
          ),
        if (_locationError != null)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveSystem.spacing(context, baseSpacing: 8),
            ),
            child: Text(
              _locationError!,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: ThemeHelpers.getErrorColor(context),
              ),
            ),
          ),
      ],
    );
  }

  /// Build ayanamsha selector
  Widget _buildAyanamshaSelector() {
    return InkWell(
      onTap: _showAyanamshaSelector,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
          vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
        ),
        decoration: BoxDecoration(
          color: ThemeHelpers.getSurfaceColor(context),
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
          border: Border.all(
            color: ThemeHelpers.getBorderColor(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.compass,
              color: ThemeHelpers.getPrimaryColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
            ResponsiveSystem.sizedBox(context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Expanded(
              child: Text(
                _getAyanamshaDisplayName(_ayanamsha),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronDown,
              color: ThemeHelpers.getSecondaryTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  /// Build house system selector
  Widget _buildHouseSystemSelector() {
    return InkWell(
      onTap: _showHouseSystemSelector,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSystem.spacing(context, baseSpacing: 16),
          vertical: ResponsiveSystem.spacing(context, baseSpacing: 12),
        ),
        decoration: BoxDecoration(
          color: ThemeHelpers.getSurfaceColor(context),
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
          border: Border.all(
            color: ThemeHelpers.getBorderColor(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.building,
              color: ThemeHelpers.getPrimaryColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
            ResponsiveSystem.sizedBox(context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Expanded(
              child: Text(
                _getHouseSystemDisplayName(_houseSystem),
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronDown,
              color: ThemeHelpers.getSecondaryTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle location search text changes with debouncing
  void _onLocationSearchChanged(String query) {
    _searchDebounceTimer?.cancel();

    if (query.length >= 3) {
      _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        _searchLocations(query);
      });
    } else {
      setState(() {
        _locationSuggestions = [];
        _showLocationSuggestions = false;
        _isSearchingLocation = false;
        _locationError = null;
      });
    }
  }

  /// Search for locations
  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearchingLocation = true;
      _locationError = null;
    });

    try {
      final locationService = SimpleLocationService();
      final results = await locationService.searchPlaces(query);

      if (mounted) {
        final suggestions = results
            .map((result) => {
                  'name': result.placeName ?? 'Unknown Location',
                  'latitude': result.latitude,
                  'longitude': result.longitude,
                })
            .toList();

        setState(() {
          _locationSuggestions = suggestions;
          _showLocationSuggestions = suggestions.isNotEmpty;
          _isSearchingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = 'Failed to search locations: $e';
          _isSearchingLocation = false;
          _showLocationSuggestions = false;
        });
      }
    }
  }

  /// Select location suggestion
  void _selectLocationSuggestion(Map<String, dynamic> location) {
    setState(() {
      _pobController.text = location['name'] ?? '';
      _latitude = location['latitude'] ?? 0.0;
      _longitude = location['longitude'] ?? 0.0;
      _showLocationSuggestions = false;
      _locationError = null;
    });
  }

  /// Show ayanamsha selector dialog
  void _showAyanamshaSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Ayanamsha System',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
            fontWeight: FontWeight.bold,
            color: ThemeHelpers.getPrimaryTextColor(context),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AyanamshaInfoHelper.getAllAyanamshaTypes().length,
            itemBuilder: (context, index) {
              final ayanamsha =
                  AyanamshaInfoHelper.getAllAyanamshaTypes()[index];
              final isSelected = _ayanamsha == ayanamsha;
              final info = AyanamshaInfoHelper.getAyanamshaInfo(ayanamsha);

              return ListTile(
                leading: Icon(
                  isSelected ? LucideIcons.check : LucideIcons.circle,
                  color: isSelected
                      ? ThemeHelpers.getPrimaryColor(context)
                      : ThemeHelpers.getSecondaryTextColor(context),
                ),
                title: Text(
                  info?.name ?? ayanamsha,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info?.description ?? 'No description available',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 12),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                    if (info?.regions.isNotEmpty == true)
                      Text(
                        'Regions: ${info!.regions.join(', ')}',
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 11),
                          color: ThemeHelpers.getTertiaryTextColor(context),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _ayanamsha = ayanamsha;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show house system selector dialog
  void _showHouseSystemSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select House System',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
            fontWeight: FontWeight.bold,
            color: ThemeHelpers.getPrimaryTextColor(context),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: HouseSystemInfoHelper.getAllHouseSystemTypes().length,
            itemBuilder: (context, index) {
              final houseSystem =
                  HouseSystemInfoHelper.getAllHouseSystemTypes()[index];
              final isSelected = _houseSystem == houseSystem;
              final info =
                  HouseSystemInfoHelper.getHouseSystemInfo(houseSystem);

              return ListTile(
                leading: Icon(
                  isSelected ? LucideIcons.check : LucideIcons.circle,
                  color: isSelected
                      ? ThemeHelpers.getPrimaryColor(context)
                      : ThemeHelpers.getSecondaryTextColor(context),
                ),
                title: Text(
                  info?.name ?? houseSystem.toString(),
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: ThemeHelpers.getPrimaryTextColor(context),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info?.description ?? 'No description available',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 12),
                        color: ThemeHelpers.getSecondaryTextColor(context),
                      ),
                    ),
                    if (info?.usage.isNotEmpty == true)
                      Text(
                        'Usage: ${info!.usage}',
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 11),
                          color: ThemeHelpers.getTertiaryTextColor(context),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _houseSystem = houseSystem;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemeHelpers.getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get ayanamsha display name
  String _getAyanamshaDisplayName(String ayanamsha) {
    final info = AyanamshaInfoHelper.getAyanamshaInfo(ayanamsha);
    return info?.name ?? ayanamsha;
  }

  /// Get house system display name
  String _getHouseSystemDisplayName(String houseSystem) {
    final info = HouseSystemInfoHelper.getHouseSystemInfo(houseSystem);
    return info?.name ?? houseSystem;
  }

  /// Save profile
  Future<void> _saveProfile() async {
    // Validate form
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: ThemeHelpers.getErrorColor(context),
        ),
      );
      return;
    }

    if (_pobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your place of birth'),
          backgroundColor: ThemeHelpers.getErrorColor(context),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(
              ResponsiveSystem.spacing(context, baseSpacing: 20)),
          decoration: BoxDecoration(
            color: ThemeHelpers.getSurfaceColor(context),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeHelpers.getPrimaryColor(context),
                ),
              ),
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
              Text(
                'Saving profile...',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Create UserModel from form data
      final user = UserModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // Generate unique ID
        name: _nameController.text.trim(),
        dateOfBirth: _dob,
        timeOfBirth: TimeOfBirth.fromTimeOfDay(_tob),
        placeOfBirth: _pobController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        sex: _sex,
        ayanamsha: _ayanamsha,
        houseSystem: _houseSystem,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user data using UserService
      final userService = ref.read(userServiceProvider.notifier);
      final result = await userService.saveUser(user);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (result.isSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: ThemeHelpers.getPrimaryColor(context),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: ThemeHelpers.getErrorColor(context),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: ThemeHelpers.getErrorColor(context),
        ),
      );
    }
  }
}
